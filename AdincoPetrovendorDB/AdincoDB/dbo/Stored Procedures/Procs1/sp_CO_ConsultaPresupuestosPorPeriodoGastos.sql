--╔════════════════════════════════════════════╗
--║Uso de SP en Sistema de ADINCO y PETROVENDOR║
--╚════════════════════════════════════════════╝
--=============================================
-- Author:		Miguel
-- Create date: 10-1-2017
-- Description:	Consuta los presupuestos
--=============================================
-- Author:		Daniel AC
-- Create date: 13/07/2022
-- Description:	Orden de tablas 
--=============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	10 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK 
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPresupuestosPorPeriodoGastos]
    @IdPeriodo INT = 0
AS
BEGIN
    SET NOCOUNT ON;
	-- 
    SELECT CO_ProgramaActividad.IdProgramaActividad,
           CO_ProgramaActividad.IdPeriodoContrato,
           CO_ProgramaActividad.IdTipoProgramaActividad,
           CO_ProgramaActividad.NombrePrograma,
           CO_PeriodoContrato.IdContrato,
           CO_PeriodoContrato.NombrePeriodo,
           CO_PeriodoContrato.Inicio,
           CO_PeriodoContrato.Fin,
           CO_Presupuesto.IdPresupuesto,
           CONCAT(CO_Presupuesto.Nombre, ' [', CO_Presupuesto.IdPresupuestoCNH, ']') AS Nombre
    FROM CO_ProgramaActividad (NOLOCK)
        JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
        JOIN CO_Presupuesto (NOLOCK)
            ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
    WHERE (CO_PeriodoContrato.IdPeriodo = @IdPeriodo)
          AND (CO_Presupuesto.Actual = 1);
END;