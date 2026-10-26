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



CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    floor INT,
    CHECK (floor >= 1)
);

CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(10) NOT NULL,
    department_id INT,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    CHECK (role IN ('Doctor', 'Nurse')),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

CREATE TABLE Room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    department_id INT,
    capacity INT NOT NULL,
    CHECK (capacity > 0),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

CREATE TABLE Patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(20),
    allergies VARCHAR(255) DEFAULT 'None'
);

CREATE TABLE Severity (
    severity_id INT PRIMARY KEY,
    level_name VARCHAR(20) NOT NULL UNIQUE,
    priority INT NOT NULL UNIQUE,
    description VARCHAR(255)
);


CREATE TABLE Medication (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    dosage_unit VARCHAR(10) NOT NULL
);

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

