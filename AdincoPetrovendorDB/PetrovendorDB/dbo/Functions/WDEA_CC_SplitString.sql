DROP FUNCTION IF EXISTS WDEA_CC_SplitString
GO
CREATE FUNCTION [dbo].[WDEA_CC_SplitString]
    (
        @List NVARCHAR(MAX),
        @Delim VARCHAR(255)
    )
    RETURNS varchar(200)
    AS
	begin
	declare @centrocosto varchar(200);
    declare @Temp TABLE (valor varchar(200), idx int);
	
	insert into @Temp(valor, idx)
	(SELECT [Value], idx = RANK() OVER (ORDER BY n) FROM 
          ( 
            SELECT n = Number, 
              [Value] = LTRIM(RTRIM(SUBSTRING(@List, [Number],
              CHARINDEX(@Delim, @List + @Delim, [Number]) - [Number])))
            FROM (SELECT Number = ROW_NUMBER() OVER (ORDER BY name)
              FROM sys.all_objects) AS x
              WHERE Number <= LEN(@List)
              AND SUBSTRING(@Delim + @List, [Number], LEN(@Delim)) = @Delim
          ) AS y
        ) 
    set @centrocosto = (select top 1 valor from @Temp where idx = 3)
	return @centrocosto
	end;