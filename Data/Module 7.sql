-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name));
	 
CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no));
	
CREATE TABLE dept_manager (
dept_no varchar(9) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no));
	
CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no));
  
CREATE TABLE dept_employee (
	emp_no INT NOT NULL,
	dept_no varchar(9) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no));

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no));

SELECT * FROM employees;

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- export data into new table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info

DROP table retirement_info;

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info as ri
LEFT JOIN dept_employee as de
ON ri.emp_no = de.emp_no;

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_employee as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

SELECT * FROM current_emp

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
into retiring_emp_dept
FROM current_emp as ce
LEFT JOIN dept_employee as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT * FROM salaries
ORDER BY to_date DESC;

SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_employee as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
		
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_employee as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no);

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	ti.title,
	ti.from_date,
	s.salary
--INTO title_retiring
FROM retirement_info as ri
INNER JOIN titles as ti
ON (ti.emp_no = ri.emp_no)
INNER JOIN salaries as s
ON (ti.from_date = s.from_date);


-- employee retirement info
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--Employees retiring title
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	ti.title,
	ti.from_date,
	s.salary
INTO title_retiring_1
FROM retirement_info as ri
INNER JOIN salaries as s
ON (ri.emp_no = s.emp_no)
INNER JOIN titles as ti
ON (ti.emp_no = ri.emp_no);

--selecting duplicate names
SELECT
  tr1.first_name,
  tr1.last_name,
  count(*)
FROM title_retiring_1 as tr1
GROUP BY
  tr1.first_name,
  tr1.last_name
HAVING count(*) > 1;

--counting how many duplicates per name
SELECT * FROM
  (SELECT *, count(*)
  OVER
    (PARTITION BY
      tr1.first_name,
      tr1.last_name
    ) AS count
  FROM title_retiring_1 as tr1) tableWithCount
  WHERE tableWithCount.count > 1;

--removing duplicate names and keeping only most recent titles of retiring employees
SELECT emp_no, 
	first_name,
	last_name,
	title, 
	from_date, 
	salary 
INTO recent_title_retiring
FROM
  (SELECT emp_no,
   first_name, 
   last_name,
   title,
   from_date,
   salary,
     ROW_NUMBER() OVER 
(PARTITION BY (first_name, last_name) ORDER BY from_date DESC) rn
   FROM title_retiring_1
  ) tmp WHERE rn = 1
ORDER BY from_date DESC;

SELECT * FROM recent_title_retiring;

--count number of employees with same title
SELECT rtr.title, count(*)
INTO title_count
FROM recent_title_retiring as rtr
GROUP BY rtr.title;

--current employees born in 1965 elidgible for a mentor
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	ti.title,
	ti.from_date,
	ti.to_date
INTO emp_mentor
FROM employees as e
INNER JOIN titles as ti
ON (e.emp_no = ti.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
AND (to_date = '9999-01-01')

SELECT * FROM emp_mentor;