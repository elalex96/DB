------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE view vwOTEstimacion
as

	WITH tOTEstimacion(IdOTEstimacion,IdOTSolicitud,FechaCorteInicio,FechaCorteFin)
	as
	(

		select IdOTEstimacion,IdOTSolicitud,FechaCorteInicio,FechaCorteFin
		from OT_Estimacion
		where isnull(cancelada,0) = 0
		
	)

	select 
			otE.IdOTSolicitud,
			otE.IdOTEstimacion,
			otE.FolioEstimacion,
			ote.Consecutivo,
			FolioOT = ot.Folio,
			FolioSC = sc.NumeroSubContrato	,
			FechaIniCorte = FechaCorteInicio,
					FechaFinCorte = FechaCorteFin,
			Instalacion = isnull(ins.NombreInstalacion,'INDEFINIDA'),
			Actividad = isnull(ACT.NombreActividad,'INDEFINIDA'),
			Presupuesto = pre.Nombre,
			Subcontratista = subc.RazonSocial,
			AreaContractual=ac.NombreAreaContractual,
			AceptaOperador = cont.Representante,
			AceptaSubcontratista = subc.RepresentanteLegal,
			tmp.IdSCMaterial,
			tmp.COncepto,
			tmp.Descripcion,
			tmp.Unidad,
			Cantidad = max(tmp.Cantidad),
			PrecioUnitario = max(tmp.PrecioUnitario),
			Importe = max(tmp.Importe),
			tmp.IdOTSolicitudMaterial,
			Moneda = isnull(mon.TipoMonedaCorto,'NO ESPECIFICADO'),
			mon.IdMoneda
	from OT_Estimacion otE
	inner join OT_Solicitud ot on ot.IdOTSolicitud = otE.IdOTSolicitud and
						isnull(otE.cancelada,0) = 0
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubContrato
	LEFT join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc.IdPedido
	LEFT JOIN Petrovendor.dbo.PV_TipoMoneda mon on mon.idMoneda = isnull(ped.IdMoneda,ot.IdMoneda)
	INNER JOIN PV_Subcontratista subc on subc.IdSubcontratista = sc.IdSubContratista
	left join OT_SolicitudInstalacion OTins on OTins.idOTSolicitud = ot.IdOTSolicitud
	left join CO_Instalacion ins on ins.IdInstalacion = OTins.IdInstalacion
	left join CO_ActividadCIEP act on act.IdActividad = ins.IdActividad
	inner join OT_LineaPresupuesto OTlp on OTlp.IdOTSolicitud = ot.IdOTSolicitud
	inner join CO_LineaPresupuestoMes lp on lp.[IdLineaPresupuestoMes] = OTlp.IdLineaPresupuestoMes
	inner join CO_Presupuesto pre on pre.IdPresupuesto = lp.IdPresupuesto	
	inner join [dbo].[CO_Contratista] cont on cont.IdContratista = sc.IdContratista
	inner join CO_Contrato c on c.IdContrato = sc.IdContrato
	inner join CO_AreaContractual ac on ac.IdAreaContractual = c.IdAreaContractual
	inner join (


				select 
						tmpEst.IdOTEstimacion,
						om.IdOTSolicitud,
						scm.IdSCMaterial,
						scm.COncepto,
						scm.Descripcion,
						Unidad = Unidad,
						Cantidad = sum(spc.Captura),
						PrecioUnitario = scm.PrecioUnitario,
						Importe = isnull(sum(spc.Captura),0) * isnull(scm.PrecioUnitario,0),
						FechaInicioSubcontratista = Min(spc.Fecha),
						FechaFinSubcontratista = Max(spc.Fecha),
						om.IdOTSolicitudMaterial

	
				from [dbo].[OT_SolicitudProgramaCaptura] spc
				inner join OT_SolicitudMaterial om on om.IdOTSolicitudMaterial = spc.IdOTSolicitudMaterial
				inner join SC_Materiales scm on scm.IdSCMaterial = om.IdSCMaterial
				inner join Petrovendor.dbo.[PV_MM_MaterialUnidad] u on u.IdUnidad = scm.IdUnidad	
				INNER JOIN tOTEstimacion tmpEst on tmpEst.IdOTSolicitud = 	om.IdOTSolicitud		
				where 
				VoBoContratista = 1 and
				VoBoSubcontratista = 1 
				and
				(
					convert(varchar,spc.Fecha,112) between	convert(varchar,tmpEst.FechaCorteInicio,112) and 
														convert(varchar,tmpEst.FechaCorteFin,112)
					--Or 
					--(
					--	@pFechaInicioEstimacion is null 
					--	and @pFechaFinEstimacion is null
					--)

				)
				group by tmpEst.IdOTEstimacion,om.IdOTSolicitud,
						scm.IdSCMaterial,
						scm.COncepto,
						scm.Descripcion,
						 Unidad,
						  scm.PrecioUnitario,
						  om.IdOTSolicitudMaterial

	) tmp on tmp.IdOTSolicitud = ot.IdOTSolicitud and
	tmp.IdOTEstimacion = otE.IdOTEstimacion

	group by otE.IdOTSolicitud,
			otE.IdOTEstimacion,
			otE.FolioEstimacion,
			ote.Consecutivo,
			ot.Folio,
			sc.NumeroSubContrato	,
			FechaCorteInicio,
			FechaCorteFin,
			ins.NombreInstalacion,
			ACT.NombreActividad,
			pre.Nombre,
			subc.RazonSocial,
			ac.NombreAreaContractual,
			cont.Representante,
			subc.RepresentanteLegal,
			tmp.IdSCMaterial,
			tmp.COncepto,
			tmp.Descripcion,
			tmp.Unidad,
			--tmp.Cantidad,
			--tmp.PrecioUnitario,
			--tmp.Importe,
			tmp.IdOTSolicitudMaterial,
			mon.TipoMonedaCorto,
			mon.IdMoneda




