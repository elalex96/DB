-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_EP_VerificarEncuestaContestadaPed
@IdPedido INT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS ( SELECT IdProveedorEvaluado FROM  dbo.EP_EvaluacionProveedor WHERE IdEvaluacionProveedorDetalle = @IdPedido )
	BEGIN
	SELECT 'ENCUESTA_CONTESTADA'
	END
	ELSE
	BEGIN
	SELECT 'SIN_CONTESTAR'
	END
	

END
