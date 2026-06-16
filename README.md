# Project

Automated workspace builder for the Attendance Tracker application.

# Video

The video will serve as a guide to help explain and understand how to execute and run the test.
Video was uploaded to YouTube as GitHub only allows videos under 10 MB

https://youtu.be/rjt7eDtgk3k

## Requirements
* Python 3

## Setup & Run
Run these commands in your terminal one by one:

```bash
chmod +x setup_project.sh
./setup_project.sh
```

##Expected Input
When prompted, type your version name:
```text
v1
```

## Expected Output
The script automatically builds this folder structure:
```text
attendance_tracker_v1/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

## Run the Test
Test the generated system by running:
```bash
cd attendance_tracker_v1
python3 attendance_checker.py
```
