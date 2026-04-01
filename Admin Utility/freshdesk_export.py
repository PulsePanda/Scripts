#!/usr/bin/env python3
"""
Freshdesk Ticket Exporter
Exports all tickets with full conversation history to CSV for AI training.

Usage:
    python3 freshdesk_export.py
    python3 freshdesk_export.py --output ~/Desktop/tickets.csv
    python3 freshdesk_export.py --no-conversations
    python3 freshdesk_export.py --updated-since 2024-01-01
"""

import argparse
import csv
import os
import re
import sys
import time
from datetime import datetime

import requests
from requests.auth import HTTPBasicAuth

# ── Defaults ──────────────────────────────────────────────────────────────────
DEFAULT_DOMAIN  = "umbrellasystems"
DEFAULT_API_KEY = os.environ.get("FRESHDESK_API_KEY", "")
DEFAULT_OUTPUT  = os.path.expanduser(
    f"~/Downloads/freshdesk_tickets_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
)

# ── Lookup maps ───────────────────────────────────────────────────────────────
STATUS_MAP = {
    2: "Open",
    3: "Pending",
    4: "Resolved",
    5: "Closed",
    6: "Waiting on Customer",
    7: "Waiting on Third Party",
}

PRIORITY_MAP = {
    1: "Low",
    2: "Medium",
    3: "High",
    4: "Urgent",
}


# ── HTTP helper ───────────────────────────────────────────────────────────────
def get(url, api_key, params=None, retries=3):
    """GET with rate-limit back-off and retries."""
    auth = HTTPBasicAuth(api_key, "X")
    for attempt in range(retries):
        resp = requests.get(url, auth=auth, params=params, timeout=30)
        if resp.status_code == 200:
            return resp.json()
        if resp.status_code == 429:
            wait = int(resp.headers.get("Retry-After", 60))
            print(f"\n  Rate limited — waiting {wait}s...", flush=True)
            time.sleep(wait)
        elif resp.status_code == 404:
            return None
        else:
            print(f"\n  Warning: HTTP {resp.status_code} for {url}", flush=True)
            if attempt < retries - 1:
                time.sleep(2)
    return None


# ── Data fetchers ─────────────────────────────────────────────────────────────
def fetch_all_tickets(domain, api_key, updated_since=None):
    """Paginate all tickets with requester + stats embedded."""
    tickets = []
    page = 1
    base = f"https://{domain}.freshdesk.com/api/v2/tickets"

    while True:
        params = {
            "page": page,
            "per_page": 100,
            "order_type": "asc",
            "include": "requester,stats",
            "updated_since": updated_since or "2010-01-01T00:00:00Z",
        }

        print(f"  Page {page}...", end=" ", flush=True)
        data = get(base, api_key, params=params)

        if not data:
            print("done.")
            break

        tickets.extend(data)
        print(f"{len(data)} tickets  (running total: {len(tickets)})", flush=True)

        if len(data) < 100:
            break
        page += 1
        time.sleep(0.4)

    return tickets


def fetch_conversations(domain, api_key, ticket_id):
    """Return all replies/notes for a ticket."""
    url = f"https://{domain}.freshdesk.com/api/v2/tickets/{ticket_id}/conversations"
    return get(url, api_key) or []


# ── Text helpers ──────────────────────────────────────────────────────────────
def strip_html(text):
    if not text:
        return ""
    text = re.sub(r"<br\s*/?>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"</p>",       "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"<[^>]+>",    "",   text)
    return (
        text.replace("&nbsp;", " ")
            .replace("&lt;",   "<")
            .replace("&gt;",   ">")
            .replace("&amp;",  "&")
            .replace("&quot;", '"')
            .strip()
    )


def format_thread(conversations):
    """Flatten a conversation list into a single labelled string."""
    parts = []
    for c in sorted(conversations, key=lambda x: x.get("created_at", "")):
        role = "Customer" if c.get("incoming") else "Agent"
        date = c.get("created_at", "")[:10]
        body = strip_html(c.get("body", ""))
        parts.append(f"[{date} {role}]: {body}")
    return "\n---\n".join(parts)


# ── CSV writer ────────────────────────────────────────────────────────────────
FIELDS = [
    "id", "subject", "status", "priority", "type", "tags",
    "created_at", "updated_at", "resolved_at",
    "requester_email", "requester_name",
    "description", "conversations", "url",
]


def export_csv(tickets, domain, api_key, output_path, include_conversations):
    total = len(tickets)
    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()

        for i, ticket in enumerate(tickets, 1):
            tid = ticket["id"]
            print(f"  Exporting {i}/{total}  (#{tid}) ...", end="\r", flush=True)

            conversations = ""
            if include_conversations:
                convs = fetch_conversations(domain, api_key, tid)
                conversations = format_thread(convs)
                time.sleep(0.2)

            req = ticket.get("requester") or {}
            stats = ticket.get("stats") or {}
            resolved_raw = stats.get("resolved_at") or ""

            writer.writerow({
                "id":              tid,
                "subject":         ticket.get("subject", ""),
                "status":          STATUS_MAP.get(ticket.get("status"), str(ticket.get("status", ""))),
                "priority":        PRIORITY_MAP.get(ticket.get("priority"), str(ticket.get("priority", ""))),
                "type":            ticket.get("type", ""),
                "tags":            ", ".join(ticket.get("tags", [])),
                "created_at":      ticket.get("created_at", "")[:10],
                "updated_at":      ticket.get("updated_at", "")[:10],
                "resolved_at":     resolved_raw[:10],
                "requester_email": req.get("email", ""),
                "requester_name":  req.get("name", ""),
                "description":     strip_html(ticket.get("description", "")),
                "conversations":   conversations,
                "url":             f"https://{domain}.freshdesk.com/helpdesk/tickets/{tid}",
            })

    print(f"\n  Wrote {total} tickets → {output_path}")


# ── Entry point ───────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Export all Freshdesk tickets to CSV")
    parser.add_argument("--domain",        default=DEFAULT_DOMAIN,  help="Freshdesk subdomain")
    parser.add_argument("--api-key",       default=DEFAULT_API_KEY, help="Freshdesk API key")
    parser.add_argument("--output",        default=DEFAULT_OUTPUT,  help="Output CSV path")
    parser.add_argument("--no-conversations", action="store_true",  help="Skip conversation threads (faster)")
    parser.add_argument("--updated-since", help="Only tickets updated since YYYY-MM-DD")
    args = parser.parse_args()

    include_conversations = not args.no_conversations

    print("Freshdesk Ticket Exporter")
    print(f"  Domain  : {args.domain}.freshdesk.com")
    print(f"  Output  : {args.output}")
    print(f"  Threads : {'yes' if include_conversations else 'no'}")
    if args.updated_since:
        print(f"  Since   : {args.updated_since}")
    print()

    print("Fetching tickets...")
    tickets = fetch_all_tickets(args.domain, args.api_key, updated_since=args.updated_since)
    print(f"\n{len(tickets)} tickets fetched.\n")

    if not tickets:
        print("No tickets found. Check domain and API key.")
        sys.exit(1)

    print("Writing CSV...")
    export_csv(tickets, args.domain, args.api_key, args.output, include_conversations)

    print(f"\nDone — {args.output}")


if __name__ == "__main__":
    main()
