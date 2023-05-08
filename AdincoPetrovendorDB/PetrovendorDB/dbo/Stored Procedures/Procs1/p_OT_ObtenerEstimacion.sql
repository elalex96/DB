CREATE Proc p_OT_ObtenerEstimacion
@pIdOTSolicitud int,
@pIdOTEstimacion int,
@pFechaInicioEstimacion datetime=null,
@pFechaFinEstimacion datetime=null
as

	declare @consecutivo int,
			@fechaIniCorte DateTime


	select 
							om.IdOTSolicitud,
							scm.IdSCMaterial,
							scm.COncepto,
							scm.Descripcion,
							Unidad = Unidad,
							Cantidad = sum(spc.Captura),
							PrecioUnitario = scm.PrecioUnitario,
							Importe = isnull(sum(spc.Captura),0) * isnull(scm.PrecioUnitario,0),
							FechaInicioSubcontratista = Min(spc.Fecha),
							FechaFinSubcontratista = Max(spc.Fecha)	,
							om.IdOTSolicitudMaterial
	into #tmpInfoPrograma
	from [dbo].[OT_SolicitudProgramaCaptura] spc
	inner join OT_SolicitudMaterial om on om.IdOTSolicitudMaterial = spc.IdOTSolicitudMaterial
	inner join SC_Materiales scm on scm.IdSCMaterial = om.IdSCMaterial
	inner join Petrovendor.dbo.[PV_MM_MaterialUnidad] u on u.IdUnidad = scm.IdUnidad
	where om.IdOTSolicitud = @pIdOTSolicitud and
	VoBoContratista = 1 and
	VoBoSubcontratista = 1 and
			(
				convert(varchar,spc.Fecha,112) between	convert(varchar,@pFechaInicioEstimacion,112) and 
													convert(varchar,@pFechaFinEstimacion,112)
				Or 
				(
					@pFechaInicioEstimacion is null 
					and @pFechaFinEstimacion is null
				)

			)
			group by om.IdOTSolicitud,
					scm.IdSCMaterial,
					scm.COncepto,
					scm.Descripcion,
				 Unidad,
				  scm.PrecioUnitario,
				  om.IdOTSolicitudMaterial


	if(
		isnull(@pIdOTEstimacion,0) > 0
	)
	begin
		select *
		from vwOTEstimacion
		where IdOTEstimacion = @pIdOTEstimacion
	end
	Else
	begin 

		select @consecutivo = isnull(max(Consecutivo),0) + 1
		from OT_Estimacion
		where IdOTSolicitud = @pIdOTSolicitud

		select @fechaIniCorte = dateadd(dd,1,max(FechaCorteFin))
		from OT_Estimacion
		where IdOTSolicitud = @pIdOTSolicitud and
		isnull(cancelada,0) = 0

		if(@fechaIniCorte is null)
		begin

			select @fechaIniCorte = min(Fecha)
			from [dbo].[OT_SolicitudProgramaCaptura] spc
			inner join [dbo].OT_SolicitudMaterial sp on sp.IdOTSolicitudMaterial = spc.IdOTSolicitudMaterial
			where sp.IdOTSolicitud = @pIdOTSolicitud

		end
		
		select 
			ot.IdOTSolicitud,
			IdOTEstimacion = 0,
			FolioEstimacion = ot.Folio +'-E' + cast(@consecutivo as varchar),
			Consecutivo = 0,
			FolioOT = ot.Folio,
			FolioSC = sc.NumeroSubContrato	,
			FechaIniCorte = @fechaIniCorte,
			FechaFinCorte = @fechaIniCorte,
			Instalacion = max(isnull(ins.NombreInstalacion,'INDEFINIDA')),
			Actividad = isnull(ACT.NombreActividad,'INDEFINIDA'),
			Presupuesto = pre.Nombre,
			Subcontratista = subc.RazonSocial,
			AreaContractual=cont.NombreContratista,
			AceptaOperador = cont.Representante,
			AceptaSubcontratista = subc.RepresentanteLegal,
			tmp.IdSCMaterial,
			tmp.COncepto,
			tmp.Descripcion,
			tmp.Unidad,
			tmp.Cantidad,
			tmp.PrecioUnitario,
			tmp.Importe,
			tmp.IdOTSolicitudMaterial,
			Moneda = isnull(mon.TipoMonedaCorto,''),
			IdMoneda = ot.IdMOneda			
			from OT_Solicitud ot
			inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubContrato
			left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc.IdPedido
			left JOIN Petrovendor.dbo.PV_TipoMoneda mon on mon.idMoneda = ot.IdMOneda
			INNER JOIN PV_Subcontratista subc on subc.IdSubcontratista = sc.IdSubContratista
			left join OT_SolicitudInstalacion OTins on OTins.idOTSolicitud = ot.IdOTSolicitud
			left join CO_Instalacion ins on ins.IdInstalacion = OTins.IdInstalacion
			left join CO_ActividadCIEP act on act.IdActividad = ins.IdActividad
			inner join OT_LineaPresupuesto OTlp on OTlp.IdOTSolicitud = ot.IdOTSolicitud
			inner join CO_LineaPresupuestoMes lp on lp.[IdLineaPresupuestoMes] = OTlp.IdLineaPresupuestoMes
			inner join CO_Presupuesto pre on pre.IdPresupuesto = lp.IdPresupuesto	
			inner join [dbo].[CO_Contratista] cont on cont.IdContratista = sc.IdContratista
			inner join #tmpInfoPrograma tmp on tmp.IdOTSolicitud = ot.IdOTSolicitud
			where ot.IdOTSolicitud = @pIdOTSolicitud
			group by ot.IdOTSolicitud,			
			 ot.Folio ,			
			sc.NumeroSubContrato	,			
			--ins.NombreInstalacion,
			ACT.NombreActividad,
			pre.Nombre,
			subc.RazonSocial,
			cont.NombreContratista,
			cont.Representante,
			subc.RepresentanteLegal,
			tmp.IdSCMaterial,
			tmp.COncepto,
			tmp.Descripcion,
			tmp.Unidad,
			tmp.Cantidad,
			tmp.PrecioUnitario,
			tmp.Importe,
			tmp.IdOTSolicitudMaterial,
			mon.TipoMonedaCorto,
			ot.IdMOneda			


	End