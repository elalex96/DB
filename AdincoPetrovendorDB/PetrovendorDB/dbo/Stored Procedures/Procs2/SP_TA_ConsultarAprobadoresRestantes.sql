-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Modificador:		<Jose Roman>
-- Create date: <16-08-2018>
-- Description:	<Se agrega la consulta del telefono de los aprobadores>
-- =============================================
CREATE PROCEDURE SP_TA_ConsultarAprobadoresRestantes
@IdProveedor INT,
@IdRol INT,
@idFlujo INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  @idFlujo AS IdFlujoTarea,
			U.IdUsuario,
			U.Nombre,
			U.Correo,
			u.Telefono
	FROM S_Usuario AS U
	INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario
	INNER JOIN S_UsuarioRol AS UR ON UR.IdUsuario = U.IdUsuario
	INNER JOIN S_Rol AS R ON R.IdRol = UR.IdRol
	INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario
	INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor	 
	WHERE  U.Activo=1 AND P.IdProveedor = @IdProveedor AND UR.IdRol = @IdRol AND UR.Activo=1
	EXCEPT
	SELECT flujo.IdFlujoTarea,
	       aprobador.IdUsuario,
           usuario.Nombre,
		   usuario.Correo,
		   usuario.Telefono
    FROM dbo.TA_FlujoTarea flujo
        INNER JOIN dbo.TA_Aprobador aprobador
            ON aprobador.IdFlujoTarea = flujo.IdFlujoTarea
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = aprobador.IdUsuario
    WHERE flujo.Activo = 1
          AND (flujo.IdTipoOperacion = 14 OR flujo.IdTipoOperacion = 2)
          AND (
                  flujo.Eliminado = 0
                  OR flujo.Eliminado IS NULL
              )
          AND flujo.IdFlujoTarea = @idFlujo

END


