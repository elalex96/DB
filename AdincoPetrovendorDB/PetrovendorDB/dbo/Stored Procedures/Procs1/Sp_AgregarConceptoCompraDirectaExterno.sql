CREATE PROCEDURE Sp_AgregarConceptoCompraDirectaExterno
(
    @IdProveedorSubcontra INT,
    @Folio INT,
    @IdUsuario INT,
    @Cantidad DECIMAL,
    @Descripcion NVARCHAR(MAX),
    @ValorUnitario DECIMAL,
    @Importe DECIMAL,
    @IdLineaPresupuesto INT,
    @IdCuentaContable INT,
    @IdCentroCosto INT,
    @IdSectoreHidrocarburos INT,
    @IdInstalacion INT,
    @InicioEjecucioan DATETIME,
    @FinEjecucion DATETIME,
    @Comentario NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @IdTicket INT


    --buscar por el folio del ticket si ya existe devolver su id, su busqueda es por folio y por proveedor
    SELECT @IdTicket = IdTicket
    FROM dbo.PV_Ticket ticket
        INNER JOIN dbo.S_UsuarioProveedor prov
            ON prov.IdUsuario = ticket.CreadoPor
    WHERE ticket.Folio = @Folio
          AND ticket.IdRazonSocialProveedor = @IdProveedorSubcontra


    IF (@IdTicket IS NULL)
    BEGIN
        INSERT INTO dbo.PV_Ticket
        (
            IdRazonSocialProveedor,
            Folio,
            CreadoPor,
            FechaCreacion
        )
        VALUES
        (   @IdProveedorSubcontra, -- IdRazonSocialProveedor - int
            @IdUsuario,            -- CreadoPor - int
            @Folio,
            GETDATE()              -- FechaCreacion - datetime
        )

        SELECT @IdTicket = @@IDENTITY

    END

    INSERT INTO dbo.Pv_TicketDesgloce
    (
        IdTicket,
        Folio,
        Cantidad,
        Descripcion,
        ValorUnitario,
        Importe,
        IdLineaPresupuesto,
        IdCuentaSectorHidrocarburos,
        IdCuentaContable,
        IdCentroCosto,
        InicioEjecucion,
        FinEjecucion,
        IdInstalacion,
        Comentario
    )
    VALUES
    (   @IdTicket,               -- IdTicket - int
        @Folio,                  -- Folio - nvarchar(150)
        @Cantidad,               -- Cantidad - int
        @Descripcion,            -- Descripcion - nvarchar(max)
        @ValorUnitario,          -- ValorUnitario - decimal(18, 0)
        @Importe,                -- Importe - decimal(18, 0)
        @IdLineaPresupuesto,     -- IdLineaPresupuesto - int
        @IdSectoreHidrocarburos, -- IdCuentaSectorHidrocarburos - int
        @IdCuentaContable,       -- IdCuentaContable - int
        @IdCentroCosto,          -- IdCentroCosto - int
        @InicioEjecucioan,       -- InicioEjecucion - datetime
        @FinEjecucion,           -- FinEjecucion - datetime
        @IdInstalacion,          -- IdInstalacion - int
        @Comentario              -- Comentario - nvarchar(max)
    )

END
