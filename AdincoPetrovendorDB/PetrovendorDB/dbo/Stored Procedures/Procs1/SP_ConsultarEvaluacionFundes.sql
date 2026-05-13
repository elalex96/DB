-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarEvaluacionFundes]
@IdProveedorEvaluado int,
@IdProveedorEvaluador int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT IdEvaluacionFundes
FROM PV_FundesEvaluacion 
WHERE ProveedorEvaluado = @IdProveedorEvaluado AND ProveedorEvaluador = @IdProveedorEvaluador AND Activo = 1

END

