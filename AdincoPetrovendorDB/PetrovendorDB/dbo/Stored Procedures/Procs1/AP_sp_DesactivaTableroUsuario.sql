CREATE PROCEDURE AP_sp_DesactivaTableroUsuario
@Id Int
as
begin
	UPDATE AP_TablerosUsuario
	SET Activo = 0
	WHERE Id = @Id
end