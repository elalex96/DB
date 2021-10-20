if exists(select * from sys.procedures where name = 'spEN_ClasificacionGrd')
begin
	drop proc spEN_ClasificacionGrd
end

go

create proc spEN_ClasificacionGrd
as
begin
	select		r.IdClasificacion,
				r.NombreClasificacion,
				r.Activo,
				r.BitJOA,
				r.CreadoPor,
				r.CreadoEl,
				r.ModificadoPor,
				r.ModificadoEl,
				UsadoEn				=	 count(e.IdClasificacion)
	from		EN_Clasificacion		r
	left join	EN_Entregable				e
	on			r.IdClasificacion		=	e.IdClasificacion
	group by	r.IdClasificacion,
				r.NombreClasificacion,
				r.CreadoPor,
				r.CreadoEl,
				r.ModificadoPor,
				r.ModificadoEl,
				r.Activo,
				r.BitJOA
				
	select		IdEntregable,
				IdClasificacion,
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