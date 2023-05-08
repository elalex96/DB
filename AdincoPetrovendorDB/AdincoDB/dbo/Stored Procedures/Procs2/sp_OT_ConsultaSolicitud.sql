-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_OT_ConsultaSolicitud 12

CREATE proc [dbo].[sp_OT_ConsultaSolicitud]
@pIdOTSolicitud int
As
	select 
			sol.IdOTSolicitud,
			sol.IdSubContrato,
			sc.NumeroSubContrato,
			NombreContratista = c.NombreContratista,
			NombreSubContratista  = psc.RazonSocial,
			--NombreActividad = act.NombreActividad,
			sol.IdPresupuesto,
			FolioOT=sol.Folio,
			--sol.IdInstalacion,
			--co.NombreInstalacion,
			sol.FechaInicio,
			sol.FechaFin,
			sol.PlazoEjecucion,
			sol.CreadoPor,
			sol.CreadoEl,
			sol.ModificadoPor,
			sol.ModificadoEl,
			sol.IsActivo,
			sol.IsEliminado,
			Objeto = ISNULL(sol.Objeto,''),
			Estatus = est.Descripcion,
			est.IdOTEstatus,
			PSC.IdSubcontratista,
			sc.IdContratista,
			FechaFinExtendida,
			ProgarmaInicialPorOperador = cast(isnull(case when sol.ProgIniPorProveedor = 1 then 0 else 1 end,0) as bit),
			Moneda = isnull([TipoMonedaCorto],'NO DEFINIDO'),			
			sol.IdCentroCosto,
			CentroCosto = CentroCosto,
			sol.CapturaManual,
			SAPPR = isnull(sol.SAPPR,''),
			sol.IdTerminos,
			t.Documento,
			PermitirAprobarProv = isnull(conf.PermitirAprobarSubcontratista,0),
			Decimales= isnull(conf.Decimales,0)

	from OT_Solicitud sol
	inner join SC_SubContrato sc on sc.idSubContrato = sol.IdSubContrato
	inner join Petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = sol.IdCentroCosto
	inner join CO_Contratista c on c.idContratista = sc.IdContratista
	inner join PV_Subcontratista psc on psc.IdSubcontratista = sc.IdSubcontratista
	INNER JOIN OT_Estatus est ON est.IdOTEstatus = sol.IdOTEstatus
	left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc.idPedido
	LEFT join Petrovendor.dbo.[PV_TipoMoneda] mon on mon.IdMOneda = ped.idMoneda
	--inner join CO_Instalacion co on co.IdInstalacion = sol.IdInstalacion
	
	
	LEFT JOIN OT_Configurador conf on conf.IdContratista = sc.IdContratista and
										conf.IdContrato = sc.IdContrato
	--inner join co_actividadCIEP act on act.idActividad = co.IdActividad
	left join PEtrovendor..TC_TerminosYCondicionesDocV2 t on t.IdTerminosYCondiciones = sol.IdTerminos
	where sol.IdOTSolicitud = @pIdOTSolicitud








