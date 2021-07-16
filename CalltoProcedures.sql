-- --------------------------------------------------------------------------------
-- Shanique Panton
-- IT 112-400
-- Final Project
-- 07/24/2020
------------------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON
------------------------------------------------------------------------------------------
--11. The last item on the list is the calls to the stored procedures. 
--You need to provide these on a SEPARATE .sql file called CallsToStoredProcs.sql. 
--Remember when you run the script to Create a stored procedure, it can be called from anywhere. 
--Don’t let this trip you up. You are “Executing” what you created in the first script. 
--Don’t comment anything out in script #2 just run the first script, then run the 2nd script and there
--should be no errors and data should be entered into the correct tables. In the CallsToStoredProcs.sql
--script, you will have the following calls to your stored procs.
--a) 8 patients for each study for screening.
--b) 5 patients randomized for each study. (including assigning drug kit)
--c) 4 patients (2 randomized and 2 not randomized patients) withdrawn from each study.
-----------------------------------------------------------------------------------------------------------

--a.1
DECLARE  @intPatientID  AS INTEGER =0
DECLARE @DOB AS DATE =CONVERT(DATE,'13/12/2019',103)
DECLARE @ScreenDate AS DATE = CONVERT(date, getdate())

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,2,@DOB,2,157,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID)  


--a.2
DECLARE @DOB1 AS DATE =CONVERT(DATE,'27/12/1994',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,3,@DOB1,1,157,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID)  


--a.3
DECLARE @DOB2 AS DATE =CONVERT(DATE,'27/03/1994',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,5,@DOB2,2,187,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID)  



--a.4
DECLARE @DOB3 AS DATE =CONVERT(DATE,'27/04/1994',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,3,@DOB3,1,187,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID)  

--a.5
DECLARE @DOB4 AS DATE =CONVERT(DATE,'11/04/1994',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,6,@DOB4,2,287,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID) 

--a.6
DECLARE @DOB5 AS DATE =CONVERT(DATE,'16/05/1994',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,2,@DOB5,1,155,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID) 

--a.7
DECLARE @DOB6 AS DATE =CONVERT(DATE,'21/02/1968',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,2,@DOB6,2,155,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID) 

--a.8
DECLARE @DOB7 AS DATE =CONVERT(DATE,'05/02/1970',103)

SELECT @intPatientID = MAX(@intPatientID)+1
EXECUTE uspScreenPatients @intPatientID OUTPUT,2,@DOB7,1,155,@ScreenDate 
PRINT 'Patient ID = ' + CONVERT (VARCHAR,@intPatientID) 

----------------------------------------------------------------------------------------------------------
--b.1

DECLARE @intDrugKitID AS INTEGER 
DECLARE @intRandomCode AS INTEGER

EXECUTE uspRandomizeStudy54321 @intDrugKitID OUTPUT,2
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

--b.2

EXECUTE uspRandomize12345  4 
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)


--b.3

EXECUTE uspRandomizeStudy54321  @intDrugKitID OUTPUT,5 
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)


--b.4

EXECUTE uspRandomize12345  7
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

--b.5

EXECUTE uspRandomizeStudy54321  @intDrugKitID OUTPUT ,8 
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

--b.6

EXECUTE uspRandomize12345  9 
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

--b.7

EXECUTE uspRandomizeStudy54321  @intDrugKitID OUTPUT ,11
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)
--b.8

EXECUTE uspRandomizeStudy54321  @intDrugKitID OUTPUT ,10
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

--b.9
EXECUTE uspRandomize12345  12 
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

--b.10
EXECUTE uspRandomize12345  13 
PRINT 'Patient ID ='+ CONVERT (VARCHAR,@intPatientID)

---------------------------------------------------------------------------------------------------------
--c.1
--Randomized

DECLARE @dtmVist AS DATE =CONVERT(DATE,GETDATE(),103)
DECLARE @intVisitID AS INTEGER 
DECLARE @intWithdrawReasonID AS INTEGER

EXECUTE uspWithdrawPatients @intVisitID OUTPUT,2,@dtmVist, 2

--c.2
--Randomized
EXECUTE uspWithdrawPatients @intVisitID OUTPUT,4,@dtmVist, 1

--c.3
--Not Randomized
EXECUTE uspWithdrawPatients @intVisitID OUTPUT,1,@dtmVist, 4

--c.4 
--Not Randomized
EXECUTE uspWithdrawPatients @intVisitID OUTPUT,3,@dtmVist,6



