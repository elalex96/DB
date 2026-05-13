IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_RegistraSecuenciaEstados'
    )
    DROP PROCEDURE USP_INS_CO_RegistraSecuenciaEstados;
GO
CREATE PROCEDURE [dbo].[USP_INS_CO_RegistraSecuenciaEstados]
    @IdUsuario              INT = 0,
    @IdContrato             INT,
    @IdContratoSeleccionado INT,
    @IdTransicion           INT,
    @IdEstadoActual         INT,
    @IdEstadoSiguiente      INT,
    @NombreCambioEstado     VARCHAR(7000)
AS
    BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;

        CREATE TABLE #Validaciones (Validacion VARCHAR(7000));
        DECLARE @NuevoEstadoSiguiente VARCHAR(7000), @NuevoEstadoActual  VARCHAR(7000);

        IF (@IdEstadoActual = @IdEstadoSiguiente)
            BEGIN
                INSERT INTO #Validaciones
                    (
                        Validacion
                    )
                            SELECT
                                'MENSAJE DE WARNING: No se puede guardar una secuencia con los mismos estados como actual y siguiente.'
            END

        IF NOT EXISTS
            (
                SELECT
                    1
                FROM
                    #Validaciones
            )
            BEGIN
                if (@IdTransicion > 0)
                    BEGIN

                           SELECT @NuevoEstadoActual = NombreEstado
                            FROM 
                            CO_EstadoRegistro_V2 WHERE IdClvEstado = @IdEstadoActual;

                            SELECT @NuevoEstadoSiguiente  = NombreEstado
                            FROM 
                            CO_EstadoRegistro_V2 WHERE IdClvEstado = @IdEstadoSiguiente;

                        INSERT INTO dbo.AP_Bitacora
                            (
                                Fecha,
                                Tipo,
                                Mensaje,
                                Detalle,
                                UsuarioId,
                                ContratoId
                            )
                                    SELECT DISTINCT
                                        GETDATE(),
                                        'Edición',
                                        'Edición CO_EstadoRegistroTransicion',
                                        'Edición de secuencia/transición (CO_EstadoRegistroTransicion) en la página 2/AdministracionCatalogos/AdministracionSecuenciaEstados.aspx: '
                                        + 'ID: [' + CONVERT(VARCHAR(19), @IdTransicion, 120) + '], ' +

                                        -- Registrando cambios en el Estado Actual
                                        'Estado Origen - antes: ['
                                        + CAST(CO_EstadoRegistro_V2.NombreEstado AS VARCHAR(7000)) + '], '
                                        + 'Estado Origen - después: [' + CAST(@NuevoEstadoActual AS VARCHAR(7000))
                                        + '], ' +

                                        -- Registrando cambios en el Estado Siguiente
                                        'Estado Destino - antes: ['
                                        + CAST(EstadoSiguiente.NombreEstado AS VARCHAR(7000)) + '], '
                                        + 'Estado Destino - después: [' + CAST(@NuevoEstadoSiguiente AS VARCHAR(7000))
                                        + '], ' +

                                        -- Registrando cambios en el Nombre del Cambio de Estado
                                        'Descripción - antes: ['
                                        + CAST(CO_EstadoRegistroTransicion.Descripcion AS VARCHAR(7000)) + '], '
                                        + 'Descripción - después: ['
                                        + CAST(@NombreCambioEstado AS VARCHAR(7000)) + '], ',
                                        @IdUsuario,
                                        @IdContratoSeleccionado
                                    FROM
                                        CO_EstadoRegistroTransicion (NOLOCK)
                                        JOIN
                                            CO_EstadoRegistro_V2 (NOLOCK)
                                                ON CO_EstadoRegistroTransicion.IdEstadoOrigen = CO_EstadoRegistro_V2.IdClvEstado
                                                   AND CO_EstadoRegistroTransicion.IdEstadoRegistroTransicion = @IdTransicion
                                                   AND CO_EstadoRegistro_V2.IdContrato  =   @IdContratoSeleccionado
                                        JOIN
                                            CO_EstadoRegistro_V2 AS EstadoSiguiente (NOLOCK)
                                                ON CO_EstadoRegistroTransicion.IdEstadoDestino = EstadoSiguiente.IdClvEstado
                                                AND EstadoSiguiente.IdContrato  =   @IdContratoSeleccionado
                                    WHERE
                                        CO_EstadoRegistroTransicion.IdEstadoRegistroTransicion = @IdTransicion;

                        UPDATE
                            CO_EstadoRegistroTransicion
                        SET
                            IdEstadoOrigen = @IdEstadoActual,
                            IdEstadoDestino = @IdEstadoSiguiente,
                            Descripcion = @NombreCambioEstado,
                            ModificadoPor = @IdUsuario,
                            ModificadoEn = GETDATE()
                        WHERE
                            IdEstadoRegistroTransicion = @IdTransicion;

                    END
                ELSE
                    BEGIN
                        INSERT INTO CO_EstadoRegistroTransicion
                            (
                                IdEstadoOrigen,
                                IdEstadoDestino,
                                Descripcion,
                                CreadoPor,
                                CreadoEn
                            )
                                    SELECT
                                        @IdEstadoActual,
                                        @IdEstadoSiguiente,
                                        @NombreCambioEstado,
                                        @IdUsuario,
                                        GETDATE();

                        SET @IdTransicion = SCOPE_IDENTITY();

                        INSERT INTO dbo.AP_Bitacora
                            (
                                Fecha,
                                Tipo,
                                Mensaje,
                                Detalle,
                                UsuarioId,
                                ContratoId
                            )
                                    SELECT  DISTINCT
                                        GETDATE(),
                                        'Creación',
                                        'Registro CO_EstadoRegistroTransicion',
                                        'Registro de secuencia/transición (CO_EstadoRegistroTransicion) en la página 2/AdministracionCatalogos/AdministracionSecuenciaEstados.aspx: '
                                        + 'ID Transición: [' + CONVERT(VARCHAR(19), @IdTransicion, 120) + '], ' +

                                        -- Registrando Estado Actual
                                        'Estado Origen: [' + CAST(CO_EstadoRegistro_V2.NombreEstado AS VARCHAR(7000))
                                        + '], ' + 'ID Estado Origen: ['
                                        + CAST(CO_EstadoRegistroTransicion.IdEstadoOrigen AS VARCHAR(20)) + '], ' +

                                        -- Registrando Estado Siguiente
                                        'Estado Destino: [' + CAST(EstadoSiguiente.NombreEstado AS VARCHAR(7000))
                                        + '], ' + 'ID Estado Destino: ['
                                        + CAST(CO_EstadoRegistroTransicion.IdEstadoDestino AS VARCHAR(20)) + '], ' +

                                        -- Registrando Nombre del Cambio de Estado
                                        'Descripción: ['
                                        + CAST(CO_EstadoRegistroTransicion.Descripcion AS VARCHAR(7000)) + '], ' ,
                                        @IdUsuario,
                                        @IdContratoSeleccionado
                                    FROM
                                        CO_EstadoRegistroTransicion (NOLOCK)
                                        JOIN
                                            CO_EstadoRegistro_V2 (NOLOCK)
                                                ON CO_EstadoRegistroTransicion.IdEstadoOrigen = CO_EstadoRegistro_V2.IdClvEstado
                                                   AND CO_EstadoRegistroTransicion.IdEstadoRegistroTransicion = @IdTransicion
                                                   AND CO_EstadoRegistro_V2.IdContrato  =   @IdContratoSeleccionado
                                        JOIN
                                            CO_EstadoRegistro_V2 AS EstadoSiguiente (NOLOCK)
                                                ON CO_EstadoRegistroTransicion.IdEstadoDestino = EstadoSiguiente.IdClvEstado
                                                AND EstadoSiguiente.IdContrato  =   @IdContratoSeleccionado
                                    WHERE
                                        CO_EstadoRegistroTransicion.IdEstadoRegistroTransicion = @IdTransicion;
                       

                    END
                      COMMIT TRANSACTION;
                        SELECT
                            *
                        FROM
                            CO_EstadoRegistroTransicion (NOLOCK)
                        WHERE
                            IdEstadoRegistroTransicion = @IdTransicion;
            END
        ELSE
            BEGIN
                COMMIT TRANSACTION;
                SELECT
                    STUFF(
                             (
                                 SELECT
                                     ', ' + Validacion
                                 FROM
                                     #Validaciones
                                 FOR XML PATH(''), TYPE
                             ).value('.', 'VARCHAR(MAX)'), 1, 2, ''
                         ) AS resultado;
            END


END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;  
END CATCH
END
