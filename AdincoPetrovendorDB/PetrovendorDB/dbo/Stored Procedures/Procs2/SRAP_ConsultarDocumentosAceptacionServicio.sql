DROP PROCEDURE IF EXISTS SRAP_ConsultarDocumentosAceptacionServicio
GO
CREATE PROCEDURE SRAP_ConsultarDocumentosAceptacionServicio
@IdDocumento int,
@IdProveedor int,
@IdAceptacionPedido int
AS
BEGIN
DECLARE @IdPedido INT = (SELECT TOP 1 AP.IdPedido
						FROM dbo.MM_AceptacionPedido AP
						LEFT JOIN dbo.MM_Pedido P 
						ON AP.IdPedido = P.IdPedido
						WHERE  P.IdProveedorCompras = @IdProveedor
							  AND AP.IdAceptacionPedido = @IdAceptacionPedido);
DECLARE @IdSolicitudAceptacionPedido INT = (SELECT IdSolicitudAceptacionPedido 
											FROM MM_SolicitudAceptacionPedido 
											WHERE IdPedido = @IdPedido AND 
											IdAceptacionPedido = @IdAceptacionPedido)
											
		SELECT  D.IdDocumento, D.NombreDocumento,null as Documento,D.Carpeta, D.Extension,
                        D.Identificador, d.Bucket AS Bucket, D.Mime 
        FROM  S_Documento_S3 D 
        WHERE  
			D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
			AND D.IdDocumento=@IdDocumento
			AND D.Activo=1
END
