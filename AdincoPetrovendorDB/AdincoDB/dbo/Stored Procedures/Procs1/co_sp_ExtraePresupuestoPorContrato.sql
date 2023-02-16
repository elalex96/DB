CREATE PROCEDURE [dbo].[co_sp_ExtraePresupuestoPorContrato]
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
         SELECT P.IdPresupuesto,  
                P.Nombre  
         FROM CO_Presupuesto AS P	(NOLOCK)  
              JOIN CO_ProgramaActividad AS PA (NOLOCK)  
			  ON P.IdProgramaActividad = PA.IdProgramaActividad  
              JOIN CO_PeriodoContrato AS PC (NOLOCK)  
			  ON PA.IdPeriodoContrato = PC.IdPeriodo  
         WHERE PC.IdContrato = @IdContrato  
END;
---------------------------------------------------------------------------------
