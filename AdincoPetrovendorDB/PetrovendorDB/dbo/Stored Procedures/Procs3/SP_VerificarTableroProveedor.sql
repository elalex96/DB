-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <24/06/2020>
-- Description:	<Verifica que el usuario sea el usuario correcto para ver determinado tablero>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_VerificarTableroProveedor] --420,2205,10014,3,3
@IdProveedor INT,
@IdUsuario INT,
@IdTableroActual INT,
@IdTipoUsuario INT,
@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	DECLARE @Roles TABLE (IdUsuario INT, IdRol INT)

	INSERT INTO @Roles
	(
	    IdUsuario,
	    IdRol
	)
	SELECT UR.IdUsuario,
	UR.IdRol
	FROM dbo.S_UsuarioRol UR
	LEFT JOIN dbo.S_UsuarioProveedor UP
		ON UP.IdUsuario = UR.IdUsuario
	WHERE UP.IdUsuario = @IdUsuario
	AND UP.IdProveedor = @IdProveedor
	AND UP.IdContrato = @IdContrato
	AND UR.Activo = 1

	DECLARE @IdTableroEncontrado INT = 0

	SELECT 
	@IdTableroEncontrado = ISNULL(RT.IdTablero,0)
	FROM dbo.Relacion_TableroRolTipo RT
	WHERE RT.IdTablero = @IdTableroActual
	AND RT.IdProveedor = @IdProveedor
	AND RT.IdTipoUsuario = @IdTipoUsuario
	AND ( RT.IdRol IN (SELECT IdRol FROM @Roles) OR ISNULL(RT.IdRol,0) = 0)
	GROUP BY RT.IdTablero

	IF @IdTableroEncontrado = @IdTableroActual
		SELECT 'verificado' AS Result
	ELSE
		SELECT 'invalido'


END
