-- =============================================
-- Author:		Daniel			
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarImpuestosFactura]
	-- Add the parameters for the stored procedure here

@IdFactura	int  
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

		 ---Eliminar Facturas Detalle Impuestos y Conceptos
			DELETE FROM  FI_CFDIConcepto
			WHERE IdFactura = @IdFactura

			DELETE FROM  FI_CFDIImpuesto
			WHERE IdFactura = @IdFactura


			SELECT 'CONCEPTOS ELIMINADOS' AS RESPONSE


END

