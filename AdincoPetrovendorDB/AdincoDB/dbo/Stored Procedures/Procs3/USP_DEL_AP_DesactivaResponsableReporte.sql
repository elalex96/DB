IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_DEL_AP_DesactivaResponsableReporte'
    )
    DROP PROCEDURE USP_DEL_AP_DesactivaResponsableReporte;
GO
CREATE PROCEDURE [dbo].[USP_DEL_AP_DesactivaResponsableReporte] --1,1,10,10007
    @IdUsuario              INT = 0,
    @IdContrato             INT,
    @IdContratoSeleccionado INT,
    @Id           INT
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
                    SELECT
                        GETDATE(),
                        'Desactivación',
                        'Desactivación AP_ResponsablesReportes',
                        'Desactivación de Responsable reporte en la página 2/AdministracionCatalogos/AdminResponsablesReportes.aspx: '
                        + 'ID: [' + CAST(@Id AS VARCHAR(20)) + '], ' +

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

        UPDATE 
        AP_ResponsablesReportes
        SET Activo = 0
        WHERE
          AP_ResponsablesReportes.Id = @Id;

        COMMIT TRANSACTION;
        SELECT
            'Desactivado correctamente' AS respuesta;
   
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;  
    END CATCH
    END
