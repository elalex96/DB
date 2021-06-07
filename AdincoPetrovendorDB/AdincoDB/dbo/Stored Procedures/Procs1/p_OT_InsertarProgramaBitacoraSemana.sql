----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[p_OT_InsertarProgramaBitacoraSemana]
@pIdOTProgramaBitacoraSemana	int,
@pIdOTSolicitud	int,
@pSemanaID	varchar(21),
@pFechaRegistro	datetime,
@pComentarios	varchar(500),
@pCreadoPor	varchar(150),
@pTipoUsuario tinyint --1.Operador 2.Subcontratista
as
begin
	DECLARE @TablaCorreo TABLE  
    (  
        Html NVARCHAR(MAX),  
        Asunto NVARCHAR(MAX),  
        CuentaRegistro NVARCHAR(500),  
        Contrasena NVARCHAR(500),  
        SMTP NVARCHAR(500),  
        Puerto INT,  
        BBC NVARCHAR(500)  
    )

	declare @CuentaRegistro nvarchar(500),
			@Contrasena nvarchar(500),
			@Smtp nvarchar(500),
			@Puerto int,
			@Bbc nvarchar(500),
			@NombreOperadora nvarchar(500),
			@NombreProveedor nvarchar(500),
			@Year int,
			@Folio nvarchar(300),
			@UsuarioAdincoID nvarchar(300),
			@pUsuarioPetrovendorID nvarchar(300),
			@URL nvarchar(500),
			@Asunto nvarchar(max),
			@Html nvarchar(max),
			@CorreoProveedor nvarchar(max),
			@IdNotificacion bigint,
			@Dominio nvarchar(500) = 'https://petrovendor.com.mx/' 
	
	
	declare @EnvioCorreo table (RazonSocial nvarchar(max), Folio nvarchar(500), Correo nvarchar(500), IdNotificacion bigint)

	select @pIdOTProgramaBitacoraSemana = isnull(max(IdOTProgramaBitacoraSemana),0) + 1
	from 	[OT_ProgramaBitacoraSemana]

	if(@pTipousuario = 1)
	begin
		--Solo se envia el correo cuando es un comentario de la operadora
		select @UsuarioAdincoID = UsuarioID
		from AP_Usuario
		where Usuario = @pCreadoPor	

		select @IdNotificacion = max(IdNotificacion) from Adinco.dbo.S_Notificacion  

		insert into @EnvioCorreo(RazonSocial, Folio, Correo, IdNotificacion)
		select contra.RazonSocial, ot.Folio, u.Correo, row_number() over(order by contra.RazonSocial) + @Idnotificacion
		from Ot_solicitud ot 
			inner join sc_subcontrato sub 
				on ot.IdSubContrato = sub.IdSubContrato
			inner join pv_subcontratista contra 
				on contra.IdSubcontratista = sub.IdSubcontratista
			left join petrovendor.dbo.S_usuarioProveedor up
				on up.IdProveedor = contra.IdPetrovendor
			left join petrovendor.dbo.s_usuario u
				on u.IdUsuario = up.IdUsuario
				and u.activo = 1
			where IdOTSolicitud = @pIdOTSolicitud and u.correo is not null
			group by contra.RazonSocial, ot.Folio, u.Correo

		SELECT top 1 @Folio = folio, @NombreProveedor = RazonSocial from @EnvioCorreo
		select @year = year(getdate())

		select @Url = concat( @dominio,'02Proveedores/CapturaProgramaOT.aspx?id=', @pIdOTSolicitud)

		select @NombreOperadora = Nombre from ap_usuario where Usuario = @pCreadoPor

		select @CuentaRegistro = CuentaRegistro, @Contrasena = Contrasena, @Smtp = SMTP, @Puerto = Puerto, @Bbc = BBC  
		from  S_CorreoServidor
		where IdCorreoServidor = (select max(IdCorreoServidor) from S_CorreoServidor)

		INSERT INTO @TablaCorreo  
		(  
			Html,  
			Asunto,
			CuentaRegistro,
			Contrasena,
			Smtp,
			Puerto,
			Bbc
		)  
		SELECT Cuerpo1, Asunto, @CuentaRegistro, @Contrasena, @Smtp, @Puerto, @Bbc
		FROM s_correo 
		where descripcion ='CONTROL_DE_OBRA_NOTIFICACION_BITACORA'

		select @Asunto = REPLACE(Asunto, '{folio_ot}', LTRIM(@Folio)),  
			   @Html = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Html , 
									 '{nombre_emisor}', @NombreOperadora),  
									 '{folio_ot}', @folio), 
									 '{nombre_receptor}', @NombreProveedor),
									 '{year}', @Year),
									 '{comentario_operadora}', @pComentarios),
									 '{url_ot}', @url)
		FROM  @TablaCorreo
		
		


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
		SELECT correo.IdNotificacion,  
			   correo.Correo,  
			   @Asunto,  
			   @Html,  
			   dateadd(minute, 1 ,GETDATE()),  
			   0,  
			   null,  
			   3,  
			   GETDATE(),  
			   NULL,  
			   NULL,  
			   @CuentaRegistro  
		FROM @EnvioCorreo correo  
	end
	

	if(@pTipousuario = 2)
	begin
		select @pUsuarioPetrovendorID = IdUsuario
		from Petrovendor.dbo.S_Usuario
		where Correo = @pCreadoPor
	end
	
	

	insert into	[dbo].[OT_ProgramaBitacoraSemana](
		IdOTProgramaBitacoraSemana,		IdOTSolicitud,		SemanaID,				FechaRegistro,
		Comentarios,					CreadoPor,			UsuarioPetrovendorID,	
		UsuarioAdincoID,				TipoUsuario
	)
	values(
		@pIdOTProgramaBitacoraSemana,		@pIdOTSolicitud,		@pSemanaID,		getdate(),
		@pComentarios,						@pCreadoPor,			@pUsuarioPetrovendorID,
		@UsuarioAdincoID,								@pTipousuario
	)
end

