-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <24/06/2020>
-- Description:	<Consulta los tableros a mostrar filtrados por tipo de usuario y roles>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarTablerosProcura] --420,2205,3,10005
@IdProveedor INT, 
@IdUsuario INT,
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

	SELECT 
	RT.IdTablero,
	ISNULL(TA.NombreMostrar,'--') NombreTablero
	FROM 
	dbo.Relacion_TableroRolTipo RT
	LEFT JOIN adinco.dbo.EN_TableroContrato TA
		ON TA.IdTableroContrato = RT.IdTablero
	WHERE 
	RT.IdProveedor = @IdProveedor 
	AND RT.IdTipoUsuario = @IdTipoUsuario
	AND ( RT.IdRol IN (SELECT IdRol FROM @Roles) OR ISNULL(RT.IdRol,0) = 0)
	AND RT.IdContrato = @IdContrato
	GROUP BY RT.IdTablero,TA.NombreMostrar

	
							

END
