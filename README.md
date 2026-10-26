# CareChart

A patient care system that helps doctors and nurses see which patients need attention first.
CSC335 Database Systems final project by **Tyler Jackson** and **Tony Branham-Wiggins**.

Built with Python (Flask) and MySQL/MariaDB, starting from the professor's
Flask + MySQL sample.

## Project layout

```
carechart/
├── app.py              # All routes (screens) and the database helpers
├── schema.sql          # CREATE TABLE statements for our 9 tables
├── seed.sql            # Fake data to fill the tables
├── requirements.txt    # Python packages
├── static/style.css    # Page styling
└── templates/          # One HTML page per screen
    ├── base.html       #   shared header, nav bar, and messages
    ├── login.html
    ├── doctor.html     #   Doctor: my patients, sorted by severity
    ├── nurse.html      #   Nurse: my assigned patients
    ├── patient.html    #   Shared: patient chart (vitals, prescriptions)
    ├── prescribe.html  #   Doctor: write a prescription
    ├── reports.html    #   Doctor: summary reports
    └── error.html
```

## Setup (runbook)

### 1. Create a database user

Open a terminal and log in to MySQL as the admin (root) user:

```bash
mysql -u root -p
```

Type your MySQL root password. When the prompt changes to `mysql>` (or
`MariaDB [(none)]>`), you are typing SQL instead of terminal commands. Run:

```sql
CREATE USER 'carechart_user'@'localhost' IDENTIFIED BY 'change_me';
```

Type `exit` to get back to the normal terminal.

### 2. Build and fill the database

```bash
mysql -u root -p < schema.sql
mysql -u root -p < seed.sql
```

Then log back in with `mysql -u root -p` and give the app's user access to
only the CareChart database:

```sql
GRANT SELECT, INSERT, UPDATE ON carechart.* TO 'carechart_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Install the Python packages

```bash
python3 -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 4. Connection settings

The app reads these environment variables, with defaults for local use:

| Variable      | Default            |
|---------------|--------------------|
| `DB_HOST`     | `127.0.0.1`        |
| `DB_PORT`     | `3306`             |
| `DB_USER`     | `carechart_user`   |
| `DB_PASSWORD` | `change_me`        |
| `DB_NAME`     | `carechart`        |
| `SECRET_KEY`  | `dev-only-change-me` (signs the login cookie) |
| `FLASK_DEBUG` | off (set to `1` while developing) |

### 5. Run it

```bash
python app.py
```

Open http://127.0.0.1:5000 and log in.

### Test logins

| Persona | Username | Password |
|---------|----------|----------|
| Doctor  | drsmith  | password123 |
| Doctor  | drpatel  | password123 |
| Doctor  | drlopez  | password123 |
| Nurse   | nlee     | password123 |
| Nurse   | nbrown   | password123 |
| Nurse   | nkim     | password123 |

## SQL checklist

Every query in `app.py` is marked `TODO (SQL)` with a note saying what it
needs to return. Until a query is written, its page still loads (with an
empty table), so screens can be built and tested one at a time.

**Always use `%s` placeholders and pass values in the params tuple. Never
paste user input into the SQL string.**

| Done | Where | Query | Owner |
|------|-------|-------|-------|
| [ ] | `schema.sql` | 9 CREATE TABLE statements | |
| [x] | `seed.sql` | Fake data for all 9 tables | |
| [ ] | `login()` | Find staff by username | |
| [ ] | `doctor_dashboard()` | Doctor's admitted patients by severity | |
| [ ] | `nurse_dashboard()` | Nurse's assigned patients + last vitals time | |
| [ ] | `patient_chart()` | Admission details | |
| [ ] | `patient_chart()` | Vitals history | |
| [ ] | `patient_chart()` | Prescriptions | |
| [ ] | `record_vitals()` | Insert vitals | |
| [ ] | `prescribe()` | Medication list for the dropdown | |
| [ ] | `prescribe()` | Insert prescription | |
| [ ] | `discharge()` | Set discharge date | |
| [ ] | `reports()` | Patients per department and severity | |
| [ ] | `reports()` | Average length of stay per department | |
| [ ] | `reports()` | Patients with no vitals in 4 hours | |

## Third-party libraries

| Library | Why we use it | License |
|---------|---------------|---------|
| Flask | Web framework: routes, templates, login sessions | BSD-3-Clause |
| Werkzeug (comes with Flask) | Password hashing and checking | BSD-3-Clause |
| mysql-connector-python | Connects Python to MySQL | GPL-2.0 |
