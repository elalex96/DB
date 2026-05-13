-- =============================================
-- Author:		<Jose Roman>
-- Create date: <04-12-2018>
-- Description:	<Se consultan los datos para la descarga del PDF Complemento>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/08/2020>
-- Description:	<Se corrigio el parametro de consulta ya que se recibe el dato exacto que se requiere consultar>
-- =============================================
-- 08/12/2021 MC buscar PDF complemento en Adinco y Petrovendor ISSUE 1509 petrovendor
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
	
	DECLARE @IdFactura INT = 0

	SET @IdFactura = ISNULL((SELECT FP.IdFactura FROM Adinco.dbo.FI_Factura FA JOIN Petrovendor.dbo.FI_Factura FP ON FA.UUID = FP.UUID COLLATE DATABASE_DEFAULT WHERE FA.IdFactura = @IdFacturaComplemento),0)

	--DECLARE @IDFACTURA2 INT = (SELECT IdFactura FROM dbo.FI_Factura WHERE UUID = @UUID AND XML <> '')

	IF(@IdFactura = 0)
	BEGIN

		SELECT NombreDoc,
				Carpeta,
				Identificador,
				Mime,
				Bucket
		FROM Petrovendor.dbo.FI_PDFComplemento
		WHERE IdFacturaComplemento = @IdFacturaComplemento AND Activo = 1

	END
	ELSE
	BEGIN

		SELECT NombreDoc,
				Carpeta,
				Identificador,
				Mime,
				Bucket
		FROM Petrovendor.dbo.FI_PDFComplemento
		WHERE IdFacturaComplemento = @IdFactura AND Activo = 1

	END
END