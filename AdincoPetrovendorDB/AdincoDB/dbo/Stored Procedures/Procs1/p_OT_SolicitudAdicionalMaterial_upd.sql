create proc p_OT_SolicitudAdicionalMaterial_upd
@IdSCMaterial int,
@IdOTSolicitudAdicional int,
@IdOTSolicitudMaterial int,
@Cantidad float,
@FechaProgramaInicio DateTime,
@FechaProgramaFin DateTIME,
@UsuarioId int
as

	declare @Id int
	IF NOT EXISTS (
		select 1
		from OT_SolicitudAdicionalMaterial
		where IdOTSolicitudAdicional = @IdOTSolicitudAdicional and
		IdSCMaterial = @IdSCMaterial
	)
	begin

		select @Id = isnull(max(id),0) + 1
		from OT_SolicitudAdicionalMaterial

		insert into OT_SolicitudAdicionalMaterial(
			Id,					IdOTSolicitudAdicional,			IdSCMaterial,		Cantidad,		FechaProgramaInicio,
			FechaProgramaFin,	CreadoEl,						CreadoPor
		)
		values(@Id,				@IdOTSolicitudAdicional,			@IdSCMaterial,		@Cantidad,		@FechaProgramaInicio,
		@FechaProgramaFin,		getdate(),						@UsuarioId) 

	end
	else
	begin

		update OT_SolicitudAdicionalMaterial
		SET Cantidad = @Cantidad,
			FechaProgramaInicio = @FechaProgramaInicio,
			FechaProgramaFin = @FechaProgramaFin,
			ModificadoEl = GETDATE(),
			ModificadoPor = @UsuarioId
		where IdSCMaterial = @IdSCMaterial and
		IdOTSolicitudAdicional = @IdOTSolicitudAdicional
	end

	
