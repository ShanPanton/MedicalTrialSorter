-- --------------------------------------------------------------------------------
-- Shanique Panton
-- IT 112-400
-- Final Project
-- 07/24/2020

-- ----------------------------------------------------------------------------------------------------
USE dbSQL2;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- -----------------------------------------------------------------------------------------------------
-- Drop Tables
--------------------------------------------------------------------------------------------------------
IF OBJECT_ID( 'TDrugKits' )						IS NOT NULL DROP TABLE	TDrugKits
IF OBJECT_ID( 'TVisits' )				        IS NOT NULL DROP TABLE	TVisits
IF OBJECT_ID( 'TVisitTypes' )					IS NOT NULL DROP TABLE	TVisitTypes
IF OBJECT_ID( 'TPatients' )						IS NOT NULL DROP TABLE	TPatients
IF OBJECT_ID( 'TSites' )						IS NOT NULL DROP TABLE	TSites
IF OBJECT_ID( 'TStates' )						IS NOT NULL DROP TABLE	TStates
IF OBJECT_ID( 'TGenders' )						IS NOT NULL DROP TABLE	TGenders
IF OBJECT_ID( 'TWithdrawReasons' )				IS NOT NULL DROP TABLE	TWithdrawReasons
IF OBJECT_ID( 'TRandomCodes' )					IS NOT NULL DROP TABLE	TRandomCodes
IF OBJECT_ID( 'TStudies' )						IS NOT NULL DROP TABLE	TStudies

------------------------------------------------------------------------------------------------------------
-- Drop VIEWS
-------------------------------------------------------------------------------------------------------------
IF OBJECT_ID( 'vPatients' )						IS NOT NULL DROP VIEW	vPatients
IF OBJECT_ID( 'vRandomizedPatients' )			IS NOT NULL DROP VIEW	vRandomizedPatients
IF OBJECT_ID( 'vRandomCodeStudy1' )			    IS NOT NULL DROP VIEW	vRandomCodeStudy1
IF OBJECT_ID( 'vRandomCodeStudy2' )			    IS NOT NULL DROP VIEW	vRandomCodeStudy2
IF OBJECT_ID( 'vAvailableDrug' )			    IS NOT NULL DROP VIEW	vAvailableDrug
IF OBJECT_ID( 'vWithdrawnPatients' )			IS NOT NULL DROP VIEW	vWithdrawnPatients

-- --------------------------------------------------------------------------------
-- Drop Procedures
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'uspScreenPatients' )			    IS NOT NULL DROP PROCEDURE	uspScreenPatients
IF OBJECT_ID( 'uspWithdrawPatients' )			IS NOT NULL DROP PROCEDURE	uspWithdrawPatients
IF OBJECT_ID( 'uspRandomizeStudy54321' )		IS NOT NULL DROP PROCEDURE	uspRandomizeStudy54321
IF OBJECT_ID( 'uspStoreRandomAssignment' )	    IS NOT NULL DROP PROCEDURE	uspStoreRandomAssignment
IF OBJECT_ID( 'uspRandomize12345' )	            IS NOT NULL DROP PROCEDURE	uspRandomize12345


-- --------------------------------------------------------------------------------
-- Step #1: Create Tables
-- -------------------------------------------------------------------------------

CREATE TABLE TStudies
(
	  intStudyID			INTEGER			NOT NULL
	,strStudyDesc	        VARCHAR(255)	NOT NULL		
	,CONSTRAINT TStudies_PK PRIMARY KEY (  intStudyID )

)

CREATE TABLE TSites
(
   intSiteID			   INTEGER				     NOT NULL
  ,intSiteNumber		   INTEGER		             NOT NULL  
  ,intStudyID		       INTEGER                   NOT NULL
  ,strName		           VARCHAR(255)              NOT NULL
  ,strAddress              VARCHAR(255)              NOT NULL
  ,strCity				   VARCHAR(255)              NOT NULL
  ,intStateID              INTEGER                   NOT NULL
  ,strZip				   VARCHAR(255)				 NOT NULL
  ,strPhone				   VARCHAR(255)              NOT NULL
  ,CONSTRAINT TSites_PK PRIMARY KEY ( intSiteID )


)


