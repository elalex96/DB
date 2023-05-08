-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/12/2022
-- Description:	funcion para obtener la fecha con un string para interfaz WDEA
-- =============================================
CREATE FUNCTION convertirFechaString
(
	-- Add the parameters for the function here
	@string NVARCHAR(MAX)
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @start INT, @end INT, @FECHA DATETIME, @delimiter NVARCHAR(2) = '/', @fechastring NVARCHAR(30)

	-- Add the T-SQL statements to compute the return value here
	SET @string = LTRIM(@string);
	SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 
	BEGIN 
        IF @end = 0  
        SET @end = LEN(@string) + 1
        
        Select @fechastring = ISNULL(@fechastring,'') + SUBSTRING(@string, @start, @end - @start) + '-'
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)
	END

	select @fechastring = substring(@fechastring, 1, (len(@fechastring) - 1))

	SET @FECHA = CONVERT(datetime,@fechastring,103)

	-- Return the result of the function
	RETURN @FECHA

END
