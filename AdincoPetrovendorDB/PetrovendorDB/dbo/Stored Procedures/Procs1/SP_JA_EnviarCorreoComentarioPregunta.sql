if exists(select * from sys.procedures where name = 'SP_JA_EnviarCorreoComentarioPregunta')
begin
	drop proc SP_JA_EnviarCorreoComentarioPregunta
end

go

-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10/04/2020>
-- Description:	<Envio de correo de notificacion de pregunta en la oferta>
-- =============================================
create PROCEDURE [dbo].[SP_JA_EnviarCorreoComentarioPregunta] --20290,2199,420,'PRUEBA 11'
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
	DECLARE @PROVEEDOR NVARCHAR(100);
	DECLARE @USUARIOPROVEEDOR NVARCHAR(100);
	DECLARE @CORREOUSUARIOPROVEEDOR NVARCHAR(100);
	DECLARE @IdNotificacion INT;
	DECLARE @URL NVARCHAR(MAX);

	declare @IdCorreo int

	select @IdCorreo = IdCorreo from dbo.TA_Correo where Asunto = 'Comentario(Pregunta) Referente a Requisicion '
	

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
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON TUS.IdTipoUsuario = US.IdTipoUsuario
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 5)
			AND PO.IdSubcontratista <> @IdProveedor
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
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON TUS.IdTipoUsuario = US.IdTipoUsuario
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
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
			LEFT JOIN dbo.S_TipoUsuario AS TUS
				ON TUS.IdTipoUsuario = US.IdTipoUsuario
		WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
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

	--ITERACION DE LA TABLA
	WHILE @CONTROWS <= @TOTALROWS
	BEGIN
	    --CONSULTA PARA OBTENER EL HTML DEL CORREO
		--SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 98
		
		SET @USUARIOPROVEEDOR = (SELECT NombreUsuario FROM #DATOSCORREO WHERE IdRow = @CONTROWS);
		SET @CORREOUSUARIOPROVEEDOR = (SELECT Correo FROM #DATOSCORREO WHERE IdRow = @CONTROWS);
		SET @URL = (SELECT URL FROM #DATOSCORREO WHERE IdRow = @CONTROWS);

		SET @HTMLCORREO = (REPLACE(@HTMLCORREO,'##NOMBRE_USUARIO##',@USUARIOPROVEEDOR));
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
			'procura@adinco.mx'
		);
		--select * from Adinco.dbo.S_Notificacion where IdNotificacion = @IdNotificacion
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

go
