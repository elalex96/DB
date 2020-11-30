-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <26/02/2018>
-- Description:	<obtiene la informacion para validar y volver a reenviar el correo de activación>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ReenviarCorreoActivacion]
@Correo NVARCHAR(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IsRegistrado BIT

	IF EXISTS (SELECT IdUsuario  FROM dbo.S_Usuario WHERE Correo = @Correo AND Activo = 0)
	BEGIN
		SET @IsRegistrado = 1
    END
	ELSE
	BEGIN
		SET @IsRegistrado = 0
    END
	   
	IF (@IsRegistrado != 0) -- verifica que el correo este registrado y que no este activo
	BEGIN

		 SELECT TOP 1 
		 N.Para,
		 N.Asunto,
		 N.Mensaje,
		 N.De,
		 EC.IdCorreo,
		 EC.IdIdentificacion 
		 FROM Adinco.dbo.S_Notificacion N (NOLOCK)
		 INNER JOIN dbo.TA_EnvioCorreo EC
		 ON N.IdNotificacion = EC.IdEnvioAdinco
		 INNER JOIN dbo.S_Usuario U
		 ON U.IdUsuario = EC.EnviadoPor 
		 WHERE 
		 EC.IdCorreo = 16
		 AND  para = @Correo

    END
    ELSE -- si cae en este else significa o que no existe en la DB o ya esta activo
    BEGIN
	   
	  DECLARE @IsActivo INT = (SELECT COUNT(IdUsuario)  FROM dbo.S_Usuario WHERE Correo = @Correo AND Activo = 1)
	  IF(@IsActivo != 0) -- cae aqui si ya esta activo
	  BEGIN
		SELECT 'ERROR','La cuenta registrada con este correo ya se encuentra activa'
      END 
	  ELSE -- si no existe en la DB
      BEGIN
		SELECT 'ERROR','El correo electrónico proporcionado no ha sido registrado'
      END 

		
	END

END