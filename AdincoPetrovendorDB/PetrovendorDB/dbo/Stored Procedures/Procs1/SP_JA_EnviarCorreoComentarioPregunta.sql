USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_JA_EnviarCorreoComentarioPregunta'
)
    DROP PROCEDURE SP_JA_EnviarCorreoComentarioPregunta;
GO
/****** Object:  StoredProcedure [dbo].[SP_JA_EnviarCorreoComentarioPregunta]    Script Date: 03/06/2022 11:09:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10/04/2020>
-- Description:	<Envio de correo de notificacion de pregunta en la oferta>
-- =============================================
-- Author:		<Luis David>
-- Create date: <01/03/2023>
-- Description:	<Se evalúa si no está >
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE PROCEDURE [dbo].[SP_JA_EnviarCorreoComentarioPregunta] --20290,2199,420,'PRUEBA 11'
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@IdUsuario INT,
	@IdProveedor INT,
	@Comentario NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TOTALROWS INT;
	DECLARE @CONTROWS INT = 1;
	DECLARE @OPERADORA NVARCHAR(MAX);
	DECLARE @USUARIOPREGUNTA NVARCHAR(100);
	DECLARE @TIPOUSUARIOPREGUNTA NVARCHAR(100);
	DECLARE @COMENTARIOPREGUNTA NVARCHAR(100);
	DECLARE @HTMLCORREO NVARCHAR(MAX);
	DECLARE @HTMLCORREOAUX NVARCHAR(MAX);
	DECLARE @PROVEEDOR NVARCHAR(100);
	DECLARE @USUARIOPROVEEDOR NVARCHAR(100);
	DECLARE @CORREOUSUARIOPROVEEDOR NVARCHAR(100);
	DECLARE @IdNotificacion INT;
	DECLARE @URL NVARCHAR(MAX);
	DECLARE @EnviarCorreo bit;
	DECLARE @IdCorreo INT = (SELECT IdCorreo FROM dbo.TA_Correo WHERE Asunto = 'Comentario(Pregunta) Referente a Requisicion ');
	DECLARE @IdUsuarioEnviarNotificacion int;
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);

	
	

	CREATE TABLE #DATOSCORREO(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		NombreProveedor NVARCHAR(100),
		NombreUsuario NVARCHAR(100),
		Correo NVARCHAR(100),
		TipoUsuario NVARCHAR(100),
		IdPeticionOferta INT,
		IdSolicitudPedido INT,
		URL NVARCHAR(MAX)
	);

	--NOMBRE DE LA OPERADORA DE LA PREGUNTA
	SET @OPERADORA = (SELECT RazonSocial FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);

	--NOMBRE DEL USUARIO QUE PREGUNTA
	SET @USUARIOPREGUNTA = (SELECT 
								US.Nombre
							FROM dbo.S_Usuario AS US
							WHERE US.IdUsuario = @IdUsuario);

	--TIPO DE USUARIO QUE PREGUNTA
	SET @TIPOUSUARIOPREGUNTA = (SELECT 
								TUS.NombreTipoUsuario
							FROM dbo.S_Usuario AS US
								LEFT JOIN dbo.S_TipoUsuario AS TUS
									ON TUS.IdTipoUsuario = US.IdTipoUsuario
							WHERE US.IdUsuario = @IdUsuario);

	--COMENTARIO PREGUNTA
	SET @COMENTARIOPREGUNTA = (@Comentario);

	--LOS DATOS DE LOS USUARIOS A LOS QUE SE ENVIARAN (VENTAS Y ADMIN) DEL PROVEEDOR
	--SE VERIDICA QUE EL QUE ENVIO EL COMENTARIO SEA LA OPERADORA O EL PROVEEDOR
	

	IF EXISTS (SELECT IdSubcontratista FROM dbo.MM_PeticionOferta WHERE IdSubcontratista = @IdProveedor AND IdSolicitudPedido = @IdSolicitudPedido)
	BEGIN
	    
		INSERT INTO #DATOSCORREO
		SELECT
			PR.RazonSocial,
			US.Nombre,
			US.Correo,
			TUS.NombreTipoUsuario,
			PO.IdPeticionOferta,
			PO.IdSolicitudPedido,
			CONCAT('https://petrovendor.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=' , CAST(PO.IdPeticionOferta AS NVARCHAR(100)))
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = PO.IdSubcontratista
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR
				ON USPR.IdProveedor = PR.IdProveedor
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = USPR.IdUsuario
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON TUS.IdTipoUsuario = US.IdTipoUsuario
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 5)
			AND PO.IdSubcontratista <> @IdProveedor
			and	US.Activo = 1
		GROUP BY PR.RazonSocial,
				 US.Nombre,
				 US.Correo,
				 TUS.NombreTipoUsuario,
				 PO.IdPeticionOferta,
				 PO.IdSolicitudPedido
		UNION
		SELECT
			PR.RazonSocial,
			US.Nombre,
			US.Correo,
			TUS.NombreTipoUsuario,
			PO.IdPeticionOferta,
			PO.IdSolicitudPedido,
			CONCAT('https://procura.adinco.mx/02Proveedores/DetalleOferta.aspx?solped=' , CAST(@IdSolicitudPedido AS NVARCHAR(100)))
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.MM_SolicitudPedido AS SP 
				ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = SP.IdProveedor
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR
				ON USPR.IdProveedor = PR.IdProveedor
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = USPR.IdUsuario
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON TUS.IdTipoUsuario = US.IdTipoUsuario
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
			and	US.Activo = 1
		GROUP BY PR.RazonSocial,
				 US.Nombre,
				 US.Correo,
				 TUS.NombreTipoUsuario,
				 PO.IdPeticionOferta,
				 PO.IdSolicitudPedido;

	END
	ELSE
	BEGIN
	    
		INSERT INTO #DATOSCORREO
		SELECT
			PR.RazonSocial,
			US.Nombre,
			US.Correo,
			TUS.NombreTipoUsuario,
			PO.IdPeticionOferta,
			PO.IdSolicitudPedido,
			CONCAT('https://petrovendor.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=' , CAST(PO.IdPeticionOferta AS NVARCHAR(100)))
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PR.IdProveedor = PO.IdSubcontratista
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR
				ON USPR.IdProveedor = PR.IdProveedor
			LEFT JOIN dbo.S_Usuario AS US
				ON US.IdUsuario = USPR.IdUsuario
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON TUS.IdTipoUsuario = US.IdTipoUsuario
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
			and	US.Activo = 1
		GROUP BY PR.RazonSocial,
				 US.Nombre,
				 US.Correo,
				 TUS.NombreTipoUsuario,
				 PO.IdPeticionOferta,
				 PO.IdSolicitudPedido;

	END

	--CONTADOR DEL TOTAL EN LA TABLA
	SET @TOTALROWS = (SELECT COUNT(IdRow) FROM #DATOSCORREO);

	SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = @IdCorreo);
	if(@HTMLCORREO is null)
	begin
		insert into BitacoraErrores values (0,'No se encontró la plantilla del correo', 'Error en el sp SP_JA_EnviarCorreoComentarioPregunta', @IdUsuario, @IdProveedor, GETDATE())
		select @HTMLCORREO = ''
	end

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON S.IdServidor = C.IdServidor
								WHERE IdCorreo = @IdCorreo) --> CTE NUMERO CORREO (TA_Correo)
	--select * from #DATOSCORREO
	--select @CONTROWS, @TOTALROWS
	--ITERACION DE LA TABLA
	select @HTMLCORREOAUX = @HTMLCORREO
	--select * from #DATOSCORREO
	WHILE @CONTROWS <= @TOTALROWS
	BEGIN
	    --CONSULTA PARA OBTENER EL HTML DEL CORREO
		select @HTMLCORREO = @HTMLCORREOAUX
		SET @EnviarCorreo = 1;
		SET @IdUsuarioEnviarNotificacion = '';

		SET @USUARIOPROVEEDOR = (SELECT NombreUsuario FROM #DATOSCORREO WHERE IdRow = @CONTROWS);
		SET @CORREOUSUARIOPROVEEDOR = (SELECT Correo FROM #DATOSCORREO WHERE IdRow = @CONTROWS);
		SET @URL = (SELECT URL FROM #DATOSCORREO WHERE IdRow = @CONTROWS);
		SET @IdUsuarioEnviarNotificacion = (SELECT IdUsuario FROM S_Usuario WHERE Correo = @CORREOUSUARIOPROVEEDOR);
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@USUARIOPROVEEDOR));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##USUARIO##',@USUARIOPREGUNTA));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPOUSUARIO##',@TIPOUSUARIOPREGUNTA));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##OPERADORA##',@OPERADORA));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##REQUISICION##',@IdSolicitudPedido));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##PREGUNTA##',@COMENTARIOPREGUNTA));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS NVARCHAR(100))));
		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_TAREA##',@URL));

		SET @IdNotificacion = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);
		SET @EnviarCorreo= (select TOP 1 IsEliminado from Petrovendor..TA_NoNotificacion where IdCorreo = @IdCorreo AND IdUsuario = @IdUsuarioEnviarNotificacion);
		IF ISNULL(@EnviarCorreo,1) = 1
		BEGIN
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
			@CORREOUSUARIOPROVEEDOR,
			CONCAT('Comentario(Pregunta) Referente a la Requisicion No.',ISNULL(@IdSolicitudPedido,0)),
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
		END
		if (exists(select * from Adinco.dbo.S_Notificacion where IdNotificacion = @IdNotificacion) and isnull(@HTMLCORREO,'')<>'')
		begin

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
				CONCAT('0 - Nuevo Comentario(Pregunta) Solicitud de Pedido #' , @IdSolicitudPedido),  -- IdIdentificacion - int
				0,
				GETDATE()
			);
		end

		SET @CONTROWS = @CONTROWS + 1;

	END

END
