CREATE PROCEDURE [dbo].[SP_FI_ConsultarFacturaImpuestos] 
	@IdFactura INT 
AS
BEGIN
-- =============================================
-- Author:		Miguel - DANIEL MODIFICACION
-- Create date: 5-12-16 - 15/08/2017
-- Description:	Consulta una factura
-- =============================================
	SET NOCOUNT ON;
-- =============================================
 
	SELECT [IdCFDIImpuesto]
      ,[IdTipoImpuesto]
      ,[Impuesto]
      ,[Tasa]
      ,[Importe]
      ,[CreadoPor]
  FROM [FI_CFDIImpuesto]
  WHERE IdFactura = @IdFactura


END

