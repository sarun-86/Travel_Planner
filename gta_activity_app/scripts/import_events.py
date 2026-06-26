"""
One-time import: reads data/GTA_Activity_App_Events.xlsx and loads each row
into the Firestore `events` collection, per the schema in travel_planner.md.

Usage:
    python scripts/import_events.py
"""

import os
import sys
from datetime import datetime

import firebase_admin
import openpyxl
from firebase_admin import credentials, firestore

PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..")
EXCEL_PATH = os.path.join(PROJECT_ROOT, "data", "GTA_Activity_App_Events.xlsx")
CREDENTIALS_PATH = os.path.join(PROJECT_ROOT, "serviceAccountKey.json")
SHEET_NAME = "Events"

EXPECTED_HEADERS = [
    "event_id", "name", "description", "region", "start_date", "end_date",
    "is_recurring", "recurrence_note", "audience", "cost_tier", "cost_note",
    "source_url", "image_url", "active",
]


def parse_date(value):
    if isinstance(value, datetime):
        return value
    return datetime.strptime(str(value).strip(), "%Y-%m-%d")


def row_to_event(row_dict):
    return {
        "name": row_dict["name"],
        "description": row_dict["description"],
        "region": row_dict["region"],
        "start_date": parse_date(row_dict["start_date"]),
        "end_date": parse_date(row_dict["end_date"]),
        "is_recurring": bool(row_dict["is_recurring"]),
        "recurrence_note": row_dict["recurrence_note"] or "",
        "audience": [a.strip() for a in str(row_dict["audience"]).split(",") if a.strip()],
        "cost_tier": row_dict["cost_tier"],
        "cost_note": row_dict["cost_note"] or "",
        "source_url": row_dict["source_url"] or "",
        "image_url": row_dict["image_url"] or "",
        "active": bool(row_dict["active"]),
        "created_at": firestore.SERVER_TIMESTAMP,
    }


def main():
    if not os.path.isfile(CREDENTIALS_PATH):
        sys.exit(f"Service account key not found at {CREDENTIALS_PATH}")

    cred = credentials.Certificate(CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    wb = openpyxl.load_workbook(EXCEL_PATH, data_only=True)
    ws = wb[SHEET_NAME]
    rows = list(ws.iter_rows(values_only=True))

    headers = list(rows[0])
    if headers != EXPECTED_HEADERS:
        sys.exit(f"Sheet headers don't match expected schema.\nFound:    {headers}\nExpected: {EXPECTED_HEADERS}")

    imported = 0
    for row in rows[1:]:
        if row[0] is None:  # skip blank rows
            continue
        row_dict = dict(zip(headers, row))
        event = row_to_event(row_dict)
        db.collection("events").document(row_dict["event_id"]).set(event)
        print(f"Imported {row_dict['event_id']}: {event['name']}")
        imported += 1

    print(f"\nDone. Imported {imported} events into Firestore.")


if __name__ == "__main__":
    main()
