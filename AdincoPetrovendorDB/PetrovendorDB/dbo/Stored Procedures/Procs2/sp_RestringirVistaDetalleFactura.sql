
CREATE PROC sp_RestringirVistaDetalleFactura
(@IdAceptacionPedido INT)
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM dbo.MM_AceptacionPedido ap
            INNER JOIN dbo.S_Proveedor p
                ON p.IdProveedor = ap.IdProveedor
            INNER JOIN dbo.RestriccionPanteraFacturas rest
                ON p.RFC = rest.RFCOperadora
                   AND rest.Activo = 1
				   AND rest.ApartirDe <= GETDATE()
        WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
    )
    BEGIN
        SELECT 1 --Restringir la vista
    END
    ELSE
    BEGIN
        SELECT 0
    END
END

