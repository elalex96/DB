
-- p_OT_EstimacionLineasPresupuesto 27,0,''
create proc p_OT_EstimacionLineasPresupuesto
@pIdOTEstimacion int,
@pIdSolicitudPedido int,
@pError varchar(250) out
as


begin try
	
	declare @IdInstalacionDefault int

	

	select  @IdInstalacionDefault = max(sl.IdInstalacion)
	from Adinco..OT_Estimacion e
	inner join Adinco..OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud
	inner join petrovendor..MM_SolicitudPedidoDetalleLineaPresupuesto sl on sl.IdCentroCosto = ot.IdCentroCosto
	where e.IdOTEstimacion = @pIdOTEstimacion

	--1. Se obtienen las lineas pre-seleccionadas desde la creación de la OT
	select otl.IdOTSolicitud,
		IdOTEstimacion = @pIdOTEstimacion,
		otl.IdLineaPresupuestoMes,
		lpm.IdPresupuesto,
		lpm.IdActividad,
		lpm.IdSubactividad,
		lpm.IdTareaPetrolera,
		IdInstalacion = isnull(lpm.IdInstalacion,max(oi.IdInstalacion)),
		lpm.IdServicio,
		AnioPre = datepart(yy,lpm.AC_PRESUP_MES),
		MesPre= datepart(mm,lpm.AC_PRESUP_MES),
		scm.IdMaterialContratista,
		AnioServ = datepart(yy,max(op.FECHA)),
		MesServ = datepart(mm,max(op.FECHA)),
		ot.IdCentroCosto
	into #tmpLineas1
	from Adinco..OT_Estimacion e
	INNER JOIN Adinco..OT_EstimacionDetalle ed on ed.IdOTEstimacion = e.IdOTEstimacion
	inner join Adinco..OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud
	
	inner join Adinco..[OT_LineaPresupuesto] otl on otl.IdOTSolicitud = ot.IdOTSolicitud
	inner join Adinco..CO_LineaPresupuestoMes lpm on lpm.IdLineaPresupuestoMes = otl.IdLineaPresupuestoMes
	inner join Adinco..OT_SolicitudMaterial sm on sm.IdOTSolicitudMaterial = ed.IdOTSolicitudMaterial AND
												SM.IdOTSolicitud = e.IdOTSolicitud
	inner join Adinco..SC_Materiales scm on scm.IdSCMaterial = sm.IdSCMaterial
	inner join Adinco..OT_SolicitudProgramaCaptura op on op.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial and
														convert(varchar,op.Fecha,112) between convert(varchar,e.FechaCorteInicio,112) and convert(varchar,e.FechaCorteFin,112)
	left join Adinco..OT_SolicitudInstalacion oi on oi.IdOTSolicitud = e.IdOTSolicitud
	where e.IdOTEstimacion = @pIdOTEstimacion
	group by otl.IdOTSolicitud,
		otl.IdLineaPresupuestoMes,
		lpm.IdPresupuesto,
		lpm.IdActividad,
		lpm.IdSubactividad,
		lpm.IdTareaPetrolera,
		lpm.IdInstalacion,
		lpm.AC_PRESUP_MES,
		lpm.AC_PRESUP_MES,
		scm.IdMaterialContratista,
		ot.IdCentroCosto,
		lpm.IdServicio

	
	--2. Se obtienen las lineas que se pueden reasignar en base a la fecha de la OT
	select lpm.IdLineaPresupuestoMes,
		lpm.IdPresupuesto,
		lpm.IdActividad,
		lpm.IdSubactividad,
		lpm.IdTareaPetrolera,
		lpm.IdInstalacion,
		lpm.IdServicio,
		AnioPre = datepart(yy,lpm.AC_PRESUP_MES),
		MesPre= datepart(mm,lpm.AC_PRESUP_MES)	
	into #tmpLineas2
	from Adinco..CO_LineaPresupuestoMes lpm
	inner join #tmpLineas1 tmp on tmp.IdPresupuesto = lpm.IdPresupuesto and
								tmp.IdActividad = lpm.IdActividad and
								tmp.IdSubactividad = lpm.IdSubactividad and
								tmp.IdTareaPetrolera = lpm.IdTareaPetrolera 
	group by lpm.IdLineaPresupuestoMes,
		lpm.IdPresupuesto,
		lpm.IdActividad,
		lpm.IdSubactividad,
		lpm.IdTareaPetrolera,
		lpm.IdInstalacion,
		lpm.IdServicio,
		lpm.AC_PRESUP_MES

	select * from #tmpLineas1
	select * from #tmpLineas2

	  --3. Insertar líneas de presupuestos
	  INSERT INTO MM_SolicitudPedidoDetalleLineaPresupuesto
        (
            IdSolicitudPedidoDetalle,
            IdCentroCosto,
            IdInstalacion,
            IdLineaPresupuesto
        )
		select spd.IdSolicitudPedidoDetalle,
		tmp1.IdCentroCosto,
		max(isnull(tmp1.IdInstalacion,@IdInstalacionDefault)),
		isnull(tmp2.IdLineaPresupuestoMes,tmp1.IdLineaPresupuestoMes)
		from   MM_SolicitudPedidoDetalle spd
		inner join #tmpLineas1 tmp1 on tmp1.IdOTEstimacion = @pIdOTEstimacion
		left join #tmpLineas2 tmp2 on tmp2.IdActividad = tmp1.IdActividad and										
										tmp2.IdPresupuesto = tmp1.IdPresupuesto and
										tmp2.IdServicio = tmp1.IdServicio and
										tmp2.IdSubactividad = tmp1.IdSubactividad and
										tmp2.IdTareaPetrolera = tmp1.IdTareaPetrolera and
										tmp2.AnioPre = tmp1.AnioServ and
										tmp2.MesPre = tmp1.MesServ
		where spd.IdSolicitudPedido = @pIdSolicitudPedido
		group by spd.IdSolicitudPedidoDetalle,
		tmp1.IdCentroCosto,
		--tmp1.IdInstalacion,
		tmp2.IdLineaPresupuestoMes,
		isnull(tmp2.IdLineaPresupuestoMes,tmp1.IdLineaPresupuestoMes)
end try
begin catch
	
	select @pError = error_message()

end catch