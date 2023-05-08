-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29/05/2018
-- Description:	Consulta de datos de la cotizacion para notificacion de ampliacion de cotizacion
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 15/06/2018
-- Description:	se agrega el id del usuario para mandarlo en el detalle y saber quien puede acceder a ver el detalle
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultarDatosCotiazcion] 
	-- Add the parameters for the stored procedure here
	@IdSolcitudPedido INT,
	@IdPeticionOferta INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MENSAJE NVARCHAR(MAX) = (SELECT JustificacionAmplicacion FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta = @IdPeticionOferta)

    -- Insert statements for procedure here
	SELECT US.Nombre AS Usuario, US.Correo, @MENSAJE, US.IdUsuario
	FROM dbo.MM_SolicitudPedido AS SOLPED
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = SOLPED.IdUsuarioSolicitante
	WHERE SOLPED.IdSolicitudPedido = @IdSolcitudPedido
END

