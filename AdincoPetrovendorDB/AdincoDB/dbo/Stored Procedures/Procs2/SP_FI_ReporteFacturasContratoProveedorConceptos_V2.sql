-- =============================================
-- Author:		Manuel CD
-- Create date: 08-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_ReporteFacturasContratoProveedorConceptos_V2 --10003,10591,2017,1
	-- Add the parameters for the stored procedure here
@IdContrato  INT,
@IdProveedor INT,
@Anio        INT,
@IdUsuario   INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdFacturaConcepto,
                    F.IdFactura,
                    Cantidad,
                    Unidad,
                    Descripcion,
                    ValorUnitario,
                    Importe
             FROM FI_CFDIConcepto FC
                  JOIN dbo.FI_Factura F ON FC.IdFactura = F.IdFactura
                  JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
             WHERE F.IdSubcontratista = @IdProveedor
                   AND F.IdContrato = @IdContrato
                   AND YEAR(F.Fecha) = @Anio
             ORDER BY F.IdFactura ASC;
         END;

