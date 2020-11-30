-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/11/2019>
-- Description:	<cambiar el estado de la plantilla de solicitud de pedido>
-- =============================================
create PROCEDURE [dbo].[SP_MM_CambiarEstatus_Plantilla_SolicitudPedido]
	-- Add the parameters for the stored procedure here
	@IdPlantillaSolicitudPedido INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MM_Plantillas_SolicitudPedido
	SET Enviada = 1,
	EnviadoPor = @IdUsuario,
	FechaModificacion = GETDATE()
	WHERE IdPlantillaSolicitudPedido = @IdPlantillaSolicitudPedido;

END
