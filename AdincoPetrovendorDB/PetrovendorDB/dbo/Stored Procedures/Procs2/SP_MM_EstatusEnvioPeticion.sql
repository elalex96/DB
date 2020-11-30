-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/02/2020>
-- Description:	<Consulta de estatus de peticion oferta>
-- =============================================
create PROCEDURE [dbo].[SP_MM_EstatusEnvioPeticion] 
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		ISNULL(PeticionEnviada,0) AS PeticionEnviada
	FROM dbo.MM_SolicitudPedido
	WHERE IdSolicitudPedido = @IdSolicitudPedido
END
