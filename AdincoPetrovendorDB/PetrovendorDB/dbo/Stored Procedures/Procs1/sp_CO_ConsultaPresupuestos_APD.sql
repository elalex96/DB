-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <24/04/2021>
-- Description:	<consulta de presupuestos para la reclasificacion presupuestal>
-- =============================================
create PROCEDURE [dbo].[sp_CO_ConsultaPresupuestos_APD]
	-- Add the parameters for the stored procedure here
	@IdContratop INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	EXEC Adinco.dbo.sp_CO_ConsultaPresupuestosPorPeriodoGastos_APD @IdContrato = @IdContratop

END
