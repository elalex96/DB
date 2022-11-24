
-- sp_IN_AL_ProgCorreoAutReserva 1,1,1,1
CREATE Proc [dbo].[sp_IN_AL_ProgCorreoAutReserva]
@IdAlmacen int,
@IdDocumento int,
@pIdOperacion int,
@pIdFlujoTarea int,
@pCreadoPor int
as


	select *
	from s_usuario

	declare @cuerpoCorreo varchar(max),
		@asunto varchar(300),
		@nomTipoOperacion varchar(250),
		
		@NSecuenciaFlujoT int,
		@cuerpoCorreoOrig  varchar(max),
		@destinatario varchar(250),
		@nombreAprobador varchar(250),
		@IdUsuarioAprobadorTarea int,
		@descripcionFlujoTarea varchar(250),
		@urlAuthority varchar(500) = '',
		@urlaceptar varchar(500) = '',
		@urlrechzar varchar(500) = '',
		@urltarea varchar(500) = '',
		@IdNotificacion int,
		@correoEnvio varchar(500)

	select @urlAuthority = isnull(DominioProcura,'')
	from IN_AL_VariablesSistema



	 SELECT HTML,Asunto,CuentaRegistro, Contrasena, SMTP, Puerto,BBC
	 into #tmpConfigCorreo
	 FROM TA_Correo AS C
	 INNER JOIN TA_CorreoServidor AS S ON S.IdServidor=C.IdServidor
	 WHERE IdCorreo = 1 --Asignar Tarea 	 
	 

	 select @cuerpoCorreoOrig = HTML,
		@asunto = Asunto,
		@nomTipoOperacion = NombreOperacion,
		@correoEnvio = CuentaRegistro
	 from #tmpConfigCorreo
	 inner join TA_Operacion op on op.IdOperacion = @pIdOperacion
	 inner join [TA_TipoOperacion] tipoOp on tipoOp.IdTipoOperacion = op.IdTipoOperacion

	 /*******Dar formato al correo********/
	 SET @asunto = REPLACE(@asunto,'##TIPO_OPERACION##',RTRIM(isnull(@nomTipoOperacion,'')))
	 SET @asunto = REPLACE(@asunto,'##NO##',RTRIM(cast(isnull(@IdDocumento,'') as varchar)))
	

	
	SELECT a.IdUsuario,
		a.NoSecuencia,
		u.Correo,
		u.Nombre,
		DescripcionFlujo = ft.Descripcion
	into #tmpTA_Aprobador
	FROM TA_Aprobador  a
	INNER JOIN S_Usuario u   on u.IdUsuario = a.IdUsuario
	inner join TA_FlujoTarea ft on ft.idFlujoTarea = A.IdFlujoTarea 
	WHERE a.IdFlujoTarea = @pIdFlujoTarea
	ORDER BY  NoSecuencia ASC	


	select @NSecuenciaFlujoT = min(NoSecuencia)
	from #tmpTA_Aprobador



	while @NSecuenciaFlujoT is not null
	begin
			set @cuerpoCorreo = @cuerpoCorreoOrig		

			/*********Dar formato al correo*************/
			select @IdUsuarioAprobadorTarea = IdUsuario,
				@destinatario = Correo,
				@nombreAprobador = Nombre,
				@descripcionFlujoTarea = DescripcionFlujo
			from #tmpTA_Aprobador
			where NoSecuencia = @NSecuenciaFlujoT		

			set @urlaceptar = 'http://' + @urlAuthority + '/04Tareas/aprobacion.aspx?num_operacion=' + cast(@pIdOperacion as varchar) + '&response=2&num_tarea=&num_user=' + cast(@IdUsuarioAprobadorTarea as varchar)
			set @urlrechzar = 'http://' + @urlAuthority + '/04Tareas/aprobacion.aspx?num_operacion=' + cast(@pIdOperacion as varchar) + '&response=3&num_tarea=&num_user=' + cast(@IdUsuarioAprobadorTarea as varchar)
			set @urltarea =	  'http://' + @urlAuthority + '/02Proveedores/DetalleSolicitudPedido.aspx?solped=' + cast(@pIdOperacion as varchar) + '&num_user=' + cast(@pIdOperacion as varchar)+ '&origin=t&tp_user=' + cast(@IdUsuarioAprobadorTarea as varchar)



			
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##NUMERO_OPERACION##',RTRIM(cast(@IdDocumento as varchar)))
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##TIPO_OPERACION##',RTRIM(@nomTipoOperacion))
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##DESCRIPCION_TAREA##',RTRIM(@descripcionFlujoTarea))
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##NOMBRE_USUARIO##',RTRIM(@nombreAprobador))
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##URL_TAREA_ACEPTAR##',RTRIM(@urlaceptar))
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##URL_TAREA_RECHAZAR##',RTRIM(@urlrechzar))
			set @cuerpoCorreo = replace(@cuerpoCorreo,'##URL_TAREA##',RTRIM(@urltarea))

			--select @cuerpoCorreo,@IdDocumento,@nomTipoOperacion,@descripcionFlujoTarea,@nombreAprobador,@urlaceptar,@urlrechzar,@urltarea


			/*********Insertar Notificación en Servidor de Correo Adinco******************/

			select @IdNotificacion = isnull(max(IdNotificacion),0) + 1
			from Adinco.[dbo].[S_Notificacion]

			insert into Adinco.[dbo].[S_Notificacion](IdNotificacion,Para,Asunto,Mensaje,FechaProgramadaEnvio,Enviada,FechaEnvio,CreadoPor,CreadoEl,ModificadoPor,
			ModificadoEl,De)
			select @IdNotificacion,@destinatario,@asunto,@cuerpoCorreo,getdate(),0,null,1/*ADMIN ADINCO**/,getdate(),null,null,@correoEnvio


			select @NSecuenciaFlujoT = min(NoSecuencia)
			from #tmpTA_Aprobador
			where NoSecuencia > @NSecuenciaFlujoT
	end


