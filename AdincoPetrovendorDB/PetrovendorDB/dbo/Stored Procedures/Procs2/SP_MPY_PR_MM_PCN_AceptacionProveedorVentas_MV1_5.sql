

-- =============================================
-- Author:		Daniel AC
-- Update date: 17-04-18
-- Description:	Actualice IdMaterial a IdMaterialVendedor
-- =============================================
CREATE procedure [dbo].[SP_MPY_PR_MM_PCN_AceptacionProveedorVentas_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdProveedor        INT,
	@IdAceptacionPedido INT,

    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
          
		  DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)

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
		  --LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = APD.Unidad
		  WHERE --A.IdSubcontratista = @PROVEDORRFC  AND 
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

