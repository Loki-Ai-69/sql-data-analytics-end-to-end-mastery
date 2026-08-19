-- ============================================================================
-- CASE STUDY 02: APOLLO HOSPITALS ANALYTICS & HEALTH METRICS
-- MODULE: Class 5 to Class 7 Master Analysis Script
-- TARGET DBMS: PostgreSQL / Standard SQL
-- ============================================================================

/*
   ============================================================================
   MODULE OVERVIEW & COVERED CONCEPTS:
   ============================================================================
   CLASS 5: Aggregate Functions (MIN, MAX, SUM, AVG, COUNT),
            COUNT(*) vs COUNT(1) vs COUNT(col) vs COUNT(DISTINCT col),
            Introduction to GROUP BY Clause & Execution Order
   CLASS 6: Grouping Sets, Multi-Column Grouping & Conditional Aggregation
   CLASS 7: Advanced Grouping, HAVING Clause (Filtering Post-Aggregation),
            WHERE vs HAVING Differences, Multi-Condition HAVING Logic
   ============================================================================
*/


-- ============================================================================
-- SECTION 1: AGGREGATE FUNCTIONS & BASIC SUMMARIZATION (CLASS 5)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q1.1: Determine the age range (youngest and oldest) of admitted patients.
-- Topic: MIN() & MAX() Aggregate Functions
-- ----------------------------------------------------------------------------
SELECT  
    MIN(age) AS min_age, 
    MAX(age) AS max_age 
FROM hospital_admissions;

-- ----------------------------------------------------------------------------
-- Q1.2: What is the average BMI (Body Mass Index) of patients diagnosed with 'Obesity'?
-- Topic: AVG() with WHERE Filtering
-- ----------------------------------------------------------------------------
SELECT 
    ROUND(AVG(bmi)::numeric, 2) AS avg_bmi 
FROM hospital_admissions 
WHERE medical_condition = 'Obesity';

-- ----------------------------------------------------------------------------
-- Q1.3: How many patients' records do we have in our database?
-- Topic: COUNT(*) Aggregation
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_patients 
FROM hospital_admissions;

-- ----------------------------------------------------------------------------
-- Q1.4: What are the various medical conditions listed in our database?
-- Topic: SELECT DISTINCT / COUNT(DISTINCT)
-- ----------------------------------------------------------------------------
-- List of all unique conditions:
SELECT DISTINCT 
    medical_condition 
FROM hospital_admissions;

-- Count of unique conditions:
SELECT 
    COUNT(DISTINCT medical_condition) AS unique_conditions_count 
FROM hospital_admissions;



-- ============================================================================
-- SECTION 2: GROUP BY CLAUSE & DISTRIBUTION ANALYSIS (CLASS 5 & 6)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q2.1: What is the distribution of patients' ages across the data?
-- Topic: Single Column GROUP BY & Sorting
-- ----------------------------------------------------------------------------
SELECT 
    age,
    COUNT(*) AS patient_count
FROM hospital_admissions
GROUP BY age
ORDER BY age ASC;

-- ----------------------------------------------------------------------------
-- Q2.2: How do billing amounts vary based on the patient's insurance provider?
-- Topic: SUM(), AVG(), MIN(), MAX() with GROUP BY
-- ----------------------------------------------------------------------------
SELECT 
    insurance_provider,
    COUNT(*) AS total_claims,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    SUM(billing_amount) AS total_claimed_amount,
    MIN(billing_amount) AS min_billing_amount,
    MAX(billing_amount) AS max_billing_amount
FROM hospital_admissions
GROUP BY insurance_provider
ORDER BY total_claimed_amount DESC;

-- ----------------------------------------------------------------------------
-- Q2.3: Analyze and compare the average duration of hospitalization for various medical conditions.
-- Topic: AVG() on Days Hospitalized with GROUP BY
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition,
    ROUND(AVG(days_hospitalised), 1) AS avg_hospital_stay_days,
    MIN(days_hospitalised) AS min_stay_days,
    MAX(days_hospitalised) AS max_stay_days
