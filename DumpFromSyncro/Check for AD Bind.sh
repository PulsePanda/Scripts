#!/bin/bash

if dsconfigad -show | awk '/Active Directory Domain/{print $NF}' | grep -q '.'; then
    syncro create-syncro-ticket --subject="Macbook on AD" --issue-type="Other" --status="New"
fi
