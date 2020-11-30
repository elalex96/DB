create proc p_OT_SolicitudAdicional_not
@pIdOTSolicitudAdicional int,
@pIdEstatus int,
@pUsuarioId int,
@pError varchar(250) out
as


	declare @urlAdinco varchar(150) = '<a href="https://adinco.mx/2/OrdenTrabajo/SolicitudAdicionalList.aspx" >Aquí</a>',
			@emailPara  varchar(1000) = '',
			@asunto VARCHAR(250),
            @mensaje VARCHAR(MAX),
			@De VARCHAR(100)= 'procura@adinco.mx',
			@FechaProgramadaEnvio DateTime,
			@NumeroOT VARCHAR(20),
			@nombreSubcontratista varchar(100),
			@nombreContratista varchar(100),
			@nombreOperadorContratista varchar(100),
			@nombreOperadorSubcontratista varchar(100),
			@contrato varchar(50),
			@pIdOTSolicitud INT,
			@pIdOTEstatus int,
			@emailSubcontratista  varchar(1000) = '',
			@urlpetrovendorTask varchar(150)='<a href="https://petrovendor.com.mx/02Proveedores/ConsultaOTSolicitudProv.aspx" >Aquí</a>'

         SELECT              
                @emailSubcontratista = usuS.Correo+ ';'+@emailSubcontratista,
				@nombreOperadorSubcontratista =upper(subC.RazonSocial),-- usuS.Nombre,
                @NumeroOT = sol.Folio,              
                @nombreSubcontratista = upper(subC.RazonSocial),
                @nombreContratista =upper(con.NombreContratista),                
                @nombreOperadorContratista = usuC.Nombre,                                
				@contrato = c.NumeroContrato,
				@pIdOTSolicitud = sol.IdOTSolicitud,
				@pIdOTEstatus = sol.IdOTEstatus
        FROM dbo.OT_Solicitud sol
        INNER JOIN dbo.SC_SubContrato sc ON sc.IdSubContrato = SOL.IdSubContrato
        inner join AP_Usuario usuC on usuC.UsuarioID = sol.CreadoPor and usuC.IsActivo = 1
        inner join CO_Contratista con on con.IdContratista = sc.IdContratista
        INNER JOIN dbo.PV_Subcontratista subC ON subC.IdSubcontratista = sc.IdSubContratista
        INNER JOIN Petrovendor.DBO.S_Proveedor prov ON prov.RFC COLLATE Latin1_General_CI_AS  = subC.RFC COLLATE Latin1_General_CI_AS       
        inner join Petrovendor.DBO.S_usuarioproveedor uprov on uprov.IdProveedor = prov.IdProveedor
        inner join Petrovendor.DBO.S_Usuario usuS on usuS.Idusuario = uprov.Idusuario and usuS.Activo = 1
		inner join CO_Contrato c on c.IdContrato = sc.IdContrato
		inner join OT_SolicitudAdicional sa on sa.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
        WHERE sol.IdOTSolicitud = sa.IdOTSolicitud

		Begin try

		begin tran
	  
	   set @FechaProgramadaEnvio = getdate()

        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		--Enviada a Manager
		if(@pIdEstatus =2)
		begin
			 set @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2,15)--Aprobación interna OT


				set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se ha registrado una solicitud de cambios para la OT, se requiere aprobación del Manager'
				set @asunto = replace(@asunto,'{contrato}',@contrato) 
				set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
				set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
				set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
				set @mensaje = replace(@mensaje,'{url_ot}',@urlAdinco)
				set @mensaje = replace(@mensaje,'{accion}','Se ha registrado una solicitud de cambios para la OT, es necesario que revises  la información y procedas a la aprobación o rechazo')
				set @mensaje = replace(@mensaje,'{contrato}',@contrato)

				 
				exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pUsuarioId,@De
		end

		--Aprobada por Manager
		if(@pIdEstatus =3)
		begin
				--Aviso para el requisitor
				set @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,15)--Requisitor


				set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'La solicitud de cambios fue aprobada, la OT se ha actualizado'
				set @asunto = replace(@asunto,'{contrato}',@contrato) 
				set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
				set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
				set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
				set @mensaje = replace(@mensaje,'{url_ot}',@urlAdinco)
				set @mensaje = replace(@mensaje,'{accion}','La solicitud de cambios fue aprobada, la OT se ha actualizado')
				set @mensaje = replace(@mensaje,'{contrato}',@contrato)

				 
				exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pUsuarioId,@De


				--Aviso para el proveedor
				  select @asunto = Asunto,
					@mensaje =Cuerpo1 
				from s_correo
				where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
				set @emailPara =@emailSubcontratista


				set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'La OT ha sido modificada por la Operadora'
				set @asunto = replace(@asunto,'{contrato}',@contrato) 
				set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
				set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreSubcontratista)
				set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
				set @mensaje = replace(@mensaje,'{url_ot}',@urlpetrovendorTask)
				set @mensaje = replace(@mensaje,'{accion}','La OT ha sido modificada por la Operadora')
				set @mensaje = replace(@mensaje,'{contrato}',@contrato)

				 
				exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pUsuarioId,@De
		end
        

		--Rechazada por Manager
		if(@pIdEstatus =4)
		begin
				--Aviso para el requisitor
				set @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,15)--Requisitor


				set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'La solicitud de cambios fue rechazada'
				set @asunto = replace(@asunto,'{contrato}',@contrato) 
				set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
				set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
				set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
				set @mensaje = replace(@mensaje,'{url_ot}',@urlAdinco)
				set @mensaje = replace(@mensaje,'{accion}','La solicitud de cambios fue rechazada')
				set @mensaje = replace(@mensaje,'{contrato}',@contrato)

				 
				exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pUsuarioId,@De


			
		end

		commit tran
		
		end try
		begin catch
			rollback tran
			set @pError = error_message()
		end catch
