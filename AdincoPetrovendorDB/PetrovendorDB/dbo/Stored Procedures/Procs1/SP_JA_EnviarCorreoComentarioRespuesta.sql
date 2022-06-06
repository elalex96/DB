USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_JA_EnviarCorreoComentarioRespuesta'
)
    DROP PROCEDURE SP_JA_EnviarCorreoComentarioRespuesta;
GO
/****** Object:  StoredProcedure [dbo].[SP_JA_EnviarCorreoComentarioRespuesta]    Script Date: 03/06/2022 11:05:10 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
															ON TUS.IdTipoUsuario = US.IdTipoUsuario
													WHERE US.IdUsuario = @IdUsuario);
	DECLARE @NOMBREPROVEEDOR NVARCHAR(500) = (SELECT RazonSocial FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);
	DECLARE @HTMLCORREO NVARCHAR(MAX);
	DECLARE @IdNotificacion INT;
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
	

	SET @IdNotificacion = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);

	INSERT INTO Adinco.dbo.S_Notificacion
	(
		IdNotificacion,
		Para,
		Asunto,
		Mensaje,
		FechaProgramadaEnvio,
		Enviada,
		FechaEnvio,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl,
		De
	)
	VALUES
	(
		@IdNotificacion,
		@CORREOUSUARIOPREGUNTA,
		CONCAT('Comentario(Respuesta) Referente a la Requisicion No.',ISNULL(@IdSolicitudPedido,0)),
		@HTMLCORREO,
		DATEADD(MINUTE,1,GETDATE()),
		0,
		NULL,
		3,
		GETDATE(),
		NULL,
		NULL,
		ISNULL(@CorreoNotificaciones,'')
	);

	INSERT INTO dbo.TA_EnvioCorreo
	(
		IdEnvioAdinco,
		IdCorreo,
		IdIdentificacion,
		EnviadoPor,
		EnviadoEl
	)
	VALUES
	(   
		@IdNotificacion, -- IdEnvioAdinco - int
		@IdCorreo, -- CORREO DE COMENTARIO/PREGUNTA PETICION OFERTA
		CONCAT('0 - Nuevo Comentario(Respuesta) Solicitud de Pedido #' , @IdSolicitudPedido),  -- IdIdentificacion - int
		0,
		GETDATE()
	);

END




