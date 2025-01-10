SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


--PROJECT TASKS
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES	
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM books

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '223 Main St'
WHERE member_id = 'C101'


-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
 
 DELETE FROM issued_status
 WHERE issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
	issued_member_id,
	COUNT(issued_id) issued_books,
	member_name
FROM issued_status
JOIN members ON issued_status.issued_member_id = members.member_id
GROUP BY  issued_member_id,member_name
HAVING COUNT(issued_id) > 1

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

SELECT
	bks.isbn,
	book_title,
	COUNT(is_sts.issued_id) AS books_issued
INTO books_count
FROM books AS bks
JOIN issued_status AS is_sts ON bks.isbn = is_sts.issued_book_isbn
GROUP BY bks.isbn,book_title

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

SELECT 
	category,
	SUM(rental_price) as rental_income
FROM books AS bks
JOIN issued_status AS iss_sts
	ON bks.isbn = iss_sts.issued_book_isbn
GROUP BY category

--Task 9: List Members Who Registered in the Last 270 Days:

SELECT * FROM members
WHERE reg_date >= DATEADD(DAY, -270, GETDATE());

-- task 10 List Employees with Their Branch Manager's Name and their branch details:

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

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

SELECT *
INTO books_with_rp_abv7
FROM books
WHERE rental_price >7

SELECT *
FROM books_with_rp_abv7

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
		DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL
