-- =============================================
-- Author: Pedro Acuña
-- Create date: 12/06/2018
-- Description: obtener la ultima fecha de modificacion de cada cotizacion de los proveedores
-- =============================================

CREATE FUNCTION Fn_ObtenerUltimaFechaPeticionOfertaDetalle
	( @IdPeticionOferta INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @UltimaFechaPeticionOfertaDetalle DATETIME

		SELECT		@UltimaFechaPeticionOfertaDetalle = MAX ( PO.FechaFinalizado )
		FROM		dbo.MM_PeticionOferta PO
		INNER JOIN	dbo.MM_PeticionOfertaDetalle POD
			ON POD.IdPeticionOferta = PO.IdPeticionOferta
		WHERE
					PO.IdPeticionOferta = @IdPeticionOferta
					AND POD.Cotizado = 1

		RETURN @UltimaFechaPeticionOfertaDetalle
	END