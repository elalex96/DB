USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PC_AceptacionPedidoDetalle_Petrovendor]    Script Date: 19/10/2022 11:13:50 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	Detalle de materiales que fueron aceptado en la aceptación de pedido
-- =============================================
ALTER PROCEDURE [dbo].[SP_PC_AceptacionPedidoDetalle_Petrovendor] 
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
          
		  SELECT 
		  APD.IdAceptacionPedidoDetalle,
		  PD.IdMaterialVendedor AS IdMaterial,
		  POD.MaterialCotizadoTextoC AS DescripcionCorta,
		  POD.UnidadProveedor AS Unidad,
		  APD.Cantidad,
		  APD.Excedente, 
		  ISNULL(APD.PrecioUnitario,PD.PrecioUnitario) AS PrecioUnitario,	  
		  TM.TipoMonedaCorto AS Moneda
		  FROM MM_AceptacionPedidoDetalle AS APD
		  INNER JOIN MM_AceptacionPedido AS A ON A.IdAceptacionPedido = APD.IdAceptacionPedido
		  INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		  INNER JOIN MM_Pedido AS P ON P.IdPedido =  A.IdPedido
		  INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta=P.IdPeticionOferta
		  INNER JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle=PD.IdPeticionOfertaDetalle 
		  INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = PD.IdMoneda
		  WHERE P.IdSubcontratista =@IdProveedor  AND A.IdAceptacionPedido = @IdAceptacionPedido
		  GROUP BY 
		  APD.IdAceptacionPedidoDetalle,
		  PD.IdMaterialVendedor,
		  POD.MaterialCotizadoTextoC,
		  POD.UnidadProveedor,
		  APD.Cantidad,
		  APD.Excedente, 
		  PD.PrecioUnitario,	
		  APD.PrecioUnitario,
		  TM.TipoMonedaCorto;

     END;


	 