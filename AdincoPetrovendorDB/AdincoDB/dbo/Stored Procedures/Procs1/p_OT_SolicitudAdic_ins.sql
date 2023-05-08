create proc p_OT_SolicitudAdic_ins
@pIdOTSolicitudAdicional int out,
@pIdOTSolicitud int,
@pUsuarioId int,
@pMotivo varchar(300),
@pError varchar(250) out
as

	set @pError = ''
	if exists (
		select 1
		from OT_SolicitudAdicional
		where IdOTSolicitud = @pIdOTSolicitud and
		IdEstatusAdicional IN (1,2)
	)
	BEGIN
		set @pError = 'Ya existe una solicitud pendiente de seguimiento para la OT'
		return
	END	

	if not exists(
		select 1
		from dbo.fn_OT_GetSemanas(@pIdOTSolicitud)
		where cerrada = 0
	)
	BEGIN
		set @pError = 'No hay semanas abiertas para la OT, imposible continuar'
		return
	END	

	BEGIN TRY
		begin tran

		select @pIdOTSolicitudAdicional = isnull(max(IdOTSolicitudAdicional),0) + 1
		from OT_SolicitudAdicional

		insert into OT_SolicitudAdicional(
			IdOTSolicitudAdicional,IdOTSolicitud,IdEstatusAdicional,Motivo,CreadoEl,CreadoPor
		)
		select @pIdOTSolicitudAdicional,@pIdOTSolicitud,1,@pMotivo,getdate(),@pUsuarioId

		 insert into [dbo].[OT_SolicitudAdicionalBitacora](		
					IdOTSolicitudAdicional,IdOTEstatusAdicional,Descripcion,CreadoEl,CreadoPor
			)
			select @pIdOTSolicitudAdicional,1,@pMotivo,getdate(),@pUsuarioId

		commit tran

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET @pError = ERROR_MESSAGE()
	END CATCH