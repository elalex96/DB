USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_AgregarProveedoresInvitadosPeticionOferta'
)
    DROP PROCEDURE SP_MM_AgregarProveedoresInvitadosPeticionOferta;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/02/2020>
-- Description:	<Agregar proveedores invitados cuando la peticion ya fue enviada>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <28/04/2025>
-- Description:	<Se retorna lista de correos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarProveedoresInvitadosPeticionOferta] 
	-- Add the parameters for the stored procedure here
	@ProveedoresInvitados NVARCHAR(MAX),
	@CorreosInvitados NVARCHAR(MAX),
	@IdSolicitudPedido INT,
	@IdProveedorActual INT,
	@CreadoPor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);
	DECLARE @IDPROVEEDORINV INT;
	DECLARE @CONTPROVEDORES INT;
	DECLARE @IDPETICIONOFERTA INT;
	DECLARE @CONTAD INT = 1;
	DECLARE @CONTTOTALADMIN INT;
	DECLARE @CONT INT = 1;
	DECLARE @CONTCORREOSINVITADOS INT = 1;
	DECLARE @TOTALCORREOSINVITADOS INT;
	DECLARE @CORREOINVITACIONC NVARCHAR(100);
	DECLARE @HTMLPROVEEDORESINV NVARCHAR(MAX);
	DECLARE @CODIGOACTIVACIONC NVARCHAR(6);
	DECLARE @CORREOADMIN VARCHAR(MAX);
	DECLARE @HTMLCORREOSINV NVARCHAR(MAX);
	DECLARE @ASUNTOPROVEEDORESINV NVARCHAR(MAX);
	DECLARE @ASUNTOCORREOSINV NVARCHAR(MAX);
	DECLARE @CotizacionRestringida BIT;
	DECLARE @Descripcion NVARCHAR(MAX);
	DECLARE @NOMBREPROVEEDORACTUAL NVARCHAR(100);

	CREATE TABLE #PROVEEDORESINVITADOS
	(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		IdProveedorInvitado INT
	);

	CREATE TABLE #CORREOSADMINS
	(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		Correo NVARCHAR(100),
		Nombre NVARCHAR(100),
		IdUsuario INT
	);

	CREATE TABLE #CORREOSINVITADOS
	(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		CorreoInvitado NVARCHAR(100)
	);

	CREATE TABLE #ListaCorreos
	(
		IdRow INT IDENTITY(1,1) PRIMARY KEY,
		Destinatario NVARCHAR(MAX),
		Asunto NVARCHAR(MAX),
		CuerpoCorreo NVARCHAR(MAX),
		CreadoPor INT
	);

	SET @CotizacionRestringida  = (SELECT TOP 1 CotizacionRestringida FROM dbo.MM_PeticionOferta (NOLOCK) WHERE IdSolicitudPedido = @IdSolicitudPedido);
	SET @Descripcion  = (SELECT TOP 1 ISNULL(Descripcion,'') FROM dbo.TA_Operacion (NOLOCK) WHERE IdDocumento = @IdSolicitudPedido AND IdTipoOperacion = 6);
	SET @NOMBREPROVEEDORACTUAL = (SELECT RazonSocial FROM dbo.S_Proveedor (NOLOCK) WHERE IdProveedor = @IdProveedorActual);

	INSERT INTO #CORREOSINVITADOS
	SELECT 
		Datos
	FROM  dbo.SplitString(@CorreosInvitados,',');

	SET @TOTALCORREOSINVITADOS = (SELECT COUNT(IdRow) FROM #CORREOSINVITADOS);

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S (NOLOCK)
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 18) --> CTE NUMERO CORREO (TA_Correo)

	WHILE @CONTCORREOSINVITADOS <= @TOTALCORREOSINVITADOS
	BEGIN
		SET @CORREOINVITACIONC = (SELECT CorreoInvitado FROM #CORREOSINVITADOS WHERE IdRow = @CONTCORREOSINVITADOS);
	    SET @CODIGOACTIVACIONC = (SUBSTRING(CONVERT(VARCHAR(255), NEWID()),0,7));
		SET @HTMLCORREOSINV = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 18);

		SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV,'##NombreEmpresa##',@NOMBREPROVEEDORACTUAL));
		SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV,'##NO_CODIGO##',@CODIGOACTIVACIONC)); 
		SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV,'##CORREO_INVITACION##',@CORREOINVITACIONC));
		SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV,'##ANIO_ACTUAL##',YEAR(GETDATE()))); 
		SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV,'##DOMINIO##','https://petrovendor.com.mx/')); 
		SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV,'##SOLICITUD_PEDIDO##',CAST(@IdSolicitudPedido AS NVARCHAR(100))));
		
		INSERT INTO #ListaCorreos(Asunto, Destinatario, CuerpoCorreo, CreadoPor)
		VALUES('Invitación Cotización Petrovendor ',@CORREOINVITACIONC,@HTMLCORREOSINV, @CreadoPor)
		
		--BITACORA DE CORREO
		INSERT INTO dbo.TA_BitacoraCorreo
		(
			IdDocumento,
			Detalle,
			Correo,
			Enviado,
			FechaEnvio,
			IdUsuarioEnvio,
			IdProveedorEnvio,
			IdUsuarioReceptor
		)
		VALUES
		(   @IdSolicitudPedido,         -- IdDocumento - int
			N'Notificacion Petición Oferta/Recuperación',       -- Detalle - nvarchar(max)
			@CORREOINVITACIONC,       -- Correo - nvarchar(350)
			1,      -- Enviado - bit
			GETDATE(), -- FechaEnvio - datetime
			0,         -- IdUsuarioEnvio - int
			0,         -- IdProveedorEnvio - int
			0          -- IdUsuarioReceptor - int
			);


			INSERT INTO MM_InvitacionPeticionOferta
			(
				[Fecha],
				[CorreoEnviado], 
				[IdSolicitudPedido], 
				[CreadoPor], 
				[CorreoInvitacion],
				[Invitado],
				[Activo],
				[IdProveedorInvito],
				CodigoActivacion,
				InvitacionPorCorreo,
				[CotizacionRestringida]
			)
			VALUES 
			(
				GETDATE(),
				1,
				@IdSolicitudPedido,
				@CreadoPor,
				@CORREOINVITACIONC,
				1,
				1,
				@IdProveedorActual,
				@CODIGOACTIVACIONC,
				1,
				ISNULL(@CotizacionRestringida,0)
			);

			SET @CONTCORREOSINVITADOS = @CONTCORREOSINVITADOS + 1;
	END

	INSERT INTO #PROVEEDORESINVITADOS
	SELECT 
		CAST(Datos AS INT)
	FROM dbo.SplitString(@ProveedoresInvitados,',');

	SET @CONTPROVEDORES = (SELECT COUNT(IdRow) FROM #PROVEEDORESINVITADOS);

	--ENVIO DE LA PETICIONES OFERTAS A LOS PROVEEDORES
	WHILE @CONT <= @CONTPROVEDORES
	BEGIN
	    
		--SE OBTIENE EL PROVEEDOR DE LA PETICION DE LA TABLA RECIVIDA
		SET @IDPROVEEDORINV = (SELECT IdProveedorInvitado FROM #PROVEEDORESINVITADOS WHERE IdRow = @CONT);

		--CABECERA DE LA PETICION OFERTA
		INSERT INTO dbo.MM_PeticionOferta
		(
			IdSolicitudPedido,
			IdSubcontratista,
			CreadoPor,
			CreadoEl,
			Activo,
			Visto,
			Iniciada,
			IdTipoProceso,
			CotizacionRestringida
		)
		VALUES
		(
			@IdSolicitudPedido,
			@IDPROVEEDORINV,
			@CreadoPor,
			GETDATE(),
			1,
			1,
			0,
			2,--MERCADEO
			ISNULL(@CotizacionRestringida,0)
		);

		SET @IDPETICIONOFERTA = (SCOPE_IDENTITY());

		--AGREDADO DE LOS DETALLES DE LA PETICION OFERTA
		--VALIDACION DE COTIZACION RESTRINGIDA
		IF ISNULL(@CotizacionRestringida,0) > 0
		BEGIN
				INSERT INTO MM_PeticionOfertaDetalle
				(
					IdPeticionOferta,
					IdSolicitudPedidoDetalle,
					IdMaterial,
					IdMaterialVendedor,
					ComentariosComprador,
					CreadoEl,
					CreadoPor,
					Activo,
					NoMaterialesRequeridos,
					IdProveedorVenta,
					Cotizado,
					IdUnidad,
					IdUnidadProveedor
				)
				SELECT
					@IDPETICIONOFERTA,
					IdSolicitudPedidoDetalle,
					IdMaterial,
					IdMaterial,
					observaciones,
					GETDATE(),
					@CreadoPor,
					1,
					Cantidad,
					@IDPROVEEDORINV,
					0,
					IdUnidad,
					IdUnidad
				FROM dbo.MM_SolicitudPedidoDetalle (NOLOCK)
				WHERE IdSolicitudPedido = @IdSolicitudPedido;
		END
		ELSE
		BEGIN
		    INSERT INTO MM_PeticionOfertaDetalle
				(
					IdPeticionOferta,
					IdSolicitudPedidoDetalle,
					IdMaterial,
					ComentariosComprador,
					CreadoEl,
					CreadoPor,
					Activo,
					NoMaterialesRequeridos,
					IdProveedorVenta,
					Cotizado,
					IdUnidad
				)
				SELECT
					@IDPETICIONOFERTA,
					IdSolicitudPedidoDetalle,
					IdMaterial,
					observaciones,
					GETDATE(),
					@CreadoPor,
					1,
					Cantidad,
					@IDPROVEEDORINV,
					0,
					IdUnidad
				FROM dbo.MM_SolicitudPedidoDetalle (NOLOCK)
				WHERE IdSolicitudPedido = @IdSolicitudPedido;
		END

		

		--ENVIO DE CORREOS A LOS ADMINISTRADORES
		INSERT INTO #CORREOSADMINS
		SELECT 
			U.Correo, 
			U.Nombre, 
			U.IdUsuario
		FROM S_Usuario AS U (NOLOCK)
			JOIN S_UsuarioProveedor AS UP (NOLOCK)
				ON UP.IdUsuario = U.IdUsuario  
			JOIN S_Proveedor AS P (NOLOCK)
				ON UP.IdProveedor = P.IdProveedor
		WHERE P.IdProveedor = @IDPROVEEDORINV
			AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario= 3) 
			AND U.Activo = 1;

		SET @CONTTOTALADMIN = (SELECT COUNT(IdRow) FROM #CORREOSADMINS);

		WHILE @CONTAD <= @CONTTOTALADMIN
		BEGIN

			SET @CORREOADMIN = (SELECT Correo FROM #CORREOSADMINS WHERE IdRow = @CONTAD);
			SET @HTMLPROVEEDORESINV = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = 11);
			--ARMADO DEL HTML
			--ASUNTO
			--NOMBRE USUARIO
			SET @HTMLPROVEEDORESINV = (REPLACE(@HTMLPROVEEDORESINV,'##NOMBRE_USUARIO##',(SELECT Nombre FROM #CORREOSADMINS WHERE IdRow = @CONTAD)));
			--DESCRIPCION
			SET @HTMLPROVEEDORESINV = (REPLACE(@HTMLPROVEEDORESINV,'##DESCRIPCION_TAREA##',@Descripcion));
			--URL
			SET @HTMLPROVEEDORESINV = (REPLACE(@HTMLPROVEEDORESINV,'##URL_PO##',CONCAT('https://petrovendor.com.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=' , CAST(@IDPETICIONOFERTA AS NVARCHAR(100)))));
			--AÑO
			SET @HTMLPROVEEDORESINV = (REPLACE(@HTMLPROVEEDORESINV,'##ANIO_ACTUAL##',CAST(YEAR(GETDATE()) AS NVARCHAR(100))));
			--SOLICITUD DE PEDIDO
			SET @HTMLPROVEEDORESINV = (REPLACE(@HTMLPROVEEDORESINV,'##SOLICITUD_PEDIDO##',CAST(@IdSolicitudPedido AS NVARCHAR(100))));
			--CORREO
			
			INSERT INTO #ListaCorreos(Asunto, Destinatario, CuerpoCorreo, CreadoPor)
		    VALUES(CONCAT('Petición Oferta No.',ISNULL(@IDPETICIONOFERTA,0)),@CORREOADMIN,@HTMLPROVEEDORESINV, @CreadoPor)
		
			--BITACORA DE CORREO
			INSERT INTO dbo.TA_BitacoraCorreo
			(
			    IdDocumento,
			    Detalle,
			    Correo,
			    Enviado,
			    FechaEnvio,
			    IdUsuarioEnvio,
			    IdProveedorEnvio,
			    IdUsuarioReceptor
			)
			VALUES
			(   @IDPETICIONOFERTA,         -- IdDocumento - int
			    N'Notificacion Petición Oferta/Recuperación',       -- Detalle - nvarchar(max)
			    @CORREOADMIN,       -- Correo - nvarchar(350)
			    1,      -- Enviado - bit
			    GETDATE(), -- FechaEnvio - datetime
			    0,         -- IdUsuarioEnvio - int
			    0,         -- IdProveedorEnvio - int
			    0          -- IdUsuarioReceptor - int
			    );

			INSERT INTO MM_InvitacionPeticionOferta
			(
				[Fecha],
				[CorreoEnviado], 
				[IdSolicitudPedido], 
				[IdProveedorInvitado], 
				[CreadoPor], 
				[IdPeticionOferta], 
				[CorreoInvitacion],
				[Invitado],
				[Activo],
				[IdProveedorInvito],
				[CotizacionRestringida])
			VALUES 
			(
				GETDATE(),
				1,
				@IdSolicitudPedido,
				@IDPROVEEDORINV,
				@CreadoPor,
				@IDPETICIONOFERTA,
				@CORREOADMIN,
				1,
				1,
				@IdProveedorActual,
				ISNULL(@CotizacionRestringida,0)
			)

			SET @CONTAD = @CONTAD + 1;

		END;

		SET @CONTAD = 1;--SE FORMATEA EL CONTADOR
		SET @CONTTOTALADMIN = 0;
		TRUNCATE TABLE #CORREOSADMINS;--SE VACIA LA TABLA PARA LOS ADMINISTRADORES DEL SIG PROVEEDOR
		
		SET @CONT = @CONT + 1;
	END;

	SELECT 'SUCCESS'

	SELECT Asunto, Destinatario, CuerpoCorreo, CreadoPor
	FROM #ListaCorreos

END
