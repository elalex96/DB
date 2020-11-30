-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/11/17
-- Description:	Aplicacion movil Adinco, cambia contraseña
-- =============================================
CREATE PROCEDURE [dbo].[CambioContraseñaAppAdinco]
	-- Add the parameters for the stored procedure here
	@Contraseña varchar(50),
	@idUser int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
UPDATE ap_usuario SET contraseña = @Contraseña WHERE UsuarioID=@idUser;

END

