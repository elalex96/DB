-- =============================================
-- Author: Pedro Acu�a
-- Create date: 21/06/2018
-- Description: obtener la fecha de registro de la CArta de contenido nacional
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaRegistroACPCN
	( @IdAceptacionPedido INT ,
	  @IdSubcontratista INT,
	  @IdPeticionOferta int )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaRegistro DATETIME

		SELECT		@FechaRegistro = D.CreadoEl
		FROM		dbo.S_Documento_S3 AS D
		INNER JOIN	MM_AceptacionCartaPCN AS AC_PCN
			ON AC_PCN.IdDocumento = D.IdDocumento
		INNER JOIN	MM_AceptacionPedido AS AP
			ON AP.IdAceptacionPedido = AC_PCN.IdAceptacionPedido
		INNER JOIN	MM_Pedido AS P
			ON P.IdPedido = AP.IdPedido
		INNER JOIN	S_TipoValidacionDoc AS TV
			ON TV.IdTipoValidacionDoc = AC_PCN.IdEstatus
		INNER JOIN	S_TipoDocumento AS TU
			ON TU.IdTipoDocumento = D.IdTipoDocumento
		WHERE
					AP.IdAceptacionPedido = @IdAceptacionPedido
					AND P.IdSubcontratista = @IdSubcontratista
					AND P.IdPeticionOferta = @IdPeticionOferta

		RETURN @FechaRegistro
	END