FROM hospital_admissions
GROUP BY medical_condition
ORDER BY avg_hospital_stay_days DESC;

-- ----------------------------------------------------------------------------
-- Q2.4: Calculate the average billing amount for cancer patients in each hospital.
-- Topic: WHERE Filtering combined with GROUP BY
-- ----------------------------------------------------------------------------
SELECT 
    hospital,
    COUNT(*) AS cancer_patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_cancer_billing
FROM hospital_admissions
WHERE LOWER(medical_condition) = 'cancer'
GROUP BY hospital
ORDER BY avg_cancer_billing DESC;

-- ----------------------------------------------------------------------------
-- Q2.5: How are the different blood types distributed among patients with diabetes?
-- Topic: GROUP BY on Specific Sub-category
-- ----------------------------------------------------------------------------
SELECT 
    blood_type,
    COUNT(*) AS patient_count
FROM hospital_admissions
WHERE LOWER(medical_condition) = 'diabetes'
GROUP BY blood_type
ORDER BY patient_count DESC;

-- ----------------------------------------------------------------------------
-- Q2.6: What percentage of patients are diagnosed with each medical condition?
-- Topic: Subquery inside SELECT for Overall Percentage Calculation
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition,
    COUNT(*) AS patient_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hospital_admissions)), 2) || '%' AS percentage_patients
FROM hospital_admissions
GROUP BY medical_condition
ORDER BY COUNT(*) DESC;

-- ----------------------------------------------------------------------------
-- Q2.7: What is the gender ratio (male to female) for each medical condition?
-- Topic: Conditional Aggregation using CASE WHEN inside SUM()
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition,
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
    CASE 
        WHEN SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) > 0 
        THEN ROUND(
            SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END)::numeric / 
            NULLIF(SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END), 0), 2)
        ELSE NULL 
    END AS male_to_female_ratio
FROM hospital_admissions
GROUP BY medical_condition;



-- ============================================================================
-- SECTION 3: TOP-N DEMOGRAPHIC & CLINICAL INSIGHTS (CLASS 7)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q3.1: Identify the top 3 preferred insurance providers among patients.
-- Topic: GROUP BY, ORDER BY DESC, LIMIT
-- ----------------------------------------------------------------------------
SELECT 
    insurance_provider, 
    COUNT(*) AS patient_count 
FROM hospital_admissions
GROUP BY insurance_provider
ORDER BY patient_count DESC
LIMIT 3;

-- ----------------------------------------------------------------------------
-- Q3.2: Find the most common medical conditions among senior patients (Age >= 60).
-- Topic: Filtering with WHERE before GROUP BY
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition, 
    COUNT(*) AS patient_count 
FROM hospital_admissions
WHERE age >= 60
GROUP BY medical_condition
ORDER BY patient_count DESC
LIMIT 3;

-- ----------------------------------------------------------------------------
-- Q3.3: Count universal donors (O-) and universal recipients (AB+) patients.
-- Topic: IN Operator with Grouped Aggregation
-- ----------------------------------------------------------------------------
SELECT 
    blood_type, 
    COUNT(*) AS patient_count 
FROM hospital_admissions
WHERE blood_type IN ('O-', 'AB+')
GROUP BY blood_type;

-- ----------------------------------------------------------------------------
-- Q3.4: Classify patients into BMI health categories and get category counts.
-- Topic: CASE WHEN in SELECT & Grouping by Column Position / Derived Expression
-- ----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN bmi < 20 THEN 'Underweight'
        WHEN bmi BETWEEN 20 AND 25 THEN 'Normal Weight'
        WHEN bmi BETWEEN 25 AND 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    COUNT(*) AS patient_count
FROM hospital_admissions
GROUP BY 1
ORDER BY patient_count ASC;

