-- ============================================================================
-- CareChart - Seed Data (all made up, no real patients)
-- ============================================================================
-- Run AFTER schema.sql:   mysql -u root -p < seed.sql
--
-- Seed data does NOT need its own tables. It is just INSERT statements that
-- put fake rows into the same 9 tables that schema.sql created.
--
-- Insert in the same order the tables were created, so every foreign key
-- points to a row that already exists. Because the tables were just created,
-- AUTO_INCREMENT ids start at 1 and go up in the order rows are inserted.
-- The comments next to each row show the id it will get, so you can see
-- which numbers to use in the later tables.
--
-- DATES: instead of fixed dates, admissions and vitals use things like
--     NOW() - INTERVAL 2 DAY      (= "2 days ago")
--     NOW() - INTERVAL 3 HOUR     (= "3 hours ago")
-- That way the data always looks current, no matter what day the professor
-- runs this file, and the "no vitals in 4 hours" report always has results.
-- ============================================================================

USE carechart;


-- ---------------------------------------------------------------------------
-- 1. Department
-- ---------------------------------------------------------------------------
INSERT INTO Department (name, floor) VALUES
('Emergency',  1),   -- department_id 1
('Cardiology', 2),   -- department_id 2
('Pediatrics', 3),   -- department_id 3
('Surgery',    4);   -- department_id 4


-- ---------------------------------------------------------------------------
-- 2. Staff
-- Every test account uses the password:  password123
-- The long scrypt:... text is that password run through make_hash.py.
-- (The same hash works for every row because it is the same password.)
-- ---------------------------------------------------------------------------
INSERT INTO Staff (first_name, last_name, role, department_id, email, phone, username, password_hash) VALUES
-- Doctors
('Sarah', 'Smith', 'Doctor', 1, 'ssmith@carechart.test', '203-555-0101', 'drsmith',
 'scrypt:32768:8:1$fVsaMO3At724CJpR$7227cc757f5af2b153dbe084a7a4baae5f7a38aa7e40e841c01844adb6091fa039e67370e08bb231c8d066a051b0185e934014f9ef8d1123aac30af1ba026487'),  -- staff_id 1
('James', 'Patel', 'Doctor', 2, 'jpatel@carechart.test', '203-555-0102', 'drpatel',
 'scrypt:32768:8:1$fVsaMO3At724CJpR$7227cc757f5af2b153dbe084a7a4baae5f7a38aa7e40e841c01844adb6091fa039e67370e08bb231c8d066a051b0185e934014f9ef8d1123aac30af1ba026487'),  -- staff_id 2
('Maria', 'Lopez', 'Doctor', 3, 'mlopez@carechart.test', '203-555-0103', 'drlopez',
 'scrypt:32768:8:1$fVsaMO3At724CJpR$7227cc757f5af2b153dbe084a7a4baae5f7a38aa7e40e841c01844adb6091fa039e67370e08bb231c8d066a051b0185e934014f9ef8d1123aac30af1ba026487'),  -- staff_id 3
-- Nurses
('Emily', 'Lee',   'Nurse',  1, 'elee@carechart.test',   '203-555-0201', 'nlee',
 'scrypt:32768:8:1$fVsaMO3At724CJpR$7227cc757f5af2b153dbe084a7a4baae5f7a38aa7e40e841c01844adb6091fa039e67370e08bb231c8d066a051b0185e934014f9ef8d1123aac30af1ba026487'),  -- staff_id 4
('David', 'Brown', 'Nurse',  2, 'dbrown@carechart.test', '203-555-0202', 'nbrown',
 'scrypt:32768:8:1$fVsaMO3At724CJpR$7227cc757f5af2b153dbe084a7a4baae5f7a38aa7e40e841c01844adb6091fa039e67370e08bb231c8d066a051b0185e934014f9ef8d1123aac30af1ba026487'),  -- staff_id 5
('Grace', 'Kim',   'Nurse',  3, 'gkim@carechart.test',   '203-555-0203', 'nkim',
 'scrypt:32768:8:1$fVsaMO3At724CJpR$7227cc757f5af2b153dbe084a7a4baae5f7a38aa7e40e841c01844adb6091fa039e67370e08bb231c8d066a051b0185e934014f9ef8d1123aac30af1ba026487');  -- staff_id 6


-- ---------------------------------------------------------------------------
-- 3. Room
-- ---------------------------------------------------------------------------
INSERT INTO Room (room_number, department_id, capacity) VALUES
('ER-101', 1, 1),   -- room_id 1
('ER-102', 1, 1),   -- room_id 2
('ER-103', 1, 2),   -- room_id 3
('C-201',  2, 2),   -- room_id 4
('C-202',  2, 2),   -- room_id 5
('P-301',  3, 2),   -- room_id 6
('P-302',  3, 2),   -- room_id 7
('S-401',  4, 1),   -- room_id 8
('S-402',  4, 1);   -- room_id 9


