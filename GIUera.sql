CREATE DATABASE GIUera


GO
USE GIUera

create table Users(
id int primary key identity,
first_name varchar(20),
last_name varchar(20),
password varchar(20),
gender bit,
email varchar(50),
address varchar(10)
)



create table Instructor(
id int foreign key references Users ON DELETE CASCADE ON UPDATE CASCADE,
rating DECIMAL(2,1),
PRIMARY KEY(id)
)

create table UserMobileNumber(
id int foreign key references Users ON DELETE CASCADE ON UPDATE CASCADE ,
mobileNumber varchar(20),
PRIMARY KEY(id,mobileNumber)
)


create table Student (
id int foreign key references Users ON DELETE CASCADE ON UPDATE CASCADE,
gpa DECIMAL(1,1),
PRIMARY KEY(id)
)

create table Admins(
id int foreign key references Users,
PRIMARY KEY(id)
)



create table Course (
id int primary key IDENTITY,
credit_hours int,
Cname varchar(10),
courseDescription varchar(200),
price DECIMAL(6,2),
content varchar(200),
Aid int foreign key references Admins ,
I_id int foreign key references Instructor ,
accepted bit
)

			

create table Assignment (
C_id int foreign key references Course ON DELETE CASCADE ON UPDATE CASCADE,
number int ,
A_type varchar(10) ,
fullgrade int ,
A_weight decimal(4,1), 
deadline datetime,
content varchar(200),
PRIMARY KEY(C_id,number,A_type)
)



create table Feedback (
C_id int foreign key references Course ON DELETE CASCADE ON UPDATE CASCADE,
number int identity,
comment varchar(100),
numberOfLikes int, 
S_id int foreign key references Student,
PRIMARY KEY(C_id,number)
)

create table promoCode(
code varchar(6) primary key ,
issueDate datetime,
expiryDate datetime,
discountAmount decimal(4,2) ,
A_id int foreign key references Admins 
)

create table StudentHasPromoCode (
S_id int foreign key references Student ,
code varchar(6) foreign key references promoCode ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY(S_id,code)
)

create table CreditCard (
number varchar(15) primary key ,
cardHolderName varchar(16),
expiryDate datetime,
cvv varchar(3)
)

create table StudentAddCreditCard (
S_id int foreign key references Student ,
CCN varchar(15) foreign key references CreditCard ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY(S_id,CCN)
)

create table StudentTakeCourse (
S_id int foreign key references Student ,
C_id int foreign key references Course ON UPDATE CASCADE ON DELETE CASCADE,
I_id int foreign key references Instructor ,
payedFor bit,
grade decimal(10,2)
PRIMARY KEY(S_id,C_id,I_id),
)



create table studentTakeAssignment(
S_id int foreign key references Student ,
C_id int ,
A_number int ,
A_type varchar(10) ,
FOREIGN KEY(C_id,A_number,A_type) REFERENCES Assignment,
grade decimal(5,2),
PRIMARY KEY(S_id,C_id,A_number,A_type)
)

create table StudentRateInstructor (
S_id int foreign key references Student, 
I_id int foreign key references Instructor,
rate DECIMAL(2,1),
PRIMARY KEY(S_id,I_id)
)

create table StudentCertifyCourse(
S_id int foreign key references Student ,
C_id int foreign key references Course ON DELETE CASCADE ON UPDATE CASCADE,
issueDate datetime,
PRIMARY KEY(S_id,C_id)
)

create table CoursePrerequisiteCourse(
C_id int ,
Prerequisite_id int,
PRIMARY KEY(C_id,Prerequisite_id),
FOREIGN KEY(C_id) REFERENCES Course ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(Prerequisite_id) REFERENCES Course
)


create table InstructorTeachCourse (
I_id int foreign key references instructor,
C_id int foreign key references Course ON DELETE CASCADE ON UPDATE CASCADE
PRIMARY KEY(I_id,C_id)
)



