
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	02 de Marzo del 2023
-- Descripción:			Se agregan LTRIM y RTRIM correspondientes
-- =============================================
CREATE PROCEDURE [dbo].[ActualizarInsertarPozosAmat]
    @IdUsuario INT,
    @IdAreaContractual INT,
    @IdInstalacion INT = 0, --> Cuando es 0 es Insert y cuando es mayor a 0 es update
    @NombreInstalacion VARCHAR(4000),
    @NombreInstalacionAlterno VARCHAR(4000),
    @IdCatalogoSCIEP INT,
    @IdCampo INT,
    @Activo BIT
AS
BEGIN
    DECLARE @IdActividad INT,
            @IdEstatus INT,
            @IdYacimiento INT

    SELECT TOP 1
        @IdActividad = IdActividad
    FROM CO_ActividadCIEP
    WHERE LTRIM(RTRIM(UPPER(NombreActividad))) = 'POZOS'

    SELECT TOP 1
        @IdEstatus = idEstatus
    FROM CO_EstadoPozos
    WHERE LTRIM(RTRIM(UPPER(TipoEstatus))) = 'ACTIVO'

    SELECT TOP 1
        @IdYacimiento = IdYacimiento
    FROM CO_AreaContractualYacimiento
    WHERE IdAreaContractual = @IdAreaContractual

    IF (ISNULL(@IdInstalacion, 0) <> 0)
    BEGIN
        UPDATE CO_Instalacion
        SET NombreInstalacion =  LTRIM(RTRIM(@NombreInstalacion)),
            IdInstalacionPemex = NULL,
            EsBolsa = 0,
            IdActividad = @IdActividad,             --> Asignar el id correspondiente a pozos
            IdUsuario = @IdUsuario,
            FecMovto = GETDATE(),
            NombreInstalacionAlterno =  LTRIM(RTRIM(@NombreInstalacionAlterno)),
            IdCatalogoSCIEP = @IdCatalogoSCIEP,
            IdAreaContractual = @IdAreaContractual, --> Dato interno que no se muestra en pantalla
            Activo = @Activo,
            CUIP = NULL,
            IdYacimiento = @IdYacimiento,           --> Id del yacimiento default del area contractual
            IdCampo = @IdCampo,
            UTMX = 0,
            UTMY = 0,
            IdEstatus = @IdEstatus,                 --> id del estatus activo de la tabla co_estadopozos
            ModificadoPor = @IdUsuario,
            ModificadoEn = GETDATE(),
            ComodinBolsa = 0
        WHERE IdInstalacion = @IdInstalacion
    END

    IF (ISNULL(@IdInstalacion, 0) = 0)
    BEGIN
        INSERT INTO CO_Instalacion
        (
            NombreInstalacion,
            IdInstalacionPemex,
            EsBolsa,
            IdActividad,              --> Asignar el id correspondiente a pozos
            IdUsuario,                --> Dato interno que no se muestra en pantalla
            FecMovto,                 --> Dato interno que no se muestra en pantalla
            NombreInstalacionAlterno, --> Nombre alterno que ingresa el usuario
            IdCatalogoSCIEP,          --> ID SCIEP que ingresa el usuario
            IdAreaContractual,        --> Dato interno que no se muestra en pantalla
            Activo,                   --> Indicador si el pozo esta activo o no
            CUIP,                     --> NULL
            WelIID,                   --> Id del pozo en caso de existir, NULL para registros nuevos
            IdYacimiento,             --> Id del yacimiento default del area contractual
            IdCampo,                  --> Id de la macropera (mostrar combo)
            UTMX,                     --> 0
            UTMY,                     --> 0
            IdEstatus,                --> id del estatus activo de la tabla co_estadopozos
            CreadoPor,                --> Dato interno que no se muestra en pantalla
            CreadoEn,                 --> Dato interno que no se muestra en pantalla
            ComodinBolsa              --> 0)
        )
        SELECT  LTRIM(RTRIM(@NombreInstalacion)),
               NULL,
               0,
               @IdActividad,
               @IdUsuario,
               GETDATE(),
                LTRIM(RTRIM(@NombreInstalacionAlterno)),
               @IdCatalogoSCIEP,
               @IdAreaContractual,
               @Activo,
               NULL,
               NULL,
               @IdYacimiento,
               @IdCampo,
               0,
               0,
               @IdEstatus,
               @IdUsuario,
               GETDATE(),
               0
    END
END