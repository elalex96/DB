CREATE PROCEDURE SP_ValidarTipoUsuario
@TipoUsuario int,
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  
SELECT U.IdTipoUsuario
FROM [dbo].[S_Usuario] U
    INNER JOIN [dbo].[S_UsuarioProveedor] UP
        ON U.IdUsuario = UP.IdUsuario
WHERE UP.IsAdmin = 0
      AND UP.IdProveedor = @IdProveedor
      AND U.Activo = 1
      AND U.IdTipoUsuario = @TipoUsuario

END
