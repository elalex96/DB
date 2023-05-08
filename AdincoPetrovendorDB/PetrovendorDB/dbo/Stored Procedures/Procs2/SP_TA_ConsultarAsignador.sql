
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22-05-17
-- Description:	Regresa la información del asignador de una tarea				
-- =============================================
-- =============================================
-- Author:		Pedro acuña
-- Create date: 30-07-18
-- Description:	en caso de que se haya dado de baja el usuario que creo la aprobacion entonces se le envia al administrador		
-- =============================================
-- =============================================
-- Author:		Abel Rivera
-- Create date: 19-12-19
-- Description:	Se modifico el select ya que la consulta era incorrecta y mostraba usuarios de diferentes proveedores	
-- =============================================

CREATE PROCEDURE [dbo].[SP_TA_ConsultarAsignador]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @IdUsuario INT, @Nombre NVARCHAR(MAX), @Correo NVARCHAR(MAX)

		SELECT		@IdUsuario = s.IdUsuario, @Nombre = s.Nombre, @Correo = s.Correo
		FROM		TA_Operacion AS O
		INNER JOIN	S_Usuario AS S
			ON S.IdUsuario = O.IdAsignador
		WHERE
					IdOperacion = @IdOperacion
					AND S.Activo = 1

		IF ( @IdUsuario IS NULL ) -- si no esta el usuario activo tomo al primer administrador para notificarle
			BEGIN
				--SELECT		TOP 1
				--			S.IdUsuario, S.Nombre, S.Correo
				--FROM		TA_Operacion AS O
				--INNER JOIN	S_Usuario AS S
				--	ON S.IdUsuario = O.IdAsignador
				--INNER JOIN	dbo.S_UsuarioProveedor uProv
				--	ON O.IdAsignador = uProv.IdUsuario
				--WHERE
				--			IdOperacion = @IdOperacion
				--			AND S.Activo = 1
				--			OR	S.IdTipoUsuario = 3
				SELECT TOP 1
				S.IdUsuario, S.Nombre, S.Correo
				FROM dbo.TA_Operacion O
				INNER JOIN dbo.S_UsuarioProveedor UP
					ON UP.IdProveedor = O.IdProveedor
				INNER JOIN dbo.S_Usuario S
					ON S.IdUsuario = UP.IdUsuario
				WHERE 
						O.IdOperacion = @IdOperacion
						AND ( S.Activo = 1 OR S.IdTipoUsuario = 3 )

			END

		SELECT @IdUsuario  AS IdUsuario, @Nombre AS Nombre, @Correo AS Correo
	END