GO
CREATE PROCEDURE studentRegister--maybe
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@email varchar(50),
@gender bit,
@address varchar(10)
AS
INSERT INTO Users (first_name,last_name,password,email,gender,address)
VALUES(@first_name,@last_name,@password,@email,@gender,@address)
DECLARE @id INT 
SELECT @id = Users.id
FROM Users
WHERE first_name = @first_name AND last_name = @last_name AND password = @password
AND email=@email AND gender = @gender AND address = @address
INSERT INTO Student (ID,gpa) VALUES (@id, 0.00)



GO
CREATE PROCEDURE InstructorRegister
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@email varchar(50),
@gender bit,
@address varchar(10)
AS
INSERT INTO Users (first_name,last_name,password,email,gender,address)
VALUES(@first_name,@last_name,@password,@email,@gender,@address)
DECLARE @id INT 
SELECT @id = Users.id
FROM Users
WHERE first_name = @first_name AND last_name = @last_name AND password = @password
AND email=@email AND gender = @gender AND address = @address
INSERT INTO Instructor(ID,rating) VALUES (@id, 0.0)

GO
CREATE PROC lastUserId

AS
select Max(id) AS ID  from Users



GO
CREATE PROCEDURE UserLogin
@ID int,
@password varchar(20),
@success bit output,
@type int output
AS
IF EXISTS(SELECT Users.id FROM Users WHERE Users.id = @id And password=@password)
BEGIN
SET @success = 1
IF EXISTS(SELECT Admins.id FROM Admins WHERE Admins.id = @id)
SET @type = 0
IF EXISTS(SELECT Student.id FROM Student WHERE Student.id = @id)
SET @type = 1

IF EXISTS(SELECT Instructor.id FROM Instructor WHERE Instructor.id = @id)
SET @type = 2

END

ELSE
BEGIN
SET @success = 0
SET @type = 0
END
PRINT(@success)
PRINT(@type)





GO
CREATE PROCEDURE addMobile
@ID int,
@mobile_number varchar(20)
AS
INSERT INTO UserMobileNumber(id,mobileNumber) VALUES (@ID,@mobile_number)





--3)As an admin I should be able to:

Go
create proc AdminListInstr--updated
As
select u.first_name,u.last_name
from Instructor i INNER JOIN Users u ON i.id=u.id



GO
create proc AdminViewInstructorProfile
@I_id int
As 
select *
from Instructor



Go

create proc AdminViewAllCourses
As
select * 
from Course


Go
create proc AdminViewNonAcceptedCourses
As 
select *
from Course
where accepted =0


Go
create proc AdminViewCourseDetails
As
select coursedescription , content
from Course


GO
CREATE PROC AdminAcceptRejectCourse
@adminId int,@courseId int
AS
	UPDATE Course
	SET accepted=1
	WHERE Aid=@adminId AND id=@courseId




GO
create proc AdminCreatePromocode --updated
@code varchar(6),
@isuueDate datetime,
@expiryDate datetime,
@discount decimal(4,2),
@adminId int
AS

Insert into promoCode values(@code,@isuueDate,@expiryDate,@discount,@adminId)

drop proc AdminCreatePromocode 

GO

create proc AdminListAllStudents --updated
AS
select *
from Users

drop proc AdminListAllStudents

GO

create proc AdminViewStudentProfile --updated
@sid int
AS
select *
from Student


GO
create proc AdminIssuePromocodeToStudent --updated
@sid int,
@pid varchar(6)
AS
Insert into StudentHasPromoCode Values(@sid,@pid)






--4) As an instructor I am able to:
GO
CREATE PROC InstAddCourse
@creditHours int,@name varchar(10),@courseDescription varchar(200),@price DECIMAL(6,2),@instructorId int
AS
declare @cid int
	INSERT INTO Course (credit_hours,Cname,courseDescription,price,I_id)
		VALUES(@creditHours,@name,@courseDescription,@price,@instructorId)
	Select @cid=Max(id) from Course
	Insert Into InstructorTeachCourse
		Values(@instructorId,@cid)

		


GO
CREATE PROC AddAnotherInstructorToCourse
	@instId int,@cid int,@adderIns int
	AS
		INSERT INTO InstructorTeachCourse(I_id,C_id)
			VALUES(@instId,@cid)



