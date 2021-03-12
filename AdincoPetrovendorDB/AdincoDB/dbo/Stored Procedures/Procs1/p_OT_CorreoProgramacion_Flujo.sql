/*
pIdOTEstatus  
100 aprobacion de volumenes por proveedor 
101 aprobacion de volumenes por operador
102 bitacora por operador
103 bitacora por proveedor
*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC p_OT_CorreoProgramacion_Flujo
@pIdOTSolicitud INT,
@pCreadoPor INT,
@pError VARCHAR(250) OUT,
@pIdOTEstatus int -- 100 modificacion de volumenes por operador, --101 modificacion de volumenes por operador,--102 Semana Cerrada por Operador,--103 abrir semana,104 Captura PR
AS
    DECLARE 
            @para VARCHAR(1000)='',
            @asunto VARCHAR(250),
            @mensaje VARCHAR(MAX),
            @De VARCHAR(100)= 'procura@adinco.mx',
            @NumeroOT VARCHAR(20),
            @IdNotificacion INT,
            @nombreOperadorContratista varchar(100),
            @nombreContratista varchar(100),
            @nombreOperadorSubcontratista varchar(100),
            @nombreSubcontratista varchar(100),
            @emailContratista varchar(1000)='',
            @emailSubcontratista varchar(1000)='',
            @urlAdinco varchar(300),
            @urlAdincoProg varchar(300),
            @urlPetrovendor varchar(300),           
            @urlPetrovendorProg varchar(300),
            @urlProcura varchar(300),
            @fechacambioProg datetime   ,
            @idSubcontrato int      ,
            @aprobadoresOT varchar(500) = '',
            @emailPara  varchar(1000) = '',
            @progInicialproveedor bit=0 ,
            @tarea varchar(300),
            @FechaProgramadaEnvio DAteTime,
            @urlAdincoTask varchar(150) = '<a href="https://adinco.mx/2/OrdenTrabajo/ConsultaOTSolicitud.aspx" >Aquí</a>',
            @urlpetrovendorTask varchar(150)='<a href="https://petrovendor.com.mx/02Proveedores/ConsultaOTSolicitudProv.aspx" >Aquí</a>',
			@contrato varchar(50)
    SELECT              
                ---@emailContratista = usuC.Usuario,
                @emailSubcontratista = usuS.Correo+ ';'+@emailSubcontratista,
                @NumeroOT = sol.Folio,              
                @nombreSubcontratista = upper(subC.RazonSocial),
                @nombreContratista =upper(con.NombreContratista),
                @nombreOperadorSubcontratista =upper(subC.RazonSocial),-- usuS.Nombre,
                @nombreOperadorContratista = usuC.Nombre,
                @idSubcontrato = sol.IdSubcontrato,
                @progInicialproveedor = sol.ProgIniPorProveedor,
				@contrato = c.NumeroContrato
        FROM dbo.OT_Solicitud sol
        INNER JOIN dbo.SC_SubContrato sc ON sc.IdSubContrato = SOL.IdSubContrato
        inner join AP_Usuario usuC on usuC.UsuarioID = sol.CreadoPor and usuC.IsActivo = 1
        inner join CO_Contratista con on con.IdContratista = sc.IdContratista
        INNER JOIN dbo.PV_Subcontratista subC ON subC.IdSubcontratista = sc.IdSubContratista
        INNER JOIN Petrovendor.DBO.S_Proveedor prov ON prov.RFC COLLATE Latin1_General_CI_AS  = subC.RFC COLLATE Latin1_General_CI_AS       
        inner join Petrovendor.DBO.S_usuarioproveedor uprov on uprov.IdProveedor = prov.IdProveedor
        inner join Petrovendor.DBO.S_Usuario usuS on usuS.Idusuario = uprov.Idusuario and usuS.Activo = 1
		inner join CO_Contrato c on c.IdContrato = sc.IdContrato
        WHERE IdOTSolicitud = @pIdOTSolicitud
    set @urlAdinco =@urlAdincoTask -- '<a href="http://adinco.mx/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
    set @urlAdincoProg = @urlAdincoTask --'<a href="http://adinco.mx/2/OrdenTrabajo/CapturaProgramaOT.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
    set @urlPetrovendor = @urlpetrovendorTask--'<a href="http://petrovendor.com.mx/02Proveedores/RegistrarOTSolicitudProv.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
    set @urlPetrovendorProg = @urlpetrovendorTask--'<a href="http://petrovendor.com.mx/02Proveedores/CapturaProgramaOT.aspx?id='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
    set @urlProcura = '<a href="http://procura.adinco.mx/02Proveedores/ActualizarSCOTConvenio.aspx?id='+cast(@idSubcontrato as varchar)+'&id2='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'

	

    -- Estatus: Enviada a Aprobador interno
    if @pIdOTEstatus IN( 11,3) -- Enviar a aprobador interno
    begin
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2,2)--Aprobación interna OT
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

        
        set @para =@emailPara
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se requiere aprobación por Manager'
		set @asunto = replace(@asunto,'{contrato}',@contrato) 
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdinco)
        set @mensaje = replace(@mensaje,'{accion}','Una nueva OT ha sido registrada, es necesario que revises  la información y procedas a la aprobación o rechazo')
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)

        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    end
    -- Estatus: Enviada a Subcontratista
    if @pIdOTEstatus = 2 
    begin
        --OBTENER LOS APROBADORES CON FUNCION
        
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        
        set @tarea = case when @progInicialproveedor = 1 then 'Es necesario capturar la volumetría para la OT que le ha sido asignada'
                            when @progInicialproveedor = 0 then 'Es necesario aprobar/rechazar la volumetría de la OT asignada'
                    end
        
        set @para =@emailSubcontratista
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 
                    case when @progInicialproveedor = 1 then 'Se requiere capturar volumetría'
                            when @progInicialproveedor = 0 then 'Se requiere aprobar/rechazar la volumetría de la OT asignada'
                    end
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreOperadorSubcontratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlPetrovendor)
        set @mensaje = replace(@mensaje,'{accion}',@tarea)
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De

    end
    -- Estatus: Modificada por Operador
    if @pIdOTEstatus = 4
    begin
        --OBTENER LOS APROBADORES CON FUNCION
        
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        
        set @tarea = 'La operadora ha realizado cambios en la volumetría para la OT, es necesario revisar para Aprobar/Rechazar'
        
        set @para =@emailSubcontratista
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'Se requiere revisar cambios realizados por la operadora'
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlPetrovendor)
        set @mensaje = replace(@mensaje,'{accion}',@tarea)
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De

    end
    -- Estatus: Aceptada subContratista u operadora
    IF(
        @pIdOTEstatus IN( 5,6)/*******Aceptada subContratista****/
    )
    
    BEGIN
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
    
        set @para =@emailSubcontratista
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'OT Aprobada'
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlPetrovendorProg)
        set @mensaje = replace(@mensaje,'{accion}','La OT ha sido aprobada y ya es posible que se inicien los trabajos por parte del proveedor. ')          
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        --Enviar a proveedor
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
        --Enviar a subcontratista
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2,3)--Aprobación interna OT
        select @emailPara =@emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,3)--Creadores de OT
        select @emailPara =@emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,4,3)--Creadores de Estimaciones
        
        --Enviar a Operadora
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		 set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'OT Aprobada'
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoProg)
        set @mensaje = replace(@mensaje,'{accion}','La OT ha sido aprobada y ya es posible que se inicien los trabajos por parte del proveedor. ')          
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De

        /*****Si la OT no tiene PR Solicitar captura de PR al requisitor*****/
        if exists(
            select 1
            from OT_Solicitud 
            where IdOTSolicitud = @pIdOTSolicitud and
            rtrim(isnull(SAPPR,'')) = ''
        )
        begin
            set @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,9)
            
            select @asunto = isnull(Asunto,'') ,
                @mensaje =Cuerpo1 
            from s_correo
            where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

			set @asunto = replace(@asunto,'{contrato}',@contrato)
            set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se requiere captura de PR en OT'
            set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
            set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
            set @mensaje = replace(@mensaje,'{nombre_receptor}','')
            set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoTask)
            set @mensaje = replace(@mensaje,'{accion}','Es necesario que se realice la captura del número de PR de SAP en la OT asignada ')         
			set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
            set @FechaProgramadaEnvio = getdate()
            exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De     
        
        end

    END
    -- Estatus: Propuesta subcontratisat
    IF(
        @pIdOTEstatus IN( 3)
    )
    
    BEGIN
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        
        --Enviar a subcontratista
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2,2)--Aprobación interna OT
        
        --Enviar a Operadora
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'Se requiere revisar cambios realizador por el proveedor'
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoProg)
        set @mensaje = replace(@mensaje,'{accion}','El proveedor ha capturado volumetría inicial, es necesario revisar ')
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    END
    -- Estatus: Rechazada subContratista u operadora
    IF(
        @pIdOTEstatus IN( 7,8)/*******Aceptada subContratista****/
    )
    
    BEGIN
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        --OBTENER LOS APROBADORES CON FUNCION
        --select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2)--Aprobación interna OT
        --select @emailPara =@emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1)--Creadores de OT
        
        set @para =@emailSubcontratista
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'OT Rechazada'
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdinco)
        set @mensaje = replace(@mensaje,'{accion}','La OT ha sido rechazada. ')         
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        --Enviar a proveedor
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
        --Enviar a subcontratista
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2,4)--Aprobación interna OT
        select @emailPara =@emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,4)--Creadores de OT
        
        --Enviar a Operadora
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoProg)
        set @mensaje = replace(@mensaje,'{accion}','La OT ha sido rechazada ')          
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    END
    -- Estatus: Cerrada Manualmente
    IF(
        @pIdOTEstatus IN( 12)
    )
    
    BEGIN
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
    
        set @para =@emailSubcontratista + ';'
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'OT Cerrada'
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlPetrovendorProg)
        set @mensaje = replace(@mensaje,'{accion}','La OT ha sido cerrada por la operadora, ya no es posible realizar modificaciones  ')            
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        --Enviar a proveedor
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
        --Enviar a subcontratista
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,2,10)--Aprobación interna OT
        select @emailPara =@emailPara + ';' + dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,10)--Creadores de OT        
        --Enviar a Operadora
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}','')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoProg)
        set @mensaje = replace(@mensaje,'{accion}','La OT ha sido cerrada por la operadora, ya no es posible realizar modificaciones ')         
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    END
    -- Estatus: Requiere Convenio
    if @pIdOTEstatus IN( 9) -- Requiere Convenio
    begin
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailPara =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,6,5)--Aprobación interna OT
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

        
        set @para =@emailPara
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'Se requiere aprobación de convenio'
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlProcura)
        set @mensaje = replace(@mensaje,'{accion}','Una OT ha sido registrada pero excede la capacidad del Contrato. Es necesareio revisar en procura')
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)

        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    end
    

    /*******VOBO DE VOLUMENES POR PROVEEDOR****/
    IF(
        @pIdOTEstatus IN( 100)
    )
    
    BEGIN
        --OBTENER LOS VALIDADORES CON FUNCION
        select @emailcontratista =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,3,6)--Aprobación interna OT

        
        select top 1  @fechacambioProg = pc.Fecha
        from OT_Solicitud ot 
        inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud
        inner join OT_SolicitudProgramaCaptura pc on pc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
        where ot.IdOTSolicitud = @pIdOTSolicitud
        order by FechaVoBoSubcontratista desc
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        
        set @para =@emailcontratista
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'El proveedor registró avance'
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}',@nombreSubcontratista)
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoProg)
        set @mensaje = replace(@mensaje,'{accion}','El proveedor ha realizado modificaciones en el avance para el día ' + convert(varchar,@fechacambioProg,103))
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    
    END
    /*******VOBO DE VOLUMENES POR OPERADOR****/
    IF(
        @pIdOTEstatus IN( 101)
    )
    
    BEGIN
        
        select top 1  @fechacambioProg = pc.Fecha
        from OT_Solicitud ot 
        inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud
        inner join OT_SolicitudProgramaCaptura pc on pc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
        where ot.IdOTSolicitud = @pIdOTSolicitud
        order by FechaVoBocontratista desc
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        
        set @para =@emailsubcontratista
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'La operadora realizó una revisión de avance'
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreSubcontratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{url_ot}',@urlPetrovendorProg)
        set @mensaje = replace(@mensaje,'{accion}','La oepradora ha realizado cambios en el avance para el día ' + convert(varchar,@fechacambioprog,103))
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
        
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    
    END
        
        /*******SEMANA CERRADA****/
        IF(
        @pIdOTEstatus IN( 102)
    )
    
    BEGIN
        
    
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'
        set @urlAdinco = '<a href="http://adinco.mx/2/OrdenTrabajo/GenerarEstimacionOT.aspx?id1='+cast(@pIdOTSolicitud as varchar)+'" >Aquí</a>'
    
        --OBTENER LOS APROBADORES CON FUNCION
        select @emailcontratista =dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,4,7)--Aprobación interna OT
        
        
        set @para =@emailContratista
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'Cierre de Semana registrado'

        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO - Control de obra' )
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{url_ot}',@urlAdinco)
        set @mensaje = replace(@mensaje,'{accion}','Se ha cerrado una semana de trabajo, ya es posible generar la estimación')
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    
    END 

        /*******ABRIR SEMANA****/
        IF(
        @pIdOTEstatus IN( 103)
    )
    
    BEGIN
        
        --OBTENER LOS APROBADORES CON FUNCION
        
        select @asunto = Asunto,
            @mensaje =Cuerpo1 
        from s_correo
        where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'  
        
        
        set @para =@emailSubcontratista
        set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT)+'Reapertura de semana realizada'
		set @asunto = replace(@asunto,'{contrato}',@contrato)
        set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
        set @mensaje = replace(@mensaje,'{nombre_receptor}',@nombreContratista)
        set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra')
        set @mensaje = replace(@mensaje,'{url_ot}',@urlPetrovendor)
        set @mensaje = replace(@mensaje,'{accion}','Se ha Reabierto una semana de trabajo por la operadora')
		set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        set @FechaProgramadaEnvio = getdate()
        exec p_s_notificacion_ins 0,@para,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De
    
    END 
    IF(
        @pIdOTEstatus IN( 104)
    )
    begin
    /*****Si la OT no tiene PR Solicitar captura de PR al requisitor*****/
        if exists(
            select 1
            from OT_Solicitud 
            where IdOTSolicitud = @pIdOTSolicitud and
            rtrim(isnull(SAPPR,'')) = ''
        )
        begin
            set @emailPara = dbo.fn_OT_GetMailUsuariosEstatus(@pIdOTSolicitud,@pIdOTEstatus,1,9)
            
            select @asunto = isnull(Asunto,''),
                @mensaje =Cuerpo1 
            from s_correo
            where descripcion = 'CONTROL_DE_OBRA_NOTIFICACION'

            set @asunto = replace(@asunto,'{folio_ot}',@NumeroOT) + 'Se requiere captura de PR en OT'
			set @asunto = replace(@asunto,'{contrato}',@contrato) 
            set @mensaje = replace(@mensaje,'{folio_ot}',@NumeroOT)
            set @mensaje = replace(@mensaje,'{nombre_emisor}','ADINCO-Control de Obra' )
            set @mensaje = replace(@mensaje,'{nombre_receptor}','')
            set @mensaje = replace(@mensaje,'{url_ot}',@urlAdincoTask)
            set @mensaje = replace(@mensaje,'{accion}','Es necesario que se realice la captura del número de PR de SAP en la OT asignada ')         
			set @mensaje = replace(@mensaje,'{contrato}',@contrato)
        
            set @FechaProgramadaEnvio = getdate()
            exec p_s_notificacion_ins 0,@emailPara,@asunto,@mensaje,@FechaProgramadaEnvio,0,@pCreadoPor,@De     
        
        end
    end
GO