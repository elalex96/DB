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
-- Create date: 16/04/2025
-- Description:	Se personaliza correos de notificación para que se envie siempre a la operadora,para que este al tanto de todo, 
-- pero tambien al proveedor cuando es el que registro la pregunta y se revise una respuesta 
-- se descarta enviarse el correo al usuario cuando es el usuario que levanto la pregunta y el mismo agrega una respuesta 
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
		para varchar(max),
		asunto varchar(500),
		html varchar(max)
	)

	DROP TABLE IF EXISTS #CorreoConcat
	CREATE TABLE #CorreoConcat(
	Para VARCHAR(MAX),
	Correos VARCHAR(MAX)
	)

	DROP TABLE IF EXISTS #DATOSCORREO
	CREATE TABLE #DATOSCORREO(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		IdUsuario int,
		Correo NVARCHAR(MAX),
		IsCorreoAdinco BIT,
		Para NVARCHAR(MAX)
	);

	DROP TABLE IF EXISTS #CorreoProveedorOferta
	CREATE TABLE #CorreoProveedorOferta(
		IdPeticionOferta INT,
		Correos VARCHAR(MAX)
	)
	
	DROP TABLE IF EXISTS #ProveedoresParticipantes
	CREATE TABLE #ProveedoresParticipantes(
		IdProveedor INT,
		IdPeticionOferta INT
	)


    -- Insert statements for procedure here
	DECLARE @IdProveedorPetrovendor INT = 0
	DECLARE @IDPETICIONOFERTA INT  = 0
	DECLARE @EXCLUIR_USUARIO_ID INT  = 0

	DECLARE @IDUSUARIOPREGUNTA INT 
	DECLARE @PREGUNTA_PRINCIPAL NVARCHAR(MAX)  
	DECLARE @NOMBREUSUARIOPREGUNTA NVARCHAR(500) 
	DECLARE @CORREOUSUARIOPREGUNTA NVARCHAR(500) 
	DECLARE @NOMBREUSUARIORESPUESTA NVARCHAR(500) 
	DECLARE @CORREOUSUARIORESPUESTA NVARCHAR(500) 
	DECLARE @NOMBREPROVEEDOR NVARCHAR(500)  
	DECLARE @HTMLCORREO NVARCHAR(MAX), 
	@HTMLCORREOOPERADORA NVARCHAR(MAX), 
	@HTMLCORREOPROVEEDOR NVARCHAR(MAX),
	@ASUNTO NVARCHAR(500);

	DECLARE @IDUSUARIOPREGUNTA_IDADINCO INT 
	DECLARE @IDUSUARIORESPUESTA_IDADINCO INT
	DECLARE @IdCorreo  int
    DECLARE @CorreosConcat  NVARCHAR(MAX)
	DECLARE @EsComentarioBaseOperadora BIT = 0
	DECLARE @EsRespuestaActualOperadora BIT = 0
	DECLARE @ExisteRespuestaProveedor BIT = 0
	
	DECLARE @UrlPetrovendor NVARCHAR(500)= (SELECT TOP 1 Url FROM TA_Dominios  (NOLOCK) WHERE IdDominio= 1) --> CTE PETROVENDOR
	DECLARE @UrlProcura NVARCHAR(500)= (SELECT TOP 1 Url FROM TA_Dominios  (NOLOCK) WHERE IdDominio= 2)--> CTE PROCURA


	SELECT @NOMBREPROVEEDOR = RazonSocial 
	FROM dbo.S_Proveedor  (NOLOCK)
	WHERE IdProveedor = @IdProveedor;

	SELECT @CORREOUSUARIORESPUESTA = Correo,
	@NOMBREUSUARIORESPUESTA = Nombre
	FROM dbo.S_Usuario (NOLOCK)
	WHERE IdUsuario = @IdUsuario

	SELECT @PREGUNTA_PRINCIPAL = Comentario,
	@IDUSUARIOPREGUNTA = IdUsuario
	FROM dbo.JA_ComentarioBase  (NOLOCK)
	WHERE IdComentarioBase = @IdComentarioBase;

	SELECT @IDUSUARIOPREGUNTA_IDADINCO = IdUsuarioADINCO 
	FROM dbo.S_Usuario  (NOLOCK)
	WHERE IdUsuario = @IDUSUARIOPREGUNTA

	SELECT @IDUSUARIORESPUESTA_IDADINCO = IdUsuarioADINCO
	FROM dbo.S_Usuario (NOLOCK)
	WHERE IdUsuario = @IdUsuario
	
	SELECT 
    @NOMBREUSUARIOPREGUNTA = Nombre,
    @CORREOUSUARIOPREGUNTA = Correo
	FROM dbo.S_Usuario  (NOLOCK)
	WHERE IdUsuario = @IDUSUARIOPREGUNTA;

	-- Regla: identificar si el comentario base y la respuesta actual vienen de operadora.
	SET @EsComentarioBaseOperadora = CASE WHEN ISNULL(@IDUSUARIOPREGUNTA_IDADINCO,0) <> 0 THEN 1 ELSE 0 END
	SET @EsRespuestaActualOperadora = CASE WHEN ISNULL(@IDUSUARIORESPUESTA_IDADINCO,0) <> 0 THEN 1 ELSE 0 END

	-- Regla: si ya existe al menos una respuesta de proveedor en el hilo, ya no aplica la notificación masiva adicional a proveedores.
	SET @ExisteRespuestaProveedor = CASE WHEN EXISTS(
		SELECT 1
		FROM dbo.JA_ComentarioRelacion CR (NOLOCK)
			JOIN dbo.JA_ComentarioRespuesta R (NOLOCK)
				ON CR.IdComentarioRespuesta = R.IdComentarioRespuesta
			JOIN dbo.S_Usuario U (NOLOCK)
				ON R.IdUsuario = U.IdUsuario
		WHERE CR.IdComentarioBase = @IdComentarioBase
			AND ISNULL(U.IdUsuarioADINCO,0) = 0
	) THEN 1 ELSE 0 END
	
	-- Regla: los proveedores participantes del hilo son el proveedor que creo el comentario base y los proveedores que han respondido al menos una vez.
	INSERT INTO #ProveedoresParticipantes(IdProveedor, IdPeticionOferta)
	SELECT DISTINCT
		PO.IdSubcontratista,
		PO.IdPeticionOferta
	FROM dbo.S_UsuarioProveedor UP (NOLOCK)
		JOIN dbo.MM_PeticionOferta PO (NOLOCK)
			ON UP.IdProveedor = PO.IdSubcontratista 
			AND PO.IdSolicitudPedido = @IdSolicitudPedido
	WHERE @EsComentarioBaseOperadora = 0
		AND UP.IdUsuario = @IDUSUARIOPREGUNTA

	INSERT INTO #ProveedoresParticipantes(IdProveedor, IdPeticionOferta)
	SELECT DISTINCT
		PO.IdSubcontratista,
		PO.IdPeticionOferta
	FROM dbo.JA_ComentarioRelacion CR (NOLOCK)
		JOIN dbo.JA_ComentarioRespuesta R (NOLOCK)
			ON CR.IdComentarioRespuesta = R.IdComentarioRespuesta 
		JOIN dbo.S_Usuario U (NOLOCK)
			ON R.IdUsuario = U.IdUsuario 
		JOIN dbo.S_UsuarioProveedor UP (NOLOCK)
			ON  U.IdUsuario = UP.IdUsuario
		JOIN dbo.MM_PeticionOferta PO (NOLOCK)
			ON UP.IdProveedor = PO.IdSubcontratista 
			AND PO.IdSolicitudPedido = @IdSolicitudPedido
	WHERE CR.IdComentarioBase = @IdComentarioBase
		AND ISNULL(U.IdUsuarioADINCO,0) = 0
		AND NOT EXISTS(
			SELECT 1
			FROM #ProveedoresParticipantes PP
			WHERE PP.IdProveedor = PO.IdSubcontratista
				AND PP.IdPeticionOferta = PO.IdPeticionOferta
		)
		
	-- VALIDAR SI EL USUARIO RESPONDIO SU MISMA PREGUNTA ENTONCES NO INCLUIRLO EN EL CORREO DE NOTIFICACIÓN
	IF @IDUSUARIOPREGUNTA =  @IdUsuario
	BEGIN
		SET @EXCLUIR_USUARIO_ID = @IdUsuario
	END 

	SELECT @IdCorreo = IdCorreo 
	FROM dbo.TA_Correo (NOLOCK)
	WHERE Descripcion = 'Notificacion de respuesta a una pregunta en la oferta'

	IF @IdCorreo IS NULL
	BEGIN
		INSERT INTO BitacoraErrores values (0,'No se encontró la plantilla del correo [Notificacion de respuesta a una pregunta en la oferta]', 'Error en el sp SP_JA_EnviarCorreoComentarioRespuesta', @IdUsuario, @IdProveedor, GETDATE())
		SELECT 
	    para,
		asunto,
		html 
		FROM #CorreosEnviarSDK
		RETURN;
	END
	-- USUARIOS DE LA OPERADORA SIEMPRE RECIBEN NOTIFICACIÓN DE LAS RESPUESTAS DE TODAS LAS PREGUNTAS
	    INSERT INTO #DATOSCORREO(
		IdUsuario,
		Correo,
		IsCorreoAdinco,
		Para)
	    SELECT
		Us.IdUsuario,	
		US.Correo,
		CASE WHEN US.Dominio = 'ADINCO.MX'
		then 1 else 0
		end as IsCorreoAdinco,	
		'PROVEEDOR-PROCURA'		
		FROM MM_SolicitudPedido AS SP   (NOLOCK)
		    JOIN S_Proveedor AS PR  (NOLOCK)
				ON SP.IdProveedor = PR.IdProveedor 
			JOIN S_UsuarioProveedor AS USPR  (NOLOCK)
				ON PR.IdProveedor = USPR.IdProveedor 
			JOIN S_Usuario AS US  (NOLOCK)
				ON USPR.IdUsuario = US.IdUsuario  
				AND	US.Activo = 1
				AND US.IdUsuario <> @EXCLUIR_USUARIO_ID
			JOIN S_TipoUsuario AS TUS  (NOLOCK)
				ON US.IdTipoUsuario = TUS.IdTipoUsuario 
			LEFT JOIN Petrovendor..TA_NoNotificacion as TANN  (NOLOCK)
			    ON US.IdUsuario = TANN.IdUsuario 
			     AND  TANN.IdCorreo = @IdCorreo
				 AND TANN.IdProveedor = SP.IdProveedor
		WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 
			OR US.IdTipoUsuario = 5)  --> CTE 3 ADMIN Y 5 COMPRAS
			AND	US.Activo = 1
			AND ISNULL(TANN.IsEliminado,-1) <> 0 -- SE VALIDA SI EL USUARIO NO TIENE BLOQUEADO EL CORREO EN TA_NoNotificacion, EN LA TABLA SI ESTA 1 QUIERE DECIR QUE ESTA ACTIVO, SI ESTA EN 0 QUIERE DECIR QUE [...]
		GROUP BY US.Correo,
				 US.Dominio,
				 Us.IdUsuario
		ORDER BY US.Correo ASC;

	SET @HTMLCORREO = (SELECT HTML FROM dbo.TA_Correo  (NOLOCK) WHERE IdCorreo = @IdCorreo);
	SET @Respuesta = CASE 
		WHEN LEN(@Respuesta) > 200 THEN LEFT(@Respuesta,197) + '...'
		ELSE @Respuesta
	END

	SET @HTMLCORREO = REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##','Usuario')
	SET @HTMLCORREO = REPLACE(@HTMLCORREO,'##PROVEEDOR##',CONCAT(ISNULL(@NOMBREUSUARIORESPUESTA,''),' de ',ISNULL(@NOMBREPROVEEDOR,'')))
	SET @HTMLCORREO = REPLACE(@HTMLCORREO,'##REQUISICION##',CAST(ISNULL(@IdSolicitudPedido,0) AS NVARCHAR(100)))
	SET @HTMLCORREO = REPLACE(@HTMLCORREO,'##RESPUESTA##',@Respuesta)
	SET @HTMLCORREO = REPLACE(@HTMLCORREO,'##PREGUNTA##',@PREGUNTA_PRINCIPAL)
	SET @HTMLCORREO = REPLACE(@HTMLCORREO,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS NVARCHAR(100)))
	SET @ASUNTO = CONCAT('Comentario(Respuesta) Referente a la Requisicion No.',ISNULL(@IdSolicitudPedido,0))

	INSERT INTO #CorreoConcat(
		Para,
		Correos
	)
	SELECT
		'PROVEEDOR-PROCURA',
		STUFF((SELECT ';' + DTS.Correo
				FROM #DATOSCORREO DTS
				WHERE DTS.Para = 'PROVEEDOR-PROCURA'
				FOR XML PATH('')), 1, 1, '')

	SET @CorreosConcat = (SELECT TOP 1 Correos FROM #CorreoConcat WHERE Para = 'PROVEEDOR-PROCURA')

	IF ISNULL(@CorreosConcat,'') <> ''
	BEGIN 
		SET @HTMLCORREOOPERADORA = @HTMLCORREO
		SET @HTMLCORREOOPERADORA = REPLACE(@HTMLCORREOOPERADORA,'##URL_TAREA##',CONCAT(@UrlProcura,'02Proveedores/DetalleOferta.aspx?solped=',CAST(ISNULL(@IdSolicitudPedido,0) AS NVARCHAR(100))))

		INSERT INTO #CorreosEnviarSDK(para, asunto, html)
		VALUES(@CorreosConcat, @ASUNTO, @HTMLCORREOOPERADORA)
	END

	-- Regla: si hay proveedores participantes, se notifica solo a esos proveedores con la URL de su oferta.
	IF EXISTS (SELECT 1 FROM #ProveedoresParticipantes)
	BEGIN
		DELETE FROM #CorreoProveedorOferta

		INSERT INTO #CorreoProveedorOferta(IdPeticionOferta, Correos)
		SELECT
			PP.IdPeticionOferta,
			STUFF((SELECT ';' + US2.Correo
					FROM dbo.S_UsuarioProveedor USPR2 (NOLOCK)
						JOIN dbo.S_Usuario US2 (NOLOCK)
							ON USPR2.IdUsuario = US2.IdUsuario
							AND US2.Activo = 1
							AND US2.IdUsuario <> @EXCLUIR_USUARIO_ID
						JOIN dbo.S_TipoUsuario TUS2 (NOLOCK)
							ON US2.IdTipoUsuario = TUS2.IdTipoUsuario
						LEFT JOIN Petrovendor..TA_NoNotificacion TANN2 (NOLOCK)
							ON US2.IdUsuario = TANN2.IdUsuario
							AND TANN2.IdCorreo = @IdCorreo
							AND TANN2.IdProveedor = USPR2.IdProveedor
					WHERE USPR2.IdProveedor = PP.IdProveedor
						AND (US2.IdTipoUsuario = 3 OR US2.IdTipoUsuario = 4)
						AND ISNULL(TANN2.IsEliminado,-1) <> 0
					FOR XML PATH('')), 1, 1, '')
		FROM #ProveedoresParticipantes PP
		GROUP BY PP.IdProveedor, PP.IdPeticionOferta

		INSERT INTO #CorreosEnviarSDK(para, asunto, html)
		SELECT
			CPO.Correos,
			@ASUNTO,
			REPLACE(@HTMLCORREO,'##URL_TAREA##',CONCAT(@UrlPetrovendor,'01Proveedores/CO_CotizacionDetalle.aspx?oferta=',CAST(CPO.IdPeticionOferta AS NVARCHAR(100))))
		FROM #CorreoProveedorOferta CPO
		WHERE ISNULL(CPO.Correos,'') <> ''
	END
	-- Regla fallback: si el hilo sigue siendo exclusivo de operadora, se notifica a todos los proveedores de la solicitud con su propia URL de oferta.
	ELSE IF @EsComentarioBaseOperadora = 1
		AND @EsRespuestaActualOperadora = 1
		AND @ExisteRespuestaProveedor = 0
	BEGIN
		DELETE FROM #CorreoProveedorOferta

		INSERT INTO #CorreoProveedorOferta(IdPeticionOferta, Correos)
		SELECT
			PO.IdPeticionOferta,
			STUFF((SELECT ';' + US2.Correo
					FROM dbo.MM_PeticionOferta PO2 (NOLOCK)
						JOIN dbo.S_Proveedor PR2 (NOLOCK)
							ON PO2.IdSubcontratista = PR2.IdProveedor
						JOIN dbo.S_UsuarioProveedor USPR2 (NOLOCK)
							ON PR2.IdProveedor = USPR2.IdProveedor
						JOIN dbo.S_Usuario US2 (NOLOCK)
							ON USPR2.IdUsuario = US2.IdUsuario
							AND US2.Activo = 1
							AND US2.IdUsuario <> @EXCLUIR_USUARIO_ID
						JOIN dbo.S_TipoUsuario TUS2 (NOLOCK)
							ON US2.IdTipoUsuario = TUS2.IdTipoUsuario
						LEFT JOIN Petrovendor..TA_NoNotificacion TANN2 (NOLOCK)
							ON US2.IdUsuario = TANN2.IdUsuario
							AND TANN2.IdCorreo = @IdCorreo
							AND TANN2.IdProveedor = USPR2.IdProveedor
					WHERE PO2.IdPeticionOferta = PO.IdPeticionOferta
						AND PO2.IdSolicitudPedido = @IdSolicitudPedido
						AND (US2.IdTipoUsuario = 3 OR US2.IdTipoUsuario = 4)
						AND ISNULL(TANN2.IsEliminado,-1) <> 0
					FOR XML PATH('')), 1, 1, '')
		FROM dbo.MM_PeticionOferta PO (NOLOCK)
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
		GROUP BY PO.IdPeticionOferta

		INSERT INTO #CorreosEnviarSDK(para, asunto, html)
		SELECT
			CPO.Correos,
			@ASUNTO,
			REPLACE(@HTMLCORREO,'##URL_TAREA##',CONCAT(@UrlPetrovendor,'01Proveedores/CO_CotizacionDetalle.aspx?oferta=',CAST(CPO.IdPeticionOferta AS NVARCHAR(100))))
		FROM #CorreoProveedorOferta CPO
		WHERE ISNULL(CPO.Correos,'') <> ''
	END
	   
	SELECT 
	    para,
		asunto,
		html 
	FROM #CorreosEnviarSDK
END