GO
CREATE PROC UpdateCourseContent
	@instrId int,@courseId int,@content varchar(200)
	AS
		UPDATE Course
		SET content=@content
		WHERE I_id=@instrId AND id=@courseId


GO
CREATE PROC UpdateCourseDescription
	@instId int,@cid int,@description varchar(200)
	AS
		UPDATE Course
		SET courseDescription=@description
		WHERE I_id=@instId AND id=@cid




GO
CREATE PROC InstructorViewAcceptedCoursesByAdmin
	@instrId int
	AS
		SELECT *
		FROM Course
		WHERE I_id=@instrId AND accepted=1



GO
CREATE PROC DefineCoursePrerequisites
	@cid int,@prequisiteId int
	AS
		INSERT INTO CoursePrerequisiteCourse
			VALUES(@cid,@prequisiteId)



GO
CREATE PROC DefineAssignmentOfCourseOfCertianType
	@instId int, @cid int , @number int, @type varchar(10), @fullGrade int, @weight decimal(4,1), @deadline datetime, @content varchar(200)
	AS
		INSERT INTO Assignment (C_id,number,A_type,fullgrade,A_weight,deadline,content)
			VALUES (@cid,@number,@type,@fullGrade,@weight,@deadline,@content)

GO
CREATE PROC ViewInstructorProfile--updated
	@instrId int
	AS
		SELECT u.*,i.rating,c.C_id
		FROM Users u INNER JOIN Instructor i ON u.id=i.id INNER JOIN InstructorTeachCourse c ON c.I_id=u.id
		WHERE u.id=@instrId
		

GO
CREATE PROC InstructorViewAssignmentsStudents
	@instrId int, @cid int
	AS
	SELECT sta.*
	FROM studentTakeAssignment sta INNER JOIN InstructorTeachCourse i ON sta.C_id=i.C_id
	WHERE sta.C_id=@cid AND i.I_id=@instrId



GO
CREATE PROC InstructorgradeAssignmentOfAStudent
	@instrId int, @sid int , @cid int, @assignmentNumber int, @type varchar(10), @grade decimal(5,2)
	AS
	INSERT INTO studentTakeAssignment
		VALUES(@sid,@cid,@assignmentNumber,@type,@grade)



GO
CREATE PROC ViewFeedbacksAddedByStudentsOnMyCourse
	@instrId int, @cid int
	AS
	SELECT f.*
	FROM Feedback f INNER JOIN Course c ON f.C_id =c.id
					INNER JOIN InstructorTeachCourse itc ON f.C_id=itc.C_id
	WHERE f.C_id=@cid AND itc.I_id=@instrId



GO
CREATE PROC updateInstructorRate
	@instId int
	AS
	DECLARE @avgRate decimal(2,1)
		SELECT @avgRate=AVG(rate)
		FROM StudentRateInstructor
		WHERE I_id=@instId

		UPDATE Instructor
		SET rating=@avgRate



GO
CREATE  PROC InstructorIssueCertificateToStudent
	@cid int , @sid int , @instId int, @issueDate datetime
	AS
	If exists(SELECT I_id from InstructorTeachCourse where @instId=I_id AND @cid=C_id )
	BEGIN
	INSERT INTO StudentCertifyCourse
	 VALUES(@sid,@cid,@issueDate)
	END

	





-- 5)As a registered student I should be able to:


GO
CREATE PROC viewMyProfile--updated
	@id int
	AS
		SELECT u1.*,s1.gpa
		FROM Users u1 INNER JOIN Student s1 ON u1.id=s1.id
		WHERE u1.id=@id AND s1.id=@id



GO
CREATE PROC editMyProfile
	@id int,@firstName varchar(10),@lastName varchar(10),@password varchar(10),@gender bit,@email varchar(10),@address varchar(10)
	AS

		UPDATE Users
		SET  first_Name=@firstName, last_name=@lastName, password=@password,gender=@gender, email=@email, address=@address
		WHERE id=@id

GO
CREATE PROC availableCourses
	AS
		SELECT id,Cname
		FROM Course



