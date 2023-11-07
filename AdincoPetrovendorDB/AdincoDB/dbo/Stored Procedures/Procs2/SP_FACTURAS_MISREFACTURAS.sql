IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_MISREFACTURAS'
)
    DROP PROCEDURE SP_FACTURAS_MISREFACTURAS;
GO

CREATE PROCEDURE [dbo].[SP_FACTURAS_MISREFACTURAS] 
	@IdContrato INT,
	@IdUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FI_Factura.IdFactura,
           ISNULL(FI_Factura.Serie, '') Serie,
           ISNULL(FI_Factura.Folio, '') Folio,
           FI_Factura.Fecha,
           ISNULL(FI_Factura.FormaPago, '') FormaPago,
           FI_Factura.SubTotal,
           ISNULL(FI_Factura.Moneda, '') Moneda,
           FI_Factura.MontoConIva,
           ISNULL(FI_Factura.MetodoPago, '') MetodoPago,
           ISNULL(FI_Factura.UUID, '') UUID,
           FI_Factura.FechaRecepcion,
           ISNULL(PV_Subcontratista.RazonSocial, '') RazonSocial,
           ISNULL(FI_Factura.Emisor, '') Emisor
    FROM FI_Factura (NOLOCK)
        JOIN PV_Subcontratista (NOLOCK)
            ON FI_Factura.IdContrato = @IdContrato
               AND FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
        JOIN FI_RelacionRefacturas (NOLOCK)
            ON FI_Factura.IdFactura = FI_RelacionRefacturas.IdFacturaPadre
    GROUP BY FI_Factura.IdFactura,
             ISNULL(FI_Factura.Serie, ''),
             ISNULL(FI_Factura.Folio, ''),
             FI_Factura.Fecha,
             ISNULL(FI_Factura.FormaPago, ''),
             FI_Factura.SubTotal,
             ISNULL(FI_Factura.Moneda, ''),
             FI_Factura.MontoConIva,
             ISNULL(FI_Factura.MetodoPago, ''),
             ISNULL(FI_Factura.UUID, ''),
             FI_Factura.FechaRecepcion,
             ISNULL(PV_Subcontratista.RazonSocial, ''),
             ISNULL(FI_Factura.Emisor, '')
END;