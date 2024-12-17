USE ADINCO
GO
DROP PROC IF EXISTS co_sp_ExtraePresupuestoPorContrato
GO
-- =============================================
-- Author:		Luis David
-- Create date: 4/12/2024
-- Description:	Se deja unicamente el filtro por Activo Procura
-- =============================================
CREATE PROCEDURE [dbo].[co_sp_ExtraePresupuestoPorContrato]  
    @IdUsuario INT,  
    @IdContrato INT  
AS  
BEGIN  
         SELECT P.IdPresupuesto,    
                P.Nombre    
         FROM CO_Presupuesto AS P (NOLOCK)    
              JOIN CO_ProgramaActividad AS PA (NOLOCK)    
     ON P.IdProgramaActividad = PA.IdProgramaActividad    
              JOIN CO_PeriodoContrato AS PC (NOLOCK)    
     ON PA.IdPeriodoContrato = PC.IdPeriodo    
         WHERE PC.IdContrato = @IdContrato
		 AND P.ActivoProcura = 1
END;  
