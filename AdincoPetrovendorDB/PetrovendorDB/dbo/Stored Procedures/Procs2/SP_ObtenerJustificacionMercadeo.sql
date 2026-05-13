-- =============================================
-- Author:	Pedro Acuña
-- Create date: 04-07-2018
-- Description:	SP para obtener la justificacion de la peticion oferta x solicitud de pedido
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 20/03/2021
-- Description:	Se optimiza la consulta para la pantalla detalle_pedido del issue 984
-- =============================================
CREATE PROCEDURE SP_ObtenerJustificacionMercadeo 
@IdSolicitudPedido INT
AS
	BEGIN
		DECLARE @TipoAdjudicacion INT

		SELECT		@TipoAdjudicacion = ISNULL ( sp.IdTipoProceso, 0 )
		FROM		dbo.MM_SolicitudPedido sp
		LEFT JOIN	MM_TipoPedido tipo
			ON sp.IdTipoProceso = tipo.IdTipoPedido
		WHERE		sp.IdSolicitudPedido = @IdSolicitudPedido

		IF ( @TipoAdjudicacion = 2 ) -- Mercadeo
			BEGIN
				SELECT	JustificacionSolOferta
				FROM	dbo.MM_SolicitudPedido
				WHERE	IdSolicitudPedido = @IdSolicitudPedido
			END

		IF ( @TipoAdjudicacion = 4 ) --Adj Directa
			BEGIN
				SELECT	TOP 1
						JustificacionAdjDirecta
				FROM	MM_PeticionOferta
				WHERE
						IdSolicitudPedido = @IdSolicitudPedido
						AND JustificacionAdjDirecta IS NOT NULL
			END
	END
