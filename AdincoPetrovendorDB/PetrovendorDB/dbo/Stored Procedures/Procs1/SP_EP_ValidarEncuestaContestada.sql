-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <10/01/2018>
-- Description:	<Valida que la encuesta del pedido ya no pueda ser contestada dos veces por el mismo usuario>
-- =============================================
CREATE PROCEDURE SP_EP_ValidarEncuestaContestada
@IdPedido INT,
@IdUsuario INT,

--Parametros del contrato
@IdContrato INT,
@FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS
	(
	SELECT IdEvaluacionProveedor FROM dbo.EP_EvaluacionProveedor WHERE IdPedido = @IdPedido AND IdUsuarioEvaluador = @IdUsuario AND EstatusEvaluacion = 1
	)
	BEGIN
		SELECT 'ENCUESTA_CONTESTADA_POR_EL_USUARIO'
    END    
	ELSE
	BEGIN
		SELECT 'SIN_CONTESTAR'
    END
	
	

	


END
