
CREATE PROCEDURE CO_ModificaPropietarios
    @IdPropietario INT,
    @IdAreaContractual INT,
    @NombrePropietario NVARCHAR(MAX),
    @KM2 FLOAT,
    @FI DATE,
	@RFC NVARCHAR(13),
	@correo NVARCHAR(50),
	@telefono NVARCHAR(13),
	@direccion NVARCHAR(150),
    @Bit_Activo BIT,
    @idContrato INT = 0,
    @IdUsuario INT = 0,
	@MontoRenta Money
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @COUNT INT;

    IF (@IdAreaContractual <> 0 AND @NombrePropietario <> '' AND @FI <> '')
    BEGIN
        UPDATE CO_PropietariosAreaContractual
        SET IdAreaContractual = @IdAreaContractual, -- IdAreaContractual - int
            NombrePropietario = @NombrePropietario, -- NombrePropietario - nvarchar(500)
            KM2 = @KM2,                             -- KM2 - float
            FechaIniPago = @FI,
			RFC=@RFC,
			Correo=@correo,
			Telefono=@telefono,
			Direccion=@direccion,
            Bit_Activo = @Bit_Activo ,             -- FechaIniPago - date
			MontoRenta = @MontoRenta
        WHERE IdPropietario = @IdPropietario;

    END;
END;

