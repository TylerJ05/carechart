-- ============================================================================
-- CareChart - Database Schema
-- CSC335 Database Systems | Tyler Jackson and Tony Branham-Wiggins
-- ============================================================================
-- Run with:   mysql -u root -p < schema.sql
--
-- The three lines below come from the professor's sample schema. They rebuild
-- the database from scratch every time this file runs.
--
-- Each table's design (columns, types, rules) is copied from our
-- "CareChart Table Design" doc as comments. Write the CREATE TABLE statement
-- under each one. They are listed in the order they must be created: a table
-- has to exist before another table's FOREIGN KEY can point to it.
-- ============================================================================

DROP DATABASE IF EXISTS carechart;
CREATE DATABASE carechart;
USE carechart;


-- ---------------------------------------------------------------------------
-- 1. Department
--   department_id  INT           Primary key, auto increment
--   name           VARCHAR(50)   NOT NULL, UNIQUE
--   floor          INT           CHECK floor >= 1
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Department
CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    floor INT,
    CHECK (floor >= 1)
);

-- ---------------------------------------------------------------------------
-- 2. Staff  (doctors and nurses, plus their login info)
--   staff_id               INT           Primary key, auto increment
--   first_name, last_name  VARCHAR(50)   NOT NULL
--   role                   VARCHAR(10)   NOT NULL, CHECK role IN ('Doctor', 'Nurse')
--   department_id          INT           Foreign key -> Department
--   email                  VARCHAR(100)  NOT NULL, UNIQUE
--   phone                  VARCHAR(20)
--   username               VARCHAR(30)   NOT NULL, UNIQUE
--   password_hash          VARCHAR(255)  NOT NULL
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Staff
CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(10) NOT NULL,
    department_id INT,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    username VARCHAR(30) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    CHECK (role IN ('Doctor', 'Nurse')),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- ---------------------------------------------------------------------------
-- 3. Room
--   room_id        INT           Primary key, auto increment
--   room_number    VARCHAR(10)   NOT NULL, UNIQUE
--   department_id  INT           Foreign key -> Department
--   capacity       INT           NOT NULL, CHECK capacity > 0
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Room
CREATE TABLE Room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    department_id INT,
    capacity INT NOT NULL,
    CHECK (capacity > 0),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- ---------------------------------------------------------------------------
-- 4. Patient  (personal info only)
--   patient_id             INT           Primary key, auto increment
--   first_name, last_name  VARCHAR(50)   NOT NULL
--   date_of_birth          DATE          NOT NULL
--   gender                 VARCHAR(10)
--   phone                  VARCHAR(20)
--   allergies              VARCHAR(255)  Defaults to 'None'
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Patient
CREATE TABLE Patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(20),
    allergies VARCHAR(255) DEFAULT 'None'
);

-- ---------------------------------------------------------------------------
-- 5. Severity  (lookup table)
--   severity_id  INT           Primary key
--   level_name   VARCHAR(20)   NOT NULL, UNIQUE (Low, Moderate, High, Critical)
--   priority     INT           NOT NULL, UNIQUE (1 = most urgent, used for sorting)
--   description  VARCHAR(255)  e.g. 'Check vitals every hour'
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Severity
CREATE TABLE Severity (
    severity_id INT PRIMARY KEY,
    level_name VARCHAR(20) NOT NULL UNIQUE,
    priority INT NOT NULL UNIQUE,
    description VARCHAR(255)
);


-- ---------------------------------------------------------------------------
-- 6. Medication
--   medication_id  INT           Primary key, auto increment
--   name           VARCHAR(100)  NOT NULL, UNIQUE
--   dosage_unit    VARCHAR(10)   NOT NULL (mg, mL, g)
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Medication
CREATE TABLE Medication (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    dosage_unit VARCHAR(10) NOT NULL
);

-- ---------------------------------------------------------------------------
-- 7. Admission  (one row per hospital stay)
--   admission_id    INT           Primary key, auto increment
--   patient_id      INT           NOT NULL, Foreign key -> Patient
--   room_id         INT           Foreign key -> Room
--   doctor_id       INT           NOT NULL, Foreign key -> Staff
--   nurse_id        INT           Foreign key -> Staff
--   severity_id     INT           NOT NULL, Foreign key -> Severity
--   admit_date      DATETIME      NOT NULL
--   discharge_date  DATETIME      NULL while still admitted; CHECK discharge_date >= admit_date
--   reason          VARCHAR(255)  NOT NULL
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Admission
CREATE TABLE Admission (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT,
    doctor_id INT NOT NULL,
    nurse_id INT,
    severity_id INT NOT NULL,
    admit_date DATETIME NOT NULL,
    discharge_date DATETIME NULL,
    reason VARCHAR(255) NOT NULL,
    CHECK (discharge_date >= admit_date),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    FOREIGN KEY (doctor_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (nurse_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (severity_id) REFERENCES Severity(severity_id)
);

-- ---------------------------------------------------------------------------
-- 8. Vitals
--   vitals_id                  INT           Primary key, auto increment
--   admission_id               INT           NOT NULL, Foreign key -> Admission
--   nurse_id                   INT           NOT NULL, Foreign key -> Staff
--   recorded_at                DATETIME      NOT NULL, defaults to current time
--   temperature                DECIMAL(4,1)  CHECK between 90 and 110 (F)
--   heart_rate                 INT           CHECK between 20 and 250
--   systolic_bp, diastolic_bp  INT
--   oxygen_level               INT           CHECK between 0 and 100
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Vitals
CREATE TABLE Vitals (
    vitals_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    nurse_id INT NOT NULL,
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    temperature DECIMAL(4,1),
    heart_rate INT,
    systolic_bp INT,
    diastolic_bp INT,
    oxygen_level INT,
    CHECK (temperature BETWEEN 90 AND 110),
    CHECK (heart_rate BETWEEN 20 AND 250),
    CHECK (oxygen_level BETWEEN 0 AND 100),
    FOREIGN KEY (admission_id) REFERENCES Admission(admission_id),
    FOREIGN KEY (nurse_id) REFERENCES Staff(staff_id)
);

-- ---------------------------------------------------------------------------
-- 9. Prescription
--   prescription_id  INT           Primary key, auto increment
--   admission_id     INT           NOT NULL, Foreign key -> Admission
--   doctor_id        INT           NOT NULL, Foreign key -> Staff
--   medication_id    INT           NOT NULL, Foreign key -> Medication
--   dose             DECIMAL(6,2)  NOT NULL, CHECK dose > 0
--   frequency        VARCHAR(50)   NOT NULL (e.g. 'Every 8 hours')
--   start_date       DATETIME      NOT NULL
--   end_date         DATETIME      NULL = still active; CHECK end_date >= start_date
-- ---------------------------------------------------------------------------
-- TODO: CREATE TABLE Prescription
CREATE TABLE Prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medication_id INT NOT NULL,
    dose DECIMAL(6,2) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NULL,
    CHECK (dose > 0),
    CHECK (end_date >= start_date),
    FOREIGN KEY (admission_id) REFERENCES Admission(admission_id),
    FOREIGN KEY (doctor_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (medication_id) REFERENCES Medication(medication_id)
);