CREATE TABLE TPatients
(
	 intPatientID 			INTEGER	            	NOT NULL
	,intPatientNumber       INTEGER					NOT NULL
	,intSiteID 				INTEGER     			NOT NULL		
	,dtmDOB 			    DATE					NOT NULL
	,intGenderID			INTEGER     			NOT NULL
	,intWeight				INTEGER     			NOT NULL
	,intRandomCodeID		INTEGER				--ALLOW NULL
	,CONSTRAINT TPatients_PK PRIMARY KEY ( intPatientID	)
		
)


CREATE TABLE TVisitTypes
(
	  intVisitTypeID 		INTEGER			NOT NULL
	,strVisitDesc			VARCHAR(255)	NOT NULL
	,CONSTRAINT TVisitTypes_PK PRIMARY KEY ( intVisitTypeID  )

)



CREATE TABLE TVisits
(
	 intVisitID				INTEGER	  IDENTITY     	NOT NULL
	,intPatientID			INTEGER					NOT NULL
	,dtmVisit 				DATE					NOT NULL	
	,intVisitTypeID 	    INTEGER     			NOT NULL
	,intWithdrawReasonID    INTEGER		  --Allow Nulls
	,CONSTRAINT TVisits_PK PRIMARY KEY ( intVisitID)		
														
)

CREATE TABLE TRandomCodes
(
	 intRandomCodeID 		INTEGER			NOT NULL
	,intRandomCode			INTEGER			NOT NULL
	,intStudyID			    INTEGER			NOT NULL
	,strTreatment			VARCHAR(1)      NOT NULL  --(A-active or P-placebo)
	,blnAvailable           VARCHAR(1)      NOT NULL --(T or F) use a varchar data type
	,CONSTRAINT TRandomCodes_PK PRIMARY KEY ( intRandomCodeID )
	,CONSTRAINT CK_RandomCodes_STR CHECK(strTreatment='A' or strTreatment='P')
	,CONSTRAINT CK_RandomCodes_BLN CHECK(blnAvailable='T' or blnAvailable='F')
)

CREATE TABLE TDrugKits
(
	 intDrugKitID   		INTEGER			NOT NULL
	,intDrugKitNumber		INTEGER			NOT NULL
	,intSiteID 			    INTEGER			NOT NULL
	,strTreatment 			VARCHAR(1)      NOT NULL  --(A-active or P-placebo)
	,intVisitID             INTEGER	  --(if a Visit ID entered it is already assigned and therefore not available) allow Nulls
	,CONSTRAINT TDrugKits_PK PRIMARY KEY ( intDrugKitID )
	,CONSTRAINT CK_DrugKits CHECK(strTreatment='A' or strTreatment='P')

)


CREATE TABLE TWithdrawReasons
(
	 intWithdrawReasonID   	INTEGER			NOT NULL
	,strWithdrawDesc 		VARCHAR(255)	NOT NULL
	,CONSTRAINT TWithdrawReasons_PK PRIMARY KEY ( intWithdrawReasonID )

)


CREATE TABLE TGenders
(
	 intGenderID   	INTEGER			NOT NULL
	,strGender		VARCHAR(255)	NOT NULL
	,CONSTRAINT TGenders_PK PRIMARY KEY ( intGenderID )

)


CREATE TABLE TStates
(
	 intStateID   	    INTEGER			NOT NULL
	,strStateDesc		VARCHAR(255)	NOT NULL
	,CONSTRAINT TStates_PK PRIMARY KEY ( intStateID  )

)


