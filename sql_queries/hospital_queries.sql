

-- Create patients table
CREATE TABLE patients(
patient_id INT PRIMARY KEY,
patient_name VARCHAR(100),
gender VARCHAR(10),
age INT,
phone VARCHAR(20),
city VARCHAR(50),
admission_date DATE
);

-- Create doctors table
CREATE TABLE doctors(
doctor_id INT PRIMARY KEY,
doctor_name VARCHAR(100),
specialization VARCHAR(100),
experience_years INT,
phone VARCHAR(20),
department_id INT
);

-- Create departments table
CREATE TABLE departments(
department_id INT PRIMARY KEY,
department_name VARCHAR(100),
floor_number INT,
head_doctor VARCHAR(100)
);

-- Create appointments table
CREATE TABLE appointments(
appointment_id INT PRIMARY KEY,
patient_id INT,
doctor_id INT,
appointment_date DATE,
appointment_time TIME,
status VARCHAR(30),
FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
FOREIGN KEY(doctor_id) REFERENCES doctors(doctor_id)
);

-- Create billing table
CREATE TABLE billing(
bill_id INT PRIMARY KEY,
patient_id INT,
appointment_id INT,
bill_amount DECIMAL(10,2),
payment_status VARCHAR(30),
bill_date DATE,
FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id)
);

-- Create medical records table
CREATE TABLE medical_records(
record_id INT PRIMARY KEY,
patient_id INT,
doctor_id INT,
diagnosis VARCHAR(255),
treatment VARCHAR(255),
record_date DATE,
FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
FOREIGN KEY(doctor_id) REFERENCES doctors(doctor_id)
);

-- View all patients
SELECT patient_id,patient_name,city
FROM patients
ORDER BY patient_name;

-- View all doctors
SELECT doctor_id,doctor_name,specialization
FROM doctors
ORDER BY specialization;

-- Find patients above age 50
SELECT patient_name,age,city
FROM patients
WHERE age>50;

-- Find doctors with more than 10 years experience
SELECT doctor_name,specialization,experience_years
FROM doctors
WHERE experience_years>10;

-- Count patients by city
SELECT city,COUNT(*) AS total_patients
FROM patients
GROUP BY city;

-- Count doctors by specialization
SELECT specialization,COUNT(*) AS total_doctors
FROM doctors
GROUP BY specialization;

-- Find total appointments
SELECT COUNT(*) AS total_appointments
FROM appointments
WHERE status='Completed';

-- Find cancelled appointments
SELECT appointment_id,patient_id,status
FROM appointments
WHERE status='Cancelled';

-- Show patients with appointments
SELECT patients.patient_name,appointments.appointment_date,appointments.status
FROM appointments
JOIN patients ON appointments.patient_id=patients.patient_id;

-- Show doctors with appointments
SELECT doctors.doctor_name,appointments.appointment_date,appointments.status
FROM appointments
JOIN doctors ON appointments.doctor_id=doctors.doctor_id;

-- Find highest billing amount
SELECT bill_id,patient_id,bill_amount
FROM billing
ORDER BY bill_amount DESC;

-- Find average billing amount
SELECT AVG(bill_amount) AS average_bill,total_records
FROM(
SELECT bill_amount,COUNT(*) AS total_records
FROM billing
GROUP BY bill_amount
)AS bills;

-- Find unpaid bills
SELECT bill_id,patient_id,payment_status
FROM billing
WHERE payment_status='Pending';

-- Find completed payments
SELECT bill_id,bill_amount,payment_status
FROM billing
WHERE payment_status='Paid';

-- Find department wise doctors
SELECT departments.department_name,COUNT(doctors.doctor_id) AS total_doctors
FROM doctors
JOIN departments ON doctors.department_id=departments.department_id
GROUP BY departments.department_name;

-- Find most active department
SELECT departments.department_name,COUNT(appointments.appointment_id) AS total_appointments
FROM appointments
JOIN doctors ON appointments.doctor_id=doctors.doctor_id
JOIN departments ON doctors.department_id=departments.department_id
GROUP BY departments.department_name;

-- Find patient medical records
SELECT patients.patient_name,medical_records.diagnosis,medical_records.treatment
FROM medical_records
JOIN patients ON medical_records.patient_id=patients.patient_id;

-- Find doctors handling most patients
SELECT doctors.doctor_name,COUNT(appointments.patient_id) AS total_patients
FROM appointments
JOIN doctors ON appointments.doctor_id=doctors.doctor_id
GROUP BY doctors.doctor_name;

-- Find monthly billing report
SELECT MONTH(bill_date) AS bill_month,SUM(bill_amount) AS total_revenue
FROM billing
GROUP BY MONTH(bill_date);

-- Create procedure for patient bills
DELIMITER //

CREATE PROCEDURE GetPatientBills(IN patientid INT)
BEGIN
SELECT patient_id,bill_amount,payment_status
FROM billing
WHERE patient_id=patientid;
END //

DELIMITER ;

-- Call procedure
CALL GetPatientBills(1);

-- Create appointment summary view
CREATE VIEW appointment_summary AS
SELECT doctors.doctor_name,COUNT(appointments.appointment_id) AS total_appointments
FROM appointments
JOIN doctors ON appointments.doctor_id=doctors.doctor_id
GROUP BY doctors.doctor_name;

-- View appointment summary
SELECT doctor_name,total_appointments,total_appointments*1
FROM appointment_summary
ORDER BY total_appointments DESC;

-- Create trigger for bill validation
DELIMITER //

CREATE TRIGGER check_bill_amount
BEFORE INSERT ON billing
FOR EACH ROW
BEGIN
IF NEW.bill_amount<0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Invalid Bill Amount';
END IF;
END //

DELIMITER ;

-- Create index on patient name
CREATE INDEX idx_patient_name
ON patients(patient_name);

-- Create index on doctor specialization
CREATE INDEX idx_specialization
ON doctors(specialization);

-- Create index on appointment date
CREATE INDEX idx_appointment_date
ON appointments(appointment_date);

-- Update payment status
UPDATE billing
SET payment_status='Paid'
WHERE bill_id=10;

-- Delete cancelled appointments
DELETE FROM appointments
WHERE status='Cancelled';

-- Find newest admitted patients
SELECT patient_name,city,admission_date
FROM patients
ORDER BY admission_date DESC;

-- Find total revenue by department
SELECT departments.department_name,SUM(billing.bill_amount) AS total_revenue
FROM billing
JOIN appointments ON billing.appointment_id=appointments.appointment_id
JOIN doctors ON appointments.doctor_id=doctors.doctor_id
JOIN departments ON doctors.department_id=departments.department_id
GROUP BY departments.department_name;