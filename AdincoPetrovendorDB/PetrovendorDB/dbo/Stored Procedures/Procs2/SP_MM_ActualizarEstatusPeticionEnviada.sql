-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24-04-17
-- Description:	 Actualiza el estado de Iniciado de una petición de Oferta Enviado
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_ActualizarEstatusPeticionEnviada] 
	-- Add the parameters for the stored procedure here

	@IdSolicitudPedido int,
	@Estatus bit 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	UPDATE [dbo].[MM_SolicitudPedido] 
	SET [PeticionEnviada]= @Estatus
	WHERE [IdSolicitudPedido]=@IdSolicitudPedido

END


