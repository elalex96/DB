CREATE PROCEDURE [dbo].[sp_GridInsertaDomicilio]
(
    @IdProveedor INT,
    @IdUsuario INT,
    @IdTipoDomicilio INT,
    @Calle NVARCHAR(300),
    @NoExterior NVARCHAR(300),
    @NoInterior NVARCHAR(300),
    @Colonia NVARCHAR(300),
    @Municipio NVARCHAR(300),
    @Estado NVARCHAR(300),
    @IdPais INT,
    @CodigoPostal NVARCHAR(150),
    @TipoViabilidad NVARCHAR(500),
    @NombreViabilidad NVARCHAR(500)
)
AS
BEGIN
    INSERT INTO dbo.DG_Domicilio
    (
        Estado,
        Municipio,
        Colonia,
        TipoViabilidad,
        NombreViabilidad,
        NoExterior,
        NoInterior,
        CodigoPostal,
        IdTipoDomicilio,
        IdProveedor,
        IdCreadoPor,
        FechaAlta,
        Activo,
        IdPais,
        Calle
    )
    VALUES
    (   @Estado,           -- Estado - nvarchar(300)
        @Municipio,        -- Municipio - nvarchar(300)
        @Colonia,          -- Colonia - nvarchar(300)
        @TipoViabilidad,   -- TipoViabilidad - nvarchar(500)
        @NombreViabilidad, -- NombreViabilidad - nvarchar(500)
        @NoExterior,       -- NoExterior - nvarchar(300)
        @NoInterior,       -- NoInterior - nvarchar(300)
        @CodigoPostal,     -- CodigoPostal - nvarchar(150)
        @IdTipoDomicilio,  -- IdTipoDomicilio - int
        @IdProveedor,      -- IdProveedor - int
        @IdUsuario,        -- IdCreadoPor - int
        GETDATE(),         -- FechaAlta - datetime
        1,                 -- Activo - bit
        @IdPais,           -- IdPais - int
        @Calle             -- Calle - nvarchar(300)
    )
END


