-- =============================================
-- Author:		Daniel Moreno
-- Create date: 2022-03-16
-- Description:	Procedimiento almacenado que ACTUALIZA la información de la carta CN ligada a una factura
-- =============================================
CREATE PROC p_FI_CCNFactura_UPD
@pIdDocumento INT,
@pIdAWS INT
as



	UPDATE Petrovendor..S_Documento_S3
	SET Identificador = AWS.UUIDAmazon,
		Mime = AWS.Meta,
		Bucket = ISNULL(AWS.Bucket,D.Bucket),
		NombreDocumento = AWS.NombreArchivo
	FROM Petrovendor..S_Documento_S3 D
	INNER JOIN AWS_Documentos AWS ON AWS.AWSDocumentoId = @pIdAWS
	WHERE IdDocumento = @pIdDocumento