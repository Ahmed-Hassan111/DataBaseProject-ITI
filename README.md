# 🎓 Examination System Database

A comprehensive SQL Server database solution for managing educational examinations, students, instructors, courses, and academic performance tracking.

![SQL Server](https://img.shields.io/badge/SQL%20Server-2019%2B-red?logo=microsoft-sql-server)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

---

## 📌 Overview

This project implements a full-featured examination management system using advanced SQL Server capabilities including:

✅ **Stored Procedures** – CRUD operations for all entities  
✅ **User-Defined Functions** – Auto-grading, age calculation, ranking  
✅ **Views** – Pre-built reports for analytics and dashboards  
✅ **Triggers** – Business logic enforcement (auto-grade, time locks, overlap prevention)  
✅ **Role-Based Security** – 4 user roles with granular permissions  

---

## 🚀 Key Features

| Feature | Description |
|---------|-------------|
| 🔐 **RBAC Security** | Admin, Instructor, Manager, Student roles with encrypted procedures |
| 🤖 **Auto-Grading** | Automatic scoring for MCQ/TrueFalse questions via triggers |
| 🎲 **Random Exam Generation** | Create exams by pulling random questions from question pool |
| 📊 **Performance Analytics** | Views for rankings, pass rates, students at risk, course stats |
| ⏱️ **Time Validation** | Prevent answers after exam ends; block scheduling conflicts |
| 📝 **Audit Logging** | Track all grade changes with user and timestamp |

---

## 🗄️ Core Tables
Student ── StuExam ── Exam ── Course
   │           │         │
   │           │         └─ QuestionPool
   │           │
   └─ StAnswer (with auto-grading)

   
**Main Entities**: Student, Instructor, Course, Exam, QuestionPool, Department, Intake, Branch, User
<img width="1598" height="800" alt="Diagram" src="https://github.com/user-attachments/assets/448c1c4a-4cad-4fd9-a9dc-4865fc70b762" />
ERD + Mapping
![ERD+Mapping](https://github.com/user-attachments/assets/354091b7-5fde-4069-92b7-0f205d1971be)


---

## ⚡ Quick Start

```sql
-- 1. Create database & tables
:r Creation_Database.sql
:r Creation_Tables.sql

-- 2. Deploy objects
:r StoredProcedures.sql
:r Functions.sql
:r Views.sql
:r Triggers.sql
:r Roles.sql

-- 3. Load sample data
:r Insertion.sql

-- 4. Test
EXEC GetSelectStudent;
SELECT dbo.fn_CalculateAge('2000-01-15');
SELECT * FROM vw_CoursePerformanceSummary;

🔐 Security Roles
Role
	
Admin	
Full access (db_owner)

Instructor
Read students, grade exams, view reports

Manager
View all data, manage intakes/branches

Student
View own results via secured views/functions

📦 Project Structure
├── Creation_Database.sql      # Database setup
├── Creation_Tables.sql        # Tables & constraints
├── Insertion.sql              # Sample data
├── StoredProcedures.sql       # CRUD & business logic SPs
├── Functions.sql              # Scalar functions (grading, ranking)
├── Views.sql                  # Reporting views
├── Triggers.sql               # Automation & validation
├── Roles.sql                  # Users, roles, permissions
└── README.md                  # This file

Database: Microsoft SQL Server 2019+
Tools: SSMS, T-SQL
Security: Logins, Users, Roles, WITH ENCRYPTION, DENY/GRANT
Best Practices: Transactions, error handling, SET NOCOUNT ON
