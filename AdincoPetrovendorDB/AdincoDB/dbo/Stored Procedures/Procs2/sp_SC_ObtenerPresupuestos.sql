IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ObtenerPresupuestos'
)
    DROP PROCEDURE sp_SC_ObtenerPresupuestos;
GO
CREATE Proc [dbo].[sp_SC_ObtenerPresupuestos]
    @pIdContratista int,
    @pIdSubContrato int,
    @pSoloSeleccionados bit = 0
As
BEGIN
CREATE TABLE #tmpResult
(
    IdSubContratoPresupuesto INT,
    IdPresupuesto INT,
    NombrePresupuesto NVARCHAR(MAX),
    Comentario NVARCHAR(MAX),
    FechaAprobacionPEP DATE
)

INSERT INTO #tmpResult
(
    IdSubContratoPresupuesto,
    IdPresupuesto,
    NombrePresupuesto,
    Comentario,
    FechaAprobacionPEP
)
SELECT SC_Presupuesto.IdSubContratoPresupuesto,
       CO_Presupuesto.IdPresupuesto,
       NombrePresupuesto = CO_Presupuesto.Nombre,
       CO_Presupuesto.Comentario,
       CO_Presupuesto.FechaAprobacionPEP
FROM CO_Presupuesto (NOLOCK)
    INNER JOIN CO_ProgramaActividad (NOLOCK)
        ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
		AND CO_Presupuesto.Activo = 1    
    INNER JOIN CO_PeriodoContrato (NOLOCK)
        ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
    INNER JOIN CO_Contrato (NOLOCK)
        ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
		AND CO_Contrato.IdContratista = @pIdContratista
    LEFT JOIN SC_Presupuesto (NOLOCK)
        ON CO_Presupuesto.IdPresupuesto = SC_Presupuesto.IdPresupuesto
           AND SC_Presupuesto.IdSubContrato = @pIdSubContrato
WHERE 
	CO_Contrato.IdContratista = @pIdContratista
      AND CO_Presupuesto.Activo = 1
      AND (
              (
                  @pSoloSeleccionados = 1
                  AND SC_Presupuesto.IdSubContratoPresupuesto IS NOT NULL
              )
              OR (@pSoloSeleccionados = 0)
          )
ORDER BY SC_Presupuesto.IdSubContratoPresupuesto DESC,
         CO_Presupuesto.Nombre

IF NOT EXISTS (select 1 from #tmpResult)
BEGIN

   INSERT INTO #tmpResult
    (
        IdSubContratoPresupuesto,
        IdPresupuesto,
        NombrePresupuesto,
        Comentario,
        FechaAprobacionPEP
    )
    SELECT IdSubContratoPresupuesto = 0,
           CO_Presupuesto.IdPresupuesto,
           NombrePresupuesto = CO_Presupuesto.Nombre,
           CO_Presupuesto.Comentario,
           CO_Presupuesto.FechaAprobacionPEP
    FROM CO_Presupuesto		(NOLOCK)
        INNER JOIN CO_ProgramaActividad	(NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
			AND CO_Presupuesto.Activo = 1
        INNER JOIN CO_PeriodoContrato	(NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
        INNER JOIN CO_Contrato	(NOLOCK)
            ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato
    WHERE 
		 CO_Contrato.IdContratista = @pIdContratista
          AND CO_Presupuesto.Activo = 1
    ORDER BY
		CO_Presupuesto.Nombre

END

SELECT *
FROM #tmpResult

END;


