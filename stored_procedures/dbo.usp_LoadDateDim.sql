USE [DFNB3]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDateDim]    Script Date: 3/29/2021 5:48:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--CREATE PROCEDURE [dbo].[usp_LoadDateDim] (@v_num_years as INT)
ALTER PROCEDURE [dbo].[usp_LoadDateDim] (@v_num_days as INT)
AS
BEGIN
/*****************************************************************************************************************
NAME:    dbo.usp_LoadDateDim
PURPOSE: Load the Date Dimension table

SUPPORT: Jaussi Consulting LLC
         www.jaussiconsulting.net
         jon@jaussiconsulting.net

MODIFICATION LOG:
Ver       Date         Author       Description
-------   ----------   ----------   -----------------------------------------------------------------------------
1.0       11/17/2019   JJAUSSI      1. Built this starter script for LDS BC IT 243
1.0       03/21/2021   Mireya       1. Swap with @v_num_days for better precision
1.0       03/29/2021   Mireya       1. Completed the base data and the date record.

RUNTIME: 
1 sec

NOTES: 
Load the Date Dimension - inspired by the Kimball Group's Calendar Date Dimension

Example usage...

EXEC dbo.usp_LoadDateDim 250;


LICENSE: 
This code is covered by the GNU General Public License which guarantees end users
the freedom to run, study, share, and modify the code. This license grants the recipients
of the code the rights of the Free Software Definition. All derivative work can only be
distributed under the same license terms.

******************************************************************************************************************/

-- Q1: Where to get the sample data from?
-- A1: Here it is...dump it to Excel > Date Dimension - sample v1.0.xlsx

--SELECT d.*
--  FROM RPT.dbo.datedim AS d
-- WHERE d.year_number = 2019
--       OR date_id IN
--                    (
--                     18500101
--                   , 99991231
--                    );



-- Q2: What are the first and last dates in the Date Dimension?
-- A2: Here they are > 99991231 is the go to default date > 250 years total

--SELECT MIN(d.date_id)
--     , MAX(d.date_id)
--  FROM RPT.dbo.datedim AS d;

--SELECT COUNT(1)
--  FROM RPT.dbo.DateDim AS dd;
---- 91,677 = 250 years + 1 day

--SELECT TOP 2 *
--  FROM RPT.dbo.DateDim AS dd
-- ORDER BY dd.date_id DESC;

-- 18500101 -- First day
-- 21001231 -- Last day
-- 99991231 -- Default day

--SELECT d.*
--  FROM RPT.dbo.datedim AS d
-- WHERE d.day_date = format((@v_first_date + n.n), 'yyyy-MM-dd');



-- Q3: How to load the Date Dimension
-- A3: Use dbo.Nums and figure it out



-- 1) Set the oldest date value

DECLARE @v_first_date as datetime

SET @v_first_date = '1849-12-31'



-- 2) Reload the base data

TRUNCATE TABLE dbo.DateDim;

