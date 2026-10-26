"""
CareChart - patient care system for doctors and nurses.
CSC335 Database Systems final project
Tyler Jackson and Tony Branham-Wiggins

Built from the professor's Flask + MySQL sample (python-sql-injection-sample).
Kept from the sample: the Flask setup, DB_CONFIG read from environment
variables, get_connection(), dictionary cursors, and try/finally cleanup.
Removed: the product search, the deliberately vulnerable query, and the
raw-SQL debug panel.

HOW THE SQL WORKS IN THIS FILE
------------------------------
Each route has a `sql = None` line with a comment saying what the query must
do and which column names the HTML page expects back.

Until a query is written, the helpers below treat `None` as "not written yet":
pages still load (with empty tables) and actions show a yellow notice, so we
can build and test one screen at a time.

SAFETY RULE: never glue user input into the SQL string. Put %s placeholders in
the SQL and pass the values in the params tuple, like the "safe equivalent"
shown in the professor's sample.
"""

import os
from datetime import datetime
from functools import wraps

import mysql.connector
from flask import Flask, abort, flash, redirect, render_template, request, session, url_for

app = Flask(__name__)
# Used to sign the login session cookie. Set SECRET_KEY in your environment.
app.secret_key = os.environ.get("SECRET_KEY", "dev-only-change-me")

DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "127.0.0.1"),
    "port": int(os.environ.get("DB_PORT", "3306")),
    "user": os.environ.get("DB_USER", "carechart_user"),
    "password": os.environ.get("DB_PASSWORD", "change_me"),
    "database": os.environ.get("DB_NAME", "carechart"),
}


# ---------------------------------------------------------------------------
# Database helpers
# ---------------------------------------------------------------------------

def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


def query_all(sql, params=()):
    """Run a SELECT and return a list of rows. Each row is a dict:
    {column_name: value}. Returns [] if the SQL hasn't been written yet."""
    if not sql:
        return []
    conn = get_connection()
    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(sql, params)
        return cursor.fetchall()
    finally:
        if cursor:
            cursor.close()
        conn.close()


def query_one(sql, params=()):
    """Run a SELECT that should return one row. Returns the row (a dict),
    or None if nothing matched or the SQL hasn't been written yet."""
    rows = query_all(sql, params)
    return rows[0] if rows else None


def execute(sql, params=()):
    """Run an INSERT, UPDATE, or DELETE and save it (commit).
    Returns the number of rows changed, or None if the SQL isn't written yet."""
    if not sql:
        flash("This action's SQL hasn't been written yet (see the TODO in app.py).", "warning")
        return None
    conn = get_connection()
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        conn.commit()
        return cursor.rowcount
    except mysql.connector.Error:
        conn.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        conn.close()


@app.errorhandler(mysql.connector.Error)
def database_error(err):
    """Show database errors on a friendly page instead of crashing.
    CHECK constraint and foreign key failures will show up here too."""
    return render_template("error.html", message=str(err)), 500


# ---------------------------------------------------------------------------
# Form helpers
# ---------------------------------------------------------------------------

def form_int(name):
    """Read a whole number from the submitted form, or None if left blank."""
    value = request.form.get(name, "").strip()
    return int(value) if value else None


def form_float(name):
    """Read a decimal number from the submitted form, or None if left blank."""
    value = request.form.get(name, "").strip()
    return float(value) if value else None


# ---------------------------------------------------------------------------
# Login
# ---------------------------------------------------------------------------

def login_required(role=None):
    """Put @login_required() on a route to require login, or
    @login_required("Doctor") / @login_required("Nurse") to limit it to one persona."""
    def decorator(view):
        @wraps(view)
        def wrapped(*args, **kwargs):
            if "staff_id" not in session:
                return redirect(url_for("login"))
            if role and session.get("role") != role:
                abort(403)
            return view(*args, **kwargs)
        return wrapped
    return decorator


def home_for_role():
    return url_for("doctor_dashboard") if session.get("role") == "Doctor" else url_for("nurse_dashboard")


@app.route("/")
def index():
    if "staff_id" not in session:
        return redirect(url_for("login"))
    return redirect(home_for_role())


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")

        # TODO (SQL): Find the Staff member with this username.
        #   Param: username
        #   Columns needed: staff_id, first_name, last_name, role, password
        sql = None

        if not sql:
            flash("The login query hasn't been written yet (see the TODO in login() in app.py).", "warning")
            return render_template("login.html")

        staff = query_one(sql, (username,))
        if staff and staff["password"] == password:
            session.clear()
            session["staff_id"] = staff["staff_id"]
            session["role"] = staff["role"]
            prefix = "Dr. " if staff["role"] == "Doctor" else "Nurse "
            session["display_name"] = prefix + staff["last_name"]
            return redirect(home_for_role())
        flash("Wrong username or password.", "error")

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


# ---------------------------------------------------------------------------
# Doctor screens
# ---------------------------------------------------------------------------

@app.route("/doctor")
@login_required("Doctor")
def doctor_dashboard():
    # TODO (SQL): Patients currently admitted (not yet discharged) whose
    #   attending doctor is the logged-in doctor, most urgent severity first.
    #   Param: the doctor's staff_id
    #   Columns the page expects: admission_id, first_name, last_name,
    #   room_number, level_name, admit_date
    sql = None
    patients = query_all(sql, (session["staff_id"],))
    return render_template("doctor.html", patients=patients)


