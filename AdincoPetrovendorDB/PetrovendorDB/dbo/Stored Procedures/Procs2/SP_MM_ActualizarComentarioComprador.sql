-- =============================================
-- Author:	<Alexander Gomez>
-- Create date: <24/03/2021>
-- Description:	<Actualizacion del comentario del comprador del pedido>
-- Description:	<Este sp faltaba en prod, solo se modifica para contemplarlo en la publicacion>
-- =============================================
-- Author:	<Alexander Gomez>
-- Create date: <27/05/2021>
-- Description:	<Este sp faltaba en prod, solo se modifica para contemplarlo en la publicacion>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarComentarioComprador]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@Comentario nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.TA_Operacion
	SET Descripcion = @Comentario
	WHERE IdDocumento = @IdSolicitudPedido
	AND IdTipoOperacion = 6

	SELECT @Comentario

END