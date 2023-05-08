-- =============================================
-- Author:		DANIEL CRUZ
-- Create date: 21-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Aceptacion_DetalleProveedorVentas] 
	-- Add the parameters for the stored procedure here
 
@IdAceptacionPedido INT,
@IdProveedor INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         
	     
         SELECT 
		 AP.IdAceptacionPedido,
		 PD.IdPedidoDetalle,
		 PD.IdMaterialVendedor AS IdMaterial,
		 M.DescripcionCorta,
		 U.Unidad,
		 APD.Cantidad,
		 APD.Excedente,
		 ((APD.Cantidad+APD.Excedente)) AS CantidadTotal,
		 PD.PrecioUnitario,
		 ((APD.Cantidad+APD.Excedente)*PD.PrecioUnitario) AS SubTotal,
		 TM.TipoMonedaCorto
		 FROM MM_AceptacionPedidoDetalle AS APD
		 INNER JOIN MM_AceptacionPedido  AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		 INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido
		 INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle= APD.IdPedidoDetalle
		 INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
		 INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS SUB ON SUB.IdSubFamilia = M.IdSubfamilia
		 INNER JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad  = SUB.IdUnidad   
		 INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = PD.IdMoneda
         WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND P.IdSubcontratista=@IdProveedor
		 ORDER BY M.DescripcionCorta

		 ---Este proveedor es el de ventas
		 --- Execute SP_MM_Aceptacion_DetalleProveedorVentas 41,428
     END;

