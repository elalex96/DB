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