
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09-01-2019>
-- Description:	<Se consultan las restricciones de factura registradas por un proveedor>
-- =============================================

CREATE PROCEDURE FI_SP_ConsultarRestriccionFacturaPorProveedor	
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT Activo, Excedente
	FROM dbo.FI_RestriccionFactura
	WHERE IdProveedor = @IdProveedor
END