-- =============================================
-- Author:		Daniel AC
-- Create date: 24-06-17
-- Description:	CONSULTA materiales para Aceptación de Pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Aceptacion_ConsultaPedidoDetalle]
	-- Add the parameters for the stored procedure here
	@IdPedido int,
	@IdProveedor int
	  	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	CREATE TABLE #PEDIDO_DETALLE(IdPedidoDetalle int, IdMaterialVendedor int,DescripcionCorta nvarchar(max) )
	INSERT INTO #PEDIDO_DETALLE(IdPedidoDetalle, IdMaterialVendedor,DescripcionCorta)
	VALUES(NULL, NULL, 'Seleccionar un Material/Servicio')

	INSERT INTO #PEDIDO_DETALLE(IdPedidoDetalle, IdMaterialVendedor,DescripcionCorta)
	SELECT PD.IdPedidoDetalle,PD.IdMaterialVendedor, M.DescripcionCorta
	FROM MM_PedidoDetalle AS PD
	INNER JOIN MM_Pedido AS P ON P.IdPedido = PD.IdPedido  
	INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	WHERE P.IdPedido = @IdPedido AND P.IdProveedorCompras = @IdProveedor
	AND P.RecepcionServicio= 1 AND PD.RecepcionPedido = 1
	
	SELECT * FROM #PEDIDO_DETALLE

END


