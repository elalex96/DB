USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_PCN_AceptacionDetalleProveedorVentas_MV1_5]    Script Date: 06/04/2021 02:32:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		  CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar(10)),1,5) AS float) AS PCN,
		  --ROUND(ISNULL(APD.PCN,0),3) AS PCN,
		  --SUBSTRING(LTRIM(ISNULL(APD.PCN,0)),1,CHARINDEX('.',LTRIM(ISNULL(APD.PCN, ''))) + 3) AS PCN,	  
		  TM.TipoMonedaCorto AS Moneda
		  FROM MM_AceptacionPedidoDetalle AS APD
		  INNER JOIN MM_AceptacionPedido AS A ON A.IdAceptacionPedido = APD.IdAceptacionPedido
		  INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		  INNER JOIN MM_Pedido AS P ON P.IdPedido =  A.IdPedido
		  INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta=P.IdPeticionOferta
		  INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle=PD.IdPeticionOfertaDetalle 
		  INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = PD.IdMoneda
		  WHERE P.IdSubcontratista =@IdProveedor  AND A.IdAceptacionPedido = @IdAceptacionPedido AND APD.IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle
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