GO 
CREATE PROC courseInformation--Updated
	@cid int
	AS
		SELECT c.id,c.credit_hours,c.Cname,c.courseDescription,c.price,i.I_id,u.first_name,u.last_name
		FROM Course c 
		INNER JOIN InstructorTeachCourse i ON i.C_id=c.id
		INNER JOIN Users u ON i.I_id = u.id
		WHERE c.id=@cid







GO
CREATE PROC enrollInCourse--updated
	@sid int,@cid int,@instr int
	AS
	if NOT EXISTS( SELECT S_id,C_id FROM StudentTakeCourse WHERE  @sid=S_id AND C_id=@cid )
	BEGIN
	INSERT INTO StudentTakeCourse (S_id,C_id,I_id)
		VALUES(@sid,@cid,@instr)
	END





GO
CREATE PROC addCreditCard--maybe
	@sid int, @number varchar(15),@cardHolderName varchar(16), @expiryDate datetime,@cvv varchar(3)
	AS
		INSERT INTO CreditCard (number,cardHolderName,expiryDate,cvv)
			VALUES(@number,@cardHolderName,@expiryDate,@cvv)

		INSERT INTO StudentAddCreditCard(S_id,CCN)
			VALUES(@sid,@number)



GO
CREATE PROC viewPromoCode--updated
	@sid int
	AS
		SELECT sc.code,pc.issueDate,pc.expiryDate,pc.discountAmount
		FROM StudentHasPromoCode sc INNER JOIN promoCode pc ON sc.code=pc.code
		WHERE S_id = @sid



GO
CREATE PROC payCourse
	@cid int,@sid int
	AS
	UPDATE StudentTakeCourse
	SET payedFor=1
	WHERE C_id=@cid AND S_id=@sid


GO 
CREATE PROC enrollInCourseViewContent--updated
	@sid int, @cid int
	AS
	SELECT stc.C_id,c.credit_hours,c.Cname,c.courseDescription,c.price,c.content
	FROM StudentTakeCourse stc INNER JOIN Course c ON stc.C_id=c.id
	WHERE stc.S_id=@sid AND stc.C_id=@cid




GO
CREATE PROC enrollInCoursesView--fatya
	@sid int
	AS
	SELECT stc.C_id,c.Cname
	FROM StudentTakeCourse stc INNER JOIN Course c ON stc.C_id=c.id
	WHERE S_id=@sid




GO 
CREATE PROC viewAssign--updated
	@courseId int,@Sid int
	AS
		SELECT a.C_id,a.number,a.A_type,a.fullgrade,a.A_weight,a.deadline, a.content

		FROM Assignment a INNER JOIN StudentTakeCourse stc ON a.C_id=stc.C_id
		WHERE a.C_id = @courseId AND stc.S_id = @Sid


GO
CREATE PROC submitAssign
	@assignType varchar(10), @assignNumber int, @sid int,@cid int
	AS
		Insert Into studentTakeAssignment (A_type,A_number,S_id,C_id)
			Values(@assignType,@assignNumber,@sid,@cid)

GO
CREATE PROC viewAssignGrades
	@assignNumber int, @assignType varchar(10), @cid int,@sid int
	AS
		SELECT grade
		FROM studentTakeAssignment
		WHERE A_number = @assignNumber AND A_type = @assignType AND C_id = @cid AND S_id = @sid



GO
CREATE PROC viewFinalGrade
	@cid int,@sid int
	AS
		SELECT grade
		FROM StudentTakeCourse
		WHERE C_id=@cid AND S_id = @sid

		

GO
CREATE PROC addFeedback
	@comment varchar(100),@cid int,@sid int
	AS
		INSERT INTO Feedback (comment,C_id,S_id)
			VALUES(@comment,@cid,@sid)



GO
CREATE PROC rateInstructor
	@rate decimal(2,1),@sid int,@instId int
	AS
		INSERT INTO StudentRateInstructor
			VALUES(@sid,@instId,@rate)



GO
CREATE PROC viewCertificate
	@cid int,@sid int
	AS
		SELECT * 
		FROM StudentCertifyCourse
		WHERE C_id=@cid AND S_id=@sid