-- ---------------------------------------------------------------------------
-- 4. Patient
-- Patients with no allergies leave the column out, so it uses the
-- DEFAULT 'None' from the table.  Patients 6, 7 and 12 are kids (Pediatrics).
-- ---------------------------------------------------------------------------
INSERT INTO Patient (first_name, last_name, date_of_birth, gender, phone, allergies) VALUES
('Michael',  'Johnson',  '1985-04-12', 'Male',   '203-555-1001', 'Peanuts'),      -- patient_id 1
('Linda',    'Garcia',   '1972-09-30', 'Female', '203-555-1002', 'None'),         -- patient_id 2
('Robert',   'Williams', '1950-01-22', 'Male',   '203-555-1003', 'None'),         -- patient_id 3
('Patricia', 'Miller',   '1961-06-05', 'Female', '203-555-1004', 'Penicillin'),   -- patient_id 4
('Thomas',   'Davis',    '1958-11-17', 'Male',   '203-555-1005', 'None'),         -- patient_id 5
('Sophia',   'Martinez', '2016-03-09', 'Female', '203-555-1006', 'None'),         -- patient_id 6
('Ethan',    'Wilson',   '2019-07-28', 'Male',   '203-555-1007', 'None'),         -- patient_id 7
('Jessica',  'Anderson', '1994-02-14', 'Female', '203-555-1008', 'Latex'),        -- patient_id 8
('Daniel',   'Taylor',   '2001-12-03', 'Male',   '203-555-1009', 'None'),         -- patient_id 9
('Barbara',  'Thomas',   '1947-08-19', 'Female', '203-555-1010', 'Aspirin'),      -- patient_id 10
('Kevin',    'Moore',    '1989-05-25', 'Male',   '203-555-1011', 'Sulfa drugs'),  -- patient_id 11
('Olivia',   'Jackson',  '2018-10-11', 'Female', '203-555-1012', 'None');         -- patient_id 12


-- ---------------------------------------------------------------------------
-- 5. Severity
-- severity_id is NOT auto increment in this table, so we type the ids.
-- priority 1 = most urgent (used for sorting the dashboards).
-- ---------------------------------------------------------------------------
INSERT INTO Severity (severity_id, level_name, priority, description) VALUES
(1, 'Critical', 1, 'Constant monitoring'),
(2, 'High',     2, 'Check vitals every hour'),
(3, 'Moderate', 3, 'Check vitals every 4 hours'),
(4, 'Low',      4, 'Check vitals every 8 hours');


-- ---------------------------------------------------------------------------
-- 6. Medication
-- ---------------------------------------------------------------------------
INSERT INTO Medication (name, dosage_unit) VALUES
('Acetaminophen', 'mg'),   -- medication_id 1  (pain / fever)
('Ibuprofen',     'mg'),   -- medication_id 2  (pain / swelling)
('Amoxicillin',   'mg'),   -- medication_id 3  (antibiotic)
('Aspirin',       'mg'),   -- medication_id 4  (heart / blood thinner)
('Morphine',      'mg'),   -- medication_id 5  (strong pain)
('Albuterol',     'mg'),   -- medication_id 6  (asthma)
('Saline (IV)',   'mL'),   -- medication_id 7  (fluids)
('Epinephrine',   'mg'),   -- medication_id 8  (allergic reaction)
('Metoprolol',    'mg'),   -- medication_id 9  (heart rate / blood pressure)
('Ondansetron',   'mg');   -- medication_id 10 (nausea)


