--===========================================
-- LUIS DAVID
-- 14/07/2022
-- SE OBTIENE EL DOCUMENTO FIELDTICKET/PROFORMA
--===========================================
CREATE PROC SP_DEA_GetDocumento_PorTipo
@IdProveedor int , 
@IdAceptacionPedido int ,
@TipoDocumento varchar(50) 
as
BEGIN
	DECLARE @IdDocumentoFieldTicket INT = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = @TipoDocumento);
	DECLARE @IdPedido INT = (SELECT TOP 1 AP.IdPedido
							FROM dbo.MM_AceptacionPedido AP
							LEFT JOIN dbo.MM_Pedido P 
							ON AP.IdPedido = P.IdPedido
							WHERE  P.IdProveedorCompras = @IdProveedor
								  AND AP.IdAceptacionPedido = @IdAceptacionPedido);
	DECLARE @IdSolicitudAceptacionPedido INT = (SELECT IdSolicitudAceptacionPedido 
											FROM MM_SolicitudAceptacionPedido 
											WHERE IdPedido = @IdPedido AND IdAceptacionPedido = @IdAceptacionPedido);

	DECLARE @IDDOCUMENTO INT = (SELECT TOP 1 D.IdDocumento
			 FROM  S_Documento_S3 D  
			 LEFT JOIN S_Usuario AS US ON D.IdUsuario = US.IdUsuario
			 WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
			 AND D.Activo=1 
			 AND D.IdTipoDocumento = @IdDocumentoFieldTicket)
	SELECT  D.IdDocumento, D.NombreDocumento,null as Documento,D.Carpeta, D.Extension,
                        D.Identificador, d.Bucket AS Bucket, D.Mime 
        FROM  S_Documento_S3 D 
        WHERE  
			D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
			AND D.IdDocumento=@IDDOCUMENTO
			AND D.Activo=1

END		 