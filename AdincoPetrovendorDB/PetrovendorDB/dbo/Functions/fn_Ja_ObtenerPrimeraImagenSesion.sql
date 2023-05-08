CREATE FUNCTION fn_Ja_ObtenerPrimeraImagenSesion(@IdPerfil INT, @IdProveedor INT)
RETURNS INT
BEGIN
	IF(@IdPerfil = 0)
	BEGIN
		SELECT @IdPerfil = IdImagen FROM dbo.S_ImagenPerfil WHERE IdProveedor = @IdProveedor
	END	

	RETURN @IdPerfil
end