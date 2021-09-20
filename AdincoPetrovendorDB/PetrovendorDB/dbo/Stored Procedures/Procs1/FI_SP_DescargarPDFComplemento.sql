
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <04-12-2018>
-- Description:	<Se consultan los datos para la descarga del PDF Complemento>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/08/2020>
-- Description:	<Se corrigio el parametro de consulta ya que se recibe el dato exacto que se requiere consultar>
-- =============================================

CREATE PROCEDURE [dbo].[FI_SP_DescargarPDFComplemento] --72540
	@IdFacturaComplemento INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	
	--DECLARE @UUID NVARCHAR(100) = (SELECT UUID FROM Adinco.dbo.FI_Factura WHERE IdFactura = @IdFacturaComplemento);
	--DECLARE @IDFACTURA2 INT = (SELECT IdFactura FROM dbo.FI_Factura WHERE UUID = @UUID AND XML <> '');

	SELECT NombreDoc,
			Carpeta,
			Identificador,
			Mime,
			Bucket
	FROM dbo.FI_PDFComplemento
	WHERE IdFacturaComplemento = @IdFacturaComplemento
		AND Activo = 1
END