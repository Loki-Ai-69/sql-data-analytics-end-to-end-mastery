-- ============================================================================
-- CASE STUDY 01: AMAZON FARMERS MARKET (AFM) ANALYTICS
-- MODULE: Class 1 to Class 4 Master Analysis Script
-- TARGET DBMS: PostgreSQL / Standard SQL
-- ============================================================================

/*
   ============================================================================
   MODULE OVERVIEW & COVERED CONCEPTS:
   ============================================================================
   CLASS 1: Database Fundamentals, Data Types & Setup
   CLASS 2: Data Extraction (SELECT), Calculations, Aliasing (AS), Sorting (ORDER BY), 
            Top-N (LIMIT/OFFSET), Formatting (ROUND)
   CLASS 3: String Manipulations (CONCAT, UPPER, LOWER, SUBSTR), Filtering (WHERE), 
            Logical Operators (AND, OR, NOT), Range/Membership (IN, BETWEEN), Pattern Matching (LIKE)
   CLASS 4: Deduplication (DISTINCT), NULL Value Handling (IS NULL, TRIM, COALESCE), 
            Subqueries (Scalar & Multi-row), Conditional Logic (CASE WHEN)
   ============================================================================
*/


-- ============================================================================
-- SECTION 1: DATABASE OVERVIEW & BASIC DATA EXTRACTION (CLASS 1 & 2)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q1.1: Retrieve all attributes of vendors registered in Farmers Market.
-- Topic: Basic SELECT Clause (Data Retrieval)
-- ----------------------------------------------------------------------------
SELECT * FROM vendor;


-- ----------------------------------------------------------------------------
-- Q1.2: Extract specific customer profile attributes (ID, First Name, Last Name, Zip).
-- Topic: Column Projection / Selecting Specific Columns
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_zip
FROM customer;



-- ============================================================================
-- SECTION 2: INLINE CALCULATIONS, ALIASING & FORMATTING (CLASS 2)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q2.1: Calculate the total amount spent per purchase transaction.
-- Formula: Total Paid = Quantity * Cost per Quantity
-- Topic: Mathematical Operators & Column Aliasing (AS)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    product_id,
    quantity,
    cost_to_customer_per_qty,
    (quantity * cost_to_customer_per_qty) AS total_paid
FROM customer_purchases;


-- ----------------------------------------------------------------------------
-- Q2.2: Format the purchase amount to 2 decimal places for financial reporting.
-- Topic: Mathematical Function - ROUND(expression, decimals)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    product_id,
    quantity,
    cost_to_customer_per_qty,
    ROUND((quantity * cost_to_customer_per_qty)::numeric, 2) AS total_paid_formatted
FROM customer_purchases;



-- ============================================================================
-- SECTION 3: SORTING DATA & TOP-N ANALYSIS (CLASS 2)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q3.1: Fetch top 5 highest value customer purchases (Highest Revenue Orders).
-- Topic: Sorting in Descending Order (ORDER BY ... DESC) & LIMIT Clause
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    product_id,
    quantity,
    cost_to_customer_per_qty,
    ROUND((quantity * cost_to_customer_per_qty)::numeric, 2) AS total_paid
FROM customer_purchases
ORDER BY total_paid DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- Q3.2: List all products in alphabetical order by Product Name.
-- Topic: Sorting in Ascending Order (ORDER BY ... ASC)
-- ----------------------------------------------------------------------------
SELECT 
    product_id,
    product_name,
    product_category_id
FROM product
ORDER BY product_name ASC;


-- ----------------------------------------------------------------------------
-- Q3.3: Pagination Analysis: Retrieve the 2nd and 3rd most recent transactions.
-- Topic: Record Skipping using LIMIT with OFFSET
-- ----------------------------------------------------------------------------
SELECT 
    transaction_time,
    customer_id,
    product_id,
    quantity,
    cost_to_customer_per_qty,
    ROUND((quantity * cost_to_customer_per_qty)::numeric, 2) AS total_paid
FROM customer_purchases
ORDER BY transaction_time DESC
LIMIT 2 OFFSET 1;



-- ============================================================================
-- SECTION 4: STRING FUNCTIONS & TEXT MANIPULATION (CLASS 3)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q4.1: Combine customer first name and last name into a unified full name column.
-- Topic: String Concatenation (CONCAT)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    customer_first_name,
    customer_last_name,
    CONCAT(customer_first_name, ' ', customer_last_name) AS customer_full_name
FROM customer;


-- ----------------------------------------------------------------------------
-- Q4.2: Standardize customer names into Uppercase and Lowercase formats.
-- Topic: String Case Conversion (UPPER, LOWER)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    UPPER(CONCAT(customer_first_name, ' ', customer_last_name)) AS full_name_uppercase,
    LOWER(CONCAT(customer_first_name, ' ', customer_last_name)) AS full_name_lowercase
FROM customer;


-- ----------------------------------------------------------------------------
-- Q4.3: Extract the first 3 digits of customer ZIP codes for area categorization.
-- Topic: String Extraction (SUBSTR / SUBSTRING)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    customer_zip,
    SUBSTR(customer_zip, 1, 3) AS zip_area_code
FROM customer;



-- ============================================================================
-- SECTION 5: CONDITIONAL FILTERING & LOGICAL OPERATORS (CLASS 3)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q5.1: Filter purchase transactions where purchase quantity is greater than 3 units.
-- Topic: Basic WHERE Clause Filtering
-- ----------------------------------------------------------------------------
SELECT *
FROM customer_purchases
WHERE quantity > 3;