-- --------------------------------------------------------------------------------
-- Step #2: Identify and Create Foreign Keys
-- --------------------------------------------------------------------------------
--
-- #	Child								Parent						Column(s)
-- -	-----								------						---------
-- 1	TSites							    TStudys			            intStudyID
-- 2	TSites      						TStates					    intStateID
-- 3	TPatients						    TSites					    intSiteID
-- 4	TPatients							TGenders					intGenderID
-- 5	TPatients							TRandomCodes				intRandomCodeID
-- 6    TVisits                             TPatients                   intPatientID
-- 7    TVisits                             TVisitTypes                 intVisitTypeID
-- 8    TVisits                             TWithdrawReasons            intWithdrawReasonID
-- 9    TRandomCodes                        TStudys						intStudyID
-- 10   TDrugKits                           TSites                      intSiteID
-- 11   TDrugKits                           TVisits                     intVistiID

-- 1
ALTER TABLE TSites ADD CONSTRAINT TSites_TStudies_FK
FOREIGN KEY ( intStudyID ) REFERENCES TStudies ( intStudyID )

-- 2
ALTER TABLE TSites ADD CONSTRAINT TSites_TStates_FK
FOREIGN KEY (intStateID ) REFERENCES TStates ( intStateID )

-- 3
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TSites_FK
FOREIGN KEY ( intSiteID ) REFERENCES  TSites ( intSiteID )

-- 4
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TGenders_FK
FOREIGN KEY ( intGenderID ) REFERENCES TGenders ( intGenderID )

-- 5
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TRandomCodes_FK
FOREIGN KEY ( intRandomCodeID ) REFERENCES TRandomCodes ( intRandomCodeID)

--6
ALTER TABLE TVisits ADD CONSTRAINT TVisits_TPatients_FK
FOREIGN KEY ( intPatientID ) REFERENCES TPatients ( intPatientID )

-- 7
ALTER TABLE TVisits ADD CONSTRAINT TVisits_TVisitTypes_FK
FOREIGN KEY ( intVisitTypeID ) REFERENCES TVisitTypes ( intVisitTypeID )

-- 8
ALTER TABLE TVisits ADD CONSTRAINT TVisits_TWithdrawReasons_FK
FOREIGN KEY ( intWithdrawReasonID ) REFERENCES TWithdrawReasons ( intWithdrawReasonID )

-- 9
ALTER TABLE TRandomCodes ADD CONSTRAINT TRandomCodes_TStudies_FK
FOREIGN KEY ( intStudyID ) REFERENCES TStudies ( intStudyID )

-- 10
ALTER TABLE TDrugKits  ADD CONSTRAINT TDrugKits_TSites_FK
FOREIGN KEY ( intSiteID) REFERENCES TSites ( intSiteID )

-- 11
ALTER TABLE TDrugKits  ADD CONSTRAINT TDrugKits_TVisits_FK
FOREIGN KEY ( intVisitID ) REFERENCES TVisits  ( intVisitID )


-- --------------------------------------------------------------------------------
-- Step #3: Add data
-- --------------------------------------------------------------------------------

INSERT INTO TGenders ( intGenderID ,strGender)
VALUES	 ( 1, 'Female')
		,( 2,'Male')
		


INSERT INTO TStates (  intStateID ,strStateDesc)
VALUES	 ( 1, 'Ohio')
		,( 2,'Kentucky')
		,( 3,'Indiana')
		,( 4,'New Jersey')
		,( 5,'Virginia')
		,( 6,'Georgia')
		,( 7,'Iowa')




INSERT INTO TStudies ( intStudyID, strStudyDesc)
VALUES	 ( 1, 'Study 12345')--Random pick list
		,( 2, 'Study 54321')--Random generator



INSERT INTO TSites ( intSiteID,intSiteNumber,intStudyID, strName,strAddress, strCity, intStateID, strZip,strPhone)
VALUES	 ( 1, 101, 1, 'Dr. Stan Heinrich ','123 E. Main St', 'Atlanta',6, '25869','1234567890' )
		,( 2, 111, 1, 'Mercy Hospital','3456 Elmhurst Rd.', 'Secaucus',4, '32659','5013629564' )
		,( 3, 121, 1, 'St. Elizabeth Hospital','976 Jackson Way', 'Ft. Thomas',2, '41258','3026521478')
		,( 4, 501, 2, 'Dr. Robert Adler','9087 W. Maple Ave.', 'Cedar Rapids',7, '42365','6149652574')
		,( 5, 511, 2, 'Dr. Tim Schmitz','4539 Helena Run', 'Mason',1, '45040','5136987462')
		,( 6, 521, 2, 'Dr. Lawrence Snell','9201 NW. Washington Blvd.', 'Bristol',5, '20163','3876510249')



