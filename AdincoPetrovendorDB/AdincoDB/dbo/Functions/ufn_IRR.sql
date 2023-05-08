CREATE FUNCTION [dbo].[ufn_IRR]
  (
   @strIDs VARCHAR(8000),
   @guess DECIMAL(30,10)
  )
RETURNS DECIMAL(30, 10)
AS 
  BEGIN
  -- FUNCION PARA CALCULAR LA TASA INTERNA DE RETORNO
    DECLARE @t_IDs TABLE (
        id INT IDENTITY(0, 1),
        value DECIMAL(30, 10)
    )
    DECLARE @strID VARCHAR(12),@sepPos INT,@NPV DECIMAL(30, 10)
    SET @strIDs = COALESCE(@strIDs + ',', '')
    SET @sepPos = CHARINDEX(',', @strIDs)
    WHILE @sepPos > 0 
      BEGIN
        SET @strID = LEFT(@strIDs, @sepPos - 1)
        INSERT INTO @t_IDs ( value ) SELECT ( CAST(@strID AS DECIMAL(20, 10)) ) WHERE ISNUMERIC(@strID) = 1
        SET @strIDs = RIGHT(@strIDs, DATALENGTH(@strIDs) - @sepPos)
        SET @sepPos = CHARINDEX(',', @strIDs)
      END

    SET @guess = CASE WHEN ISNULL(@guess, 0) <= 0 THEN 0.00001 ELSE @guess END

    SELECT @NPV = SUM(value / POWER(1 + @guess, id)) FROM @t_IDs
    WHILE @NPV > 0 
      BEGIN
        SET @guess = @guess + 0.00001
        SELECT @NPV = SUM(value / POWER(1 + @guess, id)) FROM @t_IDs
      END
    RETURN @guess
END