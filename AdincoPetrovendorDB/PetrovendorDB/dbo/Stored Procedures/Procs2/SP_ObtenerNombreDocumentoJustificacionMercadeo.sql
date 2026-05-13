-- =============================================
-- Author:	Pedro Acuña
-- Create date: 04-07-2018
-- Description:	SP para obtener los textos de la justificacion del mercadeo
-- =============================================

CREATE PROCEDURE SP_ObtenerNombreDocumentoJustificacionMercadeo @IdSolicitudPedido INT
AS
	BEGIN
		DECLARE @TipoAdjudicacion INT

		SELECT		@TipoAdjudicacion = ISNULL ( sp.IdTipoProceso, 0 )
		FROM		dbo.MM_SolicitudPedido sp
		LEFT JOIN	MM_TipoPedido tipo
			ON tipo.IdTipoPedido = sp.IdTipoProceso
		WHERE		sp.IdSolicitudPedido = @IdSolicitudPedido

		IF ( @TipoAdjudicacion = 2 ) -- Mercadeo
			BEGIN
				SELECT	Id, NombreDocumento
				FROM	dbo.MM_PeticionOfertaMercadeoAdjunto
				WHERE
						Activo = 1
						AND IdSolicitudPedido = @IdSolicitudPedido
			END

		IF ( @TipoAdjudicacion = 4 ) --Adj Directa
			BEGIN
				SELECT	IdDocumento AS Id, NombreDocumento
				FROM	dbo.MM_PeticionOfertaADAdjunto
				WHERE
						Activo = 1
						AND IdSolicitudPedido = @IdSolicitudPedido
			END
	END