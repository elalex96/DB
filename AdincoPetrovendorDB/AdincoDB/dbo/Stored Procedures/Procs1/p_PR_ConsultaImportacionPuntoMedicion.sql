-- p_PR_ConsultaImportacionPuntoMedicion '10013','2018-01-01',100018
-- p_PR_ConsultaImportacionPuntoMedicion '','',3,2018,1
create Proc [dbo].[p_PR_ConsultaImportacionPuntoMedicion]
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
		select Fecha = t1.Mes,
				t1.FactorConversion ,
				PuntoMedicion  =pm.Nombre
		from PR_FactorPuntoEntrega  t1
		inner join #tmpIds tmp on tmp.ID = t1.PuntoEntregaID
		inner join CO_PuntosdeEntrega pm on pm.PuntoEntregaID = t1.PuntoEntregaID
		inner join [dbo].[CO_PuntosdeEntregaContrato] pec on pec.PuntoEntregaID = t1.PuntoEntregaID
		where pec.IdContrato = @pIdContrato
	End
	Else
	Begin

		select Fecha = t1.Mes,
				t1.FactorConversion ,
				PuntoMedicion  =pm.Nombre
		from PR_FactorPuntoEntrega t1		
		inner join CO_PuntosdeEntrega pm on pm.PuntoEntregaID = t1.PuntoEntregaID
		inner join [dbo].[CO_PuntosdeEntregaContrato] pec on pec.PuntoEntregaID = t1.PuntoEntregaID
		where pec.IdContrato = @pIdContrato	and 
		DATEPART(year,t1.Mes) = @pAnio and
		DATEPART(month,t1.Mes) = @pMes 
	End