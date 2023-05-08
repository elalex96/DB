CREATE PROCEDURE [dbo].[Mobile_InicioSesion]
@Usuario varchar(max),
@Idaplicacion INT= 0
as
BEGIN

IF @Idaplicacion = 1
begin
	SELECT 
	UsuarioID,Usuario,Contraseña,Nombre,IsActivo,fchRegistro,IsEliminado,IdTipoUsuario,Foto,TFAuthentication,NumeroCelular,CP.CodigoPais 
	FROM AP_Usuario as APU
	LEFT JOIN [dbo].[AP_Paises] AS CP on APU.COdigoPais = CP.idPais
	where usuario = @Usuario
END
IF @Idaplicacion = 2
	BEGIN
	SELECT 
	IdUsuario AS 'UsuarioID',
	Correo AS 'Usuario',
	Contrasena AS 'Contraseña',
	Nombre,
	1 AS 'IsActivo',
	FechaRegistro AS 'fchRegistro' ,
	IsEliminado,
	IdTipoUsuario AS 'IdTipoUsuario',
	NULL AS 'Foto',
	0 AS TFAuthentication,
	Telefono AS 'NumeroCelular',
	52 AS 'CodigoPais'
	FROM Petrovendor.dbo.S_Usuario
	WHERE Correo = @Usuario
END

END


