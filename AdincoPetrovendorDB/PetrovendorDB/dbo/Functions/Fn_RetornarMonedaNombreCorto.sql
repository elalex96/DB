-- =============================================
-- Author: Pedro Acu�a
-- Create date: 18/06/2018
-- Description: retornar el nombre corto de la moneda
-- =============================================

CREATE FUNCTION Fn_RetornarMonedaNombreCorto
	( @IdMoneda INT )
RETURNS NVARCHAR(100)
AS
	BEGIN
		DECLARE @NombreMoneda NVARCHAR(100)

		SELECT	@NombreMoneda = TipoMonedaCorto
		FROM	dbo.PV_TipoMoneda
		WHERE	IdMoneda = @IdMoneda

		RETURN @NombreMoneda
	END