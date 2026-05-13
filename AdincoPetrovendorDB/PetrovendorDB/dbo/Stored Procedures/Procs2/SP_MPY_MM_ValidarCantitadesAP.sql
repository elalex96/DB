
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <26-06-2018>
-- Description:	<Se consultan las cantidades registradas en la aceptacion de pedido y la factura para su validacion>
-- =============================================

CREATE procedure [dbo].[SP_MPY_MM_ValidarCantitadesAP] 
	@IdFactura INT,
	@IdAceptacionPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	DECLARE @TotalAceptacion MONEY
	DECLARE @CURRENCY NVARCHAR(10);

	DECLARE @IDPROFORMA INT = (SELECT TOP 1 PSES.IdPRESES 
								FROM Adinco.dbo.CO_SAPPRESES AS PSES
								LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP 
										ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
											AND  AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS
								WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)


	SELECT @TotalAceptacion = MontoTotalPrefactura
	FROM Adinco.dbo.CO_SAPPRESES
	WHERE IdPRESES = @IDPROFORMA

	SELECT 
			ISNULL(SubTotal,0) AS TotalFactura,
			ISNULL(@TotalAceptacion,0) AS TotalAceptacion
	FROM dbo.FI_Factura
	WHERE IdFactura = @IdFactura

END


