-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/11/2019>
-- Description:	<cambiar el estado de la plantilla de solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_CambiarEstatus_Plantilla_SolicitudPedido]
	-- Add the parameters for the stored procedure here
	@IdPlantillaSolicitudPedido INT,
	@IdUsuario INT,
	@SolicitudPedidoId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Bitacora NVARCHAR(MAX)

	SELECT @Bitacora=Bitacora 
	FROM MM_Plantillas_SolicitudPedido (NOLOCK)
	WHERE IdPlantillaSolicitudPedido = @IdPlantillaSolicitudPedido;

	IF ISNULL(@Bitacora,'')=''
		SET @Bitacora =CONCAT('Genero SP #',ISNULL(@SolicitudPedidoId,0),' - ',(FORMAT(GETDATE(),'dd/MM/yyyy hh:mm tt')))
	ELSE 
		SET @Bitacora =CONCAT(@Bitacora,',#',ISNULL(@SolicitudPedidoId,0),' - ',(FORMAT(GETDATE(),'dd/MM/yyyy hh:mm tt')))

    -- Insert statements for procedure here
	UPDATE MM_Plantillas_SolicitudPedido
	SET Enviada = 1,
	EnviadoPor = @IdUsuario,
	FechaModificacion = GETDATE(),
	Bitacora= @Bitacora
	WHERE IdPlantillaSolicitudPedido = @IdPlantillaSolicitudPedido;

END