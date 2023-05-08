-- =============================================
-- Author:    Reyna Olvera
-- Create date: 20200319
-- Description:  CREA GRUPOS
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_GuardaGrupo] --3,10061,12138,11477
@IdContrato int,
@IdUsuario int,
@Nombre VARCHAR(MAX)
AS  
BEGIN
  SET NOCOUNT ON;

  DECLARE @IdGrupo	 INT, @IdPerfil	INT=0,@CountPerfil INT=0, @IdRol INT=0, @NumeroContrato varchar(max);
  
  SELECT @IdRol	=	IdRol
		FROM	AP_Rol	
	WHERE Rol =	'Rol de GRUPO de Usuarios'


	SELECT @NumeroContrato	=	NumeroContrato
	FROM 
		CO_Contrato		
	WHERE IdContrato	=	@idContrato;


	SELECT @IdPerfil=ISNULL(IdPerfil,0), 
		   @CountPerfil=	COUNT(1)
	FROM 	
		AP_Perfil P
	JOIN
		AP_Rol	R
		ON	P.IdRol	=	@IdRol
	WHERE
		P.Descripcion	LIKE	'%GRUPO de Usuarios%'
		AND	P.IdContrato	=	@idContrato
	GROUP BY IdPerfil,P.IdRol

--SELECT  @IdGrupo	 , @IdPerfil	,@CountPerfil , @IdRol , @NumeroContrato ;


IF(@IdPerfil = 0	AND	@CountPerfil	=	0 AND @IdRol > 0)
BEGIN
	INSERT INTO AP_Perfil(IdRol,IdContrato,Descripcion,CreadoPor) 
	VALUES (@IdRol, @idContrato, 'GRUPO de Usuarios de contrato ' + @NumeroContrato, @IdUsuario);

	SET @IdPerfil	=	@@IDENTITY
END

IF(@IdPerfil	>	0 AND @IdRol > 0)
BEGIN

	INSERT INTO AP_Usuario(Usuario,Contraseña,Nombre,IsActivo,fchRegistro,IsEliminado,CreadoPor,IsGrupo, IdRuta) 
		VALUES (@Nombre,@Nombre,@Nombre,1,GETDATE(),0,@idUsuario,1, NULL);

		 SET	@IdGrupo	=	@@IDENTITY;

		INSERT INTO AP_PerfilUsuario(UsuarioID, PerfilID,CreadoPor)
		Select @IdGrupo,@IdPerfil,@IdUsuario
END
END

