CREATE PROCEDURE LayoutGastosSelect
AS
BEGIN
    SELECT l.IdGastosLayout,
           l.IdVendor,
           l.VendorName,
           l.Folio,
           l.Total,
           l.Subtotal,
           l.TotalUsd,
           l.SubtotalUsd,
           l.Moneda,
           l.TipoCambio,
           l.DocumentoFactura,
           l.DocumentoClearing,
           l.TextoClearing,
           l.Area,
           l.FechaClearing,
           l.FechaDoc,
           l.Cuenta,
           l.IdFmp,
           l.Fmp,
           l.Wbs,
           l.Ac,
           l.Sa,
           l.Ta,
           l.UUIDFactura,
           l.ComplementoPago,
           l.Activo,
           l.CreadoEl,
           u.Nombre CreadoPor
           FROM Gastos_Layout l 
		   LEFT JOIN dbo.AP_Usuario u ON u.UsuarioID = l.CreadoPor
		   WHERE l.Activo = 1
END;