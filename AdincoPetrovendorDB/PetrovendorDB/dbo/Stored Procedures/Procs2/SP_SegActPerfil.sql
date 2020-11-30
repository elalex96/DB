-- =============================================
-- Author:		Manuel Cruz
-- Create date: 31-01-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Modified date: 02/01/2018
-- Description:	se agrega mas espacio a la contraseña
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegActPerfil]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@IdUsuario int, 
	@Nombre nvarchar(100),
	@Correo nvarchar(50),
	@Contrasena nvarchar(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE S_Usuario
	SET 
	Nombre= @Nombre,
	Correo=@Correo,
	Contrasena=@Contrasena
	WHERE 
	IdUsuario = @IdUsuario


	select ( 'El contacto ha sido actualizado') as Mensaje
END

