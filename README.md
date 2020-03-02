# Pewlett-Hackard-Analysis
usimg the following ERD:

![EmployeeDB](https://github.com/edyeh1991/Pewlett-Hackard-Analysis/blob/master/EmployeeDB.png)
1. create list of retirment elidgible employees

  a. -- employee retirement info--
    
    SELECT first_name, last_name
    INTO retirement_info
    FROM employees
    WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
    AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31')
    
  b. select the employees whose birthdate is between 1952-01-01 and 1955-12-31 in which were hired between 1985-01-01 and 1988-12-31 to determine retirement eligibility
  
2. check to see if employees were still working at PH
3. create list of how many employees per department were leaving
4. include employee information, title, salary, management information, and departmental retirees
5. create a list of retirement eligible employees ready for a mentor for the mentorship program

a. --current employees born in 1965 elidgible for a mentor--

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

b. combine the list of employees and the list of employees titles by current employees born in 1965
