IF OBJECT_ID('[dbo].[p_OT_CorreoProgramacion_Flujo]', 'P') IS NOT NULL
	DROP PROC [dbo].p_OT_CorreoProgramacion_Flujo
GO

/*
pIdOTEstatus  
100 aprobacion de volumenes por proveedor 
101 aprobacion de volumenes por operador
102 bitacora por operador
103 bitacora por proveedor
*/
-- p_OT_CorreoProgramacion_Flujo 6,2,'',11
CREATE PROC [dbo].[p_OT_CorreoProgramacion_Flujo] @pIdOTSolicitud INT
	,@pCreadoPor INT
	,@pError VARCHAR(250) OUT
	,@pIdOTEstatus INT -- 100 modificacion de volumenes por operador, --101 modificacion de volumenes por operador,--102 Semana Cerrada por Operador,--103 abrir semana,104 Captura PR
AS
BEGIN
	DECLARE @para VARCHAR(max) = ''
		,@asunto VARCHAR(250)
		,@mensaje VARCHAR(MAX)
		,@Modulo VARCHAR(100) = 'Control de Obra'
		,@NumeroOT VARCHAR(20)
		,@IdNotificacion INT
		,@nombreOperadorContratista VARCHAR(100)
		,@nombreContratista VARCHAR(100)
		,@nombreOperadorSubcontratista VARCHAR(100)
		,@nombreSubcontratista VARCHAR(100)
		,@emailContratista VARCHAR(max) = ''
		,@emailSubcontratista VARCHAR(max) = ''
		,@urlAdinco VARCHAR(300)
		,@urlAdincoProg VARCHAR(300)
		,@urlPetrovendor VARCHAR(300)
		,@urlPetrovendorProg VARCHAR(300)
		,@urlProcura VARCHAR(300)
		,@fechacambioProg DATETIME
		,@idSubcontrato INT
		,@aprobadoresOT VARCHAR(500) = ''
		,@emailPara VARCHAR(max) = ''
		,@progInicialproveedor BIT = 0
		,@tarea VARCHAR(300)
		,@FechaProgramadaEnvio DATETIME
		,@urlAdincoTask VARCHAR(150) = '<a href="https://adinco.mx/2/OrdenTrabajo/ConsultaOTSolicitud.aspx" >Aquí</a>'
		,@urlpetrovendorTask VARCHAR(150) = '<a href="https://petrovendor.com.mx/02Proveedores/ConsultaOTSolicitudProv.aspx" >Aquí</a>'
		,@contrato VARCHAR(50)

	SELECT
		---@emailContratista = usuC.Usuario,
		@emailSubcontratista = usuS.Correo + ';' + @emailSubcontratista
		,@NumeroOT = sol.Folio
		,@nombreSubcontratista = upper(subC.RazonSocial)
		,@nombreContratista = upper(con.NombreContratista)
		,@nombreOperadorSubcontratista = upper(subC.RazonSocial)
		,-- usuS.Nombre,
		@nombreOperadorContratista = usuC.Nombre
		,@idSubcontrato = sol.IdSubcontrato
		,@progInicialproveedor = sol.ProgIniPorProveedor
		,@contrato = c.NumeroContrato
	FROM dbo.OT_Solicitud sol
	INNER JOIN dbo.SC_SubContrato sc ON sc.IdSubContrato = SOL.IdSubContrato
	INNER JOIN AP_Usuario usuC ON usuC.UsuarioID = sol.CreadoPor
		AND usuC.IsActivo = 1
	INNER JOIN CO_Contratista con ON con.IdContratista = sc.IdContratista
	INNER JOIN dbo.PV_Subcontratista subC ON subC.IdSubcontratista = sc.IdSubContratista
	INNER JOIN Petrovendor.DBO.S_Proveedor prov ON prov.RFC COLLATE Latin1_General_CI_AS = subC.RFC COLLATE Latin1_General_CI_AS
	INNER JOIN Petrovendor.DBO.S_usuarioproveedor uprov ON uprov.IdProveedor = prov.IdProveedor
	INNER JOIN Petrovendor.DBO.S_Usuario usuS ON usuS.Idusuario = uprov.Idusuario
		AND usuS.Activo = 1
	INNER JOIN CO_Contrato c ON c.IdContrato = sc.IdContrato
	WHERE IdOTSolicitud = @pIdOTSolicitud

	SET @urlAdinco = @urlAdincoTask -- '<a href="http://adinco.mx/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
	SET @urlAdincoProg = @urlAdincoTask --'<a href="http://adinco.mx/2/OrdenTrabajo/CapturaProgramaOT.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
	SET @urlPetrovendor = @urlpetrovendorTask --'<a href="http://petrovendor.com.mx/02Proveedores/RegistrarOTSolicitudProv.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
	SET @urlPetrovendorProg = @urlpetrovendorTask --'<a href="http://petrovendor.com.mx/02Proveedores/CapturaProgramaOT.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
	SET @urlProcura = '<a href="http://procura.adinco.mx/02Proveedores/ActualizarSCOTConvenio.aspx?id=' + cast(@idSubcontrato AS VARCHAR) + '&id2=' + cast(@pIdOTSolicitud AS VARCHAR) + '" >Aquí</a>'

	-- Estatus: Enviada a Aprobador interno
	IF @pIdOTEstatus IN (
			11
			,3
			) -- Enviar a aprobador interno
	BEGIN
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 2, 2) --Aprobación interna OT

		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailPara
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere aprobación por Manager'
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdinco)
		SET @mensaje = replace(@mensaje, '{accion}', 'Una nueva OT ha sido registrada, es necesario que revises  la información y procedas a la aprobación o rechazo')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	-- Estatus: Enviada a Subcontratista
	IF @pIdOTEstatus = 2
	BEGIN
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @tarea = CASE 
				WHEN @progInicialproveedor = 1
					THEN 'Es necesario capturar la volumetría para la OT que le ha sido asignada'
				WHEN @progInicialproveedor = 0
					THEN 'Es necesario aprobar/rechazar la volumetría de la OT asignada'
				END
		SET @para = @emailSubcontratista
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + CASE 
				WHEN @progInicialproveedor = 1
					THEN 'Se requiere capturar volumetría'
				WHEN @progInicialproveedor = 0
					THEN 'Se requiere aprobar/rechazar la volumetría de la OT asignada'
				END
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlPetrovendor)
		SET @mensaje = replace(@mensaje, '{accion}', @tarea)
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	-- Estatus: Modificada por Operador
	IF @pIdOTEstatus = 4
	BEGIN
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @tarea = 'La operadora ha realizado cambios en la volumetría para la OT, es necesario revisar para Aprobar/Rechazar'
		SET @para = @emailSubcontratista
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere revisar cambios realizados por la operadora'
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlPetrovendor)
		SET @mensaje = replace(@mensaje, '{accion}', @tarea)
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	-- Estatus: Aceptada subContratista u operadora
	IF (
			@pIdOTEstatus IN (
				5
				,6
				) /*******Aceptada subContratista****/
			)
	BEGIN
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailSubcontratista
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'OT Aprobada'
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlPetrovendorProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido aprobada y ya es posible que se inicien los trabajos por parte del proveedor. ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		--Enviar a proveedor
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @para
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;

		--Enviar a subcontratista
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 2, 3) --Aprobación interna OT

		SELECT @emailPara = @emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 3) --Creadores de OT

		SELECT @emailPara = @emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 4, 3) --Creadores de Estimaciones

		--Enviar a Operadora
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'OT Aprobada'
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido aprobada y ya es posible que se inicien los trabajos por parte del proveedor. ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @emailPara
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;

		/*****Si la OT no tiene PR Solicitar captura de PR al requisitor*****/
		IF EXISTS (
				SELECT 1
				FROM OT_Solicitud
				WHERE IdOTSolicitud = @pIdOTSolicitud
					AND rtrim(isnull(SAPPR, '')) = ''
				)
		BEGIN
			SET @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 9)

			SELECT @asunto = isnull(Asunto, '')
				,@mensaje = Cuerpo1
			FROM s_correo
			WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere captura de PR en OT'
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoTask)
			SET @mensaje = replace(@mensaje, '{accion}', 'Es necesario que se realice la captura del número de PR de SAP en la OT asignada ')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
			SET @FechaProgramadaEnvio = getdate();

			EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
				,@Para = @emailPara
				,@Asunto = @asunto
				,@Mensaje = @mensaje
				,@FechaProgramadaEnvio = @FechaProgramadaEnvio
				,@Enviada = 0
				,@CreadoPor = @pCreadoPor
				,@CCO = ''
				,@Modulo = @Modulo;
		END
	END

	-- Estatus: Propuesta subcontratisat
	IF (@pIdOTEstatus IN (3))
	BEGIN
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		--Enviar a subcontratista
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 2, 2) --Aprobación interna OT

		--Enviar a Operadora
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere revisar cambios realizador por el proveedor'
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'El proveedor ha capturado volumetría inicial, es necesario revisar ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @emailPara
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;
	END

	-- Estatus: Rechazada subContratista u operadora
	IF (
			@pIdOTEstatus IN (
				7
				,8
				) /*******Aceptada subContratista****/
			)
	BEGIN
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		--OBTENER LOS APROBADORES CON FUNCION
		--select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2)--Aprobación interna OT
		--select @emailPara =@emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1)--Creadores de OT
		SET @para = @emailSubcontratista
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'OT Rechazada'
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdinco)
		SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido rechazada. ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		--Enviar a proveedor
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @para
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;

		--Enviar a subcontratista
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 2, 4) --Aprobación interna OT

		SELECT @emailPara = @emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 4) --Creadores de OT

		--Enviar a Operadora
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT)
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido rechazada ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @emailPara
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;
	END

	-- Estatus: Cerrada Manualmente
	IF (@pIdOTEstatus IN (12))
	BEGIN
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailSubcontratista + ';'
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'OT Cerrada'
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlPetrovendorProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido cerrada por la operadora, ya no es posible realizar modificaciones  ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		--Enviar a proveedor
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @para
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;

		--Enviar a subcontratista
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 2, 10) --Aprobación interna OT

		SELECT @emailPara = @emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 10) --Creadores de OT        
			--Enviar a Operadora

		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT)
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido cerrada por la operadora, ya no es posible realizar modificaciones ')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

		EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
			,@Para = @emailPara
			,@Asunto = @asunto
			,@Mensaje = @mensaje
			,@FechaProgramadaEnvio = @FechaProgramadaEnvio
			,@Enviada = 0
			,@CreadoPor = @pCreadoPor
			,@CCO = ''
			,@Modulo = @Modulo;
	END

	-- Estatus: Requiere Convenio
	IF @pIdOTEstatus IN (9) -- Requiere Convenio
	BEGIN
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 6, 5) --Aprobación interna OT

		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailPara
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere aprobación de convenio'
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlProcura)
		SET @mensaje = replace(@mensaje, '{accion}', 'Una OT ha sido registrada pero excede la capacidad del Contrato. Es necesareio revisar en procura')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	/*******VOBO DE VOLUMENES POR PROVEEDOR****/
	IF (@pIdOTEstatus IN (100))
	BEGIN
		--OBTENER LOS VALIDADORES CON FUNCION
		SELECT @emailcontratista = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 3, 6) --Aprobación interna OT

		SELECT TOP 1 @fechacambioProg = pc.Fecha
		FROM OT_Solicitud ot
		INNER JOIN OT_SolicitudMaterial otm ON otm.IdOTSolicitud = ot.IdOTSolicitud
		INNER JOIN OT_SolicitudProgramaCaptura pc ON pc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
		WHERE ot.IdOTSolicitud = @pIdOTSolicitud
		ORDER BY FechaVoBoSubcontratista DESC

		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailcontratista
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'El proveedor registró avance'
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', @nombreSubcontratista)
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'El proveedor ha realizado modificaciones en el avance para el día ' + convert(VARCHAR, @fechacambioProg, 103))
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	/*******VOBO DE VOLUMENES POR OPERADOR****/
	IF (@pIdOTEstatus IN (101))
	BEGIN
		SELECT TOP 1 @fechacambioProg = pc.Fecha
		FROM OT_Solicitud ot
		INNER JOIN OT_SolicitudMaterial otm ON otm.IdOTSolicitud = ot.IdOTSolicitud
		INNER JOIN OT_SolicitudProgramaCaptura pc ON pc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
		WHERE ot.IdOTSolicitud = @pIdOTSolicitud
		ORDER BY FechaVoBocontratista DESC

		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailsubcontratista
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'La operadora realizó una revisión de avance'
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreSubcontratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlPetrovendorProg)
		SET @mensaje = replace(@mensaje, '{accion}', 'La operadora ha realizado cambios en el avance para el día ' + convert(VARCHAR, @fechacambioprog, 103))
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	/*******SEMANA CERRADA****/
	IF (@pIdOTEstatus IN (102))
	BEGIN
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @urlAdinco = '<a href="http://adinco.mx/2/OrdenTrabajo/GenerarEstimacionOT.aspx?id1=' + cast(@pIdOTSolicitud AS VARCHAR) + '" >Aquí</a>'

		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @emailcontratista = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 4, 7) --Aprobación interna OT

		SET @para = @emailContratista
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Cierre de Semana registrado'
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO - Control de obra')
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdinco)
		SET @mensaje = replace(@mensaje, '{accion}', 'Se ha cerrado una semana de trabajo, ya es posible generar la estimación')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	/*******ABRIR SEMANA****/
	IF (@pIdOTEstatus IN (103))
	BEGIN
		--OBTENER LOS APROBADORES CON FUNCION
		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		SET @para = @emailSubcontratista
		SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Reapertura de semana realizada'
		SET @asunto = replace(@asunto, '{contrato}', @contrato)
		SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
		SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
		SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
		SET @mensaje = replace(@mensaje, '{url_ot}', @urlPetrovendor)
		SET @mensaje = replace(@mensaje, '{accion}', 'Se ha Reabierto una semana de trabajo por la operadora')
		SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
		SET @FechaProgramadaEnvio = getdate();

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

	IF (@pIdOTEstatus IN (104))
	BEGIN
		/*****Si la OT no tiene PR Solicitar captura de PR al requisitor*****/
		IF EXISTS (
				SELECT 1
				FROM OT_Solicitud
				WHERE IdOTSolicitud = @pIdOTSolicitud
					AND rtrim(isnull(SAPPR, '')) = ''
				)
		BEGIN
			SET @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 9)

			SELECT @asunto = isnull(Asunto, '')
				,@mensaje = Cuerpo1
			FROM s_correo
			WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se requiere captura de PR en OT'
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', '')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdincoTask)
			SET @mensaje = replace(@mensaje, '{accion}', 'Es necesario que se realice la captura del número de PR de SAP en la OT asignada ')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)
			SET @FechaProgramadaEnvio = getdate();

			EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
				,@Para = @emailPara
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