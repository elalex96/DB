-- =============================================
-- Author:		Daniel AC
-- Create date: 07-11-17
-- Description:	Consulta de conceptos de factura
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23-03-2018>
-- Description:	<Se agrega Moneda a la consulta y se agregan parametros de contrato>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarConceptosFactura]  
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/  
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT C.Cantidad, 
		C.Descripcion, 
		C.Unidad, 
		C.ValorUnitario, 
		C.Importe,
		f.Moneda
	FROM dbo.FI_CFDIConcepto C
		INNER JOIN dbo.FI_Factura F ON F.IdFactura = C.IdFactura
	WHERE F.IdFactura = @IdFactura    
	
	
END




