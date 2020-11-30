
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-12-2018>
-- Description:	<Se valida si existen complementos para una factura>
-- =============================================

CREATE PROCEDURE FI_ValidarExisteComplemento	
	@IdFactura INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT COUNT(IdComplemento)
	FROM dbo.FI_FacturaComplemento
	WHERE IdFactura = @IdFactura
END