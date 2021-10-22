if exists(select * from sys.procedures where name = 'spEN_ResponsableGeneradorGrd')
begin
	drop proc spEN_ResponsableGeneradorGrd
end

go

create proc spEN_ResponsableGeneradorGrd
as
begin
	select		r.IdResponsableGenerador,
				r.ResponsableGenerador,
				r.CreadoPor,
				r.CreadoEn,
				UsadoEn				=	 count(e.IdRegulador)
	from		EN_ResponsableGenerador		r
	left join	EN_Entregable				e
	on			r.IdResponsableGenerador		=		e.IdResponsableGenerador
	group by	r.IdResponsableGenerador,
				r.ResponsableGenerador,
				r.CreadoPor,
				r.CreadoEn
				
	select		IdEntregable,
				IdResponsableGenerador,
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

go