@app.route("/admission/<int:admission_id>/prescribe", methods=["GET", "POST"])
@login_required("Doctor")
def prescribe(admission_id):
    if request.method == "POST":
        # TODO (SQL): Add a new Prescription for this admission.
        #   Params, in this order: admission_id, the doctor's staff_id,
        #   medication_id, dose, frequency
        #   (start_date can default to the current date/time in your SQL)
        sql = None
        params = (
            admission_id,
            session["staff_id"],
            form_int("medication_id"),
            form_float("dose"),
            request.form.get("frequency", "").strip(),
        )
        if execute(sql, params) is not None:
            flash("Prescription saved.", "success")
            return redirect(url_for("patient_chart", admission_id=admission_id))

    # TODO (SQL): All medications, for the dropdown, sorted by name.
    #   Columns the page expects: medication_id, name, dosage_unit
    meds_sql = None
    medications = query_all(meds_sql)
    return render_template("prescribe.html", admission_id=admission_id, medications=medications)


@app.route("/admission/<int:admission_id>/discharge", methods=["POST"])
@login_required("Doctor")
def discharge(admission_id):
    # TODO (SQL): Discharge the patient by setting discharge_date to now.
    #   Only if this admission belongs to the logged-in doctor and isn't
    #   already discharged.
    #   Params, in this order: admission_id, the doctor's staff_id
    sql = None
    changed = execute(sql, (admission_id, session["staff_id"]))
    if changed:
        flash("Patient discharged.", "success")
    elif changed == 0:
        flash("Couldn't discharge: not your patient, or already discharged.", "error")
    return redirect(url_for("doctor_dashboard"))


@app.route("/reports")
@login_required("Doctor")
def reports():
    # Report queries are where GROUP BY, aggregates, and subqueries can show
    # off the "complexity of SQL" part of the grade (25%).

    # TODO (SQL): Number of currently admitted patients per department and
    #   severity level.
    #   Columns the page expects: department, level_name, patient_count
    census_sql = None

    # TODO (SQL): Average length of stay (in days) per department, for
    #   discharged patients only.
    #   Columns the page expects: department, avg_stay_days
    stay_sql = None

    # TODO (SQL): Admitted patients with no vitals recorded in the last 4 hours.
    #   Columns the page expects: admission_id, first_name, last_name,
    #   room_number, level_name
    overdue_sql = None

    return render_template(
        "reports.html",
        census=query_all(census_sql),
        stays=query_all(stay_sql),
        overdue=query_all(overdue_sql),
    )


# ---------------------------------------------------------------------------
# Nurse screens
# ---------------------------------------------------------------------------

@app.route("/nurse")
@login_required("Nurse")
def nurse_dashboard():
    # TODO (SQL): Patients currently admitted who are assigned to the
    #   logged-in nurse, most urgent severity first.
    #   Param: the nurse's staff_id
    #   Columns the page expects: admission_id, first_name, last_name,
    #   room_number, level_name, allergies, last_vitals
    #   (last_vitals = time of their most recent vitals, or NULL if none)
    sql = None
    patients = query_all(sql, (session["staff_id"],))
    return render_template("nurse.html", patients=patients)


@app.route("/admission/<int:admission_id>/vitals", methods=["POST"])
@login_required("Nurse")
def record_vitals(admission_id):
    # TODO (SQL): Add a new Vitals row for this admission.
    #   Params, in this order: admission_id, the nurse's staff_id,
    #   temperature, heart_rate, systolic_bp, diastolic_bp, oxygen_level
    #   (recorded_at can default to the current date/time in your table)
    sql = None
    params = (
        admission_id,
        session["staff_id"],
        form_float("temperature"),
        form_int("heart_rate"),
        form_int("systolic_bp"),
        form_int("diastolic_bp"),
        form_int("oxygen_level"),
    )
    if execute(sql, params) is not None:
        flash("Vitals saved.", "success")
    return redirect(url_for("patient_chart", admission_id=admission_id))


# ---------------------------------------------------------------------------
# Shared screen: the patient chart (doctors and nurses both use it)
# ---------------------------------------------------------------------------

@app.route("/admission/<int:admission_id>")
@login_required()
def patient_chart(admission_id):
    # TODO (SQL): One admission with the patient's details.
    #   Param: admission_id
    #   Columns the page expects: admission_id, first_name, last_name,
    #   date_of_birth, allergies, room_number, department, level_name,
    #   reason, admit_date, discharge_date, doctor_name, nurse_name
    admission_sql = None

    # TODO (SQL): All vitals for this admission, newest first.
    #   Param: admission_id
    #   Columns the page expects: recorded_at, temperature, heart_rate,
    #   systolic_bp, diastolic_bp, oxygen_level, nurse_name
    vitals_sql = None

    # TODO (SQL): All prescriptions for this admission, active ones first.
    #   Param: admission_id
    #   Columns the page expects: medication, dose, dosage_unit, frequency,
    #   start_date, end_date, doctor_name
    rx_sql = None

    admission = query_one(admission_sql, (admission_id,))
    if admission_sql and admission is None:
        abort(404)

    return render_template(
        "patient.html",
        admission_id=admission_id,
        admission=admission,
        vitals=query_all(vitals_sql, (admission_id,)),
        prescriptions=query_all(rx_sql, (admission_id,)),
    )


@app.context_processor
def template_helpers():
    def fmt_dt(value, pattern="%m/%d %I:%M %p"):
        return value.strftime(pattern) if isinstance(value, datetime) else (value or "")
    return {"fmt_dt": fmt_dt}


if __name__ == "__main__":
    # Set FLASK_DEBUG=1 while developing. Leave it off for the final demo.
    app.run(debug=os.environ.get("FLASK_DEBUG") == "1", host="127.0.0.1", port=3000)
