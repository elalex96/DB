


create FUNCTION [dbo].[fnSplitString] 
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata varchar(max))
 
--declare @tabla  table(splitdata int)
--declare @string varchar(50) = '1580',
--	   @delimiter char(1) = ','

BEGIN 
    DECLARE @start INT, @end bigINT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 
    BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        Select Cast((SUBSTRING(@string, @start, @end - @start)) as varchar(max)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)	   
    END 
    RETURN 
END 


