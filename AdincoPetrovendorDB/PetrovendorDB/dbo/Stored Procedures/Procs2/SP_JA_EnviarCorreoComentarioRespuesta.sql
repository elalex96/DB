use petrovendor
go
drop proc if exists SP_JA_EnviarCorreoComentarioRespuesta
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10/04/2020>
-- Description:	<Envio de correo de notificacion de respuesta en la oferta>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 07/07/25
-- Description:	SE OBTIENE UNICAMENTE LA INFORMACIÓN NECESARIA DEL SDK
-- =============================================
CREATE PROCEDURE [dbo].[SP_JA_EnviarCorreoComentarioRespuesta] 
	-- Add the parameters for the stored procedure here
		@IdSolicitudPedido INT,
		@IdUsuario INT,
		@IdProveedor INT,
		@Respuesta NVARCHAR(MAX),
		@IdComentarioBase INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DROP TABLE IF EXISTS #CorreosEnviarSDK
	CREATE TABLE #CorreosEnviarSDK(
		para varchar(500),
		asunto varchar(500),
		html varchar(max),
	)
    -- Insert statements for procedure here
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
	DECLARE @IDPETICIONOFERTA INT = (SELECT TOP 1 IdPeticionOferta FROM dbo.MM_PeticionOferta WHERE IdSubcontratista = @IdProveedor AND IdSolicitudPedido = @IdSolicitudPedido);
	DECLARE @IDUSUARIOPREGUNTA INT = (SELECT IdUsuario FROM dbo.JA_ComentarioBase WHERE IdComentarioBase = @IdComentarioBase);
	DECLARE @NOMBREUSUARIOPREGUNTA NVARCHAR(500) = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IDUSUARIOPREGUNTA);
	DECLARE @CORREOUSUARIOPREGUNTA NVARCHAR(500) = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IDUSUARIOPREGUNTA);
	DECLARE @NOMBREUSUARIORESPUESTA NVARCHAR(500) = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario);
	DECLARE @CORREOUSUARIORESPUESTA NVARCHAR(500) = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario);
	DECLARE @TIPOUSUARIORESPUESTA NVARCHAR(500) = (SELECT TUS.NombreTipoUsuario
													FROM dbo.S_Usuario AS US
														LEFT JOIN dbo.S_TipoUsuario AS TUS 
															ON US.IdTipoUsuario = TUS.IdTipoUsuario
													WHERE US.IdUsuario = @IdUsuario);
	DECLARE @NOMBREPROVEEDOR NVARCHAR(500) = (SELECT RazonSocial FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);
	DECLARE @HTMLCORREO NVARCHAR(MAX);
	DECLARE @IDUSUARIOADINCO INT = (SELECT IdUsuarioADINCO FROM dbo.S_Usuario WHERE IdUsuario = @IDUSUARIOPREGUNTA);
	declare @IdCorreo  int
	
	select @IdCorreo = IdCorreo from dbo.TA_Correo where Descripcion = 'Notificacion de respuesta a una pregunta en la oferta'

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = @IdCorreo) --> CTE NUMERO CORREO (TA_Correo)

	--SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 99);
	SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = @IdCorreo);

	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@NOMBREUSUARIOPREGUNTA));
	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##USUARIO##',@NOMBREUSUARIORESPUESTA));
	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPOUSUARIO##',@TIPOUSUARIORESPUESTA));
	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##PROVEEDOR##',@NOMBREPROVEEDOR));
	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##REQUISICION##',@IdSolicitudPedido));
	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##RESPUESTA##',@Respuesta));
	SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS NVARCHAR(100))));

	IF ISNULL(@IDUSUARIOADINCO,0) <> 0
	BEGIN
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_TAREA##',CONCAT('https://procura.adinco.mx/02Proveedores/DetalleOferta.aspx?solped=' , CAST(@IdSolicitudPedido AS NVARCHAR(100)))));
	END
	ELSE
	BEGIN
	    SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_TAREA##',CONCAT('https://petrovendor.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=' , CAST(@IDPETICIONOFERTA AS NVARCHAR(100)))));
	END

	INSERT INTO #CorreosEnviarSDK(para, asunto,html)
	VALUES(@CORREOUSUARIOPREGUNTA, CONCAT('Comentario(Respuesta) Referente a la Requisicion No.',ISNULL(@IdSolicitudPedido,0)),@HTMLCORREO)

	SELECT * FROM #CorreosEnviarSDK
END