-- ---------------------------------------------------------------------------
-- 7. Admission
-- Columns: patient, room, doctor, nurse, severity, admit_date, discharge_date, reason
--   Doctors: 1 = Smith, 2 = Patel, 3 = Lopez
--   Nurses:  4 = Lee,   5 = Brown, 6 = Kim
--   Severity: 1 = Critical, 2 = High, 3 = Moderate, 4 = Low
--
-- Admissions 1-10: still in the hospital (discharge_date is NULL)
-- Admissions 11-15: already went home (for the length-of-stay report)
-- Repeat visits: patient 3 (admissions 3 and 11), patient 2 (2 and 14),
--                patient 6 (6 and 15)
-- ---------------------------------------------------------------------------
INSERT INTO Admission (patient_id, room_id, doctor_id, nurse_id, severity_id, admit_date, discharge_date, reason) VALUES
-- Currently admitted
(1,  1, 1, 4, 1, NOW() - INTERVAL 1 DAY,   NULL, 'Severe allergic reaction'),            -- admission_id 1
(2,  2, 1, 4, 2, NOW() - INTERVAL 10 HOUR, NULL, 'Broken leg from car accident'),        -- admission_id 2
(3,  4, 2, 5, 1, NOW() - INTERVAL 2 DAY,   NULL, 'Heart attack'),                        -- admission_id 3
(4,  4, 2, 5, 3, NOW() - INTERVAL 3 DAY,   NULL, 'Irregular heartbeat'),                 -- admission_id 4
(5,  5, 2, 5, 2, NOW() - INTERVAL 1 DAY,   NULL, 'Chest pain'),                          -- admission_id 5
(6,  6, 3, 6, 3, NOW() - INTERVAL 2 DAY,   NULL, 'Asthma attack'),                       -- admission_id 6
(7,  6, 3, 6, 4, NOW() - INTERVAL 1 DAY,   NULL, 'Dehydration from stomach flu'),        -- admission_id 7
(8,  8, 1, 6, 2, NOW() - INTERVAL 2 DAY,   NULL, 'Recovering from appendix surgery'),    -- admission_id 8
(9,  3, 1, 4, 4, NOW() - INTERVAL 5 HOUR,  NULL, 'Sprained wrist'),                      -- admission_id 9
(10, 9, 2, 5, 3, NOW() - INTERVAL 4 DAY,   NULL, 'Recovering from heart bypass surgery'),-- admission_id 10
-- Already discharged
(3,  5, 2, 5, 2, NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 55 DAY, 'Chest pain'),        -- admission_id 11
(11, 1, 1, 4, 3, NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 28 DAY, 'Pneumonia'),         -- admission_id 12
(12, 7, 3, 6, 4, NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 19 DAY, 'Ear infection'),     -- admission_id 13
(2,  8, 1, 6, 3, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 40 DAY, 'Knee surgery'),      -- admission_id 14
(6,  7, 3, 6, 3, NOW() - INTERVAL 90 DAY, NOW() - INTERVAL 87 DAY, 'Asthma attack');     -- admission_id 15


-- ---------------------------------------------------------------------------
-- 8. Vitals
-- Columns: admission, nurse, recorded_at, temp (F), heart rate,
--          systolic BP, diastolic BP, oxygen %
-- The nurse on each reading is the nurse assigned to that admission.
--
-- OVERDUE on purpose (no vitals in the last 4 hours) for the reports page:
--   admission 4  - last reading 6 hours ago
--   admission 7  - last reading 9 hours ago
--   admission 9  - no vitals at all yet
-- Everyone else still admitted has a reading within the last 4 hours.
-- ---------------------------------------------------------------------------
INSERT INTO Vitals (admission_id, nurse_id, recorded_at, temperature, heart_rate, systolic_bp, diastolic_bp, oxygen_level) VALUES
-- Admission 1: allergic reaction (Critical) - getting better over time
(1, 4, NOW() - INTERVAL 20 HOUR, 99.8, 128,  88, 55, 89),
(1, 4, NOW() - INTERVAL 8 HOUR,  99.1, 110,  98, 62, 93),
(1, 4, NOW() - INTERVAL 1 HOUR,  98.7,  96, 108, 70, 96),
-- Admission 2: broken leg (High)
(2, 4, NOW() - INTERVAL 9 HOUR,  98.6, 102, 138, 88, 97),
(2, 4, NOW() - INTERVAL 2 HOUR,  98.4,  90, 130, 84, 98),
-- Admission 3: heart attack (Critical)
(3, 5, NOW() - INTERVAL 40 HOUR, 99.0, 118, 165, 98, 91),
(3, 5, NOW() - INTERVAL 12 HOUR, 98.9, 104, 150, 92, 93),
(3, 5, NOW() - INTERVAL 30 MINUTE, 98.6, 92, 142, 88, 95),
-- Admission 4: irregular heartbeat (Moderate) - OVERDUE
(4, 5, NOW() - INTERVAL 30 HOUR, 98.2, 112, 135, 85, 97),
(4, 5, NOW() - INTERVAL 6 HOUR,  98.4,  88, 128, 82, 98),
-- Admission 5: chest pain (High)
(5, 5, NOW() - INTERVAL 20 HOUR, 98.8,  99, 145, 90, 96),
(5, 5, NOW() - INTERVAL 3 HOUR,  98.5,  84, 136, 86, 97),
-- Admission 6: asthma, child (Moderate)
(6, 6, NOW() - INTERVAL 40 HOUR, 100.2, 125, 105, 68, 90),
(6, 6, NOW() - INTERVAL 2 HOUR,   99.0, 100, 102, 65, 96),
-- Admission 7: dehydration, child (Low) - OVERDUE
(7, 6, NOW() - INTERVAL 20 HOUR, 100.6, 118, 95, 60, 98),
(7, 6, NOW() - INTERVAL 9 HOUR,   99.3, 104, 98, 62, 99),
-- Admission 8: after appendix surgery (High)
(8, 6, NOW() - INTERVAL 30 HOUR, 100.1,  95, 122, 80, 97),
(8, 6, NOW() - INTERVAL 90 MINUTE, 98.9, 82, 118, 76, 98),
-- Admission 9: sprained wrist (Low) - no vitals yet, so none listed here
-- Admission 10: after heart bypass (Moderate)
(10, 5, NOW() - INTERVAL 50 HOUR, 99.4,  88, 140, 85, 94),
(10, 5, NOW() - INTERVAL 3 HOUR,  98.6,  76, 128, 80, 97),
-- Discharged admissions: a couple of readings during their stay
(11, 5, NOW() - INTERVAL 59 DAY, 98.7, 101, 148, 92, 96),
(11, 5, NOW() - INTERVAL 56 DAY, 98.5,  80, 132, 84, 98),
(12, 4, NOW() - INTERVAL 30 DAY, 102.1, 108, 124, 80, 91),
(12, 4, NOW() - INTERVAL 28 DAY,  98.8,  82, 120, 78, 97),
(13, 6, NOW() - INTERVAL 20 DAY, 101.0, 115, 100, 64, 99),
(14, 6, NOW() - INTERVAL 44 DAY,  99.2,  88, 126, 82, 98),
(14, 6, NOW() - INTERVAL 41 DAY,  98.6,  76, 120, 78, 99),
(15, 6, NOW() - INTERVAL 89 DAY,  99.8, 120, 104, 66, 91);


