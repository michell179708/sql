-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema university
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `university` ;

-- -----------------------------------------------------
-- Schema university
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `university` DEFAULT CHARACTER SET utf8 ;
USE `university` ;

-- -----------------------------------------------------
-- Table `university`.`student`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`student` ;

CREATE TABLE IF NOT EXISTS `university`.`student` (
  `student_id` INT(11) NOT NULL,
  `fname` VARCHAR(45) NOT NULL,
  `lname` VARCHAR(45) NOT NULL,
  `gender` VARCHAR(1) NULL,
  `city` VARCHAR(45) NOT NULL,
  `state` CHAR(2) NOT NULL,
  `dob` DATE NOT NULL,
  PRIMARY KEY (`student_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`collegue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`collegue` ;

CREATE TABLE IF NOT EXISTS `university`.`collegue` (
  `collegue_id` INT(11) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`collegue_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`department`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`department` ;

CREATE TABLE IF NOT EXISTS `university`.`department` (
  `department_code` VARCHAR(20) NOT NULL,
  `department_name` VARCHAR(65) NOT NULL,
  `collegue_id` INT(11) NOT NULL,
  PRIMARY KEY (`department_code`),
  INDEX `fk_department_collegue1_idx` (`collegue_id` ASC) VISIBLE,
  CONSTRAINT `fk_department_collegue1`
    FOREIGN KEY (`collegue_id`)
    REFERENCES `university`.`collegue` (`collegue_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`faculty`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`faculty` ;

CREATE TABLE IF NOT EXISTS `university`.`faculty` (
  `faculty_id` INT(11) NOT NULL,
  `faculty_fname` VARCHAR(45) NOT NULL,
  `faculty_lname` VARCHAR(45) NOT NULL,
  `department_code` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`faculty_id`),
  INDEX `fk_faculty_department1_idx` (`department_code` ASC) VISIBLE,
  CONSTRAINT `fk_faculty_department1`
    FOREIGN KEY (`department_code`)
    REFERENCES `university`.`department` (`department_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`course`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`course` ;

CREATE TABLE IF NOT EXISTS `university`.`course` (
  `course_num` INT(11) NOT NULL,
  `department_code` VARCHAR(20) NOT NULL,
  `name` VARCHAR(65) NOT NULL,
  `credits` INT(11) NOT NULL,
  PRIMARY KEY (`course_num`),
  INDEX `fk_course_department1_idx` (`department_code` ASC) VISIBLE,
  CONSTRAINT `fk_course_department1`
    FOREIGN KEY (`department_code`)
    REFERENCES `university`.`department` (`department_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`term`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`term` ;

CREATE TABLE IF NOT EXISTS `university`.`term` (
  `term_id` INT(11) NOT NULL,
  `term` VARCHAR(45) NOT NULL,
  `year` YEAR(4) NOT NULL,
  PRIMARY KEY (`term_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`section`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`section` ;

CREATE TABLE IF NOT EXISTS `university`.`section` (
  `section_id` INT(11) NOT NULL,
  `number` INT(11) NOT NULL,
  `capacity` INT(11) NOT NULL,
  `term_id` INT(11) NOT NULL,
  `course_num` INT(11) NOT NULL,
  `department_code` VARCHAR(20) NOT NULL,
  `faculty_id` INT NOT NULL,
  PRIMARY KEY (`section_id`),
  INDEX `fk_section_term1_idx` (`term_id` ASC) VISIBLE,
  INDEX `fk_section_faculty1_idx` (`faculty_id` ASC) VISIBLE,
  INDEX `fk_section_department1_idx` (`department_code` ASC) VISIBLE,
  INDEX `fk_section_course1_idx` (`course_num` ASC) VISIBLE,
  CONSTRAINT `fk_section_term1`
    FOREIGN KEY (`term_id`)
    REFERENCES `university`.`term` (`term_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_section_faculty1`
    FOREIGN KEY (`faculty_id`)
    REFERENCES `university`.`faculty` (`faculty_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_section_department1`
    FOREIGN KEY (`department_code`)
    REFERENCES `university`.`department` (`department_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_section_course1`
    FOREIGN KEY (`course_num`)
    REFERENCES `university`.`course` (`course_num`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `university`.`enrollment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `university`.`enrollment` ;

CREATE TABLE IF NOT EXISTS `university`.`enrollment` (
  `student_id` INT(11) NOT NULL,
  `section_id` INT(11) NOT NULL,
  PRIMARY KEY (`student_id`, `section_id`),
  INDEX `fk_student_has_section_section1_idx` (`section_id` ASC) VISIBLE,
  INDEX `fk_student_has_section_student1_idx` (`student_id` ASC) VISIBLE,
  CONSTRAINT `fk_student_has_section_student1`
    FOREIGN KEY (`student_id`)
    REFERENCES `university`.`student` (`student_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_student_has_section_section1`
    FOREIGN KEY (`section_id`)
    REFERENCES `university`.`section` (`section_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

USE university;

 /*Insert Data into collegue*/
INSERT INTO collegue(collegue_id,name)
VALUES
(1,"College of Physical Science and Engineering"),
(2,"College of Business and Communication"),
(3,"College of Language and Letters");

INSERT INTO department(department_code,department_name,collegue_id)
VALUES
("CIT","Computer Information Technology",1),
("ECON","Economics",2),
("HUM","Humanities and Philosophy",3);

/*Insert data in the table course*/
INSERT INTO course(course_num,department_code,name,credits)
VALUES	
(111,"CIT","Intro to Databases",3),
(388,"ECON","Econometrics",4),
(150,"ECON","Micro Economics",3),
(376,"HUM","Classical Heritage",2);

INSERT INTO term(term_id,term,year)
VALUES
(1,"Winter",2018),
(2,"FALL",2019);

/* Insert data in the table faculty*/
INSERT INTO faculty(faculty_id,faculty_fname,faculty_lname,department_code)
VALUES
(1,"Marty","Morring","CIT"),
(2,"Nate","Nathan","ECON"),
(3,"Ben","Barrus","ECON"),
(4,"John","Jensen","HUM"),
(5,"Bill","Barney","CIT");
 
  /* Insert data in the table section*/
INSERT INTO section(section_id,number,capacity,term_id,course_num,department_code,faculty_id)
VALUES
(1, 1,30,2,111,"CIT",1),
(2, 1,50,2,150,"ECON",2),
(3, 2,50,2,150,"ECON",2),
(4, 1,35,2,388,"ECON",3),
(5, 1,30,2,376,"HUM",4),
(6, 2,30,1,111,"CIT",1),
(7, 3,35,1,111,"CIT",5),
(8, 1,50,1,150,"ECON",2),
(9, 2,50,1,150,"ECON",2),
(10,1,30,1,376,"HUM",4);


/* Insert data in the table Student */
INSERT INTO student(student_id,fname,lname,gender,city,state,dob)
VALUES
(1,"Paul","Miller","m","Dallas","TX","1996-02-22"),
(2,"Katie","Smith","f","Provo","UT","1995-07-22"),
(3,"Kelly","Jones","f","Provo","UT","1998-06-22"),
(4,"Devon","Merril","m","Mesa","AZ","2000-07-22"),
(5,"Mandy","Murdock","f","Topeka","KS","1996-11-22"),
(6,"Alece","Adams","f","Rigby","ID","1997-05-22"),
(7,"Bryce","Carlson","M","Bozeman","MT","1997-11-22"),
(8,"Preston","Larsen","m","Decatur","TN","1996-09-22"),
(9,"Julia","Madsen","f","Rexburg","ID","1998-09-22"),
(10,"Susan","Sorensen","f","Mesa","AZ","1998-08-09");

/*Insert date in the table enrollment*/
INSERT INTO enrollment(student_id,section_id)
VALUES

(1,1),
(1,3),
(2,4),
(3,4),
(4,5),
(5,4),
(5,5),
(6,7),
(7,6),
(7,8),
(7,10),
(8,9),
(9,9),
(10,6);

USE university;

/*1. Students, and their birthdays, of students born in September. Format the date to look like it is shown in the result set. Sort by the student's last name.
*/
SELECT fname, lname, DATE_FORMAT(dob, '%M %d, %Y') AS formatted_birthday
FROM student
WHERE MONTH(dob) = 9
ORDER BY lname;


/*2. Student's age in years and days as of Jan. 5, 2017. Sorted from oldest to youngest. (You can assume a 365 day year and ignore leap day.) Hint: Use modulus for days left over after years. 
The 5th column is just the 3rd and 4th column combined with labels.*/
SELECT fname, lname,
     FLOOR(DATEDIFF('2017-01-05', dob)/365) AS years,
	 DATEDIFF('2017-01-05', dob) % 365 AS days,
     CONCAT(FLOOR(DATEDIFF('2017-01-05', dob)/365),' Years - ', DATEDIFF('2017-01-05', dob) % 365, ' Days') AS Year_and_Days
FROM student
ORDER BY years DESC;

-- 2 ALTERNATIVE
SELECT
	fname,
    lname,
	years as Yrs,
    days as Days,
    CONCAT(years, '`Years - ', days, ' Days') AS Combined
FROM
	(SELECT
		fname,
        lname,
		FLOOR(DATEDIFF('2017-01-05', dob)/365) AS years,
		DATEDIFF('2017-01-05', dob) % 365 AS days
	FROM student) AS subquery
ORDER BY years DESC;


  
  /*3. Students taught by John Jensen. Sorted by student's last name*/
    SELECT fname, lname
    FROM student  stud
		JOIN enrollment  enroll
			ON stud.student_id = enroll.student_id
		WHERE section_id = 5 OR section_id = 10
       ORDER BY lname;
       
 
       
       /*4. Instructors Bryce will have in Winter 2018. Sort by the faculty's last name.*/
             
    SELECT faculty_fname, faculty_lname
    FROM student st
		JOIN enrollment en
			ON st.student_id = en.student_id
		JOIN section se
			ON en.section_id = se.section_id
		JOIN faculty fa
			ON se.faculty_id = fa.faculty_id
     WHERE st.student_id =  7
     ORDER BY fa.faculty_lname;      
     
     /* 5.Students that take Econometrics in Fall 2019. Sort by student last name.*/
     SELECT fname, lname
     FROM student st
      JOIN enrollment en
        ON st.student_id = en.student_id
	 WHERE en.section_id = 4
	ORDER BY lname;
        
     
    /*6. Report showing all of Bryce Carlson's courses for Winter 2018. Sort by the name of the course.*/
    SELECT co.department_code, co.course_num,name
     FROM course co
		JOIN section se
			ON co.course_num = se.course_num
         JOIN enrollment en
			ON  en.section_id = se.section_id
         JOIN student st
			ON st.student_id = en.student_id
        WHERE st.student_id = 7; 
        
        /*7. The number of students enrolled for Fall 2019*/
         SELECT term, year, COUNT(student_id) as stu_enrollment
         FROM term t
			JOIN section se
				ON t.term_id = se.term_id
			JOIN enrollment en
				ON se.section_id = en.section_id
             WHERE t.term_id = 2
                GROUP BY t.term, year;
           
           SELECT * FROM department ;
		   SELECT * FROM course;		
        /*8. The number of courses in each college. Sort by college name. */
         SELECT coll.name, COUNT(de.department_code) as courses
         FROM collegue coll
		 LEFT JOIN department de
				ON coll.collegue_id = de.collegue_id
		 LEFT JOIN course co
				ON de.department_code = co.course_num 
           GROUP BY coll.name, de.department_code
           ORDER BY coll.name;  	
              
           /*9. The total number of students each professor can teach in Winter 2018. Sort by that total number of students (teaching capacity).*/   
        SELECT faculty_fname,faculty_lname, SUM(capacity) as teaching_capacity   
        FROM faculty fa
			JOIN section se
				ON fa.faculty_id = se.faculty_id
		WHERE se.term_id = 2
        GROUP BY faculty_fname, faculty_lname
        ORDER BY teaching_capacity;
                
		
         /*10. Each student's total credit load for Fall 2019, but only students with a credit load greater than three.  Sort by credit load in descending order*/
         SELECT * FROM student;
         SELECT * FROM course;
         SELECT * FROM enrollment;
		 SELECT * FROM section;
         
         SELECT lname, fname, SUM(credits) as credits
           FROM student st
			JOIN enrollment enr
				ON st.student_id = enr.student_id
			JOIN section sec
				ON enr.section_id = sec.section_id
			JOIN course co
				ON sec.course_num = co.course_num
			JOIN term t ON sec.term_id = t.term_id
		  WHERE term = 'FALL'  AND t.year = 2019
		  GROUP BY lname, fname
          HAVING credits > 3
          ORDER BY credits DESC;

