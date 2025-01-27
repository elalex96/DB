IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_Presupuestos_grd'
)
    DROP PROCEDURE p_Presupuestos_grd
GO

CREATE PROCEDURE [dbo].[p_Presupuestos_grd]
(
    @pIdSubContrato INT
)
AS
BEGIN
    SELECT
        s.idSubcontrato,
        pre.IdPresupuesto,
        pre.IdAnioContractual,
        pre.IdProgramaActividad,
        pre.Version,
        pre.Nombre,
        pre.Comentario,
        pre.FechaAprobacionPEP,
        pre.Activo,
        pre.IdPresupuestoCNH,
        pre.Actual,
        pre.CIEP,
        pre.ActivoProcura,
        Seleccionado = CASE 
                           WHEN p.IdPresupuesto IS NULL THEN CAST(0 AS BIT) 
                           ELSE CAST(1 AS BIT) 
                       END
    FROM
        SC_Subcontrato (NOLOCK) s
    INNER JOIN
        CO_PeriodoContrato (NOLOCK) pc 
        ON pc.IdContrato = s.IdContrato
    INNER JOIN
        CO_ProgramaActividad (NOLOCK) pa 
        ON pa.IdPeriodoContrato = pc.IdPeriodo
    INNER JOIN
        CO_Presupuesto (NOLOCK) pre 
        ON pre.IdProgramaActividad = pa.IdProgramaActividad
    LEFT JOIN
        SC_Presupuesto (NOLOCK) p
        ON pre.IdPresupuesto = p.IdPresupuesto
        AND s.IdSubContrato = p.IdSubContrato
    WHERE
        s.idSubcontrato = @pIdSubContrato 
END