--INSERT INTO TPatients ( intPatientID, intPatientNumber, intSiteID,dtmDOB,intGenderID,intWeight,intRandomCodeID)


INSERT INTO TVisitTypes (intVisitTypeID, strVisitDesc)
VALUES	 ( 1, 'Screening')
		,( 2, 'Randomization')
		,( 3, 'Withdrawal')



--INSERT INTO TVisits ( intVisitID, intPatientID, dtmVisit, intVisitTypeID,intWithdrawReasonID)



INSERT INTO TRandomCodes (intRandomCodeID,intRandomCode, intStudyID,strTreatment,blnAvailable)
VALUES	 ( 1,1000,1,'A','T')
		,( 2,1001,1,'P','T')
		,( 3,1002,1,'A','T')
		,( 4,1003,1,'P','T')
		,( 5,1004,1,'P','T')
		,( 6,1005,1,'A','T')
		,( 7,1006,1,'A','T')
		,( 8,1007,1,'P','T')
		,( 9,1008,1,'A','T')
		,(10,1009,1,'P','T')
		,(11,1010,1,'P','T')
		,(12,1011,1,'A','T')
		,(13,1012,1,'P','T')
		,(14,1013,1,'A','T')
		,(15,1014,1,'A','T')
		,(16,1015,1,'A','T')
		,(17,1016,1,'P','T')
		,(18,1017,1,'P','T')
		,(19,1018,1,'A','T')
		,(20,1019,1,'P','T')

		,(21,5000,2,'A','T')
		,(22,5001,2,'A','T')
		,(23,5002,2,'A','T')
		,(24,5003,2,'A','T')
		,(25,5004,2,'A','T')
		,(26,5005,2,'A','T')
		,(27,5006,2,'A','T')
		,(28,5007,2,'A','T')
		,(29,5008,2,'A','T')
		,(30,5009,2,'A','T')
		,(31,5010,2,'P','T')
		,(32,5011,2,'P','T')
		,(33,5012,2,'P','T')
		,(34,5013,2,'P','T')
		,(35,5014,2,'P','T')
		,(36,5015,2,'P','T')
		,(37,5016,2,'P','T')
		,(38,5017,2,'P','T')
		,(39,5018,2,'P','T')
		,(40,5019,2,'P','T')



INSERT INTO TDrugKits ( intDrugKitID,intDrugKitNumber, intSiteID,strTreatment)
VALUES	 ( 1, 10000, 1,'A')
		,( 2,10001, 1,'A' )    -- don't forget intVisit ID needs to be inserted later
		,( 3,10002, 1,'A' )
		,( 4,10003,1,'P' )
		,( 5,10004,1,'P' )
		,( 6,10005,1,'P' )
		,( 7,10006,2,'A' )
		,( 8,10007,2,'A' )
		,( 9,10008,2,'A' )
		,(10,10009,2,'P' )
		,(11,10010,2,'P' )
		,(12,10011,2,'P' )
		,(13,10012,3,'A' )
		,(14,10013,3,'A' )
		,(15,10014,3,'A' )
		,(16,10015,3,'P' )
		,(17,10016,3,'P' )
		,(18,10017,3,'P' )
		,(19,10018,4,'A' )
		,(20,10019,4,'A' )
		,(21,10020,4,'A' )
		,(22,10021,4,'P' )
		,(23,10022,4,'P' )
		,(24,10023,4,'P' )
		,(25,10024,5,'A' )
		,(26,10025,5,'A' )
		,(27,10026,5,'A' )
		,(28,10027,5,'P' )
		,(29,10028,5,'P' )
		,(30,10029,5,'P' )
		,(31,10030,6,'A' )
		,(32,10031,6,'A' )
		,(33,10032,6,'A' )
		,(34,10033,6,'P' )
		,(35,10034,6,'P' )
		,(36,10035,6,'P' )


