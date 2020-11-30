-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegInsertarRegistro]
	-- Add the parameters for the stored procedure here
	@nombre nvarchar(100),
	@correo nvarchar(50),
	@contrasena nvarchar(50),
	@idtipousuario int
AS
BEGIN

	declare @activo bit = 0
	declare @idusuario int
	declare @FechaRegistro as datetime = GETDATE()
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into dbo.S_Usuario
	(Nombre,
	Correo,
	Contrasena,
	Activo,
	IdTipoUsuario,
	FechaRegistro)

	values
	(@nombre,
	@correo,
	@contrasena,
	@activo,
	4,
	@FechaRegistro)

	set @idusuario = (select @@IDENTITY)
	select @idusuario as idusuario
	---@idtipousuario
END

