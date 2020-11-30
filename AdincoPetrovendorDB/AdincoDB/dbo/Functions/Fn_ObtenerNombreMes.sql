create FUNCTION [dbo].[Fn_ObtenerNombreMes](@Language INT, @idMes INT)
RETURNS varchar(30)
AS BEGIN    
DECLARE @MonthName varchar(30);

	SET @MonthName = 
	(SELECT 
	CASE @Language WHEN 1 THEN Mes ELSE MesEng END
	FROM [dbo].[AP_Mes] WHERE idMes = @idMes);	

	RETURN @MonthName
END