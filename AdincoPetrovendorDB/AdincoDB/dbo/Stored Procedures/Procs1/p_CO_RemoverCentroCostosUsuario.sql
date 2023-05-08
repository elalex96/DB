create procedure p_CO_RemoverCentroCostosUsuario
@Id int
as
begin 
	delete from AP_UsuarioCentroCosto where Id = @Id
end