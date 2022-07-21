

--DBMD LECTURE
--UNIVERSITY DATABASE PROJECT 



--CREATE DATABASE
CREATE DATABASE UNIVERSITY_REGISTRATION;

use UNIVERSITY_REGISTRATION



--//////////////////////////////


--CREATE TABLES 


--Make sure you add the necessary constraints.
--You can define some check constraints while creating the table, but some you must define later with the help of a scalar-valued function you'll write.
--Check whether the constraints you defined work or not.
--Import Values (Use the Data provided in the Github repo). 
--You must create the tables as they should be and define the constraints as they should be. 
--You will be expected to get errors in some points. If everything is not as it should be, you will not get the expected results or errors.
--Read the errors you will get and try to understand the cause of the errors.


--create Region Table 

CREATE TABLE Region(
	RegionID int PRIMARY KEY  not null,   
	RegionName nvarchar(50)  not null     
	);
	

INSERT INTO Region VALUES (1, 'Wales'),
						  (2, 'Scotland'),
						  (3, 'England'),
						  (4, 'Northern Ireland')


select * from Region

--create Staff table

CREATE TABLE Staff(
[StaffID] int  not null identity(1,1)
constraint Staff_PK primary key ([StaffID]),
[FirstName] [nvarchar](50) NULL,
[LastName] [nvarchar](50) NULL,
 RegionID int not null FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
 );

INSERT INTO Staff
VALUES	('Neil','Mango',2),
		('Harry','Smith',3),
		('Yavette',	'Berry',4),
		('Tom',	'Garden',4),
		('Margeret','Nolan',3),
		('Kellie', 'Pear',3),
		('October', 'Lime',1),
		('Ross', 'Island', 2),
		('Victor', 'Fig',1)



 select * from [Staff]

--create Student table

CREATE TABLE Student(
	StudentID int not null identity(1,1) constraint Student_PK PRIMARY KEY (StudentID),
	FirstName nvarchar(50),
	LastName nvarchar(50),
	Register_date date not null,
	RegionID int not null ,
	StaffID int  not null,
	constraint FK1_REGION_NUM foreign key (RegionID)  references  Region(RegionID),
    constraint FK1_STAFF_NUM foreign key (StaffID)  references Staff(StaffID) 	
	);

INSERT INTO Student
VALUES	('Alec','Hunter','12.05.2020',1, 7),
		('Bronwin',	'Blueberry','12.05.2020',2,	8),
		('Charlie',	'Apricot','12.05.2020',	3,2),
		('Ursula',	'Douglas','12.05.2020',	2,1),
		('Zorro',	'Apple', '12.05.2020',	3,6),
		('Debbie',	'Orange','12.05.2020',	1,9)

 ALTER TABLE student  drop constraint FK1_REGION_NUM
 ALTER TABLE student  drop constraint FK1_STAFF_NUM
 ALTER TABLE student add
 constraint FK1_REGION_NUM foreign key (RegionID)  references Region(RegionID) on update cascade on delete cascade,
 constraint FK1_STAFF_NUM foreign key (StaffID) references Staff(StaffID) on update cascade on delete cascade


select * from [Student]



--create Course table


CREATE TABLE [Course](
[CourseID] int  not null identity(1,1) constraint Course_pk primary key (CourseID),
[Title] [nvarchar](50)  not null,
[Credit] [nvarchar](50)  not null constraint check_credit check (Credit=15 or Credit=30)
);

INSERT INTO Course
VALUES	('Fine Arts',15),
		('German',15),
		('Chemistry',30),
		('French',30),
		('Physics',30),
		('History',30),
		('Music',30),
		('Psychology',30),
		('Biology',	15)

select * from Course
--create Enrollment Table

CREATE TABLE Enrollment(								
	[StudentID] int  not null,   
	[CourseID] int  not null constraint PK_ENROLLMENT primary key (StudentID, CourseID),
	foreign key (StudentID) references Student(StudentID),
	foreign key (CourseID)  references Course(CourseID)
	);
	
INSERT INTO Enrollment
VALUES	(1, 1),
		(1,	2),
		(2,	1),
		(2,	2),
		(3,	1),
		(3,	2),
		(4,	1),
		(4,	2)




	select * from Enrollment

--create StaffCourse table

CREATE TABLE StaffCourse(
[StaffID] int not null,
[CourseID] int  not null, 
Constraint PK_STAFFCOURSE	primary key (StaffID, CourseID),
foreign key (StaffID)  references Staff (StaffID),
foreign key (CourseID) references Course (CourseID)
);

INSERT INTO StaffCourse
VALUES	(1,1),
		(2,2),
		(5,3),
		(6,4),
		(5,4),
		(2,5),
		(6,5),
		(3,9)




select * from StaffCourse



--////////////////////


--CONSTRAINTS

