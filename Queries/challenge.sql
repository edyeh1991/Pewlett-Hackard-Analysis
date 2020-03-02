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