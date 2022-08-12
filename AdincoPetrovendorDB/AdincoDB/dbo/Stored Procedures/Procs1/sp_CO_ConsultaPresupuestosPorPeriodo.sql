-- =============================================
-- Author:		Miguel
-- Create date: 10-1-2017
-- Description:	Consuta los presupuestos
-- =============================================
-- Author:		REYNA O
-- Create date: 09-08-2022
-- Description:	SE AGREGA NOLOCKS,
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPresupuestosPorPeriodo] 
-- Add the parameters for the stored procedure here
@IdPeriodo INT = 0
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT CO_ProgramaActividad.IdProgramaActividad, 
                CO_ProgramaActividad.IdPeriodoContrato, 
                CO_ProgramaActividad.IdTipoProgramaActividad, 
                CO_ProgramaActividad.NombrePrograma, 
                CO_PeriodoContrato.IdContrato, 
                CO_PeriodoContrato.NombrePeriodo, 
                CO_PeriodoContrato.Inicio, 
                CO_PeriodoContrato.Fin, 
                CO_Presupuesto.IdPresupuesto, 
                CO_Presupuesto.Nombre+'['+CO_Presupuesto.IdPresupuestoCNH+']' AS Nombre
         FROM 
			CO_ProgramaActividad	(NOLOCK)
        INNER JOIN 
			CO_PeriodoContrato		(NOLOCK)
			ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
        INNER JOIN 
			CO_Presupuesto			(NOLOCK)
			ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
        WHERE
			(CO_PeriodoContrato.IdPeriodo = @IdPeriodo);
     END;