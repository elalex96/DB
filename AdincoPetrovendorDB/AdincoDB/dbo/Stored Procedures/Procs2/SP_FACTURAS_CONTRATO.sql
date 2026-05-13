USE [Adinco]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_CONTRATO'
)
    DROP PROCEDURE SP_FACTURAS_CONTRATO;
GO
CREATE PROCEDURE [dbo].[SP_FACTURAS_CONTRATO] 
	@IDContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    SELECT IdFactura,
           ISNULL(LTRIM(RTRIM(Serie)), '') Serie,
           ISNULL(LTRIM(RTRIM(Folio)), '') Folio,
           Fecha,
           ISNULL(LTRIM(RTRIM(FormaPago)), '') FormaPago,
           ISNULL(LTRIM(RTRIM(NoCertificado)), '') NoCertificado,
           ISNULL(LTRIM(RTRIM(CondicionesDePago)), '') CondicionesDePago,
           SubTotal,
           ISNULL(LTRIM(RTRIM(Moneda)), '') Moneda,
           MontoConIva,
           ISNULL(LTRIM(RTRIM(TipoComprobante)), '') TipoComprobante,
           ISNULL(LTRIM(RTRIM(MetodoPago)), '') MetodoPago,
           ISNULL(LTRIM(RTRIM(LugarExpedicion)), '') LugarExpedicion,
           ISNULL(LTRIM(RTRIM(UUID)), '') UUID,
           FechaTimbrado,
           FechaRecepcion,
           ISNULL(LTRIM(RTRIM(emisor)), '') emisor
    FROM FI_Factura (NOLOCK)
    WHERE IdContrato = @IDContrato;
END;