CREATE PROCEDURE p_EliminarEquiposAutoconsumo
@pIdContrato	int,
@pIdEquipo	int,
@UsuarioId INT
as
	EXECUTE PR_SP_InsertBitacoraEquiposAutoconsumo @pIdContrato,@pIdEquipo,@UsuarioId,'Eliminación';

	UPDATE [PR_EquiposAutoconsumo]
	SET Activo=0
	WHERE 
		IdContrato = @pIdContrato AND
		IdEquipo = @pIdEquipo