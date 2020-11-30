-- =============================================
-- Author:	Pedro Acuña
-- Create date: 04-07-2018
-- Description:	SP para obtener los datos necesarios para la descarga de amazon s3
-- =============================================

CREATE PROCEDURE SP_DescargarDocAnexoMercadeo @IdDocAnexoMercadeo INT, @IdSolicitudPedido INT
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
				SELECT	NombreDocumento, Carpeta, Identificador, Extension, Mime
				FROM	MM_PeticionOfertaMercadeoAdjunto
				WHERE	Id = @IdDocAnexoMercadeo
			END

		IF ( @TipoAdjudicacion = 4 ) --Adj Directa
			BEGIN
				SELECT	NombreDocumento, Carpeta, Identificador, Extension, Mime
				FROM	MM_PeticionOfertaADAdjunto
				WHERE	IdDocumento = @IdDocAnexoMercadeo
			END
	END