USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_PCN_ConsultarPCN_MaterialesUtilizados
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 13-04-2018
-- Description:	CONSULTAR EL DETALLE DE MATERIALES UTILIZADOS PARA EL BIEN FINAL 
-- =============================================
-- Author:		Luis David
-- Create date: <02/09/2022>
-- Description:	<Se optimiza para el Issue #1986>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_ConsultarPCN_MaterialesUtilizados]
 
@IdAceptacionPedidoDetalle int
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	 
	 SELECT 
	 MU.IdMaterialServicioUtilizado, 
	 MU.IdTipoMaterial AS IdTipo, 
	 MU.Descripcion, MU.VM_ValorFactura AS ValorFactura, 
	 MU.PCNM_Utilizado AS ProporcionCN, 
	 MU.NombreProveedor +' / '+MU.RFC AS Proveedor, 
	 MU.RFC, 
	 MU.IdPCNProveedor
	 FROM MM_PCN_MaterialesUtilizados  AS MU
	 INNER JOIN MM_PCN_ValoresPesos AS V 
		ON MU.IdValoresEnPesosPedidoDetalle = V.IdValoresEnPesosPedidoDetalle
	 WHERE V.IdAceptacionPedidoDetalle  = @IdAceptacionPedidoDetalle
	 AND ISNULL(MU.IsEliminado,0)=0
	
 
END
