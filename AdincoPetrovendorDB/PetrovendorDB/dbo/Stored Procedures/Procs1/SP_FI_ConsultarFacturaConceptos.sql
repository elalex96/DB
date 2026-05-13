CREATE PROCEDURE [dbo].[SP_FI_ConsultarFacturaConceptos] 
	@IdFactura INT 
AS
BEGIN
-- =============================================
-- Author:		Miguel - DANIEL MODIFICACION
-- Create date: 5-12-16 - 15/08/2017
-- Description:	Consulta conceptos de una factura
-- =============================================
	SET NOCOUNT ON;
-- =============================================
 
	SELECT [IdFacturaConcepto]
      ,[Descripcion]
      ,[Cantidad]
      ,[Unidad]
      ,[ValorUnitario]
      ,[Importe]
      ,[NoIdentificacion]
      ,[CreadoPor]
  FROM [FI_CFDIConcepto] 
  WHERE IdFactura = @IdFactura


END

