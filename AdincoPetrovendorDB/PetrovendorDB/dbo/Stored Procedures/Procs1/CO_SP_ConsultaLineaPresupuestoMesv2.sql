CREATE PROCEDURE [dbo].[CO_SP_ConsultaLineaPresupuestoMesv2] --3
@presupuesto INT
AS
     BEGIN
         EXEC Adinco.dbo.CO_SP_ConsultaLineaPresupuestoMesv2 @presupuesto = @presupuesto 
     END

