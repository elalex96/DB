

-- =============================================
-- Author:		Alexander Gomez
-- Update date: 14-06-18
-- Description:	Actualice IdMaterial a IdMaterialVendedor
-- =============================================
CREATE procedure [dbo].[SP_PR_MPY_MM_PCN_AceptacionProveedorVentas_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdProveedor        NVARCHAR(20),
	@IdAceptacionPedido INT,

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
		  APD.Detalle AS DescripcionCorta,
		  APD.Unidad AS Unidad,
		  APD.Cantidad,
		  APD.Excedente, 
		  APD.PrecioUnitario,		   
		  APD.PCN,		  
		  APD.IdMoneda AS Moneda
		  FROM MPY_MM_AceptacionPedidoDetalle AS APD
		  LEFT JOIN MPY_MM_AceptacionPedido AS A ON A.IdAceptacionPedido = APD.IdAceptacionPedido 
		  --LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = APD.IdMoneda
		  --LEFT JOIN dbo.PV_MM_MaterialUnidad AS UM ON APD.Unidad = UM.IdUnidad
		  WHERE --A.IdSubContratista = @IdProveedor  AND 
		  A.IdAceptacionPedido = @IdAceptacionPedido
		  GROUP BY 
		  APD.IdAceptacionPedidoDetalle,
		  APD.Detalle,
		  APD.Unidad,
		  APD.Cantidad,
		  APD.Excedente, 
		  APD.PrecioUnitario,		   
		  APD.PCN,		  
		  APD.IdMoneda
     END;

