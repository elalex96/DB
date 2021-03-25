-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/02/2020>
-- Description:	<Consulta de estatus de peticion oferta>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <23/03/2021>
-- Description:	<Se agregan los datos de comprador asignado y fecha de envio de la peticion oferta>
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_EstatusEnvioPeticion] 
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FECHAENVIOPETICIONOFERTA DATETIME = (SELECT TOP 1 CreadoEl FROM MM_PeticionOferta WHERE IdSolicitudPedido = @IdSolicitudPedido ORDER BY CreadoEl DESC);

	DECLARE @USUARIOENVIO NVARCHAR(100) = (SELECT TOP 1 US.Nombre 
											FROM MM_PeticionOferta AS PO
												LEFT JOIN S_Usuario AS US ON PO.CreadoPor = US.IdUsuario
											WHERE IdSolicitudPedido = @IdSolicitudPedido 
											ORDER BY CreadoEl DESC);

	SELECT
		ISNULL(PeticionEnviada,0) AS PeticionEnviada,
		@FECHAENVIOPETICIONOFERTA AS FechaEnvioPeticionOferta,
		@USUARIOENVIO AS UsuarioEnvia
	FROM dbo.MM_SolicitudPedido
	WHERE IdSolicitudPedido = @IdSolicitudPedido

END
