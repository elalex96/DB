
-- select dbo.[fnGetExtension]('asdas.sad.xls')
create FUNCTION [dbo].[fnGetExtension] 
( 
    @string NVARCHAR(200)
) 
RETURNS varchar(100)
 

BEGIN 
   
   declare @result varchar(100),
		@i int,
		 @delimiter CHAR(1) = '.'

   declare @output TABLE(id int identity(1,1), splitdata varchar(max))

  
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

   select @i = max(id)
   from @output

   select @result  = '.' + isnull(splitdata,'')
   from @output
   where id = @i




   return @result

END 


