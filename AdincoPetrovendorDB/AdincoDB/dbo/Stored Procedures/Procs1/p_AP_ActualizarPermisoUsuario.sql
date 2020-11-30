create procedure p_AP_ActualizarPermisoUsuario
@Id int
as
begin 
	update AP_UsuarioMenuAccion
	set Permitir = 0
	where id = @Id
end
