
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-09-2018>
-- Description:	<Se consultan las politicas de pago de la operadora por IdPedido>
-- =============================================

CREATE PROCEDURE PP_SP_ConsultarPoliticasPagoPorPedido	
	@IdPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN

	SELECT pp.PoliticaPago 
	FROM dbo.MM_Pedido p
	INNER JOIN dbo.PP_PoliticasPago pp ON p.IdProveedorCompras = pp.IdProveedor 
	WHERE p.IdPedido = @IdPedido

END
