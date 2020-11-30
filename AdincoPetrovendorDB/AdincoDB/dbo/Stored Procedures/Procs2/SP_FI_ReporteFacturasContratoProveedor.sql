-- =============================================
-- Author:		Manuel Cruz
-- Create date: 08-01-18
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_ReporteFacturasContratoProveedor 
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
             SELECT IdFactura,
                    Serie,
                    Folio,
                    Fecha,
                    SubTotal,
                    Moneda,
                    MontoConIva,
                    TipoComprobante,
                    Emisor,
                    SUB.RazonSocial,
                    Receptor,
                    UUID,
                    FechaTimbrado,
                    IdContrato
             FROM FI_Factura F
                  JOIN dbo.PV_Subcontratista SUB ON F.IdSubcontratista = SUB.IdSubcontratista
             WHERE IdContrato = @IdContrato
                   AND F.IdSubcontratista = @IdProveedor
                   AND YEAR(F.Fecha) = @Anio
             ORDER BY F.IdFactura ASC;
         END;

