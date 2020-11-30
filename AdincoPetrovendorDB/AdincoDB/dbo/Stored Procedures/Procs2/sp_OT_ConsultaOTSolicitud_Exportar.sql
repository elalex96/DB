-- sp_OT_ConsultaOTSolicitud_Exportar 3,10
CREATE Proc sp_OT_ConsultaOTSolicitud_Exportar
	@pIdContrato		int,
	@pIdUsuario			int
As
begin

	--select * from AP_UsuarioCentroCosto

	select			IdSubContrato,
					IdSCMaterial,
					Cantidad							=			ISNULL(SUM(asignado.cantidad),0)
	into			#tmpCantidad
	from			OT_SolicitudMaterial				asignado
	inner	join	OT_Solicitud						otasignada 
	on				otasignada.IdOTSolicitud			=			asignado.IdOTSolicitud 
	where			otasignada.IsActivo					=			1 
	and				otasignada.IsEliminado				=			0	
	and				otasignada.IdOTEstatus				not in		(7,8) --rechazada
	group by		IdSubContrato,
					IdSCMaterial

	select		sol.IdOTSolicitud,
				sol.Folio,
				sol.FechaInicio,
				sol.FechaFin,
				sc2.Objeto,
				Estatus						=	ote.Descripcion, --join con OT_Estatus
				cc.CentroCosto, -- Petrovendor..CC_CentroCosto
				sc2.NumeroSubContrato,
				sc.Concepto,
				sm.IdOTSolicitud,
				Material					=	sc.Descripcion,
				Unidad,
				
				Cantidad					=	ISNULL(sm.Cantidad,0),
				CantidadDisponible = 
											case	when	ISNULL(sc.Cantidad,0) - ( t1.cantidad ) <	0 then 0
													else	ISNULL(sc.Cantidad,0) - ( t1.cantidad )
											End,
				PrecioUnitario				=	sc.PrecioUnitario,
				Importe						=	cast(isnull(sm.Cantidad,0) * isnull(sc.PrecioUnitario,0) as  money),
				sm.FechaProgramaInicio,
				sm.FechaProgramaFin,
				Moneda						=	isnull(TipoMonedaCorto,'NO DEFINIDO')	,
					SAPPR	
	from		dbo.SC_Materiales sc	
	inner join	petrovendor..MM_Material				mmm		on	mmm.IdMaterial				= sc.IdMaestro
	--left join	petrovendor..MM_Maestro					mae		on	mae.IdMaestro				= mmm.IdMaestro
	inner join	OT_Solicitud							sol		on	sol.IdSubContrato			= sc.IdSubContrato
	inner join	sc_subcontrato							sc2		on	sc2.idsubcontrato			= sol.idsubcontrato
	--left join	Petrovendor.dbo.MM_Pedido				ped		on	ped.IdPedido				= sc2.idPedido
	left join	Petrovendor.dbo.PV_TipoMoneda			moneda	on	moneda.idMoneda				= sol.IdMoneda
	inner join	OT_SolicitudMaterial					sm		on	sol.IdOTSolicitud			= sm.IdOTSolicitud 
																and	sm.IdSCMaterial				= sc.IdSCMaterial
	left join	Petrovendor.dbo.PV_MM_MaterialUnidad	uni		on	uni.IdUnidad				= SC.IdUnidad
	left join	dbo.OT_SolicitudMaterialBitacora		bita	on	bita.IdOTSolicitudMaterial	= sm.IdOTSolicitudMaterial 
																and	bita.IdTipoUsuario			= 1
	inner join	#tmpCantidad							t1		on	t1.IdSubContrato			=			sol.IdSubContrato 
																and	t1.IdSCMaterial				=			sc.IdSCMaterial
	inner join	Petrovendor..CC_CentroCosto				cc		on	cc.IdCentroCosto			=			sol.IdCentroCosto
	inner join	AP_UsuarioCentroCosto					ucc		on	cc.IdCentroCosto			=			ucc.IdCentroCosto
	inner join	OT_Estatus								ote		on	ote.IdOtEstatus				=			sol.IdOTEstatus
	where		ote.IdOTEstatus								not in	(7,8)
	and			
	sc2.IsActivo							=		1
	and			ucc.IdUsuario							=		@pIdUsuario
	and			sc2.IdContrato							=		@pIdContrato
	and			(
					(sm.Cantidad > 0 and sol.IdOTEstatus in (2,3,4,5,6,9,10,11,12))
					OR
					sol.IdOTEstatus  in (1)
				)
	and isnull(sol.IsActivo,0) = 1

	group by	sol.IdOTSolicitud,
				Folio,
				sm.IdOTSolicitud,
				sc.Concepto,
				sc.Descripcion,
				sm.IdServicio,
				sc.IdUnidad,
				sm.Cantidad,
				sc.Cantidad,
				t1.Cantidad,
				sc.PrecioUnitario,
				sm.Cantidad,
				sc.PrecioUnitario,
				sm.FechaProgramaInicio,
				sm.FechaProgramaFin,
				sm.CreadoPor,
				sm.CreadoEl,
				sm.ModificadoPor,
				sm.ModificadoEl, 
				sol.IdSubContrato,
				Unidad,
				bita.IdOTSolicitudMaterial,
				TipoMonedaCorto,
				sol.Folio,
				sol.FechaInicio,
				sol.FechaFin,
				sc2.Objeto,
				ote.Descripcion, --join con OT_Estatus
				sc.Concepto,
				cc.CentroCosto, -- Petrovendor..CC_CentroCosto
				sc2.NumeroSubContrato,
				SAPPR
		order by Folio,sc2.NumeroSubContrato
end





