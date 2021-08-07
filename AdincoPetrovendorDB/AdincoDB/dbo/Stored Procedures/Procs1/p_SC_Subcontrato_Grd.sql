CREATE proc p_SC_Subcontrato_Grd
(
	@pIdContratista	int
)
as
begin
	select		t1.IdSubContrato,
				t1.IdSubContratista,
				SubContratista				=	ISNULL(T2.RazonSocial,T2.rfc),
				t1.IdContratista,
				t1.NumeroSubContrato,
				t1.Objeto,
				t1.IdPedido,
				t1.PrefijoOT,
				t1.IdMoneda,
				TipoMoneda					=	m.TipoMonedaCorto,
				t1.IdContrato,
				IdCC = isnull(t1.IdCentroCosto,0),
				cc.CentroCosto,
				t1.FechaInicio,
				t1.FechaFin
	from		SC_Subcontrato				t1
	inner join	Adinco..PV_Subcontratista	t2
	on			t1.IdSubContratista			=	t2.IdSubcontratista
	left join	Petrovendor..PV_TipoMoneda	m
	on			t1.IdMoneda					=	m.IdMoneda
	left join	petrovendor..Cc_centrocosto	cc
	on			cc.IdCentroCosto			=	t1.IdCentroCosto
	where		IdContratista				=	@pIdContratista
	and			isnull(t1.IsEliminado,0)	= 0
	order by t1.IdSubContrato desc
	
	
end

