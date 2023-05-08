-- =============================================
-- Author:		Pedro Acuña
-- Create date: 13/08/2018
-- Description:	Guardar los roles del usuario
-- =============================================
-- Update Author:	Alexander Gomez
-- Update date: 04/07/2019
-- Description:	se agrego la eliminacion de roles
-- =============================================

CREATE PROCEDURE [dbo].[SP_GuardarRoles] 

@IdUsuario INT, 
@IdUsuarioCreador INT,
@Roles NVARCHAR(MAX)

AS
	BEGIN
		DECLARE @tablaIdRoles TABLE
			( Id INT IDENTITY ,
			  IdRol INT )

		INSERT INTO @tablaIdRoles
			( IdRol )
		SELECT splitdata  FROM dbo .fnSplitString ( @Roles, ' ' )

		DECLARE @cantidadRoles INT

		SELECT @cantidadRoles  = COUNT ( * ) FROM @tablaIdRoles

		IF ( @cantidadRoles = 0 ) --actualizar a que ese usuario no tiene roles asignados
			BEGIN
				UPDATE	S_UsuarioRol
				SET		Activo = 0, EditadoEl = GETDATE (), IdEditadoPor = @IdUsuarioCreador
				WHERE	IdUsuario = @IdUsuario
			END

		DECLARE @IdRolAux INT, @Contador INT = 1

		IF ( @cantidadRoles > 0 ) --primero revisar si existe si es asi activalo si no entonces insertalo en la tabla
			BEGIN
				WHILE ( @cantidadRoles >= @Contador )
					BEGIN
						SELECT @IdRolAux  = IdRol FROM @tablaIdRoles  WHERE Id = @Contador

						IF EXISTS ( SELECT 1  FROM S_UsuarioRol	 WHERE IdRol  = @IdRolAux AND IdUsuario	  = @IdUsuario )
							BEGIN
								UPDATE	S_UsuarioRol
								SET		Activo = 1, EditadoEl = GETDATE (), IdEditadoPor = @IdUsuarioCreador
								WHERE
										IdUsuario = @IdUsuario
										AND IdRol = @IdRolAux
							END
						ELSE
							BEGIN
								INSERT INTO dbo.S_UsuarioRol
									( IdUsuario, IdRol, Activo, IdCreadoPor, EditadoEl, IdEditadoPor, CreadoEl )
								VALUES
									( @IdUsuario ,			-- IdUsuario - int
									  @IdRolAux ,			-- IdRol - int
									  1 ,					-- Activo - bit
									  @IdUsuarioCreador ,	-- IdCreadoPor - int
									  NULL ,				-- EditadoEl - datetime
									  NULL ,				-- IdEditadoPor - int
									  GETDATE ()			-- CreadoEl - datetime
									)
							END

						SET @Contador += 1
					END
			END

			--EN CASO DE QUE SE ELIMINEN ROLES
			UPDATE dbo.S_UsuarioRol
			SET Activo = 0
			WHERE IdRol NOT IN (SELECT IdRol FROM @tablaIdRoles) AND IdUsuario = @IdUsuario

	END