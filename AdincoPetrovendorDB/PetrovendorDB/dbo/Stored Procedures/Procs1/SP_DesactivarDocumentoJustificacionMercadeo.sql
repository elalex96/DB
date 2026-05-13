USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DesactivarDocumentoJustificacionMercadeo'
)
    DROP PROCEDURE SP_DesactivarDocumentoJustificacionMercadeo;
/****** Object:  StoredProcedure [dbo].[SP_DesactivarDocumentoJustificacionMercadeo]    Script Date: 06/11/2023 06:36:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Pedro Acuña
-- Create date: 04-07-2018
-- Description:	SP para desactivar (eliminar) el documento adjunto del mercadeo
-- =============================================
-- =============================================
-- Author:	Daniel
-- Create date: 08-11-2023
-- Description:	SP para desactivar (eliminar) el documento adjunto del mercadeo o ad directa
-- =============================================

CREATE PROCEDURE [dbo].[SP_DesactivarDocumentoJustificacionMercadeo] @Id INT, @IdSolicitudPedido INT, @IdUsuario INT
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
				UPDATE	MM_PeticionOfertaMercadeoAdjunto
				SET		Activo = 0,
				ModificadoEl= GETDATE(),
				ModificadoPor = @IdUsuario
				WHERE	Id = @Id
			END

		IF ( @TipoAdjudicacion = 4 ) --Adj Directa
			BEGIN
				 UPDATE MM_PeticionOfertaADAdjunto 
				 SET Activo = 0,
				 ModificadoEl = GETDATE(),
				 ModificadoPor = @IdUsuario
				 WHERE IdDocumento = @Id

		END

	END
	
	