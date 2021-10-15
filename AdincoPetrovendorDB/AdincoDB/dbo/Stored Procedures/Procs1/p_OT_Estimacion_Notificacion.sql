-- p_OT_Estimacion_Notificacion 510,1,10
CREATE proc p_OT_Estimacion_Notificacion
@pIdOTEstimacion int,
@pTipoCorreo int, 
/*
	1. Estimacion recien generada
	2. Relacion PO
*/
@pCreadoPor int
as

	DECLARE 
			@para VARCHAR(500)='',
			@asunto VARCHAR(250),
			@mensaje VARCHAR(MAX),
			@De VARCHAR(100)= 'procura@adinco.mx',
			@urlProcura varchar(300),
			@urlPetroExt varchar(300),
			@NumeroOT VARCHAR(20),
				@nombreContratista varchar(100),
				@IdNotificacion int,
				@FechaProgramadaEnvio datetime= getdate(),
				@permitirAceptacionAut bit = 0,
				@pedido varchar(20),
				@aceptacion varchar(20),
				@urlProcuraRec varchar(300)='',
				@proveedor varchar(250)='',
				@urlCN varchar(300) = '',
				@operadora varchar(500) = '',
				@IdProveedor int,
				@contrato varchar(50),
				@IdNacionalidadProveedor INT

	--Obtencion de URL Reclasificación
	SELECT @urlProcuraRec ='<a href="'+ISNULL(URL,'')+'" >Aquí</a>' 
	FROM [APP_URLRecursos]
	WHERE Tipo = 'ProcuraReclasificacionLineasPresupuesto'

	--Obtencion de URL CN
	SELECT @urlCN =ISNULL(URL,'')
	FROM [APP_URLRecursos]
	WHERE Tipo = 'PetrovendorProveedorCartaCN'

	--Obtencion de URL Procura
	SELECT @urlProcura =ISNULL(URL,'')
	FROM [APP_URLRecursos]
	WHERE Tipo = 'ProcuraAceptacionSinParam'

	--Obtencion de URL Procura
	SELECT @urlPetroExt =ISNULL(URL,'')
	FROM [APP_URLRecursos]
	WHERE Tipo = 'PetrovendorInvoicesExtranjeros'


	--Obtener los usuarios a excluir para las notificaciones
	SELECT un.UsuarioId,un.TipoNotificacionId,un.Desactivar 
	into #tmpNotificacionesExcluir
	FROM [AP_UsuarioNotificaciones] un
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = un.UsuarioId 
	inner join OT_Estimacion e on e.IdOTEstimacion = @pIdOTEstimacion
	inner join OT_Solicitud ot on ot.IdCentroCosto = ucc.IdCentroCosto and
									ot.IdOTSolicitud = e.IdOTEstimacion
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato and
									sc.IdContrato = un.ContratoId
	where un.Desactivar = 1 



	IF(
		@pTipoCorreo IN(1)/*******Avisar al aprobador que se ha generado una Estimacion****/
	)
	BEGIN

		select @asunto = Asunto,
			@mensaje =Cuerpo1 
		from s_correo
		where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'


		select @para = u.Usuario,
			@NumeroOT = ot.Folio,
			@nombreContratista = con.NombreContratista,
			@urlProcura = '<a href="'+@urlProcura+'?ped='+cast(e.IdPedido as varchar)+'&pedgral='+cast(e.IdPedidoGeneral as varchar)+'&ori=pedido'+'" >Aquí</a>',
			@permitirAceptacionAut = isnull(cf.permitirAceptacionAut,0),
			@pedido = cast(e.IdPedidoGeneral as varchar),
			@aceptacion = cast(ap.IdAceptacionPedido as varchar),
			@proveedor = prov.RazonSocial,
			@operadora = prov2.RazonSocial,
			@IdProveedor = prov.IdProveedor,
			@contrato = c.NumeroContrato,
			@IdNacionalidadProveedor = prov.IdNacionalidad
		from OT_Estimacion e
		inner join petrovendor..MM_Pedido ped on ped.IdPedido= e.IdPedido
		inner join petrovendor..MM_SolicitudPedido sp on sp.IdSolicitudPedido = ped.IdSolicitudPedido
		--inner join petrovendor..S_Usuario utista on utista.IdUsuario =  sp.IdUsuarioSolicitante
		inner join AP_usuario u on u.UsuarioId = e.CreadoPor
		inner join OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud
		inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato
		inner join CO_Contratista con on con.IdContratista = sc.IdContratista
		inner join OT_Configurador cf on cf.IdContrato = sc.IdContrato
		inner join CO_Contrato c on c.IdContrato = sc.IdContrato
		LEFT JOIN petrovendor..MM_AceptacionPedido  ap on ap.IdPedido = e.IdPedido
		left join petrovendor..S_Proveedor prov on prov.IdProveedor = ped.IdSubcontratista
		left join petrovendor..S_Proveedor prov2 on prov2.IdProveedor = ped.IdProveedorCompras
		where e.IdOTEstimacion = @pIdOTEstimacion	 and
		isnull(e.Cancelada,0) = 0	and
		u.UsuarioId not in (
			select usuarioid
			from #tmpNotificacionesExcluir
			where TipoNotificacionId = 11--Nueva estimacion registrada
		)

		if @permitirAceptacionAut = 0
		begin
		
			set @asunto = replace(@asunto,'{contrato}',@contrato) 
			set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se requiere aceptación para Pedido:'+@pedido
			set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
			set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
			set @mensaje = replace(@mensaje,'{nombre_emisor}','Adinco- Control de Obra')
			set @mensaje = replace(@mensaje,'{url_ot}',@urlProcura)
			set @mensaje = replace(@mensaje,'{accion}','Se ha generado una Estimación de Control de Obra, es necesario ingresar a procura para realizar la aceptación del servicio')
			set @mensaje = replace(@mensaje,'{contrato}',@contrato)
		
			if isnull(@para,'') <> ''
			begin
	
					exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De	

			end		
		 
		 end

		if @permitirAceptacionAut = 1
		begin
		
			set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se Requiere Reclasificación para Aceptación:'+@aceptacion
			set @asunto = replace(@asunto,'{contrato}',@contrato) 
			set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
			set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
			set @mensaje = replace(@mensaje,'{nombre_emisor}','Adinco- Control de Obra')
			set @mensaje = replace(@mensaje,'{url_ot}',@urlProcuraRec)
			set @mensaje = replace(@mensaje,'{contrato}',@contrato)
			set @mensaje = replace(@mensaje,'{accion}','Se ha generado una Aceptación de Control de Obra, es necesario ingresar a procura para confirmar la reclasificación de los servicios')
			

			if isnull(@para,'') <> ''
			begin
	
					exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De	

			end	

			/*Notificacion para Carta CN o Comprobante extranjero dependiendo de nacionalidad*/
			IF(@IdNacionalidadProveedor = 1)
			BEGIN
				select @asunto = Asunto,
					@mensaje =HTML 
				from petrovendor..TA_Correo
				where idcorreo = 83

				set @mensaje = replace(@mensaje,'##URL_TAREA##',@urlCN)
			END
			ELSE
			BEGIN
				select @asunto = Asunto,
					@mensaje =HTML 
				from petrovendor..TA_Correo
				where Descripcion = 'SolicitudComprobanteExtranjeroAceptacion'

				set @mensaje = replace(@mensaje,'##URL_TAREA##',@urlPetroExt)
			END
			


			
			set @mensaje = replace(@mensaje,'##NOMBRE_USUARIO##',@proveedor)
			set @mensaje = replace(@mensaje,'##NO_OPERACION##',@aceptacion)
			set @mensaje = replace(@mensaje,'##NO_PEDIDO##',@pedido)
			set @mensaje = replace(@mensaje,'##OPERADORA##',@operadora)
			set @para = ''

			select @para = correo + ';'
			from petrovendor..S_UsuarioProveedor up
			inner join petrovendor..S_Usuario u on u.IdUsuario = up.IdUsuario and
										u.Activo = 1
			where IdProveedor = @IdProveedor



			if isnull(@para,'') <> ''
			begin
	
					exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De	

			end	
			

		 end


		
    END

	if(
		@pTipoCorreo = 2 --Notificar que es necesario realizar la relación de PO-Pedido
	)
	begin

		if not exists (		
			select 1
			from petrovendor..DEA_Relacion_PR_PO rpo
			inner join OT_Estimacion est on est.IdOTEstimacion = @pIdOTEstimacion and
											est.IdPedido = rpo.IdPedido
		)
		begin

			--Obtencion de URL Procura
			SELECT @urlProcura =ISNULL(URL,'')
			FROM [APP_URLRecursos]
			WHERE Tipo = 'ProcuraDEARelacionPRPO'

			select @asunto = Asunto,
				@mensaje =Cuerpo1 
			from s_correo
			where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

			select @para = dbo.fn_OT_GetMailUsuariosEstatus(ot.IdOTSolicitud,0,6,13),
				@NumeroOT = ot.Folio,				
				@urlProcura = '<a href="'+@urlProcura+'">Aquí</a>',				
				@pedido = cast(e.IdPedidoGeneral as varchar),
				@operadora = pv.RazonSocial,
				@aceptacion = ap.IdAceptacionPedido,
				@contrato = c.NumeroContrato
			from OT_Estimacion e
			inner join OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud					
			inner join SC_SubContrato sc on sc.IdSubContrato = ot.IdSubContrato
			inner join CO_Contrato c on c.IdContrato = sc.IdContrato
			inner join PV_Subcontratista pv on pv.IdSubcontratista = sc.IdSubcontratista
			inner join petrovendor..MM_AceptacionPedido ap on ap.IdPedido = e.IdPedido
			where e.IdOTEstimacion = @pIdOTEstimacion	 and
			isnull(e.Cancelada,0) = 0	


			set @asunto = replace(@asunto,'{contrato}',@contrato) 
			set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se Requiere relación PO-Pedido:'+@pedido				
			set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
			set @mensaje = replace(@mensaje,'{nombre_receptor}',@operadora)
			set @mensaje = replace(@mensaje,'{nombre_emisor}','Adinco- Control de Obra')
			set @mensaje = replace(@mensaje,'{url_ot}',@urlProcura)
			set @mensaje = replace(@mensaje,'{accion}','Se ha generado una Estimación de Control de Obra, es necesario ingresar a procura para relacionar el pedido con su PO correspondiente')
			set @mensaje = replace(@mensaje,'{contrato}',@contrato)
		

			select @para,@asunto,@mensaje
			if isnull(@para,'') <> ''
			begin
					
					exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De	

			end	


		end

	end

	

