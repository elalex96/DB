
CREATE proc [dbo].[sp_OT_EliminarSolicitudMaterial]
@pIdOTSolicitudMaterial int
as

	declare @IdOTSolicitud int

	select @IdOTSolicitud = IdOTSolicitud
	from OT_SolicitudMaterial 
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

	begin tran

	delete [OT_SolicitudMaterialBitacora]
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[OT_SolicitudPrograma]
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete OT_SolicitudMaterial
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	update OT_Solicitud
	set FechaInicio = (select min (FechaProgramaInicio) from OT_SolicitudMaterial s1 where  s1.IdOTSolicitud = @IdOTSolicitud ),
	FechaFin = (select max (FechaProgramaFin) from OT_SolicitudMaterial s1 where  s1.IdOTSolicitud = @IdOTSolicitud )
	where IdOTSolicitud = @IdOTSolicitud

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	/***************Actualizar plazo ejecución**************/
	update OT_Solicitud
	set PlazoEjecucion = isnull(Datediff(dd,FechaInicio,FechaFin),0)
	where IdOTSolicitud = @IdOTSolicitud

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	commit tran

	fin:

