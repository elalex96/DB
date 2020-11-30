-- =============================================
-- Author:		<Alexander Gome>
-- Create date: <11/02/2020>
-- Description:	<Actualizar el comentario interno en la lista de peticion oferta>
-- =============================================
create PROCEDURE [dbo].[SP_MM_ActualizarComentarioInterno]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@ComentarioInternoPO NVARCHAR(MAX),
	@IdUsuario INT ,
	@IdProveedor INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MM_SolicitudPedido
	SET ComentarioInternoPO = @ComentarioInternoPO,
		FechaAsignado = GETDATE(),
		FechaComentarioMod = GETDATE()
	WHERE IdSolicitudPedido = @IdSolicitudPedido;

	SELECT @ComentarioInternoPO AS ComentarioInternoPO

END
