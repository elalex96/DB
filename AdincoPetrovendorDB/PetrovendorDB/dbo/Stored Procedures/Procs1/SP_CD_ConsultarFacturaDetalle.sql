-- =============================================
-- Author:		Daniel AC
-- Create date: 15-11-17
-- Description:	Consultar conceptos de factura 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_CD_ConsultarFacturaDetalle]
	-- Add the parameters for the stored procedure here
	 	
	@IdFactura INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT ROW_NUMBER() OVER (ORDER BY NoIdentificacion) AS Partida,  NoIdentificacion, Descripcion, Cantidad, Unidad, ValorUnitario,Importe
	FROM [dbo].[FI_CFDIConcepto] AS FC
	INNER JOIN  FI_Factura AS F ON F.IdFactura=FC.IdFactura
	WHERE F.IdFactura=@IdFactura
	ORDER BY Descripcion ASC
  

END


