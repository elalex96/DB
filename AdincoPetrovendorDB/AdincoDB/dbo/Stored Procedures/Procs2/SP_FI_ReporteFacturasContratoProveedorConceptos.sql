-- =============================================
-- Author:		Manuel CD
-- Create date: 08-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_ReporteFacturasContratoProveedorConceptos
	-- Add the parameters for the stored procedure here
@IdFactura INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdFacturaConcepto,
                    IdFactura,
                    Cantidad,
                    Unidad,
                    Descripcion,
                    ValorUnitario,
                    Importe
             FROM FI_CFDIConcepto
             WHERE(IdFactura = @IdFactura);
         END;

