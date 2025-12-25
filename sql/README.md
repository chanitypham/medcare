# Database Setup Guide

Complete step-by-step instructions to set up the MedCare database.

---

## Directory Structure

```
sql/
├── README.md (this file)
├── schema/          Tables & indexes
├── views/           Reporting views (6 files)
├── procedures/      Business logic (2 files)
├── triggers/        Data integrity (3 files)
├── seed/            Sample data
├── queries/         Query templates
└── mutations/       Update templates
```

---

## 🔧 Detailed Steps

### Step 1: Create Database

Connect to MySQL from the project root directory:

```bash
mysql -u root -p
```

Then create the database:

```sql
CREATE DATABASE medcare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medcare_db;
```

**Alternative - MySQL Workbench**:

1. Right-click → Create Schema
2. Name: `medcare_db`
3. Charset: `utf8mb4`, Collation: `utf8mb4_unicode_ci`

---

### Step 2: Create Tables

**⚠️ IMPORTANT**: Run in this exact order (dependency order):

```sql
-- Base tables (no dependencies)
SOURCE sql/schema/create_users.sql;
SOURCE sql/schema/create_medications.sql;

-- Dependent tables
SOURCE sql/schema/create_diagnosis.sql;
SOURCE sql/schema/create_prescription_item.sql;
```

**What each creates**:

- `users`: Clerk-integrated authentication (7 columns)
- `medications`: Medication catalog with inventory (7 columns)
- `diagnosis`: Medical consultations (8 columns, 2 FKs to users)
- `prescription_item`: Junction table (8 columns, 2 FKs)

---

### Step 3: Create Indexes

```sql
SOURCE sql/schema/create_indexes.sql;
```

Creates **12 indexes** for performance:

- Users: 3 indexes (nid_number, phone, role)
- Diagnosis: 5 indexes (patient_id, doctor_id, date, composites)
- Medications: 2 indexes (name, stock_quantity)
- Prescription_item: 2 indexes (diagnosis_id, medication_id)

---

### Step 4: Create Views

```sql
SOURCE sql/views/vw_DoctorPatientVisits.sql;
SOURCE sql/views/vw_LowStockMedications.sql;
SOURCE sql/views/vw_MedicationPopularity.sql;
SOURCE sql/views/vw_PatientDiagnosisHistory.sql;
SOURCE sql/views/vw_PrescriptionDetails.sql;
SOURCE sql/views/vw_TodayDiagnoses.sql;
```

---

### Step 5: Create Procedures & Triggers

```sql
-- Procedures
SOURCE sql/procedures/sp_AddDiagnosis.sql;
SOURCE sql/procedures/sp_AddPrescriptionItem.sql;

-- Triggers
SOURCE sql/triggers/trg_AfterInsert_PrescriptionItem.sql;
SOURCE sql/triggers/trg_Prevent_Diagnosis_Deletion.sql;
SOURCE sql/triggers/trg_Prevent_Prescription_Deletion.sql;
SOURCE sql/triggers/trg_Check_DoctorPatient_insert.sql;
SOURCE sql/triggers/trg_Check_DoctorPatient_update.sql;
```

---

## 🧪 Load Sample Data (Optional)

**Prerequisites**:

1. Create 2 users via web app (1 doctor, 1 patient)
2. Complete onboarding (remember your NIDs)
3. Edit `sql/seed/seed_all.sql`:
   ```sql
   SET @DOCTOR_NID = 'your_doctor_nid';
   SET @PATIENT_NID = 'your_patient_nid';
   ```

**Run** (inside MySQL shell):

```sql
SOURCE sql/seed/seed_all.sql;
```

Loads: 15 medications | 8 diagnoses | 12 prescription items

---

## ✅ Verification

```sql
SELECT
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'medcare_db' AND TABLE_TYPE = 'BASE TABLE') AS tables,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = 'medcare_db' AND INDEX_NAME != 'PRIMARY') AS indexes,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'medcare_db') AS views,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'medcare_db' AND ROUTINE_TYPE = 'PROCEDURE') AS procedures,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = 'medcare_db') AS triggers;
```

**Expected**: Tables: 4 | Indexes: 16 (including 12 created and 4 PRIMARY) | Views: 6 | Procedures: 2 | Triggers: 5

---

## 🔄 Reset Database

Inside MySQL shell:

```sql
DROP DATABASE IF EXISTS medcare_db;
-- Then repeat setup from Step 1
```

---

## 📚 Next Steps

1. **Configure App**: Update `.env` with database credentials
2. **Create Users**: Sign up via web app
3. **Test**: See [`docs/testing.md`](../docs/testing.md)

For detailed schema documentation, see [`docs/database.md`](../docs/database.md)