INSERT INTO TWithdrawReasons ( intWithdrawReasonID ,strWithdrawDesc)
VALUES	 ( 1, 'Patient withdrew consent')
		,( 2,'Adverse event')
		,( 3,'Health issue-related to study')
		,( 4,'Health issue-unrelated to study')
		,( 5,'Personal reason')
		,( 6,'Completed the study')



		
-------------------------------------------------------------------------------------------------------------------
----2. Create the view that will show all patients at all sites for both studies. 
----You can do this together or 1 view for each study.
-----------------------------------------------------------------------------------------------------------------

GO
CREATE VIEW vPatients

As

SELECT intPatientID, intPatientNumber, intSiteID

FROM TPatients 

GO

SELECT * FROM vPatients

--------------------------------------------------------------------------------------------------------------------------
----3. Create the view that will show all randomized patients, their site and their treatment for both studies. 
----You can do this together or 1 view for each study.
-----------------------------------------------------------------------------------------------------------------------
GO
CREATE VIEW vRandomizedPatients

As

SELECT intPatientID, intPatientNumber, TDK.intSiteID, strTreatment

FROM TPatients AS TP 
	,TDrugKits AS TDK

WHERE TP.intSiteID = TDK.intSiteID


GO
SELECT * FROM vRandomizedPatients

------------------------------------------------------------------------------------------------------------------------
----4.Create the view that will show the next available random codes (MIN) for both studies. This should be 2 separate
----views as the first study only gets the next ID and the second study needs the next ID for each treatment.
------------------------------------------------------------------------------------------------------------------------
GO
CREATE VIEW vRandomCodeStudy1(intRandomCodeID,intRandomCode,intStudyID,strTreatment,blnAvailable)


As

SELECT intRandomCodeID,MIN(TRC.intRandomCode) AS AvailableRandomCode,intStudyID,strTreatment,blnAvailable 

FROM TRandomCodes as TRC

WHERE intStudyID=1

GROUP BY intStudyID, TRC.intRandomCode, TRC.intRandomCodeID,strTreatment,blnAvailable

GO

SELECT * FROM vRandomCodeStudy1
-----------------------------------------------------------------------------------------------------------------------
GO
CREATE VIEW vRandomCodeStudy2(intRandomCodeID,intRandomCode,intStudyID,strTreatment,blnAvailable)

As    -- Not sure that I understand what the second study needs the next ID for each treatment means.

SELECT intRandomCodeID,MIN(TRC.intRandomCode) AS AvailableRandomCode,intStudyID,strTreatment,blnAvailable 

FROM TRandomCodes as TRC

WHERE intStudyID=2

GROUP BY intStudyID, TRC.intRandomCode,intRandomCodeID, strTreatment,blnAvailable

GO

SELECT * FROM vRandomCodeStudy2

----------------------------------------------------------------------------------------------------------------------
----5. Create the view that will show all available drug at all sites for both studies. 
----You can do this together or 1 view for each study.
-----------------------------------------------------------------------------------------------------------------
GO
CREATE VIEW vAvailableDrug (intDrugKitID,intDrugKitNumber,intStudyID,intSiteID,strTreatment,intVisitID)

As

SELECT intDrugKitID ,intDrugKitNumber, intStudyID ,TS.intSiteID,strTreatment,intVisitID

FROM 
	TDrugKits as TDK
	,TSites as TS 

WHERE TDK.intSiteID = TS.intSiteID

GO

-----------------------------------------------------------------------------------------------------------------------------------
----6. Create the view that will show all withdrawn patients, their site, withdrawal date and withdrawal reason for both studies.
------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE VIEW vWithdrawnPatients

As

SELECT TV.intVisitTypeID, TS.intSiteID, TV.dtmVisit ,TV.intPatientID,intWithdrawReasonID 

FROM  TSites as TS
	 ,TVisits as TV

WHERE intVisitTypeID = 3


GO

