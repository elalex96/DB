IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_OT_Presupuestos'
)
    DROP PROCEDURE sp_OT_Presupuestos
GO
CREATE PROC [dbo].[sp_OT_Presupuestos]  
@pIdContratista INT,  
@pIdSubContrato INT,  
@pSoloSeleccionados BIT=0  
AS  
BEGIN 
  
SELECT CO_Presupuesto.IdPresupuesto,
       NombrePresupuesto = CO_Presupuesto.Nombre,
       CO_Presupuesto.Comentario,
       CO_Presupuesto.FechaAprobacionPEP,
       CO_Presupuesto.IdPresupuestoCNH
INTO #tmpResult
FROM CO_Presupuesto (NOLOCK)
    INNER JOIN CO_ProgramaActividad (NOLOCK)
        ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
    INNER JOIN CO_PeriodoContrato (NOLOCK)
        ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo 
    INNER JOIN CO_Contrato (NOLOCK)
        ON CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato 
            AND CO_Contrato.IdContratista = @pIdContratista
    INNER JOIN SC_Presupuesto (NOLOCK)
        ON CO_Presupuesto.IdPresupuesto = SC_Presupuesto.IdPresupuesto
           AND SC_Presupuesto.IdSubContrato = @pIdSubContrato
WHERE CO_Presupuesto.Actual = 1
      AND (
              (
                  @pSoloSeleccionados = 1
                  AND SC_Presupuesto.IdSubContratoPresupuesto IS NOT NULL
              )
              OR (@pSoloSeleccionados = 0)
          )
GROUP BY CO_Presupuesto.IdPresupuesto,
         CO_Presupuesto.Nombre,
         CO_Presupuesto.Comentario,
         CO_Presupuesto.FechaAprobacionPEP,
         CO_Presupuesto.IdPresupuestoCNH
ORDER BY CO_Presupuesto.IdPresupuesto DESC,
         CO_Presupuesto.Nombre

IF NOT EXISTS (SELECT 1 FROM #tmpResult)
BEGIN
    INSERT INTO #tmpResult
    SELECT CO_Presupuesto.IdPresupuesto,
           NombrePresupuesto = CO_Presupuesto.Nombre,
           CO_Presupuesto.Comentario,
           CO_Presupuesto.FechaAprobacionPEP,
           CO_Presupuesto.IdPresupuestoCNH
    FROM CO_Presupuesto (NOLOCK)
        INNER JOIN SC_SubContrato (NOLOCK)
            ON SC_SubContrato.IdSubContrato = @pIdSubContrato
				AND @pIdSubContrato > 0
        INNER JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad 
        INNER JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo  
        INNER JOIN CO_Contrato (NOLOCK)
            ON CO_Contrato.IdContratista = @pIdContratista
				AND CO_PeriodoContrato.IdContrato = CO_Contrato.IdContrato  
				AND SC_SubContrato.IdContrato = CO_Contrato.IdContrato  
    WHERE CO_Presupuesto.Actual = 1
    GROUP BY CO_Presupuesto.IdPresupuesto,
             CO_Presupuesto.Nombre,
             CO_Presupuesto.Comentario,
             CO_Presupuesto.FechaAprobacionPEP,
             CO_Presupuesto.IdPresupuestoCNH
    ORDER BY CO_Presupuesto.IdPresupuesto DESC

END

	SELECT *
	FROM #tmpResult
	ORDER BY IdPresupuesto DESC
END