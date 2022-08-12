-- =============================================
-- Author:		Daniel Moreno
-- Create date: 2022-03-16
-- Description:	Procedimiento almacenado que ACTUALIZA la información de la carta CN ligada a una factura
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	09 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
-- =============================================
CREATE PROC [dbo].[p_FI_CCNFactura_UPD]
    @pIdDocumento INT,
    @pIdAWS INT
AS
UPDATE Petrovendor.dbo.S_Documento_S3
SET Petrovendor.dbo.S_Documento_S3.Identificador = AWS_Documentos.UUIDAmazon,
    Petrovendor.dbo.S_Documento_S3.Mime = AWS_Documentos.Meta,
    Petrovendor.dbo.S_Documento_S3.Bucket = ISNULL(AWS_Documentos.Bucket, Petrovendor.dbo.S_Documento_S3.Bucket),
    Petrovendor.dbo.S_Documento_S3.NombreDocumento = AWS_Documentos.NombreArchivo
FROM Petrovendor.dbo.S_Documento_S3 (NOLOCK)
    INNER JOIN AWS_Documentos (NOLOCK)
        ON AWS_Documentos.AWSDocumentoId = @pIdAWS
WHERE Petrovendor.dbo.S_Documento_S3.IdDocumento = @pIdDocumento