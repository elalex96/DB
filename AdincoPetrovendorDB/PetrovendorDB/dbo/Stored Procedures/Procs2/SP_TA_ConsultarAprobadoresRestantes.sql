-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Modificador:		<Jose Roman>
-- Create date: <16-08-2018>
-- Description:	<Se agrega la consulta del telefono de los aprobadores>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarAprobadoresRestantes] --exec SP_TA_ConsultarAprobadoresRestantes @IdProveedor=573,@idFlujo=0,@IdRol=N'1'
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
	FROM S_Usuario AS U (NOLOCK)
	INNER JOIN S_TipoUsuario AS TU (NOLOCK) ON U.IdTipoUsuario = TU.IdTipoUsuario
	INNER JOIN S_UsuarioRol AS UR (NOLOCK) ON U.IdUsuario = UR.IdUsuario AND UR.IdRol = @IdRol AND UR.Activo=1
	INNER JOIN S_Rol AS R (NOLOCK) ON UR.IdRol = R.IdRol
	INNER JOIN S_UsuarioProveedor AS UP (NOLOCK) ON U.IdUsuario = UP.IdUsuario
	INNER JOIN S_Proveedor  AS P (NOLOCK) on UP.IdProveedor = P.IdProveedor AND P.IdProveedor = @IdProveedor
	WHERE  U.Activo=1  
	EXCEPT
	SELECT flujo.IdFlujoTarea,
	       aprobador.IdUsuario,
           usuario.Nombre,
		   usuario.Correo,
		   usuario.Telefono
    FROM dbo.TA_FlujoTarea flujo (NOLOCK)
        INNER JOIN dbo.TA_Aprobador aprobador (NOLOCK)
            ON aprobador.IdFlujoTarea = flujo.IdFlujoTarea
        INNER JOIN dbo.S_Usuario usuario (NOLOCK)
            ON usuario.IdUsuario = aprobador.IdUsuario
    WHERE flujo.Activo = 1
          AND (flujo.IdTipoOperacion = 14 OR flujo.IdTipoOperacion = 2)
          AND (
                  flujo.Eliminado = 0
                  OR flujo.Eliminado IS NULL
              )
          AND flujo.IdFlujoTarea = @idFlujo

END