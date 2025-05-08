-- Student Records Database Management System

-- Drop database if it exists to start fresh
DROP DATABASE IF EXISTS student_records_db;
CREATE DATABASE student_records_db;
USE student_records_db;

-- =============================================
-- TABLES FOR CORE ENTITIES
-- =============================================

-- Department table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    hod_name VARCHAR(100),
    office_location VARCHAR(50),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    establishment_date DATE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Faculty table
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title ENUM('Professor', 'Associate Professor', 'Assistant Professor', 'Lecturer', 'Instructor') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    highest_degree VARCHAR(100),
    specialization VARCHAR(150),
    status ENUM('Active', 'On Leave', 'Retired', 'Terminated') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- Courses table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(150) NOT NULL,
    description TEXT,
    credit_hours DECIMAL(3,1) NOT NULL,
    level ENUM('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- Student table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other'),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    admission_date DATE NOT NULL,
    graduation_date DATE,
    major_department_id INT,
    student_type ENUM('Undergraduate', 'Graduate', 'PhD', 'Exchange', 'Certificate') NOT NULL,
    status ENUM('Active', 'On Leave', 'Graduated', 'Withdrawn', 'Suspended') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (major_department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

-- Academic Year table
CREATE TABLE academic_years (
    academic_year_id INT AUTO_INCREMENT PRIMARY KEY,
    year_name VARCHAR(20) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (end_date > start_date)
);

-- Semester table
CREATE TABLE semesters (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT NOT NULL,
    semester_name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_start DATE NOT NULL,
    registration_end DATE NOT NULL,
    final_exam_start DATE,
    final_exam_end DATE,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(academic_year_id),
    CONSTRAINT check_semester_dates CHECK (end_date > start_date AND registration_end > registration_start)
);

-- =============================================
-- TABLES FOR RELATIONSHIPS AND OPERATIONS
-- =============================================

-- Course Offerings (Specific instances of courses in specific semesters)
CREATE TABLE course_offerings (
    offering_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    faculty_id INT,
    section_number VARCHAR(10) NOT NULL,
    room_location VARCHAR(50),
    schedule VARCHAR(100),
    max_capacity INT NOT NULL,
    current_enrollment INT DEFAULT 0,
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
    syllabus_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE RESTRICT,
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE RESTRICT,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE SET NULL,
    UNIQUE KEY (course_id, semester_id, section_number)
);

-- Enrollments (Students enrolled in specific course offerings)
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    offering_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade VARCHAR(2),
    grade_points DECIMAL(3,2),
    attendance_percentage DECIMAL(5,2),
    status ENUM('Enrolled', 'Withdrawn', 'Completed', 'Incomplete', 'Failed') NOT NULL DEFAULT 'Enrolled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id) ON DELETE CASCADE,
    UNIQUE KEY (student_id, offering_id)
);

-- Student Attendance (Tracking daily attendance)
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late', 'Excused') NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    UNIQUE KEY (enrollment_id, attendance_date)
);

-- Assessments (Types of assessments for course offerings)
CREATE TABLE assessments (
    assessment_id INT AUTO_INCREMENT PRIMARY KEY,
    offering_id INT NOT NULL,
    assessment_name VARCHAR(100) NOT NULL,
    assessment_type ENUM('Quiz', 'Assignment', 'Project', 'Midterm', 'Final', 'Presentation', 'Lab', 'Other') NOT NULL,
    max_score DECIMAL(5,2) NOT NULL,
    weight_percentage DECIMAL(5,2) NOT NULL,
    due_date DATETIME,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id) ON DELETE CASCADE
);

-- Student Assessment Results
CREATE TABLE assessment_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    score DECIMAL(5,2),
    submitted_date DATETIME,
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assessment_id) REFERENCES assessments(assessment_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    UNIQUE KEY (assessment_id, enrollment_id)
);

-- Student Academic Records (Semester-wise academic performance)
CREATE TABLE academic_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    semester_id INT NOT NULL,
    gpa DECIMAL(3,2),
    credits_attempted DECIMAL(4,1),
    credits_earned DECIMAL(4,1),
    academic_standing ENUM('Good Standing', 'Warning', 'Probation', 'Suspended', 'Dismissed') NOT NULL DEFAULT 'Good Standing',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE RESTRICT,
    UNIQUE KEY (student_id, semester_id)
);

-- Prerequisites for courses
CREATE TABLE prerequisites (
    prerequisite_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    prerequisite_course_id INT NOT NULL,
    min_grade VARCHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY (course_id, prerequisite_course_id)
);

