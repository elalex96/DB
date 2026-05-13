-- =============================================
-- Author:		Daniel AC
-- Create date: 03-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaDetalleAceptacionPedido]
	-- Add the parameters for the stored procedure here
	
	@IdAceptacionPedido int 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	---execute [SP_MM_ConsultaDetalleAceptacionPedido] 41
	 

      SELECT M.IdMaterial, M.DescripcionCorta, U.Unidad AS NombreUnidad, (APD.Cantidad + APD.Excedente) AS Cantidad
	  FROM MM_AceptacionPedidoDetalle AS APD
	  INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
	  INNER JOIN MM_PedidoDetalle AS PD on PD.IdPedidoDetalle = APD.IdPedidoDetalle
	  INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
	  INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo AS GFDT	ON GFDT.IdSubFamilia = M.IdSubFamilia
	  INNER JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = GFDT.IdUnidad
	  WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
	

   END;

