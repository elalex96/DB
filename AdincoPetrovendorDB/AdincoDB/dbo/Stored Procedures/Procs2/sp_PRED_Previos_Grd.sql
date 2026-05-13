
CREATE proc [dbo].[sp_PRED_Previos_Grd]
as
begin

	select		a.IdAprobacion,
				Aprobado			=	case when a.Aprobado is null then -1 else cast(a.Aprobado as int) end,
				IdPrevio			=	a.IdGenerico
	into		#tmp
	from		Aprobaciones			a
	where		Tabla				=	'PRED_Previos'
	and			Activo				=	1

	select		IdPrevio,
				Aprobado			=	min(Aprobado)
	into		#tmpAprobaciones
	from		#tmp
	group by	IdPrevio

	--select * from #tmpAprobaciones

	select		Aprobados		=	sum(isnull(cast(a.Aprobado as int),0)),
				a.IdGenerico,
				a.Tabla,
				fd.IdFlujo,
				Progreso			=	sum(isnull(cast(a.Aprobado as money),0))/count(cast(fd.IdFlujo as money))*100
	into		#tmpPorcentajes
	from		Aprobaciones		a
	inner join	CAT_FlujosDetalle	fd
	on			a.IdFlujoDetalle	=	fd.IdFlujoDetalle
	where		Tabla				=	'PRED_Previos'
	and			fd.Activo			=	1
	and			a.Activo			=	1
	group by	a.Activo,
				a.IdGenerico,
				a.Tabla,
				fd.IdFlujo

	select		--t1.Aprobado,
				Estatus							=		case	when	t1.Aprobado is	null	then	'Por Enviar'
																when	t1.Aprobado	=	1		then	'Aprobado'
																when	t1.Aprobado	=	-1		then	'Rechazado'
																when	t1.Aprobado	=	0		then	'En Aprobación'
														end,
				pv.IdPrevio,
				pv.IdPredio,
				pv.TabuladorIndaabin,
				pv.Vigencia,
				pv.Gestor,
				pv.JefeCampo,
				pv.Descripcion,
				p.IdPropietario,
				pac.NombrePropietario,
				p.IdMunicipio,
				m.Municipio,
				p.IdEstado,
				e.Estado,
				p.IdAreaContractual,
				ac.NombreAreaContractual,
				t.IdTipoBDT,
				t.TipoBDT,
				p.KilometrosCuadrados,
				p.Nombre,
				pv.IdTipoInstalacion,
				ti.TipoInstalacion,
				Progreso						=	t2.Progreso,
				Tabla
	from		PRED_Previos					pv
	inner join	PRED_Predios					p
	on			pv.IdPredio						=	p.IdPredio
	inner join	CO_PropietariosAreaContractual	pac
	on			p.IdPropietario					=	pac.IdPropietario
	inner join	CAT_Municipios					m
	on			p.IdMunicipio					=	m.IdMunicipio
	and			p.IdEstado						=	m.IdEstado
	inner join	CAT_Estados						e
	on			p.IdEstado						=	e.IdEstado
	inner join	CO_AreaContractual				ac
	on			ac.IdAreaContractual			=	p.IdAreaContractual
	inner join	CAT_TiposBDT					t
	on			pv.IdTipoBDT					=	t.IdTipoBDT
	inner join	CAT_TipoInstalacion				ti
	on			ti.IdTipoInstalacion			=	pv.IdTipoInstalacion
	left join	#tmpAprobaciones				t1
	on			pv.IdPrevio						=	t1.IdPrevio
	left join	#tmpPorcentajes					t2
	on			t2.IdGenerico					=	pv.IdPrevio
	where		pv.Activo						=	1
	and			p.Activo						=	1
	and			pac.Bit_Activo					=	1
	and			ac.Activo						=	1


	
end

