-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <25 01 2018>
-- Description:	<Actualiza el tipo de proceso de la solicitud de pedido>
-- =============================================
CREATE PROCEDURE SP_MM_CambiarEstatusTipoProcesoSolPed
@IdSolPed INT,
@IdTipoProceso INT,

@IdUsuario INT,
@IdContrato INT,
@FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.MM_SolicitudPedido
	SET IdTipoProceso = @IdTipoProceso
	WHERE IdSolicitudPedido = @IdSolPed

END
