# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of standalone IT administration scripts used by Umbrella Systems to manage school client environments (primarily GIS and SJA). Scripts are organized by target platform/tool and are meant to be run individually — there is no build system, test suite, or package manager.

## Repository Structure

- **Mac/** — macOS management scripts (bash). Run on target Macs or via MDM. Covers user account creation, asset tagging, data migration, Homebrew deployment.
- **Windows/** — Windows management scripts (PowerShell `.ps1` and batch `.bat`). Run on target PCs or via RMM (Syncro). Covers user/account management, printer management, asset tagging, data migration.
- **GAM/** — Google Admin SDK (GAM) scripts for Google Workspace administration. Used to manage users, OUs, Chromebooks across school tenants. `switch-customer-instance.sh` toggles between GIS and SJA GAM contexts.
- **DumpFromSyncro/** — Legacy scripts exported from Syncro RMM. Kept as reference; active versions live in `Mac/` and `Windows/`.
- **Admin Utility/** — Python utilities (e.g., Freshdesk ticket exporter).
- **Archive/** — Old/unused scripts. Do not modify.
- **backup-docker-s3.sh / restore-docker-s3.sh** — Docker backup/restore to S3 via s3cmd. Require `FOLDER_NAME` and `BUCKET_NAME` to be set before use.

## Conventions

- Mac/Linux scripts use `#!/bin/bash` shebang; Windows PowerShell scripts use `#!ps` (Syncro convention).
- Many scripts have hardcoded placeholder values (empty strings, `CHANGEME`) that must be filled in before execution.
- GAM scripts assume GAMADV-XTD3 is installed and configured with multiple customer instances (gis, sja). Use `gam select <instance> save` to switch.
- The Freshdesk exporter (`Admin Utility/freshdesk_export.py`) requires the `requests` library: `pip3 install requests`.

## Multi-Tenant Context

Scripts target two school clients with distinct environments:
- **GIS** (Twin Cities German Immersion School) — 100% macOS. Scripts deployed via MDM.
- **SJA** (Sejong Academy) — 100% Windows. Laptops are **not domain-joined** (no Active Directory). Scripts deployed one-at-a-time via **ConnectWise ScreenConnect** as PowerShell.

GAM commands and some RMM scripts need the correct tenant context before running.
