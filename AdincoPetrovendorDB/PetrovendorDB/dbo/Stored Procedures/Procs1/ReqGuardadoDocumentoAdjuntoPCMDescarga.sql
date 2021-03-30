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

    SELECT IdDocumento,--0
           NombreDocumento,--1
		   Extension,--2
		   CONCAT(Carpeta,Identificador),--3
		   Mime,--4
		   Identificador,--5
		   Carpeta--6
    FROM dbo.PCMDocumentoAdjunto
    WHERE IdProveedor = @IdProveedor
          AND IdSolicitucPedido = @IdSolicitudPedido
          AND Activo = 1
		  AND IdTipoDocumento = 28 -- Requisicion de PCM adjunto

END;
