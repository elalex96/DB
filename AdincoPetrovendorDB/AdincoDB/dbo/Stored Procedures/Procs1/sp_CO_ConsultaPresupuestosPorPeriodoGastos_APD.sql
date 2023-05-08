-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/04/2020>
-- Description:	<Consuta los presupuestos para aceptacion de pedido detalle>
-- =============================================
create PROCEDURE [dbo].[sp_CO_ConsultaPresupuestosPorPeriodoGastos_APD] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COP.IdPresupuesto, 
           CONCAT(COP.Nombre, ' [', COP.IdPresupuestoCNH, ']', ' - Periodo: ', COPC.NombrePeriodo) AS Nombre
    FROM CO_PeriodoContrato  AS COPC
      JOIN CO_ProgramaActividad AS COPA ON COPC.IdPeriodo = COPA.IdPeriodoContrato
      JOIN CO_Presupuesto AS COP ON COPA.IdProgramaActividad = COP.IdProgramaActividad AND COP.Actual = 1
	WHERE COPC.IdContrato = @IdContrato;

END