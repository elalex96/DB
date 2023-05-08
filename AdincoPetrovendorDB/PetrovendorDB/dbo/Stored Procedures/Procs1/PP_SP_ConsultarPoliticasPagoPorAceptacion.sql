-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-09-2018>
-- Description:	<Se consultan las politicas de pago por IdAceptacion>
-- =============================================
-- Author:		Luis David
-- Create date: 04/11/2021
-- Description:	Reacomodo de tablas para optimización
-- =============================================
CREATE PROCEDURE PP_SP_ConsultarPoliticasPagoPorAceptacion
	@IdAceptacionPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT pp.PoliticaPago
	FROM dbo.MM_AceptacionPedido ap
	INNER JOIN dbo.PP_PoliticasPago pp 
	ON ap.IdProveedor = pp.IdProveedor
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
END