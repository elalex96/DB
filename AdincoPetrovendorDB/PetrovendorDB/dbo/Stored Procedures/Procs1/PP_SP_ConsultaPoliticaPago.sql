
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <18-09-2018>
-- Description:	<Se consultan las politicas de pagos por proveedor>
-- =============================================

CREATE PROCEDURE PP_SP_ConsultaPoliticaPago
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT PoliticaPago
	FROM dbo.PP_PoliticasPago
	WHERE IdProveedor = @IdProveedor
END