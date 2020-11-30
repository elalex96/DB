
-- =============================================
-- Author:		Reyna Olvera
-- Create date:18/08/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE CO_InsertaPropietarios
    @IdAreaContractual INT,
    @NombrePropietario NVARCHAR(MAX),
    @KM2 FLOAT,
    @FI DATE,
	@RFC NVARCHAR(13),
	@correo NVARCHAR(50),
	@telefono NVARCHAR(13),
	@direccion NVARCHAR(150),
    @idContrato INT = 0,
    @IdUsuario INT = 0,
	@MontoRenta Money
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @COUNT INT;

    IF (@IdAreaContractual <> 0 AND @NombrePropietario <> '' AND @FI <> '')
    BEGIN

        SELECT @COUNT = COUNT(IdPropietario)
        FROM CO_PropietariosAreaContractual
        WHERE IdAreaContractual = @IdAreaContractual
              AND NombrePropietario = @NombrePropietario;
        IF @COUNT = 0
            INSERT INTO CO_PropietariosAreaContractual
            (
                IdAreaContractual,
                NombrePropietario,
                KM2,
                FechaIniPago,
                Bit_Activo,
				RFC,
				Correo,
				Telefono,
				Direccion,
				MontoRenta
            )
            VALUES
            (   @IdAreaContractual, -- IdAreaContractual - int
                @NombrePropietario, -- NombrePropietario - nvarchar(500)
                @KM2,               -- KM2 - float
                @FI,                -- FechaIniPago - date
                1,
				@RFC,                   -- Bit_Activo - bit
				@correo,
				@telefono,
				@direccion,
				@MontoRenta
                );
        ELSE
            RETURN 1; --'Ya existe un registro con los mismos datos principales'
    END;
END;

