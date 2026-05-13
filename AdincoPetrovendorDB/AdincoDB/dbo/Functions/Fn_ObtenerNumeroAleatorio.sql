CREATE FUNCTION dbo.Fn_ObtenerNumeroAleatorio(@Lower INT, @Upper INT)
RETURNS INT
AS BEGIN    

	DECLARE @Random INT;
	DECLARE @rndValue FLOAT;
	SELECT @rndValue= MyRAND FROM  Get_RAND;

	SELECT @Random = ROUND(((@Upper - @Lower -1) * @rndValue + @Lower), 0)
	RETURN @Random
END