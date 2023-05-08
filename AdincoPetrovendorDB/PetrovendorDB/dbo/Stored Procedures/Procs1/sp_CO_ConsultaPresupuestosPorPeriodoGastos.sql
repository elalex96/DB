-- =============================================-- Author:		Miguel-- Create date: 10-1-2017-- Description:	Consuta los presupuestos-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPresupuestosPorPeriodoGastos] 
-- Add the parameters for the stored procedure here
@IdPeriodo INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from-- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         SELECT CO_ProgramaActividad.IdProgramaActividad,
                CO_ProgramaActividad.IdPeriodoContrato,
                CO_ProgramaActividad.IdTipoProgramaActividad,
                CO_ProgramaActividad.NombrePrograma,
                CO_PeriodoContrato.IdContrato,
                CO_PeriodoContrato.NombrePeriodo,
                CO_PeriodoContrato.Inicio,
                CO_PeriodoContrato.Fin,
                CO_Presupuesto.IdPresupuesto,
                CONCAT(CO_Presupuesto.Nombre, ' [', CO_Presupuesto.IdPresupuestoCNH, ']')AS Nombre
                
         FROM CO_ProgramaActividad
              INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
              INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
         WHERE(CO_PeriodoContrato.IdPeriodo = @IdPeriodo)
              AND (CO_Presupuesto.Activo = 1);
     END;
