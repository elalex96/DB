IF OBJECT_ID('[dbo].[p_OT_Estimacion_Notificacion]', 'P') IS NOT NULL
	DROP PROC [dbo].[p_OT_Estimacion_Notificacion]
GO

-- p_OT_Estimacion_Notificacion 510,1,10
CREATE PROC [dbo].[p_OT_Estimacion_Notificacion] @pIdOTEstimacion INT
	,@pTipoCorreo INT
	,
	/*
	1. Estimacion recien generada
	2. Relacion PO
*/
	@pCreadoPor INT
AS
BEGIN
	DECLARE @para VARCHAR(500) = ''
		,@asunto VARCHAR(250)
		,@mensaje VARCHAR(MAX)
		,@Modulo VARCHAR(100) = 'Control de Obra'
		,@urlProcura VARCHAR(300)
		,@urlPetroExt VARCHAR(300)
		,@NumeroOT VARCHAR(20)
		,@nombreContratista VARCHAR(100)
		,@IdNotificacion INT
		,@FechaProgramadaEnvio DATETIME = getdate()
		,@permitirAceptacionAut BIT = 0
		,@pedido VARCHAR(20)
		,@aceptacion VARCHAR(20)
		,@urlProcuraRec VARCHAR(300) = ''
		,@proveedor VARCHAR(250) = ''
		,@urlCN VARCHAR(300) = ''
		,@operadora VARCHAR(500) = ''
		,@IdProveedor INT
		,@contrato VARCHAR(50)
		,@IdNacionalidadProveedor INT

	--Obtencion de URL Reclasificación
	SELECT @urlProcuraRec = '<a href="' + ISNULL(URL, '') + '" >Aquí</a>'
	FROM [APP_URLRecursos]
	WHERE Tipo = 'ProcuraReclasificacionLineasPresupuesto'

	--Obtencion de URL CN
	SELECT @urlCN = ISNULL(URL, '')
	FROM [APP_URLRecursos]
	WHERE Tipo = 'PetrovendorProveedorCartaCN'

	--Obtencion de URL Procura
	SELECT @urlProcura = ISNULL(URL, '')
	FROM [APP_URLRecursos]
	WHERE Tipo = 'ProcuraAceptacionSinParam'

	--Obtencion de URL Procura
	SELECT @urlPetroExt = ISNULL(URL, '')
	FROM [APP_URLRecursos]
	WHERE Tipo = 'PetrovendorInvoicesExtranjeros'

	--Obtener los usuarios a excluir para las notificaciones
	SELECT un.UsuarioId
		,un.TipoNotificacionId
		,un.Desactivar
	INTO #tmpNotificacionesExcluir
	FROM [AP_UsuarioNotificaciones] un
	INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc ON ucc.IdUsuario = un.UsuarioId
	INNER JOIN OT_Estimacion e ON e.IdOTEstimacion = @pIdOTEstimacion
	INNER JOIN OT_Solicitud ot ON ot.IdCentroCosto = ucc.IdCentroCosto
		AND ot.IdOTSolicitud = e.IdOTEstimacion
	INNER JOIN SC_Subcontrato sc ON sc.IdSubcontrato = ot.IdSubcontrato
		AND sc.IdContrato = un.ContratoId
	WHERE un.Desactivar = 1

	IF (
			@pTipoCorreo IN (1) /*******Avisar al aprobador que se ha generado una Estimacion****/
			)
	BEGIN
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SELECT @para = u.Usuario
			,@NumeroOT = ot.Folio
			,@nombreContratista = con.NombreContratista
			,@urlProcura = '<a href="' + @urlProcura + '?ped=' + cast(e.IdPedido AS VARCHAR) + '&pedgral=' + cast(e.IdPedidoGeneral AS VARCHAR) + '&ori=pedido' + '" >Aquí</a>'
			,@permitirAceptacionAut = isnull(cf.permitirAceptacionAut, 0)
			,@pedido = cast(e.IdPedidoGeneral AS VARCHAR)
			,@aceptacion = cast(ap.IdAceptacionPedido AS VARCHAR)
			,@proveedor = prov.RazonSocial
			,@operadora = prov2.RazonSocial
			,@IdProveedor = prov.IdProveedor
			,@contrato = c.NumeroContrato
			,@IdNacionalidadProveedor = prov.IdNacionalidad
		FROM OT_Estimacion e
		INNER JOIN petrovendor..MM_Pedido ped ON ped.IdPedido = e.IdPedido
		INNER JOIN petrovendor..MM_SolicitudPedido sp ON sp.IdSolicitudPedido = ped.IdSolicitudPedido
		INNER JOIN AP_usuario u ON u.UsuarioId = e.CreadoPor
			AND ISNULL(u.IsActivo, 0) = 1
		INNER JOIN OT_Solicitud ot ON ot.IdOTSolicitud = e.IdOTSolicitud
		INNER JOIN SC_Subcontrato sc ON sc.IdSubcontrato = ot.IdSubcontrato
		INNER JOIN CO_Contratista con ON con.IdContratista = sc.IdContratista
		INNER JOIN OT_Configurador cf ON cf.IdContrato = sc.IdContrato
		INNER JOIN CO_Contrato c ON c.IdContrato = sc.IdContrato
		LEFT JOIN petrovendor..MM_AceptacionPedido ap ON ap.IdPedido = e.IdPedido
		LEFT JOIN petrovendor..S_Proveedor prov ON prov.IdProveedor = ped.IdSubcontratista
		LEFT JOIN petrovendor..S_Proveedor prov2 ON prov2.IdProveedor = ped.IdProveedorCompras
		WHERE e.IdOTEstimacion = @pIdOTEstimacion
			AND isnull(e.Cancelada, 0) = 0

		IF @permitirAceptacionAut = 0
		BEGIN
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere aceptación para Pedido:' + @pedido
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'Adinco- Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlProcura)
			SET @mensaje = replace(@mensaje, '{accion}', 'Se ha generado una Estimación de Control de Obra, es necesario ingresar a procura para realizar la aceptación del servicio')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)

			IF isnull(@para, '') <> ''
			BEGIN
				EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
					,@Para = @para
					,@Asunto = @asunto
					,@Mensaje = @mensaje
					,@FechaProgramadaEnvio = @FechaProgramadaEnvio
					,@Enviada = 0
					,@CreadoPor = @pCreadoPor
					,@CCO = ''
					,@Modulo = @Modulo;
			END
		END

		IF @permitirAceptacionAut = 1
		BEGIN
			SELECT @para = dbo.fn_OT_GetMailUsuariosEstatus(ot.IdOTSolicitud, 0, 6, 12)
			FROM OT_Estimacion e
			INNER JOIN OT_Solicitud ot ON ot.IdOTSolicitud = e.IdOTSolicitud
			INNER JOIN SC_SubContrato sc ON sc.IdSubContrato = ot.IdSubContrato
			INNER JOIN CO_Contrato c ON c.IdContrato = sc.IdContrato
			INNER JOIN PV_Subcontratista pv ON pv.IdSubcontratista = sc.IdSubcontratista
			INNER JOIN petrovendor..MM_AceptacionPedido ap ON ap.IdPedido = e.IdPedido
			WHERE e.IdOTEstimacion = @pIdOTEstimacion
				AND isnull(e.Cancelada, 0) = 0

			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se Requiere Reclasificación para Aceptación:' + @aceptacion
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'Adinco- Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlProcuraRec)
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{accion}', 'Se ha generado una Aceptación de Control de Obra, es necesario ingresar a procura para confirmar la reclasificación de los servicios')

			IF isnull(@para, '') <> ''
			BEGIN
				EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
					,@Para = @para
					,@Asunto = @asunto
					,@Mensaje = @mensaje
					,@FechaProgramadaEnvio = @FechaProgramadaEnvio
					,@Enviada = 0
					,@CreadoPor = @pCreadoPor
					,@CCO = ''
					,@Modulo = @Modulo;
			END

			/*Notificacion para Carta CN o Comprobante extranjero dependiendo de nacionalidad*/
			IF (@IdNacionalidadProveedor = 1)
			BEGIN
				SELECT @asunto = Asunto
					,@mensaje = HTML
				FROM petrovendor..TA_Correo
				WHERE idcorreo = 83

				SET @mensaje = replace(@mensaje, '##URL_TAREA##', @urlCN)
			END
			ELSE
			BEGIN
				SELECT @asunto = Asunto
					,@mensaje = HTML
				FROM petrovendor..TA_Correo
				WHERE Descripcion = 'SolicitudComprobanteExtranjeroAceptacion'

				SET @mensaje = replace(@mensaje, '##URL_TAREA##', @urlPetroExt)
			END

			SET @mensaje = replace(@mensaje, '##NOMBRE_USUARIO##', @proveedor)
			SET @mensaje = replace(@mensaje, '##NO_OPERACION##', @aceptacion)
			SET @mensaje = replace(@mensaje, '##NO_PEDIDO##', @pedido)
			SET @mensaje = replace(@mensaje, '##OPERADORA##', @operadora)
			SET @mensaje = replace(@mensaje, '##ANIO_ACTUAL##', YEAR(GETDATE()))
			SET @para = ''

			SELECT @para = correo + ';'
			FROM petrovendor..S_UsuarioProveedor up
			INNER JOIN petrovendor..S_Usuario u ON u.IdUsuario = up.IdUsuario
				AND u.Activo = 1
			WHERE IdProveedor = @IdProveedor

			IF isnull(@para, '') <> ''
			BEGIN
				EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
					,@Para = @para
					,@Asunto = @asunto
					,@Mensaje = @mensaje
					,@FechaProgramadaEnvio = @FechaProgramadaEnvio
					,@Enviada = 0
					,@CreadoPor = @pCreadoPor
					,@CCO = ''
					,@Modulo = @Modulo;
			END
		END
	END

	IF (
			@pTipoCorreo = 2 --Notificar que es necesario realizar la relación de PO-Pedido
			)
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM petrovendor..DEA_Relacion_PR_PO rpo
				INNER JOIN OT_Estimacion est ON est.IdOTEstimacion = @pIdOTEstimacion
					AND est.IdPedido = rpo.IdPedido
				)
		BEGIN
			--Obtencion de URL Procura
			SELECT @urlProcura = ISNULL(URL, '')
			FROM [APP_URLRecursos]
			WHERE Tipo = 'ProcuraDEARelacionPRPO'

			SELECT @asunto = Asunto
				,@mensaje = Cuerpo1
			FROM s_correo
			WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

			SELECT @para = dbo.fn_OT_GetMailUsuariosEstatus(ot.IdOTSolicitud, 0, 6, 13)
				,@NumeroOT = ot.Folio
				,@urlProcura = '<a href="' + @urlProcura + '">Aquí</a>'
				,@pedido = cast(e.IdPedidoGeneral AS VARCHAR)
				,@operadora = pv.RazonSocial
				,@aceptacion = ap.IdAceptacionPedido
				,@contrato = c.NumeroContrato
			FROM OT_Estimacion e
			INNER JOIN OT_Solicitud ot ON ot.IdOTSolicitud = e.IdOTSolicitud
			INNER JOIN SC_SubContrato sc ON sc.IdSubContrato = ot.IdSubContrato
			INNER JOIN CO_Contrato c ON c.IdContrato = sc.IdContrato
			INNER JOIN PV_Subcontratista pv ON pv.IdSubcontratista = sc.IdSubcontratista
			INNER JOIN petrovendor..MM_AceptacionPedido ap ON ap.IdPedido = e.IdPedido
			WHERE e.IdOTEstimacion = @pIdOTEstimacion
				AND isnull(e.Cancelada, 0) = 0

			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se Requiere relación PO-Pedido:' + @pedido
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @operadora)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'Adinco- Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlProcura)
			SET @mensaje = replace(@mensaje, '{accion}', 'Se ha generado una Estimación de Control de Obra, es necesario ingresar a procura para relacionar el pedido con su PO correspondiente')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)

			SELECT @para
				,@asunto
				,@mensaje

			IF isnull(@para, '') <> ''
			BEGIN
				EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
					,@Para = @para
					,@Asunto = @asunto
					,@Mensaje = @mensaje
					,@FechaProgramadaEnvio = @FechaProgramadaEnvio
					,@Enviada = 0
					,@CreadoPor = @pCreadoPor
					,@CCO = ''
					,@Modulo = @Modulo;
			END
		END
	END
END