--1. Students are constrained in the number of courses they can be enrolled in at any one time. 
--	 They may not take courses simultaneously if their combined points total exceeds 180 points.


 create function enrollment_constraint (
    @StudentID int,
    @CourseID int
)
returns varchar(10)
as 
begin 
    declare @total_credit int 
    declare @new_credit int
    declare @result varchar(10)
    select @total_credit = sum(c.Credit) from Course c join Enrollment e on e.CourseID = c.CourseID JOIN student s ON s.StudentID = e.StudentID where e.StudentID = @StudentID
    select @new_credit = Credit from Course where CourseID = @CourseID
    if @total_credit + @new_credit > 180
        set @result = 'False'
    else 
        set @result = 'True'
    return @result
end

ALTER TABLE Enrollment
ADD CONSTRAINT check_enrollment1 CHECK(dbo.enrollment_constraint(StudentID,CourseID) = 'True');







--------///////////////////


--2. The student's region and the counselor's region must be the same.


CREATE FUNCTION check_region()
RETURNS INT
AS
BEGIN
DECLARE @region int
IF EXISTS(SELECT *
FROM Region r JOIN student s ON r.RegionID=s.RegionID JOIN Staff ss ON ss.RegionID = r.RegionID
WHERE s.RegionID != ss.RegionID)
SELECT @region =1 ELSE SELECT @region = 0;
RETURN @region;
END;


ALTER TABLE Staff
ADD CONSTRAINT check_region1 CHECK(dbo.check_region() = 0);


-- Check of the Credit

create function check_credit0 (
    @Title varchar(256),
    @Credit int
)
returns varchar(10)
as 
begin
    declare @credit_real tinyint
    declare @credit_result varchar(10)
    if @Title in ('Fine Arts', 'German', 'Biology')
        set @credit_real = 15
    else 
        set @credit_real = 30 
    if @Credit = @credit_real 
        set @credit_result = 'True'
    else 
        set @credit_result = 'False'
    return @credit_result
end

ALTER TABLE Course
ADD CONSTRAINT check_credit3 CHECK(dbo.check_credit0(Title, Credit) = 'True');



--///////////////////////////////



------ADDITIONALLY TASKS



--1. Test the credit limit constraint.     

INSERT INTO Course VALUES('Math', 40)

/* Msg 547, Level 16, State 0, Line 272
The INSERT statement conflicted with the CHECK constraint "check_credit". The conflict occurred in database "UNIVERSITY_REGISTRATION", table "dbo.Course", column 'Credit'.
The statement has been terminated.*/


--//////////////////////////////////

--2. Test that you have correctly defined the constraint for the student counsel's region. 


UPDATE Staff SET RegionID = 5 WHERE StaffID=1

/* Msg 547, Level 16, State 0, Line 284
The UPDATE statement conflicted with the FOREIGN KEY constraint "FK__Staff__RegionID__398D8EEE". The conflict occurred in database "UNIVERSITY_REGISTRATION", table "dbo.Region", column 'RegionID'.
The statement has been terminated.*/

--/////////////////////////


--3. Try to set the credits of the History course to 20. (You should get an error.)

UPDATE Course SET Credit = 20 WHERE Title='History'

/* Msg 547, Level 16, State 0, Line 295
The UPDATE statement conflicted with the CHECK constraint "check_credit". The conflict occurred in database "UNIVERSITY_REGISTRATION", table "dbo.Course", column 'Credit'.
The statement has been terminated.*/

--/////////////////////////////

--4. Try to set the credits of the Fine Arts course to 30.(You should get an error.)  ?

UPDATE Course SET Credit = 30 WHERE Title='Fine Arts'

select * from Course

--////////////////////////////////////

--5. Debbie Orange wants to enroll in Chemistry instead of German. (You should get an error.)

INSERT INTO Enrollment VALUES (10,3)


/*Msg 547, Level 16, State 0, Line 313
The INSERT statement conflicted with the FOREIGN KEY constraint "FK__Enrollmen__Stude__44FF419A". The conflict occurred in database "UNIVERSITY_REGISTRATION", table "dbo.Student", column 'StudentID'.
The statement has been terminated.*/



--//////////////////////////


--6. Try to set Tom Garden as counsel of Alec Hunter (You should get an error.)  ?

UPDATE student SET StaffID = 4 WHERE StudentID=1



--/////////////////////////

--7. Swap counselors of Ursula Douglas and Bronwin Blueberry.


UPDATE Student Set StaffID = 8 where FirstName ='Ursula'
UPDATE Student Set StaffID = 1 where FirstName ='Bronwin'



--///////////////////


--8. Remove a staff member from the staff table.
--	 If you get an error, read the error and update the reference rules for the relevant foreign key.


DELETE FROM Staff
WHERE StaffID=9


 
/*  ALTER TABLE Student
 DROP CONSTRAINT FK1_REGION_NUM
 ALTER TABLE Student
 DROP CONSTRAINT FK1_STAFF_NUM
 ALTER TABLE Student add
 CONSTRAINT FK1_REGION_NUM FOREIGN KEY (RegionID)  REFERENCES Region(RegionID) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT FK1_STAFF_NUM FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)ON UPDATE CASCADE ON DELETE CASCADE */



















