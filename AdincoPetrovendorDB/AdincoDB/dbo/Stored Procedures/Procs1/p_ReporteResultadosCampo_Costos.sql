
-- p_ReporteResultadosCampo_Costos 3,26,'20190101',1
CREATE proc [dbo].[p_ReporteResultadosCampo_Costos]
@pIdContrato int,
@pIdCampo int,
@pMes date,
@pIdusuario int
as


	declare @pMesIniAnio date,
			@pMesFinAnio date

	select @pMesIniAnio = dateadd(month,- (datepart(month,@pMes) -1 ), @pMes)	

	set @pMesFinAnio = dateadd(month,1,@pMes)
	set @pMesFinAnio = dateadd(day,-1,@pMesFinAnio)

	
	

	select 
		p.Campo,
		fac.IdContrato,
		serv.IdServicio,
		serv.NombreServicio,	
		reg.IdRegistro,	
		Acumulado =cast(0 as money),
		MontoGasto =reg.MontoRegistro,
		Fecha = fac.Fecha,
		IdMoneda = fac.IdMoneda,
		Paridad = cast(1 as money),
		fac.Moneda,
		reg.MesPresentacion
	into #tmpAcumulado_Prev
	from CO_Registro reg
	inner join FI_Factura fac on fac.IdFactura = reg.IdFactura
	inner join CO_Instalacion i on i.IdInstalacion = reg.IdInstalacion
	inner join PR_Pozo p on p.Id = i.WelIID
	inner join CO_LineaPresupuestoMes lpm on lpm.IdLineaPresupuestoMes = reg.IdPrograma
	inner join CO_Servicio serv on serv.idServicio = lpm.IdServicio
	where 
	fac.IdContrato = @pIdContrato and
	p.Campo = @pIdCampo and
	convert(varchar,reg.MesPresentacion,112) <= convert(varchar,@pMesFinAnio,112) and
	reg.IdEstado = 10004--Aprobado
	


	update #tmpAcumulado_Prev
	set Paridad = TipoCambio		
	from #tmpAcumulado_Prev prev
	inner join CO_TipoCambioDiario tc on tc.IdMoneda = prev.IdMoneda and 
									convert(varchar,tc.Fecha,112) = convert(varchar,prev.Fecha,112) and
									tc.Activo = 1

	update #tmpAcumulado_Prev
	set Acumulado = MontoGasto / isnull(Paridad,1)
		

	select IdServicio,
		NombreServicio,			
		Acumulado =sum(Acumulado)
	into #tmpAcumulado
	from #tmpAcumulado_Prev
	group  by IdServicio,NombreServicio


	select 	IdServicio,
		NombreServicio,
		Total = sum(Acumulado),
		Acumulado = 0
	into #tmpMes
	from #tmpAcumulado_Prev
	where datepart(year,MesPresentacion) = datepart(year,@pMes) and
	datepart(month,MesPresentacion) = datepart(month,@pMes)  
	group by IdServicio,
		NombreServicio

	

	select a.NombreServicio,
		 Total = isnull(b.Total,0),
		 Acumulado = isnull(a.Acumulado,0)
	from #tmpAcumulado a
	left join #tmpMes b on b.IdServicio = a.IdServicio

	
