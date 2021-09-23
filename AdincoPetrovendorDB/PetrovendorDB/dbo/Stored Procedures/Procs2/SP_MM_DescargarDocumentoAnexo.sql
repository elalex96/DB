drop procedure if exists SP_MM_DescargarDocumentoAnexo
--======================================
-- Modificado por: Luis David
-- Modificado el: 21/09/2021
-- Descripcion: Se retorna el bucket
--======================================
go
CREATE PROCEDURE [dbo].[SP_MM_DescargarDocumentoAnexo]
	@IdDocumentoAnexo INT
AS
BEGIN
	SELECT Nombre, '' AS Documento, Carpeta, Identificador, Extension, Mime, ISNULL(Bucket, '') as Bucket
		FROM dbo.MM_DocumentosAnexos
		WHERE IdDocumentoAnexo = @IdDocumentoAnexo

END
