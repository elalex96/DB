-- =============================================
-- Author:		Daniel AC
-- Create date: 16/11/2017
-- Description:	letra de cantidad
-- =============================================
CREATE PROCEDURE [dbo].[SP_CD_CantidadMonetariaALetras]
@IdFactura INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	DECLARE @CANTIDAD_A_CONVERTIR DECIMAL(18,2)	  
	 
	SET @CANTIDAD_A_CONVERTIR =(SELECT ISNULL(MontoConIva,0) FROM dbo.FI_Factura  WHERE IdFactura= @IdFactura)
		 

    SELECT 'CANTIDAD CON LETRA: ' + dbo.CantidadConLetra(@CANTIDAD_A_CONVERTIR) AS RepresentacionEnLetras
	
END