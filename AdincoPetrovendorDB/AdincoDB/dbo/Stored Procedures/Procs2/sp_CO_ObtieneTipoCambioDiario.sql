
CREATE PROCEDURE dbo.sp_CO_ObtieneTipoCambioDiario
@Fecha as varchar(10)
AS
BEGIN

	SELECT 
			Fecha, 
			FIX, 
			PublicacionDOF,  
			ParaPagos 
	FROM	[dbo].[CO_TipoCambioDolarDiario]
	WHERE	CONVERT(VARCHAR,Fecha,103)  = CONVERT(VARCHAR,CAST(@Fecha AS DateTime),103);
END