-- Extracurricular Activities
CREATE TABLE extracurricular_activities (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    activity_name VARCHAR(100) NOT NULL,
    activity_type ENUM('Club', 'Sport', 'Organization', 'Volunteer', 'Competition', 'Other') NOT NULL,
    description TEXT,
    faculty_advisor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (faculty_advisor_id) REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

-- Student participation in extracurricular activities
CREATE TABLE student_activities (
    participation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    activity_id INT NOT NULL,
    join_date DATE NOT NULL,
    end_date DATE,
    role VARCHAR(100),
    achievements TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES extracurricular_activities(activity_id) ON DELETE CASCADE
);


-- For Student Records Database Management System

-- =============================================
-- POPULATE DEPARTMENTS
-- =============================================
INSERT INTO departments (department_name, department_code, hod_name, office_location, contact_email, contact_phone, establishment_date, description) VALUES
('Computer Science and Informatics', 'CSI', 'Prof. Thabo Mafokeng', 'IT Building, Room 301', 'cs.hod@uni.ac.za', '+27 11 559 1234', '1985-03-15', 'Department focusing on computer science, software engineering, and data science'),
('Economics and Finance', 'ECF', 'Prof. Nomsa Dlamini', 'Commerce Building, Floor 2', 'economics.hod@uni.ac.za', '+27 11 559 2345', '1976-02-10', 'Department covering economics, finance, and monetary policy studies'),
('Electrical Engineering', 'ELE', 'Prof. Johan van der Merwe', 'Engineering Block B, Room 205', 'electrical.hod@uni.ac.za', '+27 11 559 3456', '1972-09-01', 'Department specializing in electrical and electronic engineering'),
('African Languages', 'AFL', 'Prof. Lindiwe Zulu', 'Humanities Building, Room 401', 'languages.hod@uni.ac.za', '+27 11 559 4567', '1965-05-20', 'Department focusing on indigenous African languages and linguistics'),
('Medical Sciences', 'MED', 'Prof. Sipho Nkosi', 'Health Sciences Building, Wing A', 'med.hod@uni.ac.za', '+27 11 559 5678', '1968-07-12', 'Department covering medicine, health sciences and clinical practice'),
('Law', 'LAW', 'Prof. Fatima Ebrahim', 'Law Building, Floor 3', 'law.hod@uni.ac.za', '+27 11 559 6789', '1956-03-25', 'Department focusing on South African constitutional and civil law'),
('Education', 'EDU', 'Prof. David Maluleke', 'Education Block, Room 201', 'education.hod@uni.ac.za', '+27 11 559 7890', '1960-01-30', 'Department focusing on teaching methodologies and educational psychology'),
('Environmental Sciences', 'ENV', 'Prof. Sarah Motsepe', 'Science Block, Room 110', 'environment.hod@uni.ac.za', '+27 11 559 8901', '1990-04-22', 'Department studying conservation, ecology and environmental management');

-- =============================================
-- POPULATE FACULTY
-- =============================================
INSERT INTO faculty (department_id, first_name, last_name, title, email, phone, hire_date, date_of_birth, gender, address, city, state, country, postal_code, highest_degree, specialization, status) VALUES
-- Computer Science faculty
(1, 'Thabo', 'Mafokeng', 'Professor', 'thabo.mafokeng@uni.ac.za', '+27 82 123 4567', '2005-01-15', '1970-06-12', 'Male', '45 Jubilee Road', 'Johannesburg', 'Gauteng', 'South Africa', '2001', 'PhD Computer Science', 'Machine Learning and AI', 'Active'),
(1, 'Lerato', 'Moloi', 'Associate Professor', 'lerato.moloi@uni.ac.za', '+27 83 234 5678', '2008-03-20', '1975-09-25', 'Female', '123 Pretoria Ave', 'Johannesburg', 'Gauteng', 'South Africa', '2192', 'PhD Computer Science', 'Information Security', 'Active'),
(1, 'Cameron', 'Naidoo', 'Lecturer', 'cameron.naidoo@uni.ac.za', '+27 84 345 6789', '2015-08-01', '1985-04-18', 'Male', '78 Sandton Drive, Apt 405', 'Johannesburg', 'Gauteng', 'South Africa', '2196', 'MSc Computer Science', 'Software Engineering', 'Active'),

-- Economics faculty
(2, 'Nomsa', 'Dlamini', 'Professor', 'nomsa.dlamini@uni.ac.za', '+27 82 456 7890', '2003-07-01', '1968-11-30', 'Female', '15 Rosebank Lane', 'Johannesburg', 'Gauteng', 'South Africa', '2196', 'PhD Economics', 'Development Economics', 'Active'),
(2, 'James', 'Khumalo', 'Associate Professor', 'james.khumalo@uni.ac.za', '+27 83 567 8901', '2010-01-10', '1977-05-22', 'Male', '402 Parktown North', 'Johannesburg', 'Gauteng', 'South Africa', '2193', 'PhD Finance', 'Investment Banking', 'Active'),
(2, 'Olivia', 'van Wyk', 'Lecturer', 'olivia.vwyk@uni.ac.za', '+27 84 678 9012', '2017-02-15', '1986-09-14', 'Female', '27 Melville Road', 'Johannesburg', 'Gauteng', 'South Africa', '2092', 'MCom Economics', 'Public Finance', 'Active'),

-- Electrical Engineering faculty
(3, 'Johan', 'van der Merwe', 'Professor', 'johan.vandermerwe@uni.ac.za', '+27 82 789 0123', '2002-05-10', '1967-08-03', 'Male', '89 Observatory Ave', 'Johannesburg', 'Gauteng', 'South Africa', '2198', 'PhD Engineering', 'Power Systems', 'Active'),
(3, 'Thandi', 'Mbeki', 'Associate Professor', 'thandi.mbeki@uni.ac.za', '+27 83 890 1234', '2011-08-01', '1978-02-17', 'Female', '56 Braamfontein', 'Johannesburg', 'Gauteng', 'South Africa', '2001', 'PhD Engineering', 'Telecommunications', 'Active'),
(3, 'Andrew', 'Botha', 'Lecturer', 'andrew.botha@uni.ac.za', '+27 84 901 2345', '2016-01-10', '1984-11-05', 'Male', '31 Auckland Park', 'Johannesburg', 'Gauteng', 'South Africa', '2006', 'MSc Engineering', 'Electronic Systems', 'Active'),

-- African Languages faculty
(4, 'Lindiwe', 'Zulu', 'Professor', 'lindiwe.zulu@uni.ac.za', '+27 82 012 3456', '2004-09-01', '1969-04-22', 'Female', '12 Soweto Ext', 'Johannesburg', 'Gauteng', 'South Africa', '1818', 'PhD Linguistics', 'Zulu and Xhosa Languages', 'Active'),
(4, 'Mandla', 'Tshwete', 'Associate Professor', 'mandla.tshwete@uni.ac.za', '+27 83 123 4567', '2009-06-15', '1976-12-11', 'Male', '45 Orlando West', 'Johannesburg', 'Gauteng', 'South Africa', '1804', 'PhD African Literature', 'Setswana Studies', 'Active'),
(4, 'Grace', 'Mthembu', 'Lecturer', 'grace.mthembu@uni.ac.za', '+27 84 234 5678', '2014-03-01', '1983-07-29', 'Female', '78 Diepkloof Zone 6', 'Johannesburg', 'Gauteng', 'South Africa', '1864', 'MA Languages', 'SeSotho and IsiZulu', 'Active'),

-- More faculties for other departments
(5, 'Sipho', 'Nkosi', 'Professor', 'sipho.nkosi@uni.ac.za', '+27 82 345 6789', '2001-03-15', '1966-10-08', 'Male', '23 Parktown Medical District', 'Johannesburg', 'Gauteng', 'South Africa', '2193', 'MD, PhD', 'Cardiology', 'Active'),
(6, 'Fatima', 'Ebrahim', 'Professor', 'fatima.ebrahim@uni.ac.za', '+27 82 456 7890', '2000-08-01', '1965-05-18', 'Female', '90 Constitution Hill', 'Johannesburg', 'Gauteng', 'South Africa', '2001', 'PhD Law', 'Constitutional Law', 'Active'),
(7, 'David', 'Maluleke', 'Professor', 'david.maluleke@uni.ac.za', '+27 82 567 8901', '2004-02-10', '1969-12-03', 'Male', '17 Soweto Teacher Village', 'Johannesburg', 'Gauteng', 'South Africa', '1818', 'PhD Education', 'Education Policy', 'Active'),
(8, 'Sarah', 'Motsepe', 'Professor', 'sarah.motsepe@uni.ac.za', '+27 82 678 9012', '2005-07-01', '1971-08-22', 'Female', '34 Newlands', 'Cape Town', 'Western Cape', 'South Africa', '7700', 'PhD Environmental Sciences', 'Conservation Biology', 'Active');

-- =============================================
-- POPULATE COURSES
-- =============================================
INSERT INTO courses (department_id, course_code, course_name, description, credit_hours, level) VALUES
-- Computer Science courses
(1, 'CSI1500', 'Introduction to Programming', 'Fundamentals of programming using Python with focus on problem solving', 4.0, 'Freshman'),
(1, 'CSI2500', 'Data Structures and Algorithms', 'Study of fundamental data structures and algorithms with Java implementation', 4.0, 'Sophomore'),
(1, 'CSI3510', 'Database Systems', 'Design and implementation of relational database systems', 4.0, 'Junior'),
(1, 'CSI4500', 'Machine Learning', 'Introduction to machine learning algorithms and applications', 4.0, 'Senior'),
(1, 'CSI5500', 'Advanced Artificial Intelligence', 'Deep learning, neural networks and AI applications', 4.0, 'Graduate'),

-- Economics courses
(2, 'ECF1500', 'Principles of Economics', 'Introduction to microeconomics and macroeconomics', 4.0, 'Freshman'),
(2, 'ECF2510', 'South African Economic History', 'Economic development of South Africa from colonialism to present', 4.0, 'Sophomore'),
(2, 'ECF3520', 'Development Economics', 'Economic theories and policies for developing countries with African case studies', 4.0, 'Junior'),
(2, 'ECF4530', 'International Trade', 'Theory and policy of international trade with focus on African economies', 4.0, 'Senior'),
(2, 'ECF5550', 'Economic Policy Analysis', 'Advanced analysis of fiscal and monetary policy', 4.0, 'Graduate'),

-- Electrical Engineering courses
(3, 'ELE1500', 'Circuit Theory', 'Fundamentals of electrical circuit analysis and design', 4.0, 'Freshman'),
(3, 'ELE2510', 'Digital Electronics', 'Design and analysis of digital electronic circuits', 4.0, 'Sophomore'),
(3, 'ELE3520', 'Power Systems Analysis', 'Analysis of electrical power generation and distribution systems', 4.0, 'Junior'),
(3, 'ELE4530', 'Telecommunications', 'Principles of telecommunications networks with practical applications', 4.0, 'Senior'),
(3, 'ELE5540', 'Renewable Energy Systems', 'Design and implementation of solar and wind power systems', 4.0, 'Graduate'),

-- African Languages courses
(4, 'AFL1500', 'Introduction to African Languages', 'Overview of major language families in Africa', 3.0, 'Freshman'),
(4, 'AFL2510', 'IsiZulu I', 'Beginning Zulu language and culture', 3.0, 'Freshman'),
(4, 'AFL2520', 'IsiXhosa I', 'Beginning Xhosa language and culture', 3.0, 'Freshman'),
(4, 'AFL3530', 'Advanced IsiZulu', 'Advanced Zulu language, literature and linguistics', 3.0, 'Junior'),
(4, 'AFL4540', 'African Language Linguistics', 'Comparative study of Bantu language structures', 3.0, 'Senior'),

-- Medical Sciences courses
(5, 'MED1500', 'Human Anatomy and Physiology', 'Structure and function of human body systems', 5.0, 'Freshman'),
(5, 'MED2600', 'Medical Biochemistry', 'Biochemical processes relevant to medicine', 5.0, 'Sophomore'),
(5, 'MED3700', 'Pathophysiology', 'Mechanisms of disease processes', 5.0, 'Junior'),
(5, 'MED4800', 'Clinical Medicine', 'Introduction to clinical practice and patient care', 6.0, 'Senior'),
(5, 'MED5900', 'Tropical Diseases', 'Diagnosis and treatment of diseases prevalent in Africa', 4.0, 'Graduate'),

-- Law courses
(6, 'LAW1500', 'Introduction to South African Law', 'Overview of South African legal system and history', 4.0, 'Freshman'),
(6, 'LAW2510', 'Constitutional Law', 'South African constitutional principles and cases', 4.0, 'Sophomore'),
(6, 'LAW3520', 'Human Rights Law', 'Legal framework for human rights in South Africa and Africa', 4.0, 'Junior'),
(6, 'LAW4530', 'Land Reform Law', 'Legal issues in South African land reform', 4.0, 'Senior'),
(6, 'LAW5540', 'International Law in African Context', 'Application of international law in African jurisdictions', 4.0, 'Graduate'),

-- Education courses
(7, 'EDU1500', 'Foundations of Education', 'Introduction to educational theories and practice', 4.0, 'Freshman'),
(7, 'EDU2510', 'South African Educational Systems', 'Structure and policy of education in South Africa', 4.0, 'Sophomore'),
(7, 'EDU3520', 'Curriculum Development', 'Theory and practice of curriculum design', 4.0, 'Junior'),
(7, 'EDU4530', 'Educational Technology', 'Integration of technology in teaching and learning', 4.0, 'Senior'),
(7, 'EDU5540', 'Education Policy Analysis', 'Critical analysis of educational policies', 4.0, 'Graduate'),

-- Environmental Sciences courses
(8, 'ENV1500', 'Environmental Science Fundamentals', 'Introduction to environmental science principles', 4.0, 'Freshman'),
(8, 'ENV2510', 'South African Ecosystems', 'Study of major ecosystems in South Africa', 4.0, 'Sophomore'),
(8, 'ENV3520', 'Conservation Biology', 'Principles and practice of biodiversity conservation', 4.0, 'Junior'),
(8, 'ENV4530', 'Environmental Impact Assessment', 'Methods and applications of EIA in South African context', 4.0, 'Senior'),
(8, 'ENV5540', 'Climate Change Adaptation', 'Strategies for climate change adaptation in southern Africa', 4.0, 'Graduate');

-- =============================================
-- POPULATE ACADEMIC YEARS
-- =============================================
INSERT INTO academic_years (year_name, start_date, end_date, is_current) VALUES
('2023', '2023-01-01', '2023-12-31', FALSE),
('2024', '2024-01-01', '2024-12-31', FALSE),
('2025', '2025-01-01', '2025-12-31', TRUE);

-- =============================================
-- POPULATE SEMESTERS
-- =============================================
INSERT INTO semesters (academic_year_id, semester_name, start_date, end_date, registration_start, registration_end, final_exam_start, final_exam_end, is_current) VALUES
-- 2023 semesters
(1, '2023 Semester 1', '2023-02-06', '2023-06-02', '2023-01-09', '2023-01-27', '2023-05-22', '2023-06-02', FALSE),
(1, '2023 Semester 2', '2023-07-17', '2023-11-17', '2023-06-19', '2023-07-07', '2023-11-06', '2023-11-17', FALSE),

-- 2024 semesters
(2, '2024 Semester 1', '2024-02-05', '2024-05-31', '2024-01-08', '2024-01-26', '2024-05-20', '2024-05-31', FALSE),
(2, '2024 Semester 2', '2024-07-15', '2024-11-15', '2024-06-17', '2024-07-05', '2024-11-04', '2024-11-15', FALSE),

-- 2025 semesters
(3, '2025 Semester 1', '2025-02-03', '2025-05-30', '2025-01-06', '2025-01-24', '2025-05-19', '2025-05-30', TRUE),
(3, '2025 Semester 2', '2025-07-14', '2025-11-14', '2025-06-16', '2025-07-04', '2025-11-03', '2025-11-14', FALSE);

-- =============================================
-- POPULATE STUDENTS
-- =============================================
INSERT INTO students (first_name, last_name, date_of_birth, gender, email, phone, address, city, state, country, postal_code, admission_date, major_department_id, student_type, status) VALUES
-- Computer Science students
('Thembeka', 'Ndlovu', '2002-05-15', 'Female', 'thembeka.ndlovu@student.uni.ac.za', '+27 71 123 4567', '123 Orlando West', 'Soweto', 'Gauteng', 'South Africa', '1804', '2022-01-15', 1, 'Undergraduate', 'Active'),
('Sibusiso', 'Tshabalala', '2001-09-23', 'Male', 'sibusiso.tshabalala@student.uni.ac.za', '+27 72 234 5678', '45 Auckland Park', 'Johannesburg', 'Gauteng', 'South Africa', '2092', '2021-01-20', 1, 'Undergraduate', 'Active'),
('Mpho', 'van Niekerk', '1997-11-30', 'Female', 'mpho.vanniekerk@student.uni.ac.za', '+27 73 345 6789', '78 Braamfontein', 'Johannesburg', 'Gauteng', 'South Africa', '2001', '2019-01-15', 1, 'Graduate', 'Active'),

-- Economics students
('Thabo', 'Modise', '2003-04-12', 'Male', 'thabo.modise@student.uni.ac.za', '+27 71 456 7890', '15 Diepkloof', 'Soweto', 'Gauteng', 'South Africa', '1862', '2022-01-15', 2, 'Undergraduate', 'Active'),
('Lerato', 'Sithole', '2002-07-25', 'Female', 'lerato.sithole@student.uni.ac.za', '+27 72 567 8901', '29 Northcliff', 'Johannesburg', 'Gauteng', 'South Africa', '2115', '2021-01-20', 2, 'Undergraduate', 'Active'),
('Thabiso', 'Mahlangu', '1998-03-18', 'Male', 'thabiso.mahlangu@student.uni.ac.za', '+27 73 678 9012', '56 Melville', 'Johannesburg', 'Gauteng', 'South Africa', '2092', '2019-01-15', 2, 'Graduate', 'Active'),

-- Electrical Engineering students
('Nokuthula', 'Zwane', '2001-12-05', 'Female', 'nokuthula.zwane@student.uni.ac.za', '+27 71 789 0123', '34 Alexandra', 'Johannesburg', 'Gauteng', 'South Africa', '2090', '2021-01-15', 3, 'Undergraduate', 'Active'),
('Andile', 'Mthembu', '2000-08-14', 'Male', 'andile.mthembu@student.uni.ac.za', '+27 72 890 1234', '67 Kensington', 'Johannesburg', 'Gauteng', 'South Africa', '2094', '2020-01-20', 3, 'Undergraduate', 'Active'),
('Bongani', 'Dlamini', '1997-06-22', 'Male', 'bongani.dlamini@student.uni.ac.za', '+27 73 901 2345', '89 Parktown', 'Johannesburg', 'Gauteng', 'South Africa', '2193', '2019-01-15', 3, 'Graduate', 'Active'),

-- African Languages students
('Nomvula', 'Mazibuko', '2002-02-28', 'Female', 'nomvula.mazibuko@student.uni.ac.za', '+27 71 012 3456', '12 Dobsonville', 'Soweto', 'Gauteng', 'South Africa', '1863', '2022-01-15', 4, 'Undergraduate', 'Active'),
('Themba', 'Nxumalo', '2001-05-17', 'Male', 'themba.nxumalo@student.uni.ac.za', '+27 72 123 4567', '43 Meadowlands', 'Soweto', 'Gauteng', 'South Africa', '1852', '2021-01-20', 4, 'Undergraduate', 'Active'),
('Nompumelelo', 'Khoza', '1998-09-03', 'Female', 'nompumelelo.khoza@student.uni.ac.za', '+27 73 234 5678', '78 Randburg', 'Johannesburg', 'Gauteng', 'South Africa', '2194', '2020-01-15', 4, 'Graduate', 'Active'),

-- Medical students
('Tumelo', 'Morake', '2000-01-20', 'Male', 'tumelo.morake@student.uni.ac.za', '+27 71 345 6789', '23 Orlando East', 'Soweto', 'Gauteng', 'South Africa', '1804', '2020-01-15', 5, 'Undergraduate', 'Active'),
('Zinhle', 'Ngwenya', '1999-07-12', 'Female', 'zinhle.ngwenya@student.uni.ac.za', '+27 72 456 7890', '56 Parktown North', 'Johannesburg', 'Gauteng', 'South Africa', '2193', '2019-01-20', 5, 'Undergraduate', 'Active'),
('Eric', 'Moloi', '1995-11-28', 'Male', 'eric.moloi@student.uni.ac.za', '+27 73 567 8901', '90 Rosebank', 'Johannesburg', 'Gauteng', 'South Africa', '2196', '2018-01-15', 5, 'Graduate', 'Active'),

-- Law students
('Palesa', 'Mokoena', '2001-08-09', 'Female', 'palesa.mokoena@student.uni.ac.za', '+27 71 678 9012', '45 Protea Glen', 'Soweto', 'Gauteng', 'South Africa', '1819', '2021-01-15', 6, 'Undergraduate', 'Active'),
('Tebogo', 'Molefe', '2000-04-15', 'Male', 'tebogo.molefe@student.uni.ac.za', '+27 72 789 0123', '12 Brixton', 'Johannesburg', 'Gauteng', 'South Africa', '2092', '2020-01-20', 6, 'Undergraduate', 'Active'),
('Nandi', 'Radebe', '1997-12-03', 'Female', 'nandi.radebe@student.uni.ac.za', '+27 73 890 1234', '78 Parkview', 'Johannesburg', 'Gauteng', 'South Africa', '2193', '2019-01-15', 6, 'Graduate', 'Active'),

-- Education students
('Katlego', 'Mogale', '2002-11-17', 'Male', 'katlego.mogale@student.uni.ac.za', '+27 71 901 2345', '34 Naledi', 'Soweto', 'Gauteng', 'South Africa', '1868', '2022-01-15', 7, 'Undergraduate', 'Active'),
('Nthabiseng', 'Makgoba', '2001-06-30', 'Female', 'nthabiseng.makgoba@student.uni.ac.za', '+27 72 012 3456', '56 Berea', 'Johannesburg', 'Gauteng', 'South Africa', '2198', '2021-01-20', 7, 'Undergraduate', 'Active'),
('Samuel', 'Tau', '1996-02-14', 'Male', 'samuel.tau@student.uni.ac.za', '+27 73 123 4567', '89 Yeoville', 'Johannesburg', 'Gauteng', 'South Africa', '2198', '2018-01-15', 7, 'Graduate', 'Active'),

-- Environmental Sciences students
('Zanele', 'Vilakazi', '2003-03-05', 'Female', 'zanele.vilakazi@student.uni.ac.za', '+27 71 234 5678', '12 Newlands', 'Cape Town', 'Western Cape', 'South Africa', '7700', '2022-01-15', 8, 'Undergraduate', 'Active'),
('Sizwe', 'Nkomo', '2002-08-22', 'Male', 'sizwe.nkomo@student.uni.ac.za', '+27 72 345 6789', '45 Observatory', 'Cape Town', 'Western Cape', 'South Africa', '7925', '2021-01-20', 8, 'Undergraduate', 'Active'),
('Ayanda', 'Mokwena', '1998-05-11', 'Female', 'ayanda.mokwena@student.uni.ac.za', '+27 73 456 7890', '78 Rondebosch', 'Cape Town', 'Western Cape', 'South Africa', '7700', '2019-01-15', 8, 'Graduate', 'Active');

-- =============================================
-- POPULATE COURSE OFFERINGS
-- =============================================
INSERT INTO course_offerings (course_id, semester_id, faculty_id, section_number, room_location, schedule, max_capacity, current_enrollment, status) VALUES
-- 2025 Semester 1 offerings
-- Computer Science courses
(1, 5, 3, 'SEC-01', 'IT Building Room 101', 'Mon, Wed, Fri 09:00-10:30', 40, 38, 'In Progress'),
(2, 5, 2, 'SEC-01', 'IT Building Room 102', 'Tue, Thu 10:00-12:00', 35, 30, 'In Progress'),
(3, 5, 1, 'SEC-01', 'IT Building Room 103', 'Mon, Wed 13:00-15:00', 30, 28, 'In Progress'),
(4, 5, 1, 'SEC-01', 'IT Building Room 204', 'Tue, Thu 14:00-16:00', 25, 20, 'In Progress'),
(5, 5, 2, 'SEC-01', 'Computer Lab 3', 'Wed 16:00-19:00', 20, 15, 'In Progress'),

-- Economics courses
(6, 5, 6, 'SEC-01', 'Commerce Building Room 201', 'Mon, Wed, Fri 08:00-09:30', 45, 40, 'In Progress'),
(7, 5, 5, 'SEC-01', 'Commerce Building Room 202', 'Tue, Thu 09:00-11:00', 40, 35, 'In Progress'),
(8, 5, 4, 'SEC-01', 'Commerce Building Room 203', 'Mon, Wed 11:00-13:00', 35, 30, 'In Progress'),
(9, 5, 4, 'SEC-01', 'Commerce Building Room 304', 'Tue, Thu 13:00-15:00', 30, 25, 'In Progress'),
(10, 5, 5, 'SEC-01', 'Commerce Building Room 305', 'Fri 13:00-16:00', 25, 20, 'In Progress'),

-- Electrical Engineering courses
(11, 5, 9, 'SEC-01', 'Engineering Block B Room 101', 'Mon, Wed, Fri 08:30-10:00', 35, 32, 'In Progress'),
(12, 5, 8, 'SEC-01', 'Engineering Block B Room 102', 'Tue, Thu 10:30-12:30', 30, 28, 'In Progress'),
(13, 5, 7, 'SEC-01', 'Engineering Block B Room 203', 'Mon, Wed 14:00-16:00', 25, 23, 'In Progress'),
(14, 5, 7, 'SEC-01', 'Engineering Block B Room 204', 'Tue, Thu 14:30-16:30', 25, 22, 'In Progress'),
(15, 5, 8, 'SEC-01', 'Engineering Lab 3', 'Fri 09:00-12:00', 20, 15, 'In Progress'),

-- African Languages courses
(16, 5, 12, 'SEC-01', 'Humanities Building Room 101', 'Mon, Wed, Fri 10:00-11:30', 30, 25, 'In Progress'),
(17, 5, 11, 'SEC-01', 'Humanities Building Room 102', 'Tue, Thu 08:00-10:00', 30, 28, 'In Progress'),
(18, 5, 10, 'SEC-01', 'Humanities Building Room 103', 'Mon, Wed 12:00-14:00', 25, 22, 'In Progress'),
(19, 5, 10, 'SEC-01', 'Humanities Building Room 104', 'Tue, Thu 13:00-15:00', 25, 20, 'In Progress'),
(20, 5, 11, 'SEC-01', 'Humanities Building Room 205', 'Fri 14:00-17:00', 20, 18, 'In Progress'),

-- Medical Sciences courses
(21, 5, 15, 'SEC-01', 'Health Sciences Building Room 101', 'Mon, Wed, Fri 08:00-10:00', 40, 40, 'In Progress'),
(22, 5, 15, 'SEC-01', 'Health Sciences Building Room 102', 'Tue, Thu 10:00-13:00', 35, 35, 'In Progress'),
(23, 5, 15, 'SEC-01', 'Health Sciences Lab 1', 'Mon, Wed 14:00-17:00', 30, 30, 'In Progress'),
(24, 5, 15, 'SEC-01', 'Clinical Training Room 1', 'Tue, Thu 14:00-17:00', 25, 25, 'In Progress'),
(25, 5, 15, 'SEC-01', 'Medical Research Lab', 'Fri 14:00-18:00', 15, 15, 'In Progress'),

-- Law courses
(26, 5, 16, 'SEC-01', 'Law Building Room 101', 'Mon, Wed, Fri 09:30-11:00', 45, 43, 'In Progress'),
(27, 5, 16, 'SEC-01', 'Law Building Room 102', 'Tue, Thu 11:30-13:30', 40, 38, 'In Progress'),
(28, 5, 16, 'SEC-01', 'Law Building Room 203', 'Mon, Wed 15:00-17:00', 35, 33, 'In Progress'),
(29, 5, 16, 'SEC-01', 'Law Building Room 204', 'Tue, Thu 15:30-17:30', 30, 28, 'In Progress'),
(30, 5, 16, 'SEC-01', 'Moot Court Room', 'Fri 13:30-16:30', 25, 23, 'In Progress'),

-- Education courses
(31, 5, 17, 'SEC-01', 'Education Block Room 101', 'Mon, Wed, Fri 08:30-10:00', 40, 38, 'In Progress'),
(32, 5, 17, 'SEC-01', 'Education Block Room 102', 'Tue, Thu 10:30-12:30', 35, 33, 'In Progress'),
(33, 5, 17, 'SEC-01', 'Education Block Room 203', 'Mon, Wed 13:30-15:30', 30, 28, 'In Progress'),
(34, 5, 17, 'SEC-01', 'Education Block Room 204', 'Tue, Thu 14:00-16:00', 30, 27, 'In Progress'),
(35, 5, 17, 'SEC-01', 'Teaching Lab', 'Fri 10:00-13:00', 25, 20, 'In Progress'),

-- Environmental Sciences courses
(36, 5, 18, 'SEC-01', 'Science Block Room 101', 'Mon, Wed, Fri 09:00-10:30', 35, 32, 'In Progress'),
(37, 5, 18, 'SEC-01', 'Science Block Room 102', 'Tue, Thu 11:00-13:00', 30, 28, 'In Progress'),
(38, 5, 18, 'SEC-01', 'Science Block Room 203', 'Mon, Wed 14:30-16:30', 25, 23, 'In Progress'),
(39, 5, 18, 'SEC-01', 'Science Block Room 204', 'Tue, Thu 15:00-17:00', 25, 22, 'In Progress'),
(40, 5, 18, 'SEC-01', 'Environmental Lab', 'Fri 13:00-16:00', 20, 18, 'In Progress');

-- =============================================
-- POPULATE ASSESSMENTS
-- =============================================

-- Computer Science assessments
INSERT INTO assessments (offering_id, assessment_name, assessment_type, max_score, weight_percentage, due_date, description)
VALUES
(1, 'Python Basics Quiz', 'Quiz', 20.0, 10.0, '2025-02-25 09:00:00', 'Basic Python syntax and concepts'),
(1, 'Assignment 1: Problem Solving', 'Assignment', 50.0, 15.0, '2025-03-15 23:59:59', 'Implementing algorithms in Python'),
(1, 'Midterm Exam', 'Midterm', 100.0, 30.0, '2025-03-30 09:00:00', 'Comprehensive exam on first half material'),
(1, 'Final Project', 'Project', 100.0, 25.0, '2025-05-10 23:59:59', 'Build a complete application using Python'),
(1, 'Final Exam', 'Final', 100.0, 20.0, '2025-05-25 09:00:00', 'Comprehensive exam on all course material');

-- Economics assessments
INSERT INTO assessments (offering_id, assessment_name, assessment_type, max_score, weight_percentage, due_date, description)
VALUES
(6, 'Microeconomics Quiz', 'Quiz', 20.0, 10.0, '2025-02-20 08:00:00', 'Basic supply and demand concepts'),
(6, 'Case Study Analysis', 'Assignment', 50.0, 15.0, '2025-03-10 23:59:59', 'Analysis of South African economic case'),
(6, 'Midterm Exam', 'Midterm', 100.0, 30.0, '2025-03-28 08:00:00', 'Comprehensive exam on first half material'),
(6, 'Economic Policy Paper', 'Project', 100.0, 25.0, '2025-05-05 23:59:59', 'Research paper on economic policy'),
(6, 'Final Exam', 'Final', 100.0, 20.0, '2025-05-24 08:00:00', 'Comprehensive exam on all course material');

-- Electrical Engineering assessments
INSERT INTO assessments (offering_id, assessment_name, assessment_type, max_score, weight_percentage, due_date, description)
VALUES
(11, 'Circuit Fundamentals Quiz', 'Quiz', 20.0, 10.0, '2025-02-23 08:30:00', 'Basic circuit analysis concepts'),
(11, 'Circuit Design Lab', 'Lab', 50.0, 15.0, '2025-03-12 23:59:59', 'Practical circuit design and analysis'),
(11, 'Midterm Exam', 'Midterm', 100.0, 30.0, '2025-03-26 08:30:00', 'Comprehensive exam on first half material'),
(11, 'Circuit Simulation Project', 'Project', 100.0, 25.0, '2025-05-08 23:59:59', 'Design and simulation of electronic circuits'),
(11, 'Final Exam', 'Final', 100.0, 20.0, '2025-05-23 08:30:00', 'Comprehensive exam on all course material');

-- African Languages assessments
INSERT INTO assessments (offering_id, assessment_name, assessment_type, max_score, weight_percentage, due_date, description)
VALUES
(16, 'Language Families Quiz', 'Quiz', 20.0, 10.0, '2025-02-22 10:00:00', 'African language classification'),
(16, 'Cultural Context Assignment', 'Assignment', 50.0, 15.0, '2025-03-14 23:59:59', 'Research on language and cultural context'),
(16, 'Midterm Exam', 'Midterm', 100.0, 30.0, '2025-03-29 10:00:00', 'Comprehensive exam on first half material'),
(16, 'Language Analysis Project', 'Project', 100.0, 25.0, '2025-05-09 23:59:59', 'Analysis of an African language structure'),
(16, 'Final Exam', 'Final', 100.0, 20.0, '2025-05-26 10:00:00', 'Comprehensive exam on all course material');

-- =============================================
-- POPULATE ASSESSMENT RESULTS
-- =============================================

-- Computer Science assessment results (for student 1)
INSERT INTO assessment_results (assessment_id, enrollment_id, score, submitted_date, feedback)
VALUES
(1, 1, 18.5, '2025-02-25 08:45:00', 'Excellent understanding of basic concepts'),
(2, 1, 45.0, '2025-03-14 22:30:00', 'Good problem-solving approach but could improve code efficiency');

-- Economics assessment results (for student 4)
INSERT INTO assessment_results (assessment_id, enrollment_id, score, submitted_date, feedback)
VALUES
(6, 7, 17.0, '2025-02-20 07:45:00', 'Good grasp of microeconomics principles'),
(7, 7, 42.5, '2025-03-09 20:15:00', 'Well-researched case study with strong analysis');

-- Electrical Engineering assessment results (for student 7)
INSERT INTO assessment_results (assessment_id, enrollment_id, score, submitted_date, feedback)
VALUES
(11, 13, 19.0, '2025-02-23 08:20:00', 'Exceptional understanding of circuit fundamentals'),
(12, 13, 48.0, '2025-03-11 21:00:00', 'Excellent lab work with clear documentation');

-- African Languages assessment results (for student 10)
INSERT INTO assessment_results (assessment_id, enrollment_id, score, submitted_date, feedback)
VALUES
(16, 19, 16.5, '2025-02-22 09:45:00', 'Good knowledge of language classifications'),
(17, 19, 44.0, '2025-03-13 23:00:00', 'Well-researched cultural context paper');

-- =============================================
-- POPULATE ATTENDANCE
-- =============================================

-- Computer Science attendance for student 1
INSERT INTO attendance (enrollment_id, attendance_date, status, comment)
VALUES
(1, '2025-02-10', 'Present', NULL),
(1, '2025-02-12', 'Present', NULL),
(1, '2025-02-14', 'Present', NULL),
(1, '2025-02-17', 'Absent', 'Sick - provided medical certificate'),
(1, '2025-02-19', 'Present', NULL),
(1, '2025-02-21', 'Present', NULL),
(1, '2025-02-24', 'Present', NULL),
(1, '2025-02-26', 'Late', 'Arrived 15 minutes late');

-- Economics attendance for student 4
INSERT INTO attendance (enrollment_id, attendance_date, status, comment)
VALUES
(7, '2025-02-10', 'Present', NULL),
(7, '2025-02-12', 'Present', NULL),
(7, '2025-02-14', 'Present', NULL),
(7, '2025-02-17', 'Present', NULL),
(7, '2025-02-19', 'Absent', 'Family emergency'),
(7, '2025-02-21', 'Present', NULL),
(7, '2025-02-24', 'Present', NULL),
(7, '2025-02-26', 'Present', NULL);

-- =============================================
-- POPULATE ACADEMIC RECORDS
-- =============================================

-- Computer Science students' academic records
INSERT INTO academic_records (student_id, semester_id, gpa, credits_attempted, credits_earned, academic_standing)
VALUES
(1, 4, 3.65, 16.0, 16.0, 'Good Standing'),
(2, 4, 3.82, 16.0, 16.0, 'Good Standing'),
(3, 4, 3.75, 12.0, 12.0, 'Good Standing');

-- Economics students' academic records
INSERT INTO academic_records (student_id, semester_id, gpa, credits_attempted, credits_earned, academic_standing)
VALUES
(4, 4, 3.50, 16.0, 16.0, 'Good Standing'),
(5, 4, 3.25, 16.0, 16.0, 'Good Standing'),
(6, 4, 3.90, 12.0, 12.0, 'Good Standing');


-- =============================================
-- POPULATE EXTRACURRICULAR ACTIVITIES
-- =============================================

INSERT INTO extracurricular_activities (activity_name, activity_type, description, faculty_advisor_id)
VALUES
('Computer Science Society', 'Club', 'Student organization for computer science enthusiasts', 1),
('Economics Club', 'Club', 'Discussion forum for economics students', 4),
('Electrical Engineering Society', 'Club', 'Organization for electrical engineering students', 7),
('Zulu Language and Cultural Society', 'Club', 'Promoting Zulu language and cultural heritage', 10),
('Student Medical Association', 'Organization', 'Professional development for medical students', 15),
('Moot Court Society', 'Organization', 'Legal debate and advocacy practice', 16),
('Future Teachers of South Africa', 'Organization', 'Professional development for education students', 17),
('Environmental Conservation Club', 'Club', 'Promoting environmental awareness and conservation', 18),
('University Rugby Team', 'Sport', 'Competitive university rugby team', 3),
('University Choir', 'Organization', 'Award-winning university choir performing African music', 11),
('Community Outreach Program', 'Volunteer', 'Volunteering in local communities around Johannesburg', 17),
('Tech Innovation Hub', 'Organization', 'Technology entrepreneurship and innovation center', 2);

-- =============================================
-- POPULATE STUDENT ACTIVITIES
-- =============================================

INSERT INTO student_activities (student_id, activity_id, join_date, end_date, role, achievements)
VALUES
(1, 1, '2022-02-15', NULL, 'Secretary', 'Organized annual coding competition'),
(2, 1, '2021-03-10', NULL, 'Member', 'Participated in national hackathon'),
(3, 1, '2019-02-20', NULL, 'Chairperson', 'Led team to win regional coding challenge'),
(4, 2, '2022-02-10', NULL, 'Treasurer', 'Managed club budget effectively'),
(5, 2, '2021-02-25', NULL, 'Member', 'Participated in economic policy debate'),
(7, 3, '2021-03-05', NULL, 'Vice-Chair', 'Organized engineering careers fair'),
(10, 4, '2022-02-20', NULL, 'Cultural Officer', 'Organized Zulu cultural festival'),
(13, 5, '2020-03-15', NULL, 'Secretary', 'Organized medical outreach programs'),
(16, 6, '2021-02-28', NULL, 'Competition Coordinator', 'Led team to finals in national moot court'),
(19, 7, '2022-03-10', NULL, 'Outreach Coordinator', 'Developed tutoring program for township schools'),
(22, 8, '2022-02-15', NULL, 'Projects Coordinator', 'Led campus recycling initiative'),
(2, 9, '2021-04-05', NULL, 'Team Member', 'Provincial tournament finalist'),
(11, 10, '2021-03-20', NULL, 'Choir Member', 'Performed at national arts festival'),
(20, 11, '2021-05-10', NULL, 'Program Coordinator', 'Organized literacy program for local schools'),
(3, 12, '2019-04-15', NULL, 'Innovation Lead', 'Developed award-winning student app');

-- End of South African sample data