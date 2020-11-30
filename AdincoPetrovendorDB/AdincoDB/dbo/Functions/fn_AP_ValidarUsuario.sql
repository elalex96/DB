
CREATE FUNCTION [dbo].[fn_AP_ValidarUsuario]
(
	@pUsuarioID	int,
	@pUsuario	varchar(30),
	@pContrasenia	varchar(30),
	@pNombre	varchar(250)
)
RETURNS varchar(250)
AS
BEGIN
	 declare @result varchar(250)

	 if exists(
		select 1 
		from ap_usuario
		where rtrim(Usuario) = rtrim(@pUsuario) and
		UsuarioID <> @pUsuarioID
	 )
	 begin
		set @result = 'El nombre de usuario ' + @pUsuario + ' ya está asignado'
	 end


	 return @result

END
