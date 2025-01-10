# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql

SELECT
    issued_member_id,
    COUNT(issued_id) issued_books,
    member_name
FROM issued_status
JOIN members ON issued_status.issued_member_id = members.member_id
GROUP BY  issued_member_id,member_name
HAVING COUNT(issued_id) > 1

```

### 3. SELECT INTO

- **Task 6: Create Summary Tables**: Create a new table that summarizes the total number of times each book has been issued, using SELECT INTO to generate the table based on query results.

```sql
SELECT
    bks.isbn,
    book_title,
    COUNT(is_sts.issued_id) AS books_issued
INTO books_count
FROM books AS bks
JOIN issued_status AS is_sts ON bks.isbn = is_sts.issued_book_isbn
GROUP BY bks.isbn,book_title
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    category,
    SUM(rental_price) as rental_income
FROM books AS bks
JOIN issued_status AS iss_sts
	ON bks.isbn = iss_sts.issued_book_isbn
GROUP BY category
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT
    emp1.emp_id,
    emp1.emp_name,
    emp1.position,
    br.branch_id,
    manager_id,
    CASE
	WHEN emp1.emp_id = br.manager_id  THEN NULL
	ELSE emp2.emp_name
    END AS mgr_name,
    branch_address,
    contact_no
FROM employees AS emp1
JOIN branch AS br
    ON emp1.branch_id = br.branch_id
JOIN employees AS emp2
    ON emp2.emp_id = br.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
SELECT *
INTO books_with_rp_abv7
FROM books
WHERE rental_price >7

SELECT *
FROM books_with_rp_abv7
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT
    mem.member_address,
    mem.member_name,
    books.book_title,
    iss_sts.issued_date
FROM issued_status AS iss_sts
JOIN members AS mem
    ON mem.member_id = iss_sts.issued_member_id
JOIN books 
    ON books.isbn = iss_sts.issued_book_isbn
LEFT JOIN return_status AS rs
    ON rs.issued_id = iss_sts.issued_id
WHERE rs.return_date IS NULL
    AND DATEDIFF (DAY, iss_sts.issued_date, GETDATE()) > 30
ORDER BY issued_date
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
CREATE PROCEDURE add_return_status 
    @return_id VARCHAR(15), 
    @issued_id VARCHAR(15), 
    @book_quality VARCHAR(15)
AS
BEGIN
	DECLARE @issued_book_isbn VARCHAR(20);

    -- Insert statement to add a new record to the return_status table

    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (@return_id, @issued_id, GETDATE(), @book_quality);

	--Updating book status in books table
	-- Before that we need to get isbn

	SELECT 
		@issued_book_isbn = issued_book_isbn
	FROM issued_status
	WHERE issued_id = @issued_id;

	UPDATE books
	SET status = 'Yes'
	WHERE isbn = @issued_book_isbn
END
 
-- Testing parameters

EXEC add_return_status 'RS120', 'IS136', 'Good'

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
SELECT 
	branch_id,
	COUNT(iss_sts.issued_id) AS iss_bk_cnt,
	SUM( CASE
			WHEN return_id IS NULL THEN 1
			ELSE 0
		 END) return_count,
	SUM(rental_price) AS income_generated
FROM employees AS emp
JOIN issued_status AS iss_sts ON emp.emp_id = iss_sts.issued_emp_id
LEFT JOIN return_status AS ret_sts ON iss_sts.issued_id = ret_sts.issued_id
JOIN books AS bks ON iss_sts.issued_book_isbn = bks.isbn
GROUP BY branch_id

```

**Task 16: Create a Table of Active Members
-- Use SELECT INTO to create a new table active_members containing members who have issued at least one book in the last 6 months.**

```sql
SELECT * INTO active_members
FROM members
WHERE member_id IN (
					SELECT DISTINCT issued_member_id
					FROM issued_status
					WHERE issued_date >= DATEADD(MONTH, -6, GETDATE())
					)
SELECT * FROM active_members
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
WITH top3_employees AS (SELECT 
				emp.emp_name,
				COUNT(issued_book_name)  AS num_bks_prcsd,
				branch.*,
				DENSE_RANK() OVER( ORDER BY COUNT(issued_book_name) DESC) AS ranking
			FROM issued_status AS iss_sts
			JOIN  employees AS emp
				ON iss_sts.issued_emp_id = emp.emp_id
			JOIN branch
				ON emp.branch_id = branch.branch_id
			GROUP BY iss_sts.issued_emp_id,
				 emp.emp_name,
				 branch.branch_id,
				 branch.manager_id,
				 branch.branch_address,
				 branch.contact_no
			)
SELECT
	*
FROM top3_employees 
WHERE ranking <= 3
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE PROCEDURE mng_books_status 

	@isbn VARCHAR(20),
	@issued_id VARCHAR(15), 
	@issued_member_id VARCHAR(15),
	@issued_book_name VARCHAR(60),
	@issued_emp_id VARCHAR(15)

AS
DECLARE 
	@bk_status VARCHAR(10)
BEGIN

-- GETTING ISBN

	SELECT
		@bk_status = status
	FROM books
	WHERE isbn = @isbn

--GETTING STATUS CHECKED
	IF @bk_status = 'yes'
		BEGIN
			INSERT INTO issued_status (
							issued_id,
							issued_member_id,
							issued_book_name,
							issued_date,
							issued_book_isbn,
							issued_emp_id
						  )

			VALUES (	
					@issued_id, 
					@issued_member_id,
					@issued_book_name,
					GETDATE(),
					@isbn,
					@issued_emp_id
				);

	--UPDATING BOOK STATUS
			UPDATE books
			SET status = 'No'
			WHERE isbn = @isbn;

		END

	ELSE
	-- GENERATING ELSE RESPONSE
		BEGIN
			PRINT(' Book is currently not available');
		END

	
END

-- CALLING PROCEDUERE================

EXEC  mng_books_status 
	'978-0-7432-7357-1',
	'IS136',
	'C107',
	'1491: New Revelations of the Americas Before Columbus',
	'E102'


```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

Thank you for your interest in this project!
