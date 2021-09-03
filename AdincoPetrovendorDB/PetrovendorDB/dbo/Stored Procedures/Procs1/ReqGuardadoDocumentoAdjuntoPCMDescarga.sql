-- =============================================
-- Author:		Pedro acuna
-- Create date: 05-02-2020
-- Description:	retornar los datos para la descarga del documento de PCM en la aprobacion de la solicitud de pedido
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 02/09/2021
-- Description:	SE AGREGA LA COLUMNA BUCKET
-- =============================================
DROP PROCEDURE IF EXISTS ReqGuardadoDocumentoAdjuntoPCMDescarga
GO
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
		   Carpeta,--6
		   Isnull(Bucket,'') as Bucket
    FROM dbo.PCMDocumentoAdjunto
    WHERE 
          Activo = 1
		  AND IdTipoDocumento = 28 -- Requisicion de PCM adjunto
		  AND IdProveedor = @IdProveedor
          AND IdSolicitucPedido = @IdSolicitudPedido
END;