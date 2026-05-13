-- =============================================
-- Author:		Daniel AC
-- Create date: 15-11-17
-- Description:	Consultar conceptos de factura subtotal
-- =============================================
CREATE  PROCEDURE [dbo].[SP_CD_ConsultarFacturaDetalleSubTotal]
	-- Add the parameters for the stored procedure here
	 	
	@IdFactura INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT F.SubTotal, dbo.CantidadConLetraReportes(F.SubTotal,TM.TipoMonedaCorto) AS SubtotalLetra
	FROM FI_Factura F
	LEFT JOIN dbo.PV_TipoMoneda TM ON TM.IdMoneda = F.IdMoneda
	WHERE F.IdFactura=@IdFactura
 
  

END


