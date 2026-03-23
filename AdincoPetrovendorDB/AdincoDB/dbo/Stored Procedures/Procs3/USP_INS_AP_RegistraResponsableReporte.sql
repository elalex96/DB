IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_AP_RegistraResponsableReporte'
    )
    DROP PROCEDURE USP_INS_AP_RegistraResponsableReporte;
GO
CREATE PROCEDURE [dbo].[USP_INS_AP_RegistraResponsableReporte]
    @IdUsuario              INT = 0,
    @IdContrato             INT,
    @IdContratoSeleccionado INT,
    @Id                     INT,
    @TipoReporteId          INT,
    @Tipo                   VARCHAR(7000),
    @NombrePersona          VARCHAR(7000),
    @FichaPersona           VARCHAR(7000),
    @PuestoPersona          VARCHAR(7000),
    @Activo                 BIT
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            CREATE TABLE #Validaciones (Validacion VARCHAR(7000));
            DECLARE @NuevoReporte VARCHAR(7000);

            IF (@Activo =  1)
             BEGIN
                IF EXISTS
                    (
                        SELECT
                            1
                        FROM
                            AP_ResponsablesReportes (NOLOCK)
                        WHERE
                            TipoReporteId = @TipoReporteId
                            AND ContratoId = @IdContratoSeleccionado
                            AND UPPER(REPLACE(Tipo,' ','')) = UPPER(REPLACE(@Tipo,' ',''))
                            AND Activo = 1
                            AND Id <> @Id
                    )
                    BEGIN
                        INSERT INTO #Validaciones
                            (
                                Validacion
                            )
                                    SELECT
                                        '[No se puede guardar el responsable debido a que ya existe un responsable activo para el mismo reporte, tipo y contrato.]'
                    END
                END

            IF EXISTS
                    (
                        SELECT
                            1
                        FROM
                            AP_ResponsablesReportes (NOLOCK)
                        WHERE
                            TipoReporteId = @TipoReporteId
                            AND ContratoId = @IdContratoSeleccionado
                            AND UPPER(REPLACE(Tipo,' ','')) = UPPER(REPLACE(@Tipo,' ',''))
                            AND UPPER(REPLACE(NombrePersona,' ','')) = UPPER(REPLACE(@NombrePersona,' ',''))
                            AND UPPER(REPLACE(FichaPersona,' ','')) = UPPER(REPLACE(@FichaPersona,' ',''))
                            AND UPPER(REPLACE(PuestoPersona,' ','')) = UPPER(REPLACE(@PuestoPersona,' ',''))
                            AND Id <> @Id
                    )
                    BEGIN
                        INSERT INTO #Validaciones
                            (
                                Validacion
                            )
                                    SELECT
                                        ' [No se puede realizar el guardado debido a que ya existe un responsable con el mismo nombre, ficha y puesto en el mismo reporte, tipo y contrato.]'
                    END

            IF NOT EXISTS
                (
                    SELECT
                        1
                    FROM
                        #Validaciones
                )
                BEGIN
                    if (@Id > 0)
                        BEGIN

                            SELECT
                                @NuevoReporte = NombreReporte
                            FROM
                                AP_TipoReportesSistema
                            WHERE
                                Id = @TipoReporteId;


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
                                            'Edición AP_ResponsablesReportes',
                                            'Edición de responsable de reporte (AP_ResponsablesReportes) en la página 2/AdministracionCatalogos/AdminResponsablesReportes.aspx: '
                                            + 'ID: [' + CONVERT(VARCHAR(19), @Id, 120) + '], '
                                            + 'Tipo reporte - antes: ['
                                            + CAST(AP_TipoReportesSistema.NombreReporte AS VARCHAR(7000)) + '], '
                                            + 'Tipo reporte - después: [' + CAST(@NuevoReporte AS VARCHAR(7000))
                                            + '], ' + 'Tipo reporte Id - antes: ['
                                            + CAST(AP_ResponsablesReportes.TipoReporteId AS VARCHAR(7000)) + '], '
                                            + 'Tipo reporte Id - después: [' + CAST(@TipoReporteId AS VARCHAR(7000))
                                            + '], ' + 'Tipo - antes: ['
                                            + CAST(AP_ResponsablesReportes.Tipo AS VARCHAR(7000)) + '], '
                                            + 'Tipo - después: [' + CAST(@Tipo AS VARCHAR(7000)) + '], ' +

                                            'Nombre persona - antes: ['
                                            + CAST(AP_ResponsablesReportes.NombrePersona AS VARCHAR(7000)) + '], '
                                            + 'Nombre persona - después: [' + CAST(@NombrePersona AS VARCHAR(7000))
                                            + '], ' + 'Ficha persona - antes: ['
                                            + CAST(AP_ResponsablesReportes.FichaPersona AS VARCHAR(7000)) + '], '
                                            + 'Ficha persona - después: [' + CAST(@FichaPersona AS VARCHAR(7000))
                                            + '], ' + 'Puesto persona - antes: ['
                                            + CAST(AP_ResponsablesReportes.PuestoPersona AS VARCHAR(7000)) + '], '
                                            + 'Puesto persona - después: [' + CAST(@PuestoPersona AS VARCHAR(7000))
                                            + '], ' + 'Activo - antes: ['
                                            + CASE
                                                  WHEN CAST(AP_ResponsablesReportes.Activo AS VARCHAR(20)) = '1'
                                                      THEN 'Sí'
                                                  ELSE
                                                      'No'
                                              END + '], ' + 'Activo - después: ['
                                            + CASE
                                                  WHEN CAST(@Activo AS VARCHAR(20)) = '1'
                                                      THEN 'Sí'
                                                  ELSE
                                                      'No'
                                              END + '].',
                                            @IdUsuario,
                                            @IdContratoSeleccionado
                                        FROM
                                            AP_ResponsablesReportes (NOLOCK)
                                            JOIN
                                                AP_TipoReportesSistema (NOLOCK)
                                                    ON AP_ResponsablesReportes.TipoReporteId = AP_TipoReportesSistema.Id
                                                       AND AP_ResponsablesReportes.ContratoId = @IdContratoSeleccionado
                                                       AND AP_ResponsablesReportes.Id = @Id
                                        WHERE
                                            AP_ResponsablesReportes.Id = @Id;

                            UPDATE
                                AP_ResponsablesReportes
                            SET
                                TipoReporteId = @TipoReporteId,
                                Tipo = @Tipo,
                                NombrePersona = @NombrePersona,
                                FichaPersona = @FichaPersona,
                                PuestoPersona = @PuestoPersona,
                                Activo = @Activo,
                                ModificadoPor = @IdUsuario,
                                ModificadoEn = GETDATE()
                            WHERE
                                AP_ResponsablesReportes.Id = @Id;

                        END
                    ELSE
                        BEGIN
                            INSERT INTO AP_ResponsablesReportes
                                (
                                    ContratoId,
                                    TipoReporteId,
                                    Tipo,
                                    NombrePersona,
                                    FichaPersona,
                                    PuestoPersona,
                                    Activo,
                                    CreadoEn,
                                    CreadoPor
                                )
                                        SELECT
                                            @IdContratoSeleccionado,
                                            @TipoReporteId,
                                            @Tipo,
                                            @NombrePersona,
                                            @FichaPersona,
                                            @PuestoPersona,
                                            @Activo,
                                            GETDATE(),
                                            @IdUsuario;
                                           

                            SET @Id = SCOPE_IDENTITY();

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
                                            'Creación',
                                            'Registro AP_ResponsablesReportes',
                                            'Registro de responsable de reporte (AP_ResponsablesReportes) en la página 2/AdministracionCatalogos/AdminResponsablesReportes.aspx: '
                                            + 'ID: [' + CONVERT(VARCHAR(19), @Id, 120) + '], ' +

                                            'Tipo reporte: [' + CAST(AP_TipoReportesSistema.NombreReporte AS VARCHAR(7000)) + '], '
                                            + 'Tipo reporte Id: ['
                                            + CAST(AP_ResponsablesReportes.TipoReporteId AS VARCHAR(20)) + '], '
                                            + 'Tipo: [' + CAST(AP_ResponsablesReportes.Tipo AS VARCHAR(7000)) + '], '
                                            + 'Nombre persona: ['
                                            + CAST(AP_ResponsablesReportes.NombrePersona AS VARCHAR(20)) + '], '
                                            + 'Puesto persona : ['
                                            + CAST(AP_ResponsablesReportes.PuestoPersona AS VARCHAR(7000)) + '], '
                                            + 'Ficha persona : ['
                                            + CAST(AP_ResponsablesReportes.FichaPersona AS VARCHAR(7000)) + '], '
                                            + 'Activo : ['
                                            + CASE
                                                  WHEN CAST(AP_ResponsablesReportes.Activo AS VARCHAR(20)) = '1'
                                                      THEN 'Sí'
                                                  ELSE
                                                      'No'
                                              END + '], ',
                                            @IdUsuario,
                                            @IdContratoSeleccionado
                                        FROM
                                            AP_ResponsablesReportes (NOLOCK)
                                            JOIN
                                                AP_TipoReportesSistema (NOLOCK)
                                                    ON AP_ResponsablesReportes.TipoReporteId = AP_TipoReportesSistema.Id
                                                       AND AP_ResponsablesReportes.ContratoId = @IdContratoSeleccionado
                                                       AND AP_ResponsablesReportes.Id = @Id
                                        WHERE
                                            AP_ResponsablesReportes.Id = @Id;


                        END
                    COMMIT TRANSACTION;
                    SELECT
                        *
                    FROM
                        AP_ResponsablesReportes (NOLOCK)
                    WHERE
                        Id = @Id;
                END
            ELSE
                BEGIN
                    COMMIT TRANSACTION;
                    SELECT 'MENSAJE DE WARNING: ' +
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
