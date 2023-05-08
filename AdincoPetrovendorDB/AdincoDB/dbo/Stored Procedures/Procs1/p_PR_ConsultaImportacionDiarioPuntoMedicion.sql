-- p_PR_ConsultaImportacionDiarioPuntoMedicion '10013','2018-01-01',100018
-- p_PR_ConsultaImportacionDiarioPuntoMedicion '','',10018,2018,6
create Proc [dbo].[p_PR_ConsultaImportacionDiarioPuntoMedicion]
@pIdsPuntosMed  varchar(1000),
@pFecha DATE,
@pIdContrato int,
@pAnio int=0,
@pMes int=0
as

	select ID= splitdata
	into #tmpIds
	from [dbo].[fnSplitString](@pIdsPuntosMed,',')

	if(@pAnio = 0 and @pMes = 0)
	begin
		select Fecha = t1.Fecha,				
				PuntoMedicion  =pm.Nombre,
				Presion,
				Temperatura,
				Eventos,
				Dato,
				Nominal,
				Instantaneo
		from PR_PuntoEntregaDiario  t1
		inner join #tmpIds tmp on tmp.ID = t1.PuntoEntregaID
		inner join CO_PuntosdeEntrega pm on pm.PuntoEntregaID = t1.PuntoEntregaID
		inner join [dbo].[CO_PuntosdeEntregaContrato] pec on pec.PuntoEntregaID = t1.PuntoEntregaID
		where pec.IdContrato = @pIdContrato and
		convert(varchar,t1.fecha,112) = convert(varchar,@pFecha,112)
		order by t1.Fecha,pm.Nombre
	End
	Else
	Begin

		select Fecha = t1.Fecha,				
				PuntoMedicion  =pm.Nombre,
				Presion,
				Temperatura,
				Eventos,
				Dato,
				Nominal,
				Instantaneo
		from PR_PuntoEntregaDiario t1		
		inner join CO_PuntosdeEntrega pm on pm.PuntoEntregaID = t1.PuntoEntregaID
		inner join [dbo].[CO_PuntosdeEntregaContrato] pec on pec.PuntoEntregaID = t1.PuntoEntregaID
		where pec.IdContrato = @pIdContrato	and 
		DATEPART(year,t1.Fecha) = @pAnio and
		DATEPART(month,t1.Fecha) = @pMes 
		order by t1.Fecha,pm.Nombre
	End

