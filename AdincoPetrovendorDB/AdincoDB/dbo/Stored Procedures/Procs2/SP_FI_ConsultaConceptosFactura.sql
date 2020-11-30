-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/05/2018
-- Description:	Cosnultar los conceptos de una factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaConceptosFactura]
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		ClaveProdServ,
		Cantidad,
		Unidad,
		Descripcion,
		ValorUnitario,
		Importe
	FROM dbo.FI_CFDIConcepto 
	WHERE IdFactura = @IdFactura
END