INSERT INTO dbo.DateDim
SELECT CONVERT(VARCHAR, (@v_first_date + n.n), 112) AS date_id
     , FORMAT((@v_first_date + n.n), 'yyyy-MM-dd') AS day_date
     , DATEPART(WEEKDAY, (@v_first_date + n.n)) AS day_number_in_week
     , DAY((@v_first_date + n.n)) AS day_number_in_month
     , DATEPART(dayofyear, (@v_first_date + n.n)) AS day_number_in_year
     , DATENAME(WEEKDAY, (@v_first_date + n.n)) AS day_name
     , FORMAT((@v_first_date + n.n), 'ddd') AS day_abbreviation
     , 1 AS process_day_ind
     , DATENAME(WEEK, (@v_first_date + n.n)) AS week_number_in_year
     , FORMAT(DATEADD(dd, -(DATEPART(dw, (@v_first_date + n.n)) - 1), (@v_first_date + n.n)), 'yyyy-MM-dd') AS week_start_date
     , CONVERT(VARCHAR, DATEADD(dd, -(DATEPART(dw, (@v_first_date + n.n)) - 1), (@v_first_date + n.n)), 112) AS week_start_date_id
     , FORMAT(DATEADD(dd, 7 - DATEPART(dw, (@v_first_date + n.n)), (@v_first_date + n.n)), 'yyyy-MM-dd') AS week_end_date
     , CONVERT(VARCHAR, DATEADD(dd, 7 - DATEPART(dw, (@v_first_date + n.n)), (@v_first_date + n.n)), 112) AS week_end_date_id
     , CASE WHEN DATEPART( dw, (@v_first_date + n.n )) 
	   IN (7,1) THEN 0
	   ELSE 1 END AS weekday_flag
     , CASE WHEN DATEPART( dw, (@v_first_date + n.n )) 
	   IN (7,1) THEN 1
	   ELSE 0 END AS weekend_flag
     , CASE WHEN DATEPART( dw, (@v_first_date + n.n )) 
	   IN (7) THEN 1
	   ELSE 0 END AS last_day_in_week_flag
     , DATEPART(mm, (@v_first_date + n.n )) AS month_number
     , DATENAME(mm, (@v_first_date + n.n)) AS month_name
     , FORMAT((@v_first_date + n.n), 'MMM') AS month_abbreviation
     , DAY(EOMONTH((@v_first_date + n.n))) AS month_last_day_number
     , FORMAT(DATEADD(mm, DATEDIFF(mm, 0, (@v_first_date + n.n)), 0),'yyyy-MM-dd') AS month_start_date
     , CONVERT(VARCHAR, DATEADD(mm, DATEDIFF(mm, 0, (@v_first_date + n.n)), 0), 112) AS month_start_date_id
     , FORMAT(DATEADD(dd, -1, DATEADD(mm, DATEDIFF(mm, 0, (@v_first_date + n.n)) + 1, 0)),'yyyy-MM-dd') AS month_end_date
     , CONVERT(VARCHAR, DATEADD(dd, -1, DATEADD(mm, DATEDIFF(mm, 0, (@v_first_date + n.n)) + 1, 0)), 112) AS month_end_date_id
     , FORMAT(DATEADD(DAY, -(DAY((@v_first_date + n.n ))), (@v_first_date + n.n )),'yyyy-MM-dd') AS month_end_date_previous
     , CONVERT(VARCHAR, DATEADD(DAY, -(DAY((@v_first_date + n.n ))), (@v_first_date + n.n )), 112) AS month_end_date_previous_id
     , CASE WHEN DATEPART(dd, (@v_first_date + n.n )) = DAY(EOMONTH(@v_first_date + n.n ))  THEN 1
		ELSE 0 END AS last_day_in_month_flag 
     , DATEPART( qq, (@v_first_date + n.n )) AS quarter_number
     , CASE WHEN DATEPART(qq, (@v_first_date + n.n)) = 1 THEN 'Q1'
     		WHEN DATEPART(qq, (@v_first_date + n.n)) = 2 THEN 'Q2'
     		WHEN DATEPART(qq, (@v_first_date + n.n)) = 3 THEN 'Q3'
     		WHEN DATEPART(qq, (@v_first_date + n.n)) = 4 THEN 'Q4' END AS quarter_name
     , CASE WHEN DATEPART(qq, (@v_first_date + n.n)) = 1 THEN '1'
     		WHEN DATEPART(qq, (@v_first_date + n.n)) = 2 THEN '2'
     		WHEN DATEPART(qq, (@v_first_date + n.n)) = 3 THEN '3'
     		WHEN DATEPART(qq, (@v_first_date + n.n)) = 4 THEN '4' END AS quarter_code
     , FORMAT(DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)), 0),'yyyy-MM-dd') AS quarter_start_date
     , CONVERT(VARCHAR, DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)), 0), 112) AS quarter_start_date_id
     , FORMAT(DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)) +1, 0)),'yyyy-MM-dd') AS quarter_end_date
     , CONVERT(VARCHAR, DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)) +1, 0)), 112) AS quarter_end_date_id
     , CASE WHEN  DATEPART(dd,(@v_first_date + n.n)) = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)) +1, 0)) 
		THEN 1 
		ELSE 0 END AS last_day_in_quarter_flag
     , DATEPART(yy, (@v_first_date + n.n)) AS year_number
     , FORMAT(DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)), 0),'yyyy-MM-dd') AS quarter_start_date
     , CONVERT(VARCHAR, DATEADD(yy, DATEDIFF(yy, 0, (@v_first_date + n.n)), 0), 112) AS year_start_date_id
     , FORMAT(DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)) +1, 0)),'yyyy-MM-dd') AS year_end_date
     , CONVERT(VARCHAR, DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, (@v_first_date + n.n)) +1, 0)), 112) AS year_end_date_id
     , CONVERT(VARCHAR(6),DATEADD(yy, DATEDIFF(yy, 0, (@v_first_date + n.n)), + 1), 112) AS yyyymm
     , CASE WHEN DATEPART( dy, (@v_first_date + n.n )) 
	   IN (365) THEN 1
	   ELSE 0 END AS last_day_in_year_flag
     , NULL AS holiday_ind -- Challenge field
     , NULL AS holiday_name -- Challenge field
  FROM dbo.Nums AS n
  --WHERE n.n <= (365 * @v_num_years)
  WHERE n.n <= (@v_num_days + 1)
  ORDER BY 1;



-- 3) Reload the default date record

INSERT INTO dbo.DateDim
SELECT 99991231 AS date_id
     , '9999-12-31' AS day_date
     , 0 AS day_number_in_week
     , 0 AS day_number_in_month
     , 0 AS day_number_in_year
     , 'NA' AS day_name
     , 'NA' AS day_abbreviation
     , 1 AS process_day_ind
     , 0 AS week_number_in_year
     , '9999-12-31' AS week_start_date
     , 99991231 AS week_start_date_id
     , '9999-12-31' AS week_end_date
     , 99991231 AS week_end_date_id
     , 0 AS weekday_flag
     , 0 AS weekend_flag
     , 0 AS last_day_in_week_flag
     , 0 AS month_number
     , 'NA' AS month_name
     , 'NA' AS month_abbreviation
     , 0 AS month_last_day_number
     , '9999-12-31' AS month_start_date
     , 99991231 AS month_start_date_id
     , '9999-12-31' AS month_end_date
     , 99991231 AS month_end_date_id
     , '9999-12-31' AS month_end_date_previous
     , 99991231 AS month_end_date_previous_id
     , 0 AS last_day_in_month_flag
     , 0 AS quarter_number
     , 'NA' AS quarter_name
     , 'NA' AS quarter_code
     , '9999-12-31' AS quarter_start_date
     , 99991231 AS quarter_start_date_id
     , '9999-12-31' AS quarter_end_date
     , 99991231 AS quarter_end_date_id
     , 0 AS last_day_in_quarter_flag
     , 9999 AS year_number
     , '9999-12-31' AS year_start_date
     , 99991231 AS year_start_date_id
     , '9999-12-31' AS year_end_date
     , 99991231 AS year_end_date_id
     , 999912 AS yyyymm
     , 0 AS last_day_in_year_flag
     , NULL AS holiday_ind -- Challenge field
     , NULL AS holiday_name -- Challenge field
	 ;
  END;

