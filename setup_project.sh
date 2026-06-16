#!/bin/bash

# ==============================================================================
# SECTION 3: PROCESS MANAGEMENT
# ==============================================================================
cleanup_on_interrupt() {
    echo -e "\n\n[x] Script stopped by user!"
    if [ -d "$PARENT_DIR" ]; then
        echo "[x] Creating a backup folder..."
        tar -czf "incomplete_${PARENT_DIR}_backup.tar.gz" "$PARENT_DIR" 2>/dev/null
        echo "[x] Cleaning up empty files..."
        rm -rf "$PARENT_DIR"
    fi
    echo "[x] Exited successfully."
    exit 130
}
trap cleanup_on_interrupt SIGINT

# ==============================================================================
# SECTION 4: ENVIRONMENT VALIDATION
# ==============================================================================
echo "[✓] Checking system requirements..."
if ! command -v python3 &> /dev/null; then
    echo "[x] Error: Python 3 is not found on this computer."
    exit 1
else
    echo "[✓] Success: Python 3 is ready."
fi

# ==============================================================================
# SECTION 1: DIRECTORY ARCHITECTURE AND USER INPUT
# ==============================================================================
read -p "Type a version name (example: v1): " user_input

if [ -z "$user_input" ]; then
    echo "[x] Error: You must type a version name."
    exit 1
fi

PARENT_DIR="attendance_tracker_${user_input}"
echo "[✓] Creating folders inside: ${PARENT_DIR}..."

mkdir -p "${PARENT_DIR}/Helpers"
mkdir -p "${PARENT_DIR}/reports"

# ==============================================================================
# SECTION 2: DYNAMIC CONFIGURATION
# ==============================================================================
warn_val=75
fail_val=50
run_mode="live"
total_sessions=15

echo "[✓] Settings configuration:"
read -p "Do you want to change the default settings? (yes/no): " user_choice

if [[ "$user_choice" =~ ^[Yy][Ee][Ss]$ ]]; then
    read -p "Enter Warning limit % (default 75): " custom_warn
    read -p "Enter Failure limit % (default 50): " custom_fail
    read -p "Enter Run Mode (live / dry_run) [default live]: " custom_mode
    read -p "Enter Total Class Sessions (default 15): " custom_sessions
    
    warn_val=${custom_warn:-75}
    fail_val=${custom_fail:-50}
    run_mode=${custom_mode:-"live"}
    total_sessions=${custom_sessions:-15}
fi

cat << EOF > "${PARENT_DIR}/Helpers/config.json"
{
  "thresholds": {
    "warning": 75,
    "failure": 50
  },
  "run_mode": "live",
  "total_sessions": 15
}
EOF

if [ "$warn_val" -ne 75 ]; then
    sed -i "s/\"warning\": 75/\"warning\": ${warn_val}/" "${PARENT_DIR}/Helpers/config.json"
fi

if [ "$fail_val" -ne 50 ]; then
    sed -i "s/\"failure\": 50/\"failure\": ${fail_val}/" "${PARENT_DIR}/Helpers/config.json"
fi

if [ "$run_mode" != "live" ]; then
    sed -i "s/\"run_mode\": \"live\"/\"run_mode\": \"${run_mode}\"/" "${PARENT_DIR}/Helpers/config.json"
fi

if [ "$total_sessions" -ne 15 ]; then
    sed -i "s/\"total_sessions\": 15/\"total_sessions\": ${total_sessions}/" "${PARENT_DIR}/Helpers/config.json"
fi

echo "[✓] Configuration file saved."

# ______________________________________________________________________________
cat << 'EOF' > "${PARENT_DIR}/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
        
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
        
    with open('Helpers/assets.csv', 'r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct <= config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct <= config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
                
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat << 'EOF' > "${PARENT_DIR}/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat << 'EOF' > "${PARENT_DIR}/reports/reports.log"
--- Attendance Report Run: 2026-02-08 18:10:01.460726 ---
[2026-02-08 18:10:01.460383] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-08 18:10:01.460424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF
# ______________________________________________________________________________

# ==============================================================================
# SECTION 5: FINAL OUTPUT VERIFICATION
# ==============================================================================
echo -e "\n[✓] All files and folders have been created successfully!\n"
echo "Your Project Folder Layout:"
echo "----------------------------------------"
if command -v tree &> /dev/null; then
    tree "$PARENT_DIR"
else
    echo "${PARENT_DIR}/"
    echo "├── attendance_checker.py"
    echo "├── Helpers/"
    echo "│   ├── assets.csv"
    echo "│   └── config.json"
    echo "└── reports/"
    echo "    └── reports.log"
fi
echo "----------------------------------------"
