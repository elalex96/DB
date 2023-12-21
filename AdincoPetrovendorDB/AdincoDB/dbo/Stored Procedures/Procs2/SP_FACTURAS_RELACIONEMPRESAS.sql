IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_RELACIONEMPRESAS'
)
    DROP PROCEDURE SP_FACTURAS_RELACIONEMPRESAS;
GO
CREATE PROCEDURE [dbo].[SP_FACTURAS_RELACIONEMPRESAS] 
	@IdContratista INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FI_Factura.IdFactura,
           ISNULL(LTRIM(RTRIM(FI_Factura.Serie)), '') Serie,
           ISNULL(LTRIM(RTRIM(FI_Factura.Folio)), '') Folio,
           FI_Factura.Fecha,
           ISNULL(LTRIM(RTRIM(FI_Factura.FormaPago)), '') FormaPago,
           ISNULL(LTRIM(RTRIM(FI_Factura.NoCertificado)), '') NoCertificado,
           ISNULL(LTRIM(RTRIM(FI_Factura.CondicionesDePago)), '') CondicionesDePago,
           CAST(FI_Factura.SubTotal AS MONEY) AS SubTotal,
           ISNULL(LTRIM(RTRIM(FI_Factura.Moneda)), '') Moneda,
           FI_Factura.MontoConIva,
           ISNULL(LTRIM(RTRIM(FI_Factura.TipoComprobante)), '') TipoComprobante,
           ISNULL(LTRIM(RTRIM(FI_Factura.MetodoPago)), '') MetodoPago,
           ISNULL(LTRIM(RTRIM(FI_Factura.LugarExpedicion)), '') LugarExpedicion,
           ISNULL(LTRIM(RTRIM(FI_Factura.UUID)), '') UUID,
           FI_Factura.FechaTimbrado,
           FI_Factura.FechaRecepcion,
           ISNULL(LTRIM(RTRIM(FI_Factura.emisor)), '') emisor
    FROM CO_RelacionEmpresas (NOLOCK)
        INNER JOIN FI_Factura (NOLOCK)
            ON CO_RelacionEmpresas.IdContratista = @IdContratista
               AND CO_RelacionEmpresas.IdRelacionada = FI_Factura.IdSubcontratista
    ORDER BY FI_Factura.fecha DESC;
END;