-- ----------------------------------------------------------------------------
-- Q5.2: Retrieve transactions for Customer ID 1 where cost per unit exceeds $4.00.
-- Topic: Logical AND Operator (Both conditions must be TRUE)
-- ----------------------------------------------------------------------------
SELECT *
FROM customer_purchases
WHERE customer_id = 1 
  AND cost_to_customer_per_qty > 4.00;


-- ----------------------------------------------------------------------------
-- Q5.3: Retrieve transactions of Customer ID 1 OR any transaction with cost > $10.00.
-- Topic: Logical OR Operator (At least one condition must be TRUE)
-- ----------------------------------------------------------------------------
SELECT *
FROM customer_purchases
WHERE customer_id = 1 
   OR cost_to_customer_per_qty > 10.00;


-- ----------------------------------------------------------------------------
-- Q5.4: Find all customers who do NOT live in ZIP code '90210'.
-- Topic: Logical NOT Operator
-- ----------------------------------------------------------------------------
SELECT *
FROM customer
WHERE NOT (customer_zip = '90210');



-- ============================================================================
-- SECTION 6: MEMBERSHIP, RANGES & PATTERN MATCHING (CLASS 3)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q6.1: Retrieve customer records residing in target ZIP codes ('90210', '10001', '30301').
-- Topic: Membership Operator (IN)
-- ----------------------------------------------------------------------------
SELECT *
FROM customer
WHERE customer_zip IN ('90210', '10001', '30301');


-- ----------------------------------------------------------------------------
-- Q6.2: Retrieve transactions where item cost per unit is between $5.00 and $15.00.
-- Topic: Range Filtering (BETWEEN ... AND ...)
-- ----------------------------------------------------------------------------
SELECT *
FROM customer_purchases
WHERE cost_to_customer_per_qty BETWEEN 5.00 AND 15.00;


-- ----------------------------------------------------------------------------
-- Q6.3: Search for vendors whose names start with 'Fresh' or contain 'Organic'.
-- Topic: Wildcard Pattern Matching (LIKE with '%')
-- ----------------------------------------------------------------------------
SELECT *
FROM vendor
WHERE vendor_name LIKE 'Fresh%' 
   OR vendor_name LIKE '%Organic%';



-- ============================================================================
-- SECTION 7: DISTINCT & NULL VALUE MANAGEMENT (CLASS 4)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q7.1: Extract unique/distinct ZIP codes of registered customers.
-- Topic: Deduplication (DISTINCT)
-- ----------------------------------------------------------------------------
SELECT DISTINCT customer_zip
FROM customer;


-- ----------------------------------------------------------------------------
-- Q7.2: Find customer accounts that have missing ZIP code entries.
-- Topic: NULL Checking (IS NULL / IS NOT NULL)
-- ----------------------------------------------------------------------------
SELECT *
FROM customer
WHERE customer_zip IS NULL;


-- ----------------------------------------------------------------------------
-- Q7.3: Clean customer names by removing whitespace and replacing NULL ZIP codes.
-- Topic: Text Trimming (TRIM) & Null Value Replacement (COALESCE)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    TRIM(customer_first_name) AS cleaned_first_name,
    COALESCE(customer_zip, 'N/A') AS formatted_zip
FROM customer;



-- ============================================================================
-- SECTION 8: SUBQUERIES (SCALAR & MULTI-ROW) (CLASS 4)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q8.1: Retrieve purchase records for customers living in ZIP '90210'.
-- Topic: Multi-Row Subquery (WHERE ... IN (SELECT ...))
-- ----------------------------------------------------------------------------
SELECT *
FROM customer_purchases
WHERE customer_id IN (
    SELECT customer_id 
    FROM customer 
    WHERE customer_zip = '90210'
);


-- ----------------------------------------------------------------------------
-- Q8.2: Identify purchases where overall order spend is greater than average spend.
-- Topic: Scalar Subquery (Comparison with Aggregate Subquery Output)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    product_id,
    quantity,
    cost_to_customer_per_qty,
    (quantity * cost_to_customer_per_qty) AS total_paid
FROM customer_purchases
WHERE (quantity * cost_to_customer_per_qty) > (
    SELECT AVG(quantity * cost_to_customer_per_qty) 
    FROM customer_purchases
);



-- ============================================================================
-- SECTION 9: CONDITIONAL LOGIC & SEGMENTATION (CLASS 4)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q9.1: Classify purchase orders into spend buckets (Low, Medium, High).
-- Topic: Multi-way Branching (CASE WHEN ... THEN ... ELSE ... END)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    product_id,
    (quantity * cost_to_customer_per_qty) AS total_spend,
    CASE 
        WHEN (quantity * cost_to_customer_per_qty) < 10 THEN 'Low Spend (<$10)'
        WHEN (quantity * cost_to_customer_per_qty) BETWEEN 10 AND 25 THEN 'Medium Spend ($10-$25)'
        ELSE 'High Spend (>$25)'
    END AS spend_category
FROM customer_purchases;


-- ----------------------------------------------------------------------------
-- Q9.2: Flag purchases as 'Bulk Order' (5+ items) or 'Regular Order'.
-- Topic: Binary Conditional Logic - Standard CASE Statement (PostgreSQL Compatible)
-- ----------------------------------------------------------------------------
SELECT 
    customer_id,
    product_id,
    quantity,
    CASE 
        WHEN quantity >= 5 THEN 'Bulk Order'
        ELSE 'Regular Order'
    END AS order_type
FROM customer_purchases;

-- ============================================================================
-- END OF FILE
-- ============================================================================