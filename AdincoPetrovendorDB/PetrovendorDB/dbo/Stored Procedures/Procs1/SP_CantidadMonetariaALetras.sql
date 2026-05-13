-- =============================================
-- Author:		Abel Rivera
-- Create date: <>
-- Description:	Convierte una cantidad monetaria a su representacion en texto
-- =============================================
CREATE PROCEDURE [dbo].[SP_CantidadMonetariaALetras]
@IdPedido INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdSolicitudPedido INT 
	DECLARE @IdFactura INT 
	DECLARE @CANTIDAD_A_CONVERTIR DECIMAL(18,2)

	SET @IdSolicitudPedido =(SELECT IdSolicitudPedido FROM dbo.MM_Pedido WHERE IdPedido= @IdPedido)

	SET @IdFactura = (SELECT IdFactura FROM dbo.CO_RegistroPedido WHERE IdSolicitudPedido=@IdSolicitudPedido)
	IF @IdFactura IS NOT NULL 
	BEGIN 
		SET @CANTIDAD_A_CONVERTIR =(SELECT MontoConIva FROM dbo.FI_Factura  WHERE IdFactura= @IdFactura)
		 
	END 
	ELSE
    BEGIN
		SET @CANTIDAD_A_CONVERTIR = ( SELECT SUM(PD.Subtotal) AS Total
	                              FROM MM_Pedido AS P
								  INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
								  WHERE P.IdPedido = @IdPedido )
	END 
	

    SELECT 'CANTIDAD CON LETRA: ' + dbo.CantidadConLetra(@CANTIDAD_A_CONVERTIR) AS RepresentacionEnLetras
	
	


END

