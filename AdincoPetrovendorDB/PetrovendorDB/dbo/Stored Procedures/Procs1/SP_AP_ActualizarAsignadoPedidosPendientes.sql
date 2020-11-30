-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <29/08/19>
-- Description:	<Actualiza al usuario con rol de "aceptacion de servicio" de un pedido>
-- =============================================
CREATE PROCEDURE SP_AP_ActualizarAsignadoPedidosPendientes
@IdPedido INT,
@IdProveedor INT,
@IdUsuario INT,
@Asignado INT,
@ComentariosAsignado NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.MM_Pedido 
	SET AsignadoA = @Asignado,
	ComentariosAsignado = @ComentariosAsignado,
	ModificadoPor = @IdUsuario,
	ModificadoEl = GETDATE()
	WHERE IdPedido = @IdPedido

	SELECT 'SUCCESS'

END
