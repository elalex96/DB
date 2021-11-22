
-- p_CO_SAP_ImportBitacoraNotificacion 355,0
CREATE  proc [dbo].[p_CO_SAP_ImportBitacoraNotificacion]
@pId int,
@pIdNotificacion int out
as


	DECLARE @CorreoTB AS TABLE
		(			
			Email NVARCHAR(MAX)
		);
	
	--S_Notificacion
	declare 
		
		@para varchar(500)='',
	
		@asunto varchar(250),
		@mensaje varchar(max)='',
		@de varchar(100) = '',
		@mensajeDetalle  varchar(max)='',
		@fechaUltimoEnvio datetime,
		@idContratista int


	select @para = @para + isnull(Correo,'') + ';',
		@asunto = ISNULL(html.Asunto,'') + convert(varchar,Inicio,107) + ' ' +convert(varchar,Inicio,108),
		@de = cs.CuentaRegistro,
		@mensaje= html.HTML,
		@fechaUltimoEnvio = imap.FechaUltimoEnvio,
		@idContratista = imap.IdContratista
	from [dbo].[CO_SAP_ImportBitacora] b
	inner join CO_Contrato c on c.IdContrato = b.IdContrato
	inner join [dbo].[CO_SAP_CorreosRespuesta] res on res.IdContratista = c.IdContratista
	inner join [S_CorreoServidor] cs on cs.IdCorreoServidor = 1
	inner join TA_Correo html on html.Descripcion = 'NotificacionTareaMurphyImportacionSAP'
	inner join [CO_SAP_IMAPConfiguracion] imap on imap.IdContratista = c.IdContratista
	where ISNULL(b.NotificacionEnviada,0) = 0

	-- Si la fecha de ultimo envío tiene menos de un día de diferencia, entonces salir del proceso
	IF(	
		DATEDIFF(day,ISNULL(@fechaUltimoEnvio,'20210101'),GETDATE()) < 1
		
	)
	BEGIN
		RETURN
	END

	

	if len(isnull(@para,'')) = 0
		return

	/*ELIMINAR CORREOS DUPLICADOS*/
	INSERT INTO @CorreoTB
	(
		Email
	)
	SELECT splitdata
	from [dbo].[fnSplitString](@para, ';')

	/*AGRUPAR CORREOS PARA EVITAR DUPLICADOS*/
	SELECT @para = STUFF((
         SELECT ';' + Email
            FROM @CorreoTB
			GROUP BY Email
            FOR XML PATH('')
         ), 1, 1, '')


	select @mensaje = replace(@mensaje,'{0}',
	'<B>RESULT OF IMPORTATION SAP FILES</B><BR><BR>'+
	'CONTRACT:' + '<b>'+c.NumeroContrato+'</b><br>'+
	'START:' +'<b>'+ convert(varchar,Inicio,107) + ' ' +convert(varchar,Inicio,108)+'</b><br>'+
	'END:' +'<b>'+ convert(varchar,Fin,107) + ' ' +convert(varchar,Fin,108)+'</b><br><br>'+
	case when b.TieneError = 1 then '<p style="color:red">It ended with errors</p><br><br>' else '' end)
	from [dbo].[CO_SAP_ImportBitacora] b
	inner join CO_Contrato c on c.IdContrato = b.IdContrato
	inner join [dbo].[CO_SAP_CorreosRespuesta] res on res.IdContratista = c.IdContratista
	where isnull(b.NotificacionEnviada,0) = 0

	set @mensajeDetalle = '<table class="table"><tr><td><b>Step</b></td><td><b>Result</b></td></tr>'

	select @mensajeDetalle = @mensajeDetalle +'<tr><td>'+bd.NombreArchivo+'</td>'+
							  '<td>'+case when bd.TieneError = 1 then '<p style="color:red">'+bd.Error+'</p><br><br>'
										 else '<p style="color:gren">OK</p><br><br>'
									End+'</td></tr>'
	from [dbo].[CO_SAP_ImportBitacora] b
	inner join CO_SAP_ImportBitacora_Detalle bd on bd.IdIMportBitacora = b.Id
	where isnull(b.NotificacionEnviada,0) = 0

	set @mensajeDetalle = @mensajeDetalle + '</table>'

	set @mensaje = replace(@mensaje,'{1}',@mensajeDetalle)


	/***************Obtener vendors sin TAXID**************************/

	select v.VendorIDSAP,
		v.VendorName
	into #tmpVendorBlank
	from [CO_SAP_ImportBitacora] ib
	inner join CO_SAPVendor  v on v.IdContrato = ib.IdContrato and
							rtrim(isnull(v.TaxID,'')) = ''
	where Id = @pId 
	group by v.VendorIDSAP,
		v.VendorName


	if exists(	
		select 1
		from #tmpVendorBlank
	)
	begin
	
		set @mensajeDetalle = '<p style="color:red;">There are Vendors without TAXID</p><br>'
		set @mensajeDetalle = @mensajeDetalle + '<table class="table"><tr><td><b>VendorID</b></td><td><b>Vendor Name</b></td></tr>'

		select @mensajeDetalle = @mensajeDetalle +'<tr><td>'+ cast(VendorIDSAP as varchar)+'</td>'+
							  '<td>'+VendorName+'</td></tr>'
		from #tmpVendorBlank

		set @mensajeDetalle = @mensajeDetalle + '</table>'

		set @mensaje = replace(@mensaje,'{2}',@mensajeDetalle)


	end
	Else
	Begin
		set @mensaje = replace(@mensaje,'{2}','')
	End

	select @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
	from S_Notificacion

	if isnull(@mensaje,'') <> ''
	begin

		insert into S_Notificacion(
			IdNotificacion,Para,Asunto,Mensaje,FechaProgramadaEnvio,Enviada,FechaEnvio,
			CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De,EN_MsjEnviado
		)
		select @pIdNotificacion ,@para,@asunto,isnull(@mensaje,''),dateadd(HOUR,-3,getdate()),0,null,
		1,getdate(),null,null,@de,null

	end


	--Marcar todo como enviado
	
	UPDATE [CO_SAP_ImportBitacora]
	SET NotificacionEnviada = 1
	WHERE ISNULL(NotificacionEnviada,0) = 0

	UPDATE [CO_SAP_IMAPConfiguracion]
	SET FechaUltimoEnvio = GETDATE()
	WHERE IdContratista = @idContratista
	