"""
CareChart - patient care system for doctors and nurses.
CSC335 Database Systems final project
Tyler Jackson and Tony Branham-Wiggins

Built from the professor's Flask + MySQL sample.
All queries use %s placeholders to prevent SQL injection.
"""

import os
from datetime import datetime
from functools import wraps

import mysql.connector
from flask import Flask, abort, flash, redirect, render_template, request, session, url_for

app = Flask(__name__)
# Secret key for the login session
app.secret_key = os.environ.get("SECRET_KEY", "dev-only-change-me")

# Database connection settings
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
    """Run a SELECT and return all matching rows."""
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
    """Run a SELECT and return the first row, or None."""
    rows = query_all(sql, params)
    return rows[0] if rows else None


def execute(sql, params=()):
    """Run an INSERT, UPDATE, or DELETE and save the change."""
    if not sql:
        flash("This feature isn't available yet.", "warning")
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
    """Show database errors on an error page instead of crashing."""
    return render_template("error.html", message=str(err)), 500


# ---------------------------------------------------------------------------
# Form helpers
# ---------------------------------------------------------------------------

def form_int(name):
    """Read a whole number from the form."""
    value = request.form.get(name, "").strip()
    return int(value) if value else None


def form_float(name):
    """Read a decimal number from the form."""
    value = request.form.get(name, "").strip()
    return float(value) if value else None


# ---------------------------------------------------------------------------
# Login
# ---------------------------------------------------------------------------

def login_required(role=None):
    """Require login, optionally for one role (Doctor or Nurse)."""
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


# Send doctors and nurses to their own dashboard
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

        # Find the staff member by username
        sql = "SELECT staff_id, first_name, last_name, role, password FROM Staff WHERE username = %s"
        staff = query_one(sql, (username,))

        # Check the password and log them in
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
    # Doctor's current patients, most urgent first
    sql = None
    patients = query_all(sql, (session["staff_id"],))
    return render_template("doctor.html", patients=patients)


@app.route("/admission/<int:admission_id>/prescribe", methods=["GET", "POST"])
@login_required("Doctor")
def prescribe(admission_id):
    if request.method == "POST":
        # Save a new prescription
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

    # Medication list for the dropdown
    meds_sql = None
    medications = query_all(meds_sql)
    return render_template("prescribe.html", admission_id=admission_id, medications=medications)


@app.route("/admission/<int:admission_id>/discharge", methods=["POST"])
@login_required("Doctor")
def discharge(admission_id):
    # Set the discharge date to now
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
    # Patients per department and severity
    census_sql = None

    # Average length of stay per department
    stay_sql = None

    # Patients with no vitals in the last 4 hours
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
    # Nurse's assigned patients, most urgent first
    sql = None
    patients = query_all(sql, (session["staff_id"],))
    return render_template("nurse.html", patients=patients)


@app.route("/admission/<int:admission_id>/vitals", methods=["POST"])
@login_required("Nurse")
def record_vitals(admission_id):
    # Save a new vitals reading
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
# Patient chart (shared by doctors and nurses)
# ---------------------------------------------------------------------------

@app.route("/admission/<int:admission_id>")
@login_required()
def patient_chart(admission_id):
    # Patient and admission details
    admission_sql = None

    # Vitals history, newest first
    vitals_sql = None

    # Prescriptions, active ones first
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


# Date formatting helper for the HTML pages
@app.context_processor
def template_helpers():
    def fmt_dt(value, pattern="%m/%d %I:%M %p"):
        return value.strftime(pattern) if isinstance(value, datetime) else (value or "")
    return {"fmt_dt": fmt_dt}


if __name__ == "__main__":
    # Start the app at http://localhost:3000
    app.run(debug=os.environ.get("FLASK_DEBUG") == "1", host="127.0.0.1", port=3000)
