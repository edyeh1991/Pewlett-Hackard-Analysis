# Pewlett-Hackard-Analysis
usimg the following ERD:

![EmployeeDB](https://github.com/edyeh1991/Pewlett-Hackard-Analysis/blob/master/EmployeeDB.png)
1. create list of retirment elidgible employees
  a. -- employee retirement info
    SELECT first_name, last_name
    INTO retirement_info
    FROM employees
    WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
    AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
  b. select the employees whose birthdate is between 1952-01-01 and 1955-12-31 in which were hired between 1985-01-01 and 1988-12-31 to determine retirement eligibility
2. check to see if employees were still working at PH
3. create list of how many employees per department were leaving
  a. include employee information, title, salary, management information, and departmental retirees
 4. create a list of retirement eligible employees ready for a mentor for the mentorship program
  
