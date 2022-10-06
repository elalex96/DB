create PROCEDURE p_EliminarTanque
@pId	int,
@UsuarioId INT
as
	EXECUTE PR_SP_InsertBitacoraTanque @pId,@UsuarioId,'Eliminación';

	UPDATE PR_Tanque
	SET		Activo = 0
	where 
		Id  = @pId
