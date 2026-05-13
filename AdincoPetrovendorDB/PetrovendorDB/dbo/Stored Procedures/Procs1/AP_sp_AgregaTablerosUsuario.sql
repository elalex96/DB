CREATE PROCEDURE AP_sp_AgregaTablerosUsuario
@IdTablero INT,
@IdUsuario INT
AS
BEGIN	
	IF exists (select 1 
		from AP_TablerosUsuario 
		where IdUsuario = @IdUsuario and IdTablero = @IdTablero)
	BEGIN
		UPDATE AP_TablerosUsuario
		SET Activo = 1
		WHERE IdTablero = @IdTablero and @IdUsuario = @IdUsuario

	END
	ELSE
	BEGIN 
		INSERT INTO AP_TablerosUsuario
				(	IdTablero,
					IdUsuario,
					Activo,
					CreadoEl,
					CreadoPor)
					
		VALUES(		@IdTablero,
					@IdUsuario,
					1,
					GETDATE(),
					@IdUsuario)
	END
END