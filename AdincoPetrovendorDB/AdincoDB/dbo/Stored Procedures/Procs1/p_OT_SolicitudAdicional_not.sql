IF OBJECT_ID('[dbo].[p_OT_SolicitudAdicional_not]', 'P') IS NOT NULL
	DROP PROC [dbo].[p_OT_SolicitudAdicional_not]
GO

CREATE PROC [dbo].[p_OT_SolicitudAdicional_not] @pIdOTSolicitudAdicional INT
	,@pIdEstatus INT
	,@pUsuarioId INT
	,@pError VARCHAR(250) OUT
AS
BEGIN
	DECLARE @urlAdinco VARCHAR(150) = '<a href="https://adinco.mx/2/OrdenTrabajo/SolicitudAdicionalList.aspx" >Aquí</a>'
		,@emailPara VARCHAR(1000) = ''
		,@asunto VARCHAR(250)
		,@mensaje VARCHAR(MAX)
		,@Modulo VARCHAR(100) = 'Control de Obra'
		,@FechaProgramadaEnvio DATETIME
		,@NumeroOT VARCHAR(20)
		,@nombreSubcontratista VARCHAR(100)
		,@nombreContratista VARCHAR(100)
		,@nombreOperadorContratista VARCHAR(100)
		,@nombreOperadorSubcontratista VARCHAR(100)
		,@contrato VARCHAR(50)
		,@pIdOTSolicitud INT
		,@pIdOTEstatus INT
		,@emailSubcontratista VARCHAR(1000) = ''
		,@urlpetrovendorTask VARCHAR(150) = '<a href="https://petrovendor.com.mx/02Proveedores/ConsultaOTSolicitudProv.aspx" >Aquí</a>'

	SELECT @emailSubcontratista = usuS.Correo + ';' + @emailSubcontratista
		,@nombreOperadorSubcontratista = upper(subC.RazonSocial)
		,-- usuS.Nombre,
		@NumeroOT = sol.Folio
		,@nombreSubcontratista = upper(subC.RazonSocial)
		,@nombreContratista = upper(con.NombreContratista)
		,@nombreOperadorContratista = usuC.Nombre
		,@contrato = c.NumeroContrato
		,@pIdOTSolicitud = sol.IdOTSolicitud
		,@pIdOTEstatus = sol.IdOTEstatus
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
	INNER JOIN OT_SolicitudAdicional sa ON sa.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
	WHERE sol.IdOTSolicitud = sa.IdOTSolicitud

	BEGIN TRY
		BEGIN TRAN

		SET @FechaProgramadaEnvio = getdate()

		SELECT @asunto = Asunto
			,@mensaje = Cuerpo1
		FROM s_correo
		WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		--Enviada a Manager
		IF (@pIdEstatus = 2)
		BEGIN
			SET @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 2, 15) --Aprobación interna OT
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'Se ha registrado una solicitud de cambios para la OT, se requiere aprobación del Manager'
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdinco)
			SET @mensaje = replace(@mensaje, '{accion}', 'Se ha registrado una solicitud de cambios para la OT, es necesario que revises  la información y procedas a la aprobación o rechazo')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)

			EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
				,@Para = @emailPara
				,@Asunto = @asunto
				,@Mensaje = @mensaje
				,@FechaProgramadaEnvio = @FechaProgramadaEnvio
				,@Enviada = 0
				,@CreadoPor = @pUsuarioId
				,@CCO = ''
				,@Modulo = @Modulo;
		END

		--Aprobada por Manager
		IF (@pIdEstatus = 3)
		BEGIN
			--Aviso para el requisitor
			SET @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 15) --Requisitor
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'La solicitud de cambios fue aprobada, la OT se ha actualizado'
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdinco)
			SET @mensaje = replace(@mensaje, '{accion}', 'La solicitud de cambios fue aprobada, la OT se ha actualizado')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)

			EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
				,@Para = @emailPara
				,@Asunto = @asunto
				,@Mensaje = @mensaje
				,@FechaProgramadaEnvio = @FechaProgramadaEnvio
				,@Enviada = 0
				,@CreadoPor = @pUsuarioId
				,@CCO = ''
				,@Modulo = @Modulo;

			--Aviso para el proveedor
			SELECT @asunto = Asunto
				,@mensaje = Cuerpo1
			FROM s_correo
			WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

			SET @emailPara = @emailSubcontratista
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'La OT ha sido modificada por la Operadora'
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreSubcontratista)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlpetrovendorTask)
			SET @mensaje = replace(@mensaje, '{accion}', 'La OT ha sido modificada por la Operadora')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)

			EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
				,@Para = @emailPara
				,@Asunto = @asunto
				,@Mensaje = @mensaje
				,@FechaProgramadaEnvio = @FechaProgramadaEnvio
				,@Enviada = 0
				,@CreadoPor = @pUsuarioId
				,@CCO = ''
				,@Modulo = @Modulo;
		END

		--Rechazada por Manager
		IF (@pIdEstatus = 4)
		BEGIN
			--Aviso para el requisitor
			SET @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud, @pIdOTEstatus, 1, 15) --Requisitor
			SET @asunto = replace(@asunto, '{folio_ot}', @NumeroOT) + 'La solicitud de cambios fue rechazada'
			SET @asunto = replace(@asunto, '{contrato}', @contrato)
			SET @mensaje = replace(@mensaje, '{folio_ot}', @NumeroOT)
			SET @mensaje = replace(@mensaje, '{nombre_receptor}', @nombreContratista)
			SET @mensaje = replace(@mensaje, '{nombre_emisor}', 'ADINCO-Control de Obra')
			SET @mensaje = replace(@mensaje, '{url_ot}', @urlAdinco)
			SET @mensaje = replace(@mensaje, '{accion}', 'La solicitud de cambios fue rechazada')
			SET @mensaje = replace(@mensaje, '{contrato}', @contrato)

			EXEC [dbo].[USP_INS_AP_Notificacion] @Id = 0
				,@Para = @emailPara
				,@Asunto = @asunto
				,@Mensaje = @mensaje
				,@FechaProgramadaEnvio = @FechaProgramadaEnvio
				,@Enviada = 0
				,@CreadoPor = @pUsuarioId
				,@CCO = ''
				,@Modulo = @Modulo;
		END

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN

		SET @pError = error_message()
	END CATCH
END