-- =============================================
-- Author:		Daniel AC
-- Update date: 09-02-18
-- Description:	Muestra Detalle de aceptación pedido detalle 
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 24/09/2019
-- Description:	Redonde a 3 digitos del PCN segun la SE
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 06/04/2021
-- Description:	Redonde a 3 digitos del PCN segun la SE (Modificacion)
-- =============================================
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 18/05/2022
-- Description: truncado a 3 digitos sin redondeo del PCN segun la SE Y optimizacion
-- =============================================
-- Author:		Luis David
-- Create date: <02/09/2022>
-- Description:	<Se optimiza para el Issue #1986>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionDetalleProveedorVentas_MV1_5] --44,473,1061,0,0
	-- Add the parameters for the stored procedure here
	@IdProveedor        INT,
	@IdAceptacionPedido INT,
	@IdAceptacionPedidoDetalle INT, 
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME = null
  
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
          
		  SELECT 
			  APD.IdAceptacionPedidoDetalle,
			  PD.IdMaterialVendedor AS IdMaterial,
			  POD.MaterialCotizadoTextoC AS DescripcionCorta,
			  POD.UnidadProveedor AS Unidad,
			  APD.Cantidad,
			  APD.Excedente, 
			  PD.PrecioUnitario,  
			  CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar),1,5) AS nvarchar) AS PCN,  
			  TM.TipoMonedaCorto AS Moneda
		  FROM MM_AceptacionPedidoDetalle AS APD
			  JOIN MM_AceptacionPedido AS A 
				ON APD.IdAceptacionPedido = A.IdAceptacionPedido
				AND @IdAceptacionPedido = A.IdAceptacionPedido  
				AND APD.IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle
			  JOIN MM_PedidoDetalle AS PD 
				ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
			  JOIN MM_Pedido AS P 
				ON A.IdPedido = P.IdPedido
				and @IdProveedor = P.IdSubcontratista
			  JOIN MM_PeticionOferta AS PO 
				ON P.IdPeticionOferta = PO.IdPeticionOferta
			  JOIN MM_PeticionOfertaDetalle AS POD 
				ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
			  JOIN PV_TipoMoneda (NOLOCK) AS TM 
				ON PD.IdMoneda = TM.IdMoneda
		  GROUP BY 
		  APD.IdAceptacionPedidoDetalle,
		  PD.IdMaterialVendedor,
		  POD.MaterialCotizadoTextoC,
		  POD.UnidadProveedor,
		  APD.Cantidad,
		  APD.Excedente, 
		  PD.PrecioUnitario,
		  APD.PCN,
		  TM.TipoMonedaCorto
END;