------------------------------------------------------------------------------------------------------------------
--7.Create other views and functions as needed. Put as much as possible into views and functions so you are
--pulling from them instead of from tables.
-------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------
--8.Create the stored procedure(s) that will screen a patient for both studies. You can do this together
--or 1 for each study.
-----------------------------------------------------------------------------------------------------------------

GO

CREATE PROCEDURE uspScreenPatients
				 @intPatientID     as INTEGER OUTPUT
				,@intSiteID        as INTEGER
				,@dtmDOB		   as DATE
				,@intGenderID	   as INTEGER
				,@intWeight		   as INTEGER
				,@dtmVisit         as DATE
			

AS

SET XACT_ABORT ON

BEGIN TRANSACTION

SELECT @intPatientID = MAX(intPatientID)+1
FROM TPatients (TABLOCKX)

SELECT @intPatientID = COALESCE (@intPatientID,1)

DECLARE @intPatientNumber AS INTEGER 

DECLARE NumberOfPatients CURSOR LOCAL FOR
SELECT (COUNT(*)+1) FROM TPatients WHERE TPatients.intSiteID = @intSiteID

OPEN NumberOfPatients

FETCH FROM NumberOfPatients
INTO @intPatientNumber

CLOSE NumberOfPatients


INSERT INTO TPatients (intPatientID,intPatientNumber,intSiteID,dtmDOB,intGenderID,intWeight)
VALUES (@intPatientID, @intPatientNumber,@intSiteID,@dtmDOB,@intGenderID,@intWeight)



INSERT INTO TVisits (intPatientID, dtmVisit,intVisitTypeID)
VALUES (@intPatientID,@dtmDOB,1)


COMMIT TRANSACTION

GO


---------------------------------------------------------------------------------------------------------------------------------------
--9.Create the stored procedure(s) that will withdraw a patient for both studies. You can do this together or 1 for each 
--study. Remember a patient can go from Screening Visit to Withdrawal without being randomized. This will be up to the Doctor. 
--Your code just has to be able to do it.
---------------------------------------------------------------------------------------------------------------------------------------

GO

CREATE PROCEDURE uspWithdrawPatients
				 @intVisitID          as INTEGER OUTPUT
				,@intPatientID        as INTEGER
				,@dtmVisit            as DATE
				,@intWithdrawReasonID as INTEGER

AS

SET XACT_ABORT ON

BEGIN TRANSACTION

DECLARE @dtmMostRecentVisit AS DATE

DECLARE RecentVisitDate CURSOR LOCAL FOR
SELECT MAX(dtmVisit) FROM TVisits 

OPEN RecentVisitDate

FETCH FROM RecentVisitDate
INTO @dtmMostRecentVisit

CLOSE RecentVisitDate

BEGIN
	IF @dtmMostRecentVisit > @dtmVisit 
		SET @dtmVisit = GETDATE()
END 


INSERT INTO TVisits (intPatientID,dtmVisit,intVisitTypeID,intWithdrawReasonID)
VALUES (@intPatientID,@dtmVisit,3,@intWithdrawReasonID)

COMMIT TRANSACTION

GO


------------------------------------------------------------------------------------------------------------------------
--10.Create the stored procedure(s) that will randomize a patient for both studies. 
--You can do this together or 1 for each study.
--This will include a stored procedure for obtaining a random code as well as a drug kit. 
----------------------------------------------------------------------------------------------------------------------
GO 
CREATE PROCEDURE uspStoreRandomAssignment
				
			    @intDrugKitID    as INTEGER 
			   ,@intRandomCode   as INTEGER
			   ,@intPatientID    as INTEGER
			   
AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN 

DECLARE @intVisitID AS INTEGER

SELECT @intVisitID = MAX(intVisitID)+1
FROM TVisits(TABLOCKX)
SELECT @intVisitID = COALESCE (@intVisitID,1)

INSERT INTO TVisits (intPatientID,dtmVisit,intVisitTypeID)
VALUES (@intPatientID,GETDATE(),2)


UPDATE TDrugKits 
SET intVisitID = @intVisitID
WHERE intDrugKitID = @intDrugKitID


