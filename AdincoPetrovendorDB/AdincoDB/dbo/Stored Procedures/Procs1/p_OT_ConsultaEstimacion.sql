IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_ConsultaEstimacion'
    )
    DROP PROCEDURE p_OT_ConsultaEstimacion;
GO
CREATE PROCEDURE [dbo].[p_OT_ConsultaEstimacion] @pIdOTSolicitud int
as
BEGIN
    select
        IdOTSolicitud,
        IdOTEstimacion,
        FolioEstimacion,
        FolioOT,
        FolioSC,
        FechaIniCorte,
        FechaFinCorte,
        Instalacion,
        Actividad,
        Presupuesto,
        Subcontratista,
        Total  = Sum(vw.Importe),
        Moneda = vw.Moneda
    from
        [dbo].[vwOTEstimacion] vw (NOLOCK)
    where
        IdOTSolicitud = @pIdOTSolicitud
    group by
        IdOTSolicitud,
        IdOTEstimacion,
        FolioEstimacion,
        FolioOT,
        FolioSC,
        FechaIniCorte,
        FechaFinCorte,
        Instalacion,
        Actividad,
        Presupuesto,
        Subcontratista,
        vw.Moneda

END