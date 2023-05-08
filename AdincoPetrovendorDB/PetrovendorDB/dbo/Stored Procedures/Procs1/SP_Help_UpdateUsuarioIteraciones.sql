-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <12-04-18>
-- Description:	<Actualiza el estado del usuario para ya no mostrar las actualizaciones cada vez que inicia>
-- =============================================
create PROCEDURE SP_Help_UpdateUsuarioIteraciones
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.S_Usuario SET NotificacionActualizaciones = 0 WHERE IdUsuario = @IdUsuario
	SELECT 'success'

END
