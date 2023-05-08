
create proc spEN_ReceptorEntregableGrd
as
begin
	select		r.IdReceptorEntregable,
				r.ReceptorEntregable,
				r.CreadoPor,
				r.CreadoEn,
				UsadoEn				=	 count(e.IdRegulador)
	from		EN_ReceptorEntregable		r
	left join	EN_Entregable				e
	on			r.IdReceptorEntregable		=	e.IdReceptorEntregable
	group by	r.IdReceptorEntregable,
				r.ReceptorEntregable,
				r.CreadoPor,
				r.CreadoEn
				
	select		IdEntregable,
				IdReceptorEntregable,
				Consecutivo,
				DocumentoEntregable,
				ml.IdMarcoLegal,
				ml.MarcoLegal
	from		EN_Entregable	e
	left join	EN_MarcoLegal	ml
	on			e.IdMarcoLegal	=	ml.IdMarcoLegal
	where		e.IsActivo		=	1
	and			e.IsEliminado	=	0
	and			ml.Activo		=	1
	and			e.IdRegulador	is	not	null
	order by	IdReceptorEntregable
end

