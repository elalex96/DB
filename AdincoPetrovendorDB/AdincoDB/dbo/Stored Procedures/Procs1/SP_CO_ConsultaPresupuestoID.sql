-- =============================================
-- Author:		Marcos Garcia
-- Create date: 21-01-2020
-- Description:	Consulta Datos de CO_Presupuesto por IdPresupuesto
-- =============================================
-- Alter date: 12-02-2020
-- Description:	Select Activo por Actual
-- =============================================

CREATE PROCEDURE [dbo].[SP_CO_ConsultaPresupuestoID]
--[SP_CO_ConsultaPresupuestoID] 2,0,0
--  the parameters for the stored procedure here 
@IdPresupuesto INT, 
@IdUsuario     INT, 
@IdContrato    INT
AS
     BEGIN
         SELECT IdPresupuesto, 
                Nombre, 
                IdPresupuestoCNH, 
                ISNULL(Actual, 0) AS Activo, 
                ISNULL(ActivoProcura, 0) AS ActivoProcura, 
                InicioPresupuesto, 
                FinPresupuesto
         FROM Adinco.dbo.CO_Presupuesto(NOLOCK)
         WHERE IdPresupuesto = @IdPresupuesto
         ORDER BY IdPresupuesto DESC;
     END;