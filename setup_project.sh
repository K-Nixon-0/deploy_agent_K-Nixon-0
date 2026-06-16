#!/bin/bash

read -p "Enter the version string (e.g., v1): " user_input

if [ -z "$user_input" ]; then
    echo "Error: Version string cannot be empty."
    exit 1
fi


PARENT_DIR="attendance_tracker_${user_input}"

echo "Bootstrapping project workspace inside: ${PARENT_DIR}..."


mkdir -p "${PARENT_DIR}/Helpers"
mkdir -p "${PARENT_DIR}/reports"


touch "${PARENT_DIR}/attendance_checker.py"
touch "${PARENT_DIR}/Helpers/assets.csv"
touch "${PARENT_DIR}/Helpers/config.json"
touch "${PARENT_DIR}/reports/reports.log"


echo "Project structure generated successfully!"
echo "----------------------------------------"
echo "${PARENT_DIR}/"
echo "├── attendance_checker.py"
echo "├── Helpers/"
echo "│   ├── assets.csv"
echo "│   └── config.json"
echo "└── reports/"
echo "    └── reports.log"
echo "----------------------------------------"
