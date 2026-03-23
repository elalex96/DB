IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_DEL_CO_EliminarSecuenciaEstados'
    )
    DROP PROCEDURE USP_DEL_CO_EliminarSecuenciaEstados;
GO
CREATE PROCEDURE [dbo].[USP_DEL_CO_EliminarSecuenciaEstados] --1,1,10,10007
    @IdUsuario              INT = 0,
    @IdContrato             INT,
    @IdContratoSeleccionado INT,
    @IdTransicion           INT
AS
    BEGIN

    BEGIN TRY
    BEGIN TRANSACTION;

            INSERT INTO dbo.AP_Bitacora
            (
                Fecha,
                Tipo,
                Mensaje,
                Detalle,
                UsuarioId,
                ContratoId
            )
                    SELECT DISTINCT  GETDATE(),
                        'Eliminación',
                        'Eliminación CO_EstadoRegistroTransicion',
                        'Eliminación de secuencia/transición en la página 2/AdministracionCatalogos/AdministracionSecuenciaEstados.aspx: '
                        + 'ID Transición: [' + CAST(@IdTransicion AS VARCHAR(20)) + '], ' +

                        -- Registrando Estado Actual
                        'Estado Origen: [' + CAST(CO_EstadoRegistro_V2.NombreEstado AS VARCHAR(7000)) + '], '
                        + 'ID Estado Origen: [' + CAST(CO_EstadoRegistroTransicion.IdEstadoOrigen AS VARCHAR(20)) + '], ' +

                        -- Registrando Estado Siguiente
                        'Estado Destino: [' + CAST(EstadoSiguiente.NombreEstado AS VARCHAR(7000)) + '], '
                        + 'ID Estado Destino: [' + CAST(CO_EstadoRegistroTransicion.IdEstadoDestino AS VARCHAR(20)) + '], '
                        +

                        -- Registrando Nombre del Cambio de Estado
                        'Descripción: [' + CAST(CO_EstadoRegistroTransicion.Descripcion AS VARCHAR(7000)) + '], '
                        ,
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

        DELETE CO_EstadoRegistroTransicion
        WHERE
            IdEstadoRegistroTransicion = @IdTransicion;

        COMMIT TRANSACTION;
        SELECT
            'Eliminado correctamente' AS respuesta;
   
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;  
    END CATCH
    END
