
-- =============================================
-- Author:		Luis David 
-- Create date: 07-07-2019
-- Description:	Consuta los presupuestos
-- =============================================
CREATE PROCEDURE [dbo].[p_MPY_CO_ConsultaPresupuestosPorPeriodo] 
	-- Add the parameters for the stored procedure here
@IdPeriodo INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	0 as IdProgramaActividad,
       0 as IdPeriodoContrato,
       0 as IdTipoProgramaActividad,
       'Todos' as NombrePrograma,
       0 as IdContrato,
       'Todos' as NombrePeriodo,
       '20180101' as Inicio,
       '20180101' as Fin,
       0 as IdPresupuesto,
       'Todos' as Nombre
union 
         SELECT CO_ProgramaActividad.IdProgramaActividad,
                CO_ProgramaActividad.IdPeriodoContrato,
                CO_ProgramaActividad.IdTipoProgramaActividad,
                CO_ProgramaActividad.NombrePrograma,
                CO_PeriodoContrato.IdContrato,
                CO_PeriodoContrato.NombrePeriodo,
                CO_PeriodoContrato.Inicio,
                CO_PeriodoContrato.Fin,
                CO_Presupuesto.IdPresupuesto,
                CO_Presupuesto.Nombre + '[' + CO_Presupuesto.IdPresupuestoCNH + ']' as Nombre
         FROM CO_ProgramaActividad
              INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
              INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
         
	    WHERE(CO_PeriodoContrato.IdPeriodo = @IdPeriodo)   and CO_Presupuesto.Activo=1
     END;