-- ---------------------------------------------------------------------------
-- 9. Prescription
-- Columns: admission, doctor, medication, dose, frequency, start_date, end_date
-- The doctor on each one is the admission's attending doctor.
-- end_date NULL = still taking it. end_date set = finished.
-- (Patient 4 is allergic to Penicillin and patient 10 to Aspirin,
--  so they don't get Amoxicillin or Aspirin.)
-- ---------------------------------------------------------------------------
INSERT INTO Prescription (admission_id, doctor_id, medication_id, dose, frequency, start_date, end_date) VALUES
-- Admission 1: allergic reaction
(1, 1, 8,    0.30, 'One time',          NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
(1, 1, 7, 1000.00, 'Every 8 hours',     NOW() - INTERVAL 1 DAY,  NULL),
-- Admission 2: broken leg
(2, 1, 5,    4.00, 'Every 4 hours',     NOW() - INTERVAL 10 HOUR, NULL),
(2, 1, 2,  400.00, 'Every 6 hours',     NOW() - INTERVAL 10 HOUR, NULL),
-- Admission 3: heart attack
(3, 2, 4,   81.00, 'Once a day',        NOW() - INTERVAL 2 DAY,  NULL),
(3, 2, 9,   25.00, 'Every 12 hours',    NOW() - INTERVAL 2 DAY,  NULL),
(3, 2, 5,    2.00, 'Every 4 hours',     NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 1 DAY),
-- Admission 4: irregular heartbeat
(4, 2, 9,   50.00, 'Every 12 hours',    NOW() - INTERVAL 3 DAY,  NULL),
-- Admission 5: chest pain
(5, 2, 4,   81.00, 'Once a day',        NOW() - INTERVAL 1 DAY,  NULL),
-- Admission 6: asthma (child dose)
(6, 3, 6,    2.50, 'Every 6 hours',     NOW() - INTERVAL 2 DAY,  NULL),
-- Admission 7: dehydration (child)
(7, 3, 7,  500.00, 'Every 8 hours',     NOW() - INTERVAL 1 DAY,  NULL),
(7, 3, 10,   2.00, 'Every 8 hours',     NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 12 HOUR),
-- Admission 8: after appendix surgery
(8, 1, 1,  650.00, 'Every 6 hours',     NOW() - INTERVAL 2 DAY,  NULL),
(8, 1, 3,  500.00, 'Every 8 hours',     NOW() - INTERVAL 2 DAY,  NULL),
-- Admission 9: sprained wrist
(9, 1, 2,  400.00, 'Every 6 hours',     NOW() - INTERVAL 5 HOUR, NULL),
-- Admission 10: after heart bypass
(10, 2, 9,  25.00, 'Every 12 hours',    NOW() - INTERVAL 4 DAY,  NULL),
(10, 2, 1, 650.00, 'Every 6 hours',     NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 2 DAY),
-- Discharged admissions (all ended on or before the discharge day)
(11, 2, 4,   81.00, 'Once a day',       NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 55 DAY),
(12, 1, 3,  500.00, 'Every 8 hours',    NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 28 DAY),
(13, 3, 3,  250.00, 'Every 8 hours',    NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 19 DAY),
(14, 1, 2,  600.00, 'Every 6 hours',    NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 40 DAY),
(15, 3, 6,    2.50, 'Every 6 hours',    NOW() - INTERVAL 90 DAY, NOW() - INTERVAL 87 DAY);
