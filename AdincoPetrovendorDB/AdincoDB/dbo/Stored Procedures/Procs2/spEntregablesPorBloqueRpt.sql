use Adinco
go

if exists(select * from sys.procedures where name = 'spEntregablesPorBloqueRpt')
begin
	drop proc spEntregablesPorBloqueRpt
end

go

create proc spEntregablesPorBloqueRpt
(
	@IdContrato	int,
	@FechaIni	smalldatetime,
	@FechaFin	smalldatetime
)
as
begin
/*Ramón Portales 03/12/2021*/
	declare	@IdContratista int
	select @IdContratista = IdContratista from CO_Contrato where IdContrato = @IdContrato
	
	select		RowID						=	ROW_NUMBER() OVER (	ORDER BY NumeroContrato   ),
				--ie.FechaRealEntregaRegulador,
				Mes							=	case	when month(ie.FEchaCalculadaEntregaReg) = 1  then 'Enero'
														when month(ie.FEchaCalculadaEntregaReg) = 2  then 'Febrero'
														when month(ie.FEchaCalculadaEntregaReg) = 3  then 'Marzo'
														when month(ie.FEchaCalculadaEntregaReg) = 4  then 'Abril'
														when month(ie.FEchaCalculadaEntregaReg) = 5  then 'Mayo'
														when month(ie.FEchaCalculadaEntregaReg) = 6  then 'Junio'
														when month(ie.FEchaCalculadaEntregaReg) = 7  then 'Julio'
														when month(ie.FEchaCalculadaEntregaReg) = 8  then 'Agosto'
														when month(ie.FEchaCalculadaEntregaReg) = 9  then 'Septiembre'
														when month(ie.FEchaCalculadaEntregaReg) = 10 then 'Octubre'
														when month(ie.FEchaCalculadaEntregaReg) = 11 then 'Noviembre'
														when month(ie.FEchaCalculadaEntregaReg) = 12 then 'Diciembre'
														end
												,
				NombreContrato				=	co.NumeroContrato,
				TipoEntregable				=	case	when	e.BitJOA		=	1		then 'JOA'
														when	e.BitInterno	=	1 
														and		cepia.Activo	=	1		then 'Sasisopa'
														when	e.BitInterno	=	1 
														and		cepia.Activo	is null		then 'Resolutivo'
														when	e.BitInterno	=	0
														and		e.BitJOA		=	0		then 'Lineamiento'
														
												else	''
												end,
				Funcion						=	a.NombreArea,
				SubFuncion					=	ce.Subfuncion,
				IdRegulador					=	e.IdRegulador,
				Regulador					=	r.Regulador,
				IdMarcoLegal				=	e.IdMarcoLegal,
				MarcoLegal					=	ml.MarcoLegal,
				Articulo					=	e.Articulo,
				NombreAdinco				=	e.DocumentoEntregable,
				CodigoAdinco				=	ie.idInstanciaEntregable,
				FechaAdinco					=	ie.FEchaCalculadaEntregaReg,
				FechaRealEntrega			=	ie.FechaRealEntregaRegulador,
				ActivoAdinco				=	ce.Activo,
				ComentariosShell			=	eic.Comentario
	from		EN_InstanciasEntregable		ie
	inner join	EN_ContratoEntregable		ce
	on			ce.IdContratoEntregable		=	ie.IdContratoEntregable
	inner join	EN_Entregable				e
	on			ce.IdEntregable				=	e.IdEntregable	
	left join	CO_Regulador				r
	on			r.IdRegulador				=	e.IdRegulador
	left join	EN_MarcoLegal				ml
	on			ml.IdMarcoLegal				=	e.IdMarcoLegal
	left join	EN_Area						a
	on			ce.IdArea					=	a.idArea
	left join	CO_Contrato					co
	on			co.IdContrato				=	ce.IdContrato
	and			co.IdContratista			=	@IdContratista
	left join	EN_EntregableInstanciaComentario	eic
	on			eic.EntregableInstanciaId	=	ie.idInstanciaEntregable
	left join	EN_ContratoEntregableProgramaImplementaAcciones	cepia
	on			cepia.IdContratoEntregable	=	ce.IdContratoEntregable
	where		(FEchaCalculadaEntregaReg	between	@FechaIni and @fechaFin)
	and			co.IdContratista			=	@IdContratista
	--EN_ContratoEntregableProgramaImplementaAcciones
end


go
