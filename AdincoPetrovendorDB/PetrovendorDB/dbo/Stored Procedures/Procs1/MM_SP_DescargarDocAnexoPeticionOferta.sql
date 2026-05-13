-- =============================================
-- Author:		<Jose Roman>
-- Create date: <05-04-2018>
-- Description:	<Consulta para la descarga documento anexo en la peticion de oferta>
-- Update :	DANIEL AC 10/05/2018 SE RETORNA NUEVAS COLUMNAS DE DETALLE DE ARCHIVO S3
-- =============================================

CREATE procedure [dbo].[MM_SP_DescargarDocAnexoPeticionOferta]
	@IdDocAnexoPeticionOferta INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
SELECT '' AS Documento, RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(NomDocumento, ',',''),'"', ''), '-', ''), ' ', ''), 35), Carpeta, Identificador, Extension, Mime, Isnull(Bucket,'') as Bucket
	FROM dbo.MM_DocAnexosPeticionOferta
	WHERE IdDocAnexoPeticionOferta = @IdDocAnexoPeticionOferta
END