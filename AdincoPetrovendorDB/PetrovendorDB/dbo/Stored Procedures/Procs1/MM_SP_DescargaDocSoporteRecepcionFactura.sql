-- =============================================
-- Author:		<Jose Roman>
-- Create date: <01-04-2018>
-- Description:	<Consulta para descargar el documento de soporte en la recepcion de factura>
--Update date: 10/05/2018 SE RETORNA LAS COLUMNAS DEL DETALLE DEL MATERIAL S3
--Update date: 20/09/2021 Se retorna el bucket
-- =============================================

CREATE procedure [dbo].[MM_SP_DescargaDocSoporteRecepcionFactura]
	@IdDocSoporte INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT '' AS Documento,
		NombreDoc,
		Carpeta,
		Identificador,
		Extension,
		Mime,
		isnull(Bucket,'') Bucket
	FROM dbo.MM_DocSoporteRecepcionFactura
	WHERE IdDocSoporteRecepcionFactura = @IdDocSoporte
END
