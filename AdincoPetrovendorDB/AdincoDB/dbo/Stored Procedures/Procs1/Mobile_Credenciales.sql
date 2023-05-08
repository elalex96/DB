CREATE PROCEDURE [dbo].[Mobile_Credenciales]
@Usuario varchar(max)
AS
BEGIN
DECLARE @URLString varchar(200), @tempusuid INT, @cantidadContratos INT;

IF EXISTS (SELECT 
	1
	FROM AP_Usuario as APU
	LEFT JOIN [dbo].[AP_Paises] AS CP on APU.COdigoPais = CP.idPais
	where usuario = @Usuario)
BEGIN
	
	-- Se extrae el ID del usuario del correo parámetro
	---------------------------------------------------
	SET @tempusuid = (SELECT TOP 1 UsuarioID FROM dbo.AP_Usuario WHERE Usuario = @Usuario)
	-- Se extraen los contratos asignados al usuario
	---------------------------------------------------
	SELECT distinct    
	CO_Contrato.IdContrato 
	INTO #ContratosUsuario                         
	FROM            
		AP_PerfilUsuario AS PU INNER JOIN
		AP_Usuario ON PU.UsuarioID = AP_Usuario.UsuarioID INNER JOIN
		AP_Perfil ON PU.PerfilID = AP_Perfil.IdPerfil INNER JOIN
		AP_Rol ON AP_Perfil.IdRol = AP_Rol.IdRol INNER JOIN
		CO_Contrato ON AP_Perfil.IdContrato = CO_Contrato.IdContrato INNER JOIN
		CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
	WHERE        (@tempusuid = PU.UsuarioID)

	----------------------------------------
	---SE ASIGNA IMAGEN FONDO JAGUAR SI EL USUARIO TIENE ALGÚN CONTRATO ASIGNADO
	IF (SELECT COUNT(IdContrato) FROM dbo.CO_Contrato WHERE (DescripcionContrato LIKE '%Jaguar%' OR DescripcionContrato LIKE '%Pantera%') AND IdContrato IN (SELECT IdContrato FROM #ContratosUsuario )) > 1
	BEGIN
		SET @URLString ='https://adinco.mx/appimg/fgd.jpg'
    END
	---SE ASIGNA IMAGEN FONDO ENI MÉXICO SI EL USUARIO TIENE ALGÚN CONTRATO ASIGNADO
    IF (SELECT COUNT(IdContrato) FROM dbo.CO_Contrato WHERE DescripcionContrato LIKE '%ENI MÉXICO%' AND IdContrato IN (SELECT IdContrato FROM #ContratosUsuario )) > 1
	BEGIN
		SET @URLString ='https://adinco.mx/appimg/Eni_001.jpg'
    END
	ELSE
	BEGIN
		SET @URLString ='https://adinco.mx/appimg/fgor.jpg'
    END
    
	SELECT 
	TOP 1
	UsuarioID,
	Usuario,
	Contraseña,
	Nombre,
	0 AS IdProveedor,
	1 AS 'IdAplicacion',
	'https://is3-ssl.mzstatic.com/image/thumb/Purple114/v4/6f/e6/db/6fe6db61-41a4-762c-b752-ec1ff09d4dd1/source/512x512bb.jpg' AS 'Icon',
	@URLString AS UrlImage
	FROM AP_Usuario as APU
	LEFT JOIN [dbo].[AP_Paises] AS CP on APU.COdigoPais = CP.idPais
	where usuario = @Usuario
	 AND APU.IsActivo = 1
END 
ELSE	BEGIN
	
	SELECT 
	TOP 1
	US.IdUsuario AS 'UsuarioID',
	us.Correo AS 'Usuario' ,
	US.Contrasena AS 'Contraseña',
	US.Nombre AS 'Nombre',
	UP.IdProveedor AS 'IdProveedor',
	2 AS 'IdAplicacion',
	'https://res.cloudinary.com/emazecom/image/fetch/c_limit,a_ignore,w_240,h_240/https%3A%2F%2Fuserscontent2.emaze.com%2Fimages%2F6dd533e5-8994-46c5-b469-3640fb5cadc4%2F39926e6c0e14b591366a3757f01f0e16.png' AS 'Icon',
	'http://notificaciones.adinco.mx/imagenes/fga.jpg' AS UrlImage
	FROM Petrovendor.dbo.S_Usuario AS US
	JOIN Petrovendor.dbo.S_UsuarioProveedor AS UP
	ON UP.IdUsuario = US.IdUsuario
	WHERE Correo = @Usuario
	AND US.Activo = 1
END
END

