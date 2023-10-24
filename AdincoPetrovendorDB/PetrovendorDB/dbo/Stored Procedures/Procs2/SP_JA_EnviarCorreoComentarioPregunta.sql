USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_JA_EnviarCorreoComentarioPregunta'
)
    DROP PROCEDURE SP_JA_EnviarCorreoComentarioPregunta;
	/****** Object:  StoredProcedure [dbo].[SP_JA_EnviarCorreoComentarioPregunta]    Script Date: 20/09/2023 01:36:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[SP_JA_EnviarCorreoComentarioPregunta]    Script Date: 23/10/2023 03:36:08 p. m. ******/
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
-- Author:		Luis David
-- Create date: 19/09/2023
-- Description:	Se agrupan los correos del para y los de adinco en el cco
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 23/10/2023
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor, se agrega que se notifique a los usuario de compras y que no se envie a los usuarios con configuración de alerta desactivada
-- =============================================
CREATE PROCEDURE [dbo].[SP_JA_EnviarCorreoComentarioPregunta]  
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@IdUsuario INT,
	@IdProveedor INT,
	@Comentario NVARCHAR(MAX),
	@IdOferta int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @OPERADORA NVARCHAR(MAX),
	@USUARIOPREGUNTA NVARCHAR(100),
	@TIPOUSUARIOPREGUNTA NVARCHAR(100),
	@COMENTARIOPREGUNTA NVARCHAR(100),
	@HTMLCORREO NVARCHAR(MAX),
	@CORREOUSUARIOPROVEEDOR NVARCHAR(100),
	@IdNotificacion INT,
	@URL NVARCHAR(MAX),
	@IdCorreo INT = (SELECT IdCorreo FROM dbo.TA_Correo WHERE Asunto = 'Comentario(Pregunta) Referente a Requisicion'),
	@CorreoNotificaciones NVARCHAR(MAX),
	@CorreosAdinco NVARCHAR(MAX),
	@CorreosOperadora NVARCHAR(MAX) = NULL,
	@CorreoAgrupadoEnviar INT = 0,
	@IdPeticionOfertaRow INT, @TipoProveedorRow VARCHAR(MAX), @ContadorCorreo INT = 0

	
	DROP TABLE IF EXISTS #CorreoEnviarPorProveedor
	CREATE TABLE #CorreoEnviarPorProveedor(
	Id INT IDENTITY(1,1),
	IdPeticionOferta INT,
	TipoProveedor VARCHAR(MAX)
	)
	
	DROP TABLE IF EXISTS #CorreoConcat
	CREATE TABLE #CorreoConcat(
	IsCorreoAdinco bit,
	Correos VARCHAR(MAX)
	)

	DROP TABLE IF EXISTS #DATOSCORREO
	CREATE TABLE #DATOSCORREO(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		IdUsuario int,
		NombreProveedor NVARCHAR(100),
		NombreUsuario NVARCHAR(100),
		Correo NVARCHAR(100),
		IsCorreoAdinco BIT,
		TipoUsuario NVARCHAR(100),
		IdPeticionOferta INT,
		IdSolicitudPedido INT,
		URL NVARCHAR(MAX),
		IdUsuarioAdinco INT,
		Para NVARCHAR(100)
	);

	--NOMBRE DE LA OPERADORA DE LA PREGUNTA
	SET @OPERADORA = (SELECT RazonSocial FROM dbo.S_Proveedor  (NOLOCK)
						WHERE IdProveedor = @IdProveedor);

	--NOMBRE DEL USUARIO QUE PREGUNTA
	SET @USUARIOPREGUNTA = (SELECT 
								US.Nombre
							FROM dbo.S_Usuario AS US  (NOLOCK)
							WHERE US.IdUsuario = @IdUsuario);

	--TIPO DE USUARIO QUE PREGUNTA
	SET @TIPOUSUARIOPREGUNTA = (SELECT 
								TUS.NombreTipoUsuario
							FROM dbo.S_Usuario AS US  (NOLOCK)
								LEFT JOIN dbo.S_TipoUsuario AS TUS  (NOLOCK)
									ON US.IdTipoUsuario = TUS.IdTipoUsuario
							WHERE US.IdUsuario = @IdUsuario);

	--COMENTARIO PREGUNTA
	SET @COMENTARIOPREGUNTA = (@Comentario);

	--LOS DATOS DE LOS USUARIOS A LOS QUE SE ENVIARAN (VENTAS Y ADMIN) DEL PROVEEDOR
	--SE VERIDICA QUE EL QUE ENVIO DEL COMENTARIO SEA LA OPERADORA O EL PROVEEDOR
	IF EXISTS (SELECT IdSubcontratista FROM dbo.MM_PeticionOferta WHERE IdSubcontratista = @IdProveedor AND IdSolicitudPedido = @IdSolicitudPedido)
	BEGIN
		INSERT INTO #DATOSCORREO(
		IdUsuario,
		NombreProveedor,
		NombreUsuario,
		Correo,
		IsCorreoAdinco,
		TipoUsuario,
		IdPeticionOferta,
		IdSolicitudPedido,
		URL,
		IdUsuarioAdinco,
		Para)
		SELECT
			Us.IdUsuario,
			PR.RazonSocial,
			US.Nombre,
			US.Correo,
			CASE WHEN US.Dominio = 'ADINCO.MX'
			then 1 else 0
			end as IsCorreoAdinco,
			TUS.NombreTipoUsuario,
			PO.IdPeticionOferta,
			PO.IdSolicitudPedido,
			CONCAT('https://petrovendor.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=' , CAST(PO.IdPeticionOferta AS NVARCHAR(100))),
			US.IdUsuarioADINCO,
			'PROVEEDOR-PETROVENDOR'
		FROM dbo.MM_PeticionOferta AS PO  (NOLOCK)
			LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
				ON PO.IdSubcontratista = PR.IdProveedor 
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR  (NOLOCK)
				ON  PR.IdProveedor = USPR.IdProveedor 
			LEFT JOIN dbo.S_Usuario AS US  (NOLOCK)
				ON USPR.IdUsuario = US.IdUsuario 
				AND	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS  (NOLOCK)
				ON US.IdTipoUsuario = TUS.IdTipoUsuario 
			LEFT JOIN Petrovendor..TA_NoNotificacion as TANN  (NOLOCK)
				on US.idUsuario = TANN.IdUsuario 
			and  TANN.IdCorreo = @IdCorreo
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4) --> CTE 3 ADMIN, 4 VENTAS Y 5 COMPRAS
			AND PO.IdSubcontratista <> @IdProveedor
			AND	US.Activo = 1
			AND ISNULL(TANN.IsEliminado,-1) <> 0   -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion, EN LA TABLA SI ESTA 1 QUIERE DECIR QUE ESTA ACTIVO, SI ESTA EN 0 QUIERE DECIR QUE ESTA ELIMINADA  LA NOTIFICACION
		GROUP BY PR.RazonSocial,
				 US.Nombre,
				 US.Correo,
				 TUS.NombreTipoUsuario,
				 PO.IdPeticionOferta,
				 PO.IdSolicitudPedido,
				 US.Dominio,
				 Us.IdUsuario,
				 Us.IdUsuarioADINCO
		UNION
		SELECT
			Us.IdUsuario,
			PR.RazonSocial,
			US.Nombre,
			US.Correo,
			CASE WHEN US.Dominio = 'ADINCO.MX'
			then 1 else 0
			end as IsCorreoAdinco,
			TUS.NombreTipoUsuario,
			PO.IdPeticionOferta,
			PO.IdSolicitudPedido,
			CONCAT('https://procura.adinco.mx/02Proveedores/DetalleOferta.aspx?solped=' , CAST(@IdSolicitudPedido AS NVARCHAR(100))),
			US.IdUsuarioADINCO,
			'PROVEEDOR-PROCURA'
		FROM dbo.MM_PeticionOferta AS PO  (NOLOCK)
			LEFT JOIN dbo.MM_SolicitudPedido AS SP   (NOLOCK)
				ON  PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
				ON SP.IdProveedor = PR.IdProveedor 
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR  (NOLOCK)
				ON PR.IdProveedor = USPR.IdProveedor 
			LEFT JOIN dbo.S_Usuario AS US  (NOLOCK)
				ON USPR.IdUsuario = US.IdUsuario  
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS  (NOLOCK)
				ON US.IdTipoUsuario = TUS.IdTipoUsuario 
			LEFT JOIN Petrovendor..TA_NoNotificacion as TANN  (NOLOCK)
			on US.idUsuario = TANN.IdUsuario 
			and  TANN.IdCorreo = @IdCorreo
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4 OR US.IdTipoUsuario = 5)  --> CTE 3 ADMIN, 4 VENTAS Y 5 COMPRAS
			and	US.Activo = 1
			AND ISNULL(TANN.IsEliminado,-1) <> 0 -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion, EN LA TABLA SI ESTA 1 QUIERE DECIR QUE ESTA ACTIVO, SI ESTA EN 0 QUIERE DECIR QUE ESTA ELIMINADA  LA NOTIFICACION
			AND PO.IdPeticionOferta = @IdOferta
		GROUP BY PR.RazonSocial,
				 US.Nombre,
				 US.Correo,
				 TUS.NombreTipoUsuario,
				 PO.IdPeticionOferta,
				 PO.IdSolicitudPedido,
				 US.Dominio,
				 Us.IdUsuario,
				 US.IdUsuarioADINCO
		ORDER BY US.IdUsuarioADINCO ASC; -- Se agrupan primero los usuarios proveedor

	END
	ELSE
	BEGIN
		-- EL CORREO ES PARA LA OPERADORA 
		INSERT INTO #DATOSCORREO(
		IdUsuario,
		NombreProveedor,
		NombreUsuario,
		Correo,
		IsCorreoAdinco,
		TipoUsuario,
		IdPeticionOferta,
		IdSolicitudPedido,
		URL,
		IdUsuarioAdinco,
		Para)
		SELECT
			Us.IdUsuario,
			PR.RazonSocial,
			US.Nombre,
			US.Correo,
			CASE WHEN US.Dominio = 'ADINCO.MX'
			then 1 else 0 end as IsCorreoAdinco,
			TUS.NombreTipoUsuario,
			PO.IdPeticionOferta,
			PO.IdSolicitudPedido,
			CONCAT('https://petrovendor.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=' , CAST(PO.IdPeticionOferta AS NVARCHAR(100))),
			US.IdUsuarioADINCO,
			'PROVEEDOR-PETROVENDOR'
		FROM dbo.MM_PeticionOferta AS PO  (NOLOCK)
			LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
				ON PO.IdSubcontratista = PR.IdProveedor 
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR  (NOLOCK)
				ON PR.IdProveedor = USPR.IdProveedor
			LEFT JOIN dbo.S_Usuario AS US  (NOLOCK)
				ON USPR.IdUsuario = US.IdUsuario
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS  (NOLOCK)
				ON US.IdTipoUsuario = TUS.IdTipoUsuario
			LEFT JOIN Petrovendor..TA_NoNotificacion as TANN  (NOLOCK)
			on US.idUsuario = TANN.IdUsuario 
			AND  TANN.IdCorreo = @IdCorreo
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 5) --> CTE 3 ADMIN Y 5 VENTAS
			and	US.Activo = 1
			AND ISNULL(TANN.IsEliminado,-1) <> 0 -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion, EN LA TABLA SI ESTA 1 QUIERE DECIR QUE ESTA ACTIVO, SI ESTA EN 0 QUIERE DECIR QUE ESTA ELIMINADA  LA NOTIFICACION
		GROUP BY PR.RazonSocial,
				 US.Nombre,
				 US.Correo,
				 TUS.NombreTipoUsuario,
				 PO.IdPeticionOferta,
				 PO.IdSolicitudPedido,
				 US.Dominio,
				 Us.IdUsuario,
				 US.IdUsuarioADINCO
	ORDER BY US.IdUsuarioADINCO ASC; -- Se agrupan primero los usuarios proveedor
	END

	-- SE AGRUPAN LOS USUARIOS POR PETICION OFERTA Y POR TIPO DE PROVEEDOR PARA SABER QUE URL MANDAR SI RUTA DE PETRO O PROCURA 
	INSERT INTO #CorreoEnviarPorProveedor(IdPeticionOferta, TipoProveedor)
	SELECT IdPeticionOferta,Para
	FROM #DATOSCORREO
	GROUP BY IdPeticionOferta,Para


	
	SET @CorreoAgrupadoEnviar = (SELECT COUNT(Id) FROM #CorreoEnviarPorProveedor)
	SET @ContadorCorreo = 1
	

	WHILE    @CorreoAgrupadoEnviar >= @ContadorCorreo
	BEGIN 
		SET @IdPeticionOfertaRow = 0
		SET @TipoProveedorRow=''
		SET @HTMLCORREO =''
		SET @CorreosOperadora =''
		SET @CorreosAdinco =''

		SELECT 
	    @IdPeticionOfertaRow =IdPeticionOferta, 
		@TipoProveedorRow = TipoProveedor
		FROM #CorreoEnviarPorProveedor
		WHERE Id = @ContadorCorreo

		DELETE FROM #CorreoConcat --> BORRAR PARA EVITAR QUE SE DUPLIQUEN
		-- SE CONCATENAN Y SE AGRUPAN LOS CORREOS DEPENDIENDO EL DOMINIO
		INSERT INTO #CorreoConcat(
			IsCorreoAdinco,
			Correos)
		SELECT 
			DTC.IsCorreoAdinco, 
			STUFF((SELECT ';'+DTS.Correo
				   FROM #DATOSCORREO DTS
				   WHERE DTS.IsCorreoAdinco = DTC.IsCorreoAdinco
				   AND DTS.IdPeticionOferta = @IdPeticionOfertaRow
				   AND DTS.Para = @TipoProveedorRow
				   FOR XML PATH('')), 1, 1, '') AS ParticipantNames
		FROM #DATOSCORREO DTC
		WHERE DTC.IdPeticionOferta = @IdPeticionOfertaRow
		AND DTC.Para = @TipoProveedorRow
		GROUP BY DTC.IsCorreoAdinco;

		--SE OBTIENEN LOS USUARIOS YA CONCATENADOS
		SET @CorreosOperadora = (SELECT Correos FROM #CorreoConcat WHERE IsCorreoAdinco = 0)
		SET @CorreosAdinco = (SELECT Correos FROM #CorreoConcat WHERE IsCorreoAdinco = 1)


			SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = @IdCorreo);
			if(@HTMLCORREO is null)
			begin
				insert into BitacoraErrores values (0,'No se encontró la plantilla del correo', 'Error en el sp SP_JA_EnviarCorreoComentarioPregunta', @IdUsuario, @IdProveedor, GETDATE())
				select @HTMLCORREO = ''
			end

			SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
									FROM TA_Correo AS C  (NOLOCK)
										INNER JOIN TA_CorreoServidor AS S  (NOLOCK)
											ON C.IdServidor = S.IdServidor
									WHERE IdCorreo = @IdCorreo) --> CTE NUMERO CORREO (TA_Correo)
		
			SET @URL = (SELECT TOP 1 URL FROM #DATOSCORREO 
						WHERE IdPeticionOferta = @IdPeticionOfertaRow
						AND Para = @TipoProveedorRow);
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##','USUARIO A ELIMINAR'));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##USUARIO##',@USUARIOPREGUNTA));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##TIPOUSUARIO##',@TIPOUSUARIOPREGUNTA));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##OPERADORA##',@OPERADORA));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##REQUISICION##',@IdSolicitudPedido));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##PREGUNTA##',@COMENTARIOPREGUNTA));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS NVARCHAR(100))));
			SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##URL_TAREA##',@URL));

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
				De,
				CCO
			)
			VALUES
			(
				@IdNotificacion,
				ISNULL(@CorreosOperadora,@CorreosAdinco),-- Si no hay correos destinatarios se envían a los usuarios adinco
				CONCAT('Comentario(Pregunta) Referente a la Requisicion No.',ISNULL(@IdSolicitudPedido,0)),
				ISNULL(@HTMLCORREO,''),
				DATEADD(MINUTE,1,GETDATE()),
				0,
				NULL,
				3,
				GETDATE(),
				NULL,
				NULL,
				ISNULL(@CorreoNotificaciones,''),
				@CorreosAdinco
			);
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
			SET @ContadorCorreo = @ContadorCorreo +1
		END 

end