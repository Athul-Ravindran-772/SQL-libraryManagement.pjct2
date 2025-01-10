 -- SQL Project - Library Management System N2

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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

/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

ALTER PROCEDURE add_return_status 
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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
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

-- Task 16: Create a Table of Active Members
-- Use SELECT INTO to create a new table active_members containing members who have issued at least one book in the last 6 months.

DROP TABLE active_members

SELECT * INTO active_members
FROM members
WHERE member_id IN (
					SELECT DISTINCT issued_member_id
					FROM issued_status
					WHERE issued_date >= DATEADD(MONTH, -6, GETDATE())
					)
SELECT * FROM active_members


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

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


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

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

