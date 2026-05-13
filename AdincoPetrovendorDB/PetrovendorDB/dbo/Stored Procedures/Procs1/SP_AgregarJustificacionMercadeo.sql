-- =============================================
-- Author:	Pedro Acuña
-- Create date: 03-07-2018
-- Description:	SP que agrega el texto de la justificacion de la peticion oferta del mercadeo
-- =============================================

CREATE PROCEDURE SP_AgregarJustificacionMercadeo @IdSolicitudPedido INT, @Justificacion NVARCHAR(MAX)
AS
	BEGIN
		UPDATE	dbo.MM_SolicitudPedido
		SET		JustificacionSolOferta = @Justificacion
		WHERE	IdSolicitudPedido = @IdSolicitudPedido
	END