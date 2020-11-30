-- =============================================
-- Author:	Daniel Cruz
-- Create date: 27-03-18
-- Description:	Consultar detalle de materiales de pedimento o comprobante  actual
-- =============================================
CREATE    PROCEDURE [dbo].[SP_PC_CD_ConsultarDetallePedimentoComprobante] 
	-- Add the parameters for the stored procedure here
@IdProveedor        INT,
@IdPedidoComprobante INT,
@IdContrato INT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
         
		 SELECT 
		 IdPedimentoComprobanteDetalle,
		 U.Unidad,
		 PCD.NumeroSerieMercancia,
		 PCD.DescripcionMercancia,
		 PCD.PrecioUnitario,
		 PCD.Cantidad,
		 PCD.ImporteTotal 
		 FROM dbo.FI_PedimentoComprobanteDetalle PCD
		 INNER JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante=PCD.IdPedimentoComprobante
		 LEFT JOIN  Adinco.dbo.PV_MM_MaterialUnidad AS U ON U.IdUnidad= PCD.IdUnidadMedida
		 WHERE PC.IdPedimentoComprobante=@IdPedidoComprobante AND PC.IdContrato=@IdContrato

 

END; 
