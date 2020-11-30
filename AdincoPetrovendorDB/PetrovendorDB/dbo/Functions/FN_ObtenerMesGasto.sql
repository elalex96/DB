
-- =============================================
-- Author:		Jose Roman
-- Create date: 04-01-2019
-- Description: Se consulta el mes del gasto
-- =============================================
CREATE FUNCTION FN_ObtenerMesGasto
(
	@IdFactura INT
)
RETURNS DATE
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Mes DATE


	SET @Mes = (SELECT TOP 1 MesPresentacion FROM Adinco.dbo.CO_Registro WHERE IdFactura = @IdFactura)
	
	-- Return the result of the function
	RETURN @Mes;

END

