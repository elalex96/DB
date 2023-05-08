-- =============================================
-- Author:		Miguel
-- Create date: 10-1-2017
-- Description:	Consuta los Programas de activiades por presupuesto
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaProgramasActividadPorPeriodo] 
	-- Add the parameters for the stored procedure here
	@IdPeriodo int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        CO_ProgramaActividad.IdProgramaActividad, CO_ProgramaActividad.IdPeriodoContrato, CO_ProgramaActividad.IdTipoProgramaActividad, CO_ProgramaActividad.NombrePrograma, 
                         CO_PeriodoContrato.IdContrato, CO_PeriodoContrato.NombrePeriodo, CO_PeriodoContrato.Inicio, CO_PeriodoContrato.Fin
FROM            CO_ProgramaActividad INNER JOIN
                         CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
WHERE        (CO_PeriodoContrato.IdPeriodo  = @IdPeriodo)
END
