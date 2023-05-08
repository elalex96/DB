-- =============================================
-- Author:		Alexander Gomez
-- Update date: 14-06-18
-- Description:	Muestra Detalle de aceptación pedido detalle 
-- =============================================
CREATE procedure [dbo].[SP_PR_MPY_MM_PCN_AceptacionDetalleProveedorVentas_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdProveedor        NVARCHAR(20),
	@IdAceptacionPedido INT,
	@IdAceptacionPedidoDetalle INT, 
    @IdContrato    INT = NULL,
    @IdUsuario     INT = NULL,
    @FechaRegistro DATETIME = NULL 
  
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
          
		  SELECT 
		  APD.IdAceptacionPedidoDetalle,
		  APD.IdMaterialVendendor AS IdMaterial,
		  APD.Detalle AS DescripcionCorta,
		  APD.Unidad,
		  APD.Cantidad,
		  APD.Excedente, 
		  APD.PrecioUnitario,		  
		  APD.PCN,		  
		  APD.IdMoneda AS Moneda
		  FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD
		  INNER JOIN dbo.MPY_MM_AceptacionPedido AS A ON A.IdAceptacionPedido = APD.IdAceptacionPedido 
		  --INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = APD.IdMoneda
		  WHERE --A.IdSubContratista = @IdProveedor  AND 
		  A.IdAceptacionPedido = @IdAceptacionPedido AND APD.IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle
		  GROUP BY 
		  APD.IdAceptacionPedidoDetalle,
		  APD.IdMaterialVendendor,
		  APD.Detalle,
		  APD.Unidad,
		  APD.Cantidad,
		  APD.Excedente, 
		  APD.PrecioUnitario,		  
		  APD.PCN,		  
		  APD.IdMoneda
     END;

