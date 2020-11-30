-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegRenovarContrasena]
	-- Add the parameters for the stored procedure here
	@idusuario int,
	@contrasena nvarchar(50)
AS
BEGIN
	declare @respuesta bit = 1
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for procedure here
	update dbo.S_Usuario
	set Contrasena = @contrasena
	where IdUsuario = @idusuario

	select Correo from S_Usuario where IdUsuario = @idusuario and Activo = 1

END

