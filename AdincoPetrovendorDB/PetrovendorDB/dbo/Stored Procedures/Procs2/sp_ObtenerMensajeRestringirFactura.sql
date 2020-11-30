
CREATE PROC sp_ObtenerMensajeRestringirFactura
(@IdAceptacionPedido INT)
AS
BEGIN
    SELECT rest.Mensaje
    FROM dbo.MM_AceptacionPedido ap
        INNER JOIN dbo.S_Proveedor p
            ON p.IdProveedor = ap.IdProveedor
        INNER JOIN dbo.RestriccionPanteraFacturas rest
            ON p.RFC = rest.RFCOperadora
               AND rest.Activo = 1
               AND rest.ApartirDe <= GETDATE()
    WHERE ap.IdAceptacionPedido = @IdAceptacionPedido

END

