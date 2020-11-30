
create proc spEnviarXls
(
	@IdUsuario		int,
	@Para			varchar(100),
	@NombreArchivo	varchar(250),
	@Adjunto		image,
	@Msg			varchar(250)
)
as
begin

	declare	@idNotificacion			int,
			@idNotificacionAdjunto	int

	select @idNotificacion			=	isnull(max(IdNotificacion),0)+1			from	S_Notificacion
	select @idNotificacionAdjunto	=	isnull(max(IdNotificacionAdjunto),0)+1	from	S_NotificacionAdjunto

	
	begin try

		begin tran
			insert into S_Notificacion
						(
							IdNotificacion,				Para,				Asunto,				Mensaje,		FechaProgramadaEnvio,			Enviada,						
							FechaEnvio,					CreadoPor,			CreadoEl,			ModificadoPor,	ModificadoEl,					De,						
							EN_MsjEnviado				
						)
				values	(
							@IdNotificacion,			@Para,				@Msg,				@Msg,			GETDATE(),	0,								
							null,						@IdUsuario,			GETDATE(),			null,			GETDATE(),						'procura@adinco.mx',					
							null
						)

			insert into S_NotificacionAdjunto
						(
							IdNotificacionAdjunto,		IdNotificacion,		NombreArchivo,		Adjunto,		CreadoPor,				CreadoEl
						)
				values	(
							@idNotificacionAdjunto,		@idNotificacion,	@NombreArchivo,		@Adjunto,		@IdUsuario,				GETDATE()
						)

						select 1
		commit
	end try
	begin catch
		select  
				ErrorNumber		=	ERROR_NUMBER(),
				ErrorSeverity	=	ERROR_SEVERITY(),
				ErrorState		=	ERROR_STATE(),
				ErrorProcedure	=	ERROR_PROCEDURE(),
				ErrorMessage	=	ERROR_MESSAGE()  
		rollback
	end catch

end

