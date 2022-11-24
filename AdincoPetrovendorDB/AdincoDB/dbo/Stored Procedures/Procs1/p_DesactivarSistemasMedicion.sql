CREATE Proc p_DesactivarSistemasMedicion
@pIdSistema	int,
@UsuarioId INT
as
BEGIN
	EXECUTE PR_SP_InsertBitacoraSistemaMedicion @pIdSistema,@UsuarioId,'Desactivación';

	update PR_SistemasMedicion
	set Activo = 0
	where IdSistema = @pIdSistema
END
