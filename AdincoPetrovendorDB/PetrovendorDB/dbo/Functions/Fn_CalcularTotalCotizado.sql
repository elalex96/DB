-- =============================================
-- Author: Alexander Gomez
-- Create date: 12/03/2019
-- Description: Calcular por el idpeticionoferta el total de una cotizacion apartir de los detalles del mismo
-- =============================================

CREATE FUNCTION Fn_CalcularTotalCotizado
	( @IDPETICIONOFERTA INT)
RETURNS MONEY
AS
	BEGIN
		DECLARE @TOTALCOTIZACION MONEY

		SELECT
			@TOTALCOTIZACION = SUM(POD.Disponibilidad * POD.PrecioUnitario)
		FROM dbo.MM_PeticionOfertaDetalle AS POD
		WHERE POD.IdPeticionOferta = @IDPETICIONOFERTA

		RETURN @TOTALCOTIZACION
	END