UPDATE TRandomCodes 
SET blnAvailable = 'F'
WHERE intRandomCodeID = @intRandomCode

UPDATE TPatients
SET intRandomCodeID = @intRandomCode
WHERE intPatientID = @intPatientID


END

GO


CREATE PROCEDURE uspRandomizeStudy54321

				 @intDrugKitID        as INTEGER OUTPUT
				,@intPatientID        as INTEGER
				
AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN 

DECLARE @strTreatment AS VARCHAR(255)

	SELECT RAND()

	IF RAND() <= 0.5 
		SET @strTreatment = 'P'
	ELSE
		SET @strTreatment = 'A'
END

DECLARE @studyID AS INTEGER = 2
DECLARE @NumberOfActivePatients AS INTEGER

DECLARE NumberOfActivePatients CURSOR LOCAL FOR

SELECT COUNT(TDK.intDrugKitID)
FROM TSites AS TS JOIN TDrugKits AS TDK on TDK.intSiteID = TS.intSiteID
WHERE TS.intStudyID = @studyID AND TDK.intVisitID IS NOT NULL AND TDK.strTreatment = 'A'

OPEN NumberOfActivePatients

FETCH FROM NumberOfActivePatients
INTO @NumberOfActivePatients
CLOSE NumberOfActivePatients


DECLARE @NumberOfPlaceboPatients as INTEGER
DECLARE NumberOfPlaceboPatients CURSOR LOCAL FOR

SELECT COUNT(TDK.intDrugKitID)
FROM TSites AS TS
JOIN TDrugKits AS TDK on TDK.intSiteID = TS.intSiteID
WHERE TS.intStudyID = @studyID AND TDK.intVisitID is not null AND TDK.strTreatment = 'P'


OPEN NumberOfPlaceboPatients

FETCH FROM NumberOfPlaceboPatients

INTO @NumberOfPlaceboPatients

CLOSE NumberOfPlaceboPatients


BEGIN
    IF @NumberOfActivePatients - @NumberOfPlaceboPatients> 2
        SET @strTreatment = 'P'
    IF @NumberOfPlaceboPatients - @NumberOfActivePatients > 2
        SET @strTreatment = 'A'
END

DECLARE @drugkitID as INTEGER
DECLARE @RandomCodeID as INTEGER


DECLARE DrugKit CURSOR LOCAL FOR
SELECT intDrugKitID
FROM vAvailableDrug
WHERE intVisitID IS NULL AND strTreatment = @strTreatment

OPEN DrugKit
FETCH FROM DrugKit
INTO @drugkitID
CLOSE DrugKit


DECLARE RandomCode CURSOR LOCAL FOR
SELECT intRandomCodeID 
FROM vRandomCodeStudy2
WHERE vRandomCodeStudy2.blnAvailable  = 'T'

DECLARE @intRandomCode AS INTEGER

OPEN RandomCode
FETCH FROM RandomCode
INTO @intRandomCode
CLOSE RandomCode


EXECUTE uspStoreRandomAssignment  @intDrugKitID, @intRandomCode,@intPatientID  


GO
			   
------------------------------------------------------------------------------------------------------------

GO

CREATE PROCEDURE uspRandomize12345
						@intPatientID AS INTEGER

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN 

DECLARE RandomCode CURSOR LOCAL FOR
SELECT intRandomCodeID 
FROM vRandomCodeStudy1
WHERE vRandomCodeStudy1.blnAvailable  = 'T'

DECLARE @intRandomCode AS INTEGER

OPEN RandomCode
FETCH FROM RandomCode
INTO @intRandomCode
CLOSE RandomCode

DECLARE @intDrugKitID AS INTEGER

DECLARE DrugKit CURSOR LOCAL FOR
SELECT intDrugKitID
FROM vAvailableDrug
WHERE intVisitID IS NULL 

OPEN DrugKit
FETCH FROM DrugKit
INTO @intdrugkitID
CLOSE DrugKit


EXECUTE uspStoreRandomAssignment  @intDrugKitID,@intRandomCode,@intPatientID  

END


GO
-------------------------------------------------------------------------------------------------------------------------