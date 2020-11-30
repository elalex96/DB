-- =============================================
-- Author:		Daniel AC
-- Create date: 24-06-17
-- Description:	CONSULTA Aceptación Servicio/Material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaAceptacionServicioAllMaterialProveedor]
	-- Add the parameters for the stored procedure here
	@IdPedidoDetalle int
 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- PD Pedido Detalle
	-- AS Aceptación de Servicio true 

	DECLARE @IdPedido int 
	DECLARE @NumPDxProveedor int 
	DECLARE @NumPDxProveedorAS int
	DECLARE @Response bit 


	-----CREATE TABLE #DATOS_PROVEEDOR()
	SET @IdPedido =
	(SELECT PD.IdPedido
	FROM MM_PedidoDetalle AS PD
	INNER JOIN MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	WHERE IdPedidoDetalle = @IdPedidoDetalle)


	SET @NumPDxProveedorAS  =
	(SELECT COUNT(PD.IdPedidoDetalle) AS Count_PD
	FROM MM_PedidoDetalle AS PD
	WHERE PD.IdPedido = @IdPedido
	AND PD.AceptacionServicio= 1)

	IF @NumPDxProveedor = @NumPDxProveedorAS
	BEGIN 
		SET @Response = 1
	END 
	ELSE
	BEGIN 
		SET @Response = 0
	END 


	SELECT @Response


END

