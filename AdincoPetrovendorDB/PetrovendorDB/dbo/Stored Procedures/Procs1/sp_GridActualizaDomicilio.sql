CREATE PROCEDURE [dbo].[sp_GridActualizaDomicilio]
(
    @IdDomicilio INT,
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
    UPDATE dbo.DG_Domicilio
    SET IdTipoDomicilio = @IdTipoDomicilio,
        Calle = @Calle,
        NoExterior = @NoExterior,
        NoInterior = @NoInterior,
        Colonia = @Colonia,
        Municipio = @Municipio,
        Estado = @Estado,
        IdPais = @IdPais,
        CodigoPostal = @CodigoPostal,
        TipoViabilidad = @TipoViabilidad,
        NombreViabilidad = @NombreViabilidad,
        IdActualizadoPor = @IdUsuario,
        FechaCambio = GETDATE()
    WHERE IdDomicilio = @IdDomicilio
          AND IdProveedor = @IdProveedor
END
