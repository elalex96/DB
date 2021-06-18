-- p_ProduccionDiaria_By_ValorConciliado 10022
create proc p_ProduccionDiaria_By_ValorConciliado
@pIdValoresConciliadosProducion INT
as

	select 
		Pozo = pozo.Nombre,
		p.Fecha,
		AguaProdDiaria = p.PctAguaControl,
		GasProdDiaria = p.ProduccionRealGasM3,
		AceiteProdDiaria = p.ProduccionReal,
		AguaProdDiariaTot = cast(0 as float),
		GasProdDiariaTot = cast(0 as float),
		AceiteProdDiariaTot = cast(0 as float),
		PuntoEntrega = pe.Nombre
	into #tmpResult
	from CO_ValoresConciliadosProducion vp
	INNER JOIN PR_Pozo pozo on pozo.PuntoEntregaID = vp.PuntoEntregaID
	INNER JOIN PR_ProdDiariaPozo p on p.Pozo = pozo.Id AND
								YEAR(p.Fecha) = YEAR(vp.Mes) AND
								MONTH(p.Fecha) = MONTH(vp.Mes)
	INNER JOIN CO_PuntosdeEntrega pe on pe.PuntoEntregaID = pozo.PuntoEntregaID
	WHERE vp.IdValoresConciliadosProducion = @pIdValoresConciliadosProducion
	order by 
	p.Fecha,
	pozo.Nombre


	update #tmpResult
	set AguaProdDiariaTot = (select SUM(AguaProdDiaria) from #tmpResult s1 WHERE s1.Fecha = r.Fecha),
		GasProdDiariaTot = (select SUM(GasProdDiaria) from #tmpResult s1 WHERE s1.Fecha = r.Fecha),
		AceiteProdDiariaTot = (select SUM(AceiteProdDiaria) from #tmpResult s1 WHERE s1.Fecha = r.Fecha)
	from #tmpResult r

	SELECT *
	FROM #tmpResult
		
