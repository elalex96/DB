USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaPresupuestosPorPeriodoGastos'
)
    DROP PROCEDURE sp_CO_ConsultaPresupuestosPorPeriodoGastos;
/****** Object:  StoredProcedure [dbo].[sp_CO_ConsultaPresupuestosPorPeriodoGastos]    Script Date: 13/07/2022 02:10:36 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================
-- Author:		Miguel
-- Create date: 10-1-2017
-- Description:	Consuta los presupuestos
--=============================================
--=============================================
-- Author:		Daniel AC
-- Create date: 13/07/2022
-- Description:	Orden de tablas 
--=============================================
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
                CONCAT(CO_Presupuesto.Nombre, ' [', CO_Presupuesto.IdPresupuestoCNH, ']') AS Nombre
         FROM CO_ProgramaActividad
              JOIN CO_PeriodoContrato 
				ON CO_ProgramaActividad.IdPeriodoContrato  = CO_PeriodoContrato.IdPeriodo 
              JOIN CO_Presupuesto 
				ON CO_ProgramaActividad.IdPeriodoContrato  = CO_Presupuesto.IdProgramaActividad 
         WHERE(CO_PeriodoContrato.IdPeriodo = @IdPeriodo)
              AND (CO_Presupuesto.Actual = 1);
     END;