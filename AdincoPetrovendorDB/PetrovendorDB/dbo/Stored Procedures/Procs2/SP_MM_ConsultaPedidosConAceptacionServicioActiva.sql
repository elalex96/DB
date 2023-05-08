-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Pedido Detalle que tienen un estatus de recepción de pedido Aceptado 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosConAceptacionServicioActiva]
	-- Add the parameters for the stored procedure here
	@IdPedido int,
	@IdProveedor int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	

	DECLARE @NOMBRE_PROVEEDOR_VENTAS NVARCHAR(MAX)

	SET	@NOMBRE_PROVEEDOR_VENTAS = (SELECT DISTINCT PV.RazonSocial +' '+ PV.RegimenCapital AS Proveedor
									FROM MM_Pedido AS P 
									INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
									WHERE P.IdPedido = @IdPedido)								

	SELECT P.IdPedido, PV.IdProveedor, 
	@NOMBRE_PROVEEDOR_VENTAS AS Proveedor , 
	SP.UnaSolaEntregaRequerida,
	SP.EntregasParciales,
	SP.FechaEntregaRequerida, 
	CASE SP.EntregasParciales WHEN 1 THEN SP.FechaEntregaFinRequerida ELSE NULL END   AS FechaEntregaFinRequerida
	FROM MM_Pedido AS P 
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	WHERE P.IdPedido = @IdPedido AND SP.IdProveedor= @IdProveedor
	
	

END

