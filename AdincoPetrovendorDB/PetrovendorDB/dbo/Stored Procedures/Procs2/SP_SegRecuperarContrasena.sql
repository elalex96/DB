-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegRecuperarContrasena]
	-- Add the parameters for the stored procedure here
	@Correo nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdUsuario, Nombre FROM S_Usuario WHERE Correo = @Correo AND Activo = 1

END
