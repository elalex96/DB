IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_OT_ObtenMesesDisponiblesParaReporteDeOT'
    )
    DROP PROCEDURE USP_SEL_OT_ObtenMesesDisponiblesParaReporteDeOT
GO
CREATE PROCEDURE [dbo].[USP_SEL_OT_ObtenMesesDisponiblesParaReporteDeOT] --3,10,2867
    @ContratoId    INT,
    @UsuarioId     INT,
    @OTSolicitudId INT
AS
    BEGIN
        SET NOCOUNT ON

        SELECT
            PrimerDiaMes                 as IdFecha,
            CONCAT(NombreMes, '-', Anio) AS Fecha
        FROM
            [dbo].[OT_SolicitudMaterial] (NOLOCK)
            JOIN
                SC_Materiales (NOLOCK)
                    on OT_SolicitudMaterial.IdOTSolicitud = @OTSolicitudId
                       AND OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
            JOIN
                [dbo].[OT_SolicitudProgramaCaptura] (NOLOCK)
                    ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                       AND [OT_SolicitudProgramaCaptura].VoBoContratista = 1
                       AND [OT_SolicitudProgramaCaptura].VoBoSubcontratista = 1
            JOIN
                OT_ProgramaSemanaCerrada (NOLOCK)
                    ON OT_ProgramaSemanaCerrada.IdOTSolicitud = @OTSolicitudId
                       AND OT_SolicitudProgramaCaptura.Fecha
                       BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
                       AND OT_ProgramaSemanaCerrada.isActivo = 1
            JOIN
                AP_Calendario (NOLOCK)
                    ON OT_SolicitudProgramaCaptura.Fecha = AP_Calendario.IdFecha
        WHERE
            OT_ProgramaSemanaCerrada.IdOTSolicitud = @OTSolicitudId
        GROUP BY
            PrimerDiaMes,
            CONCAT(NombreMes, '-', Anio);
    END