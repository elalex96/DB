
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-12-2018>
-- Description:	<Se valida si existen complementos para una factura>
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/10/2021
-- Description:	Se contemplan los complementos de adinco
-- =============================================

CREATE PROCEDURE [dbo].[FI_ValidarExisteComplemento]	
	@IdFactura INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	
	DECLARE @UUIDFACTURA NVARCHAR(1000) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura);
	DECLARE @COMPLEMENTOS INT = 0;

	--COMPLEMENTOS PETROVENDOR
	SELECT 
		@COMPLEMENTOS = COUNT(IdComplemento)
	FROM Petrovendor.dbo.FI_FacturaComplemento
	WHERE IdFactura = @IdFactura;
--	AND IsEliminado IS NULL;
	

	--COMPLEMENTOS ADINCO
	SELECT 
		@COMPLEMENTOS = @COMPLEMENTOS + COUNT(IdComplementoDePago)
	FROM Adinco.dbo.FI_CPDocRelacionado
	WHERE IdDocumento = @UUIDFACTURA;

	SELECT @COMPLEMENTOS;


END