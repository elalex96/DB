use petrovendor
go
drop proc if exists SP_JA_EnviarCorreoComentarioPregunta
go
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
-- =============================================
-- Author:		Luis David
-- Create date: 19/09/2023
-- Description:	Se agrupan los correos del para y los de adinco en el cco
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
	DECLARE @OPERADORA NVARCHAR(MAX),
	@USUARIOPREGUNTA NVARCHAR(100),
	@TIPOUSUARIOPREGUNTA NVARCHAR(100),
	@COMENTARIOPREGUNTA NVARCHAR(100),
	@HTMLCORREO NVARCHAR(MAX),
	@CORREOUSUARIOPROVEEDOR NVARCHAR(100),
	@IdNotificacion INT,
	@URL NVARCHAR(MAX),
	@IdCorreo INT = (SELECT IdCorreo FROM dbo.TA_Correo WHERE Asunto = 'Comentario(Pregunta) Referente a Requisicion '),
	@CorreoNotificaciones NVARCHAR(MAX),
	@CorreosAdinco NVARCHAR(MAX),
	@CorreosOperadora NVARCHAR(MAX) = NULL;

	
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
		IdUsuarioAdinco INT
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
									ON US.IdTipoUsuario = TUS.IdTipoUsuario
							WHERE US.IdUsuario = @IdUsuario);

	--COMENTARIO PREGUNTA
	SET @COMENTARIOPREGUNTA = (@Comentario);

	--LOS DATOS DE LOS USUARIOS A LOS QUE SE ENVIARAN (VENTAS Y ADMIN) DEL PROVEEDOR
	--SE VERIDICA QUE EL QUE ENVIO EL COMENTARIO SEA LA OPERADORA O EL PROVEEDOR
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
		IdUsuarioAdinco)
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
			US.IdUsuarioADINCO
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PO.IdSubcontratista = PR.IdProveedor 
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR
				ON  PR.IdProveedor = USPR.IdProveedor 
			LEFT JOIN dbo.S_Usuario AS US
				ON USPR.IdUsuario = US.IdUsuario 
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON US.IdTipoUsuario = TUS.IdTipoUsuario 
		LEFT JOIN Petrovendor..TA_NoNotificacion as TANN
			on US.idUsuario = TANN.IdUsuario 
			and  TANN.IdCorreo = @IdCorreo
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 5)
			AND PO.IdSubcontratista <> @IdProveedor
			and	US.Activo = 1
			AND isnull(TANN.IsEliminado,0) = 0 -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion
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
			US.IdUsuarioADINCO
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.MM_SolicitudPedido AS SP 
				ON  PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.S_Proveedor AS PR
				ON SP.IdProveedor = PR.IdProveedor 
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR
				ON PR.IdProveedor = USPR.IdProveedor 
			LEFT JOIN dbo.S_Usuario AS US
				ON USPR.IdUsuario = US.IdUsuario  
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON US.IdTipoUsuario = TUS.IdTipoUsuario 
			LEFT JOIN Petrovendor..TA_NoNotificacion as TANN
			on US.idUsuario = TANN.IdUsuario 
			and  TANN.IdCorreo = @IdCorreo
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
			and	US.Activo = 1
			AND isnull(TANN.IsEliminado,0) = 0 -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion
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
		IdUsuarioAdinco)
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
			US.IdUsuarioADINCO
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.S_Proveedor AS PR
				ON PO.IdSubcontratista = PR.IdProveedor 
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR
				ON PR.IdProveedor = USPR.IdProveedor
			LEFT JOIN dbo.S_Usuario AS US
				ON USPR.IdUsuario = US.IdUsuario
				and	US.Activo = 1
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON US.IdTipoUsuario = TUS.IdTipoUsuario
			LEFT JOIN Petrovendor..TA_NoNotificacion as TANN
			on US.idUsuario = TANN.IdUsuario 
			and  TANN.IdCorreo = @IdCorreo
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
			and	US.Activo = 1
			AND isnull(TANN.IsEliminado,0) = 0 -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion
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

-- SE CONCATENAN Y SE AGRUPAN LOS CORREOS DEPENDIENDO EL DOMINIO
INSERT INTO #CorreoConcat(
	IsCorreoAdinco,
	Correos)
SELECT 
    DTC.IsCorreoAdinco, 
    STUFF((SELECT ';'+DTS.Correo
           FROM #DATOSCORREO DTS
           WHERE DTS.IsCorreoAdinco = DTC.IsCorreoAdinco
           FOR XML PATH('')), 1, 1, '') AS ParticipantNames
FROM [dbo].#DATOSCORREO DTC
GROUP BY DTC.IsCorreoAdinco;

--SE OBTIENEN LOS USUARIOS YA CONCATENADOS
SET @CorreosOperadora = (SELECT Correos FROM #CorreoConcat WHERE IsCorreoAdinco = 0)
SET @CorreosAdinco = (SELECT Correos FROM #CorreoConcat WHERE IsCorreoAdinco = 1)


	SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = @IdCorreo);
	if(@HTMLCORREO is null)
	begin
		insert into BitacoraErrores values (0,'No se encontró la plantilla del correo', 'Error en el sp SP_JA_EnviarCorreoComentarioPregunta', @IdUsuario, @IdProveedor, GETDATE())
		select @HTMLCORREO = ''
	end

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = @IdCorreo) --> CTE NUMERO CORREO (TA_Correo)
		
		SET @URL = (SELECT top 1 URL FROM #DATOSCORREO);
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
end
