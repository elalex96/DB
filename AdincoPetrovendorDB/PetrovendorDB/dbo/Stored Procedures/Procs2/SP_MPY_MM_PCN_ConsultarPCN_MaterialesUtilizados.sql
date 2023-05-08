-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04-06-2018
-- Description:	CONSULTAR EL DETALLE DE MATERIALES UTILIZADOS PARA EL BIEN FINAL 
-- =============================================
CREATE procedure [dbo].[SP_MPY_MM_PCN_ConsultarPCN_MaterialesUtilizados]
 
@IdAceptacionPedidoDetalle int
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	 
	 SELECT 
	 MU.IdMaterialServicioUtilizado, 
	 MU.IdTipoMaterial AS IdTipo, 
	 MU.Descripcion, 
	 MU.VM_ValorFactura AS ValorFactura, 
	 MU.PCNM_Utilizado AS ProporcionCN, 
	 MU.NombreProveedor +' / '+MU.RFC AS Proveedor, 
	 MU.RFC, 
	 MU.IdPCNProveedor
	 FROM dbo.MPY_MM_PCN_MaterialesUtilizados  AS MU
	 INNER JOIN dbo.MPY_MM_PCN_ValoresPesos AS V ON V.IdValoresEnPesosPedidoDetalle = MU.IdValoresEnPesosPedidoDetalle
	 INNER JOIN dbo.MPY_MM_AceptacionPedidoDetalle as APD ON APD.IdAceptacionPedidoDetalle = V.IdAceptacionPedidoDetalle
	 LEFT JOIN dbo.MPY_MM_PCN_Proveedor AS PPCN ON PPCN.IdPCNProveedor=MU.IdPCNProveedor
	 WHERE V.IdAceptacionPedidoDetalle  = @IdAceptacionPedidoDetalle
	 AND ISNULL(MU.IsEliminado,0)=0
	
 
END

 