-- ----------------------------------------------------------------------------
-- Q3.5: Identify the ethnic group most susceptible to Cancer.
-- Topic: Filtering String Conditions with LOWER() & Ranking
-- ----------------------------------------------------------------------------
SELECT 
    ethnicity, 
    COUNT(*) AS cancer_patient_count 
FROM hospital_admissions 
WHERE LOWER(medical_condition) = 'cancer'
GROUP BY ethnicity
ORDER BY cancer_patient_count DESC
LIMIT 1;

-- ----------------------------------------------------------------------------
-- Q3.6: Find prescription counts for medical conditions and medication pairs.
-- Topic: Multi-Column GROUP BY (medical_condition, medication)
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition, 
    medication, 
    COUNT(*) AS prescription_count 
FROM hospital_admissions
GROUP BY medical_condition, medication
ORDER BY prescription_count DESC;



-- ============================================================================
-- SECTION 4: POST-AGGREGATION FILTERING WITH HAVING CLAUSE (CLASS 7)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q4.1: Identify doctors who have treated more than 10 unique patients.
-- Topic: HAVING with COUNT(DISTINCT col)
-- ----------------------------------------------------------------------------
SELECT 
    doctor, 
    COUNT(DISTINCT name) AS number_of_patients 
FROM hospital_admissions
GROUP BY doctor
HAVING COUNT(DISTINCT name) > 10
ORDER BY number_of_patients DESC;

-- ----------------------------------------------------------------------------
-- Q4.2: Conditions with Avg Stay > 15 days AND Max Billing > $25,000.
-- Topic: HAVING with Multiple Aggregate Conditions (AND)
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition, 
    ROUND(AVG(days_hospitalised)) AS avg_hospitalisation_days,
    MAX(billing_amount) AS max_billing_amount 
FROM hospital_admissions
GROUP BY medical_condition
HAVING AVG(days_hospitalised) > 15 
   AND MAX(billing_amount) > 25000;

-- ----------------------------------------------------------------------------
-- Q4.3: Hospitals where average billing exceeds the overall average by 50%.
-- Topic: HAVING with Scalar Subquery Aggregation
-- ----------------------------------------------------------------------------
SELECT 
    hospital, 
    ROUND(AVG(billing_amount), 2) AS avg_hospital_billing 
FROM hospital_admissions
GROUP BY hospital
HAVING AVG(billing_amount) > (
    SELECT AVG(billing_amount) * 1.5 
    FROM hospital_admissions
);

-- ----------------------------------------------------------------------------
-- Q4.4: Show conditions where total Emergency billing is LESS than Elective billing.
-- Topic: Conditional SUM() inside HAVING Clause
-- ----------------------------------------------------------------------------
SELECT 
    medical_condition, 
    SUM(CASE WHEN admission_type = 'Emergency' THEN billing_amount ELSE 0 END) AS emergency_billing,
    SUM(CASE WHEN admission_type = 'Elective' THEN billing_amount ELSE 0 END) AS elective_billing
FROM hospital_admissions
GROUP BY medical_condition
HAVING SUM(CASE WHEN admission_type = 'Emergency' THEN billing_amount ELSE 0 END) <
       SUM(CASE WHEN admission_type = 'Elective' THEN billing_amount ELSE 0 END)
ORDER BY medical_condition;

-- ----------------------------------------------------------------------------
-- Q4.5: Doctors treating >= 3 Cancer patients with Average Billing > $25,000.
-- Topic: Combining WHERE (Row Filtering) and HAVING (Group Filtering)
-- ----------------------------------------------------------------------------
SELECT 
    doctor, 
    COUNT(*) AS cancer_patient_count, 
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount 
FROM hospital_admissions
WHERE medical_condition = 'Cancer'
GROUP BY doctor
HAVING COUNT(*) >= 3 
   AND AVG(billing_amount) > 25000
ORDER BY doctor;

-- ============================================================================
-- END OF FILE
-- ============================================================================