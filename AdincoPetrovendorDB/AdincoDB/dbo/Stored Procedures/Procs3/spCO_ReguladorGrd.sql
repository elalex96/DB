
create proc spCO_ReguladorGrd
as
begin
	select		r.IdRegulador,
				r.Regulador,
				r.NombreRegulador,
				r.LogoRegulador,
				UsadoEn				=	 count(e.IdRegulador),
				r.AWSDocumentoId,
				aws.UUIDAmazon,
				aws.Bucket,
				aws.Meta
	from		CO_Regulador		r
	left join	EN_Entregable		e
	on			r.IdRegulador		=	e.IdRegulador
	left join	AWS_Documentos		aws
	on			r.AWSDocumentoId	=	aws.AWSDocumentoId
	group by	r.IdRegulador,
				r.Regulador,
				r.NombreRegulador,
				r.LogoRegulador,
				r.AWSDocumentoId,
				aws.UUIDAmazon,
				aws.Bucket,
				aws.Meta
				
	select		IdEntregable,
				IdRegulador,
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
end

