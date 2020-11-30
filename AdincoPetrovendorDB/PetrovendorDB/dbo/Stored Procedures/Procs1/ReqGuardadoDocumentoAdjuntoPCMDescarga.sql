
-- =============================================
-- Author:		Pedro acuna
-- Create date: 05-02-2020
-- Description:	retornar los datos para la descarga del documento de PCM en la aprobacion de la solicitud de pedido
-- =============================================
CREATE PROCEDURE [dbo].[ReqGuardadoDocumentoAdjuntoPCMDescarga]
    @IdProveedor INT,
    @IdSolicitudPedido INT
AS
BEGIN
    SELECT IdDocumento,
           NombreDocumento,
		   Extension,
		   CONCAT(Carpeta,Identificador)
    FROM dbo.PCMDocumentoAdjunto
    WHERE IdProveedor = @IdProveedor
          AND IdSolicitucPedido = @IdSolicitudPedido
          AND Activo = 1
		  AND IdTipoDocumento = 28 -- Requisicion de PCM adjunto

END;

