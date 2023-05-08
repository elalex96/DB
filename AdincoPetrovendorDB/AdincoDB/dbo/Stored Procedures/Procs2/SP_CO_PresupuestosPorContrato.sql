-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CO_PresupuestosPorContrato 
	-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT P.IdPresupuesto,
                P.Nombre
         FROM CO_Presupuesto AS P
              INNER JOIN CO_ProgramaActividad AS PA ON P.IdProgramaActividad = PA.IdProgramaActividad
              INNER JOIN CO_PeriodoContrato AS PC ON PA.IdPeriodoContrato = PC.IdPeriodo
         WHERE PC.IdContrato = @IdContrato
               AND P.Activo = 1
     END

