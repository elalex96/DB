-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/01/2021>
-- Description:	<Consuta los presupuestos para solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPresupuestosPorPeriodoGastos_SOLPED] 
	-- Add the parameters for the stored procedure here
	@IdPeriodo INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COP.IdPresupuesto, 
           CONCAT(COP.Nombre, ' [', COP.IdPresupuestoCNH, ']') AS Nombre
    FROM CO_PeriodoContrato  AS COPC
      JOIN CO_ProgramaActividad AS COPA ON COPC.IdPeriodo = COPA.IdPeriodoContrato
      JOIN CO_Presupuesto AS COP ON COPA.IdProgramaActividad = COP.IdProgramaActividad AND COP.Actual = 1
    WHERE COPC.IdPeriodo = @IdPeriodo;
END
