
--use adinco

-- p_ReporteResultadosCampo 10018,4,'20180601',1
CREATE proc [dbo].[p_ReporteResultadosCampo]
@pIdContrato int,
@pIdCampo int,
@pMes date,
@pIdusuario int
as


	declare @precioGas float,
			@precioPetroleo float,
			@precioCondensado float,
			@nombreCampo varchar(550),
			@IdContratista int,
			@pMesIniAnio datetime,
			@pMesAux datetime,
			@tasaRegalia float,
			@pozosActivosMes int,
			@pozosActivosTot int,
			@costos float,
			@costosAcumulados float


			select @nombreCampo = isnull(Nombre,'') from PR_Campo
			where Id = @pIdCampo


			select @IdContratista = IdContratista
			from CO_Contrato 
			where IdContrato = @pIdContrato

			select @pMesIniAnio = dateadd(month,- (datepart(month,@pMes) -1 ), @pMes)	


			CREATE TABLE #TMPProdTest(
				NombreCampo varchar(550),
				IDContrato varchar(1000),
				Mes Date,
				ProduccionPetroleo float,
				ProduccionCOndensado float,
				ProduccionAgua float,
				ProduccionGas float,
				PozosOperando tinyint,
				Eventos varchar(3000),
				FechaAct bit null,
				ProduccionPetroleoNeto Float
			)

			CREATE TABLE #TMPCuotaContractual(
				Mes Date,
				NumeroContrato varchar(100),
				CC float,
				SuperficieKm float,
				TotalCC float,
				Impuesto float,
				TotalImpuesto float
			)

			CREATE TABLE #TMPCostos
			(
				Servicio varchar(3000),
				Total float,
				Acumulado float
			)

			/********Obtener Costos ************/
			INSERT INTO #TMPCostos(Servicio,Total,Acumulado)
			exec p_ReporteResultadosCampo_Costos @pIdContrato ,@pIdCampo ,@pMes ,@pIdusuario 


			/****CUOTA CONTRACTUAL*************/
			insert into #TMPCuotaContractual
			exec sp_CP_CalculaCuotaContractualeImpuesto @IdContratista,@pMesIniAnio,@pMes 


			/*******PRECIOS****************/
			select precioPetroleo = isnull(case when IdTipoHidrocarburo = 1 then max(Precio) else @precioPetroleo end,0),
			precioCondensado = isnull(case when IdTipoHidrocarburo = 2 then max(Precio) else @precioCondensado end,0),
			precioGas = isnull(case when IdTipoHidrocarburo = 3 then max(Precio) else @precioGas end,0),
			Mes,
			TasaRegaliaBase = isnull(max(TasaRegalia),0)
			into #tmpPreciosPrev
			from CP_MetodoCalculoHidrocarburoMes
			where idCOntrato = @pIdContrato and
			Mes between @pMesIniAnio and @pMes and IdTipoHidrocarburo in (1,2,3)
			group by IdTipoHidrocarburo,Mes		
	

			select precioPetroleo = max(precioPetroleo), 
					precioCondensado = max(precioCondensado),
					precioGas = max(precioGas),
					Mes,
					TasaRegaliaBase = max(TasaRegaliaBase)
			into #tmpPrecios
			from #tmpPreciosPrev
			group by Mes		

			

			select 
				@precioPetroleo = precioPetroleo,
				@precioCondensado = precioCondensado,
				@precioGas = precioGas ,
				@tasaRegalia = TasaRegaliaBase
			from #tmpPrecios
			where Mes = (select max(mes) from #tmpPrecios)


			/*************PRODUCCIÓN****************************/
			/*********Obtener toda la producción del Anio************************/

			set @pMesAux = 	@pMesIniAnio

			
	

			while @pMesAux <= @pMes
			begin

					declare @DiaUltimoMes date

					
					set @DiaUltimoMes = dateadd(month,1,@pMesAux)
						
					set @DiaUltimoMes = dateadd(day,-1,@DiaUltimoMes)		
					
											
		
					insert into #TMPProdTest(
					NombreCampo ,				IDContrato ,				Mes ,				ProduccionPetroleo ,
					ProduccionCOndensado ,			ProduccionAgua ,			ProduccionGas ,		PozosOperando ,
					Eventos ,ProduccionPetroleoNeto
					)
					exec [sp_CNH_Reporte_CNH_DGM_09_POD] @pIdContrato,@DiaUltimoMes,@pIdUsuario,1

					
					

					

					update #TMPProdTest
					set Mes = @pMesAux,
						FechaAct = 1
					where FechaAct is null

					set @pMesAux = dateadd(month,1,@pMesAux)

			end

			
			
			
		
			
			/*********ANTES DE ELIMINAR LA PRODUCCIÓN DE LOS DEMÁS CAMPOS, OBTENER LOS CAMPOS ACTIVOS POR MES******************/
			select Mes,
				  Campos = count(distinct NombreCampo),
				  SuperficieKmPorCampo = SuperficieKm2 / count(distinct NombreCampo),
				  ac.SuperficieKm2
			into #tmpCamposActivos
			from #TMPProdTest
			inner join CO_Contrato c on c.IdContrato = @pidContrato
			inner join CO_AreaContractual ac on ac.IdAreaContractual = c.IdAreaContractual 
			group by Mes,SuperficieKm2


			delete #TMPProdTest
			where rtrim(NombreCampo) <> rtrim(@nombreCampo)	

			
			
						
			

			select PrecioGas =  @precioGas , 
				PrecioPetroleo = @precioPetroleo ,
				PrecioCondensado = @precioCondensado ,
				TasaRegaliaBase = @tasaRegalia,
				ProduccionGas = isnull(Sum(ProduccionGas),0),
				ProduccionGasAcumulado = cast(0 as float),
				ProduccionPetroleo = isnull(Sum(ProduccionPetroleoNeto) ,0),
				ProduccionPetroleoAcumulado = cast(0 as float),
				ProduccionCondensado = isnull(Sum(ProduccionCondensado),0),
				ProduccionCondensadoAcumulado = cast(0 as float),
				IngresosGas = isnull(Sum(ProduccionGas),0) * isnull(@PrecioGas,0),
				IngresosGasAcumulado = cast(0 as float),
				IngresosPetroleo =  isnull(Sum(ProduccionPetroleoNeto),0) * isnull(@precioPetroleo,0),
				IngresosPetroleoAcumulado = cast(0 as float),
				IngresosCondensado = isnull(Sum(ProduccionCOndensado),0) * isnull(@precioCondensado,0)	,
				IngresosCondensadoAcumulado = cast(0 as float),
				Regalia = cast(0 as float),	
				RegaliaAcumulado = cast(0 as float),
				RegaliaAdicional = cast(0 as float),	
				RegaliaAdicionalAcumulado = cast(0 as float),	
				CuotaContractual = cast(0 as float),	
				CuotaContractualAcumulada = cast(0 as float),	
				ImpuestoFaseEx = cast(0 as float),
				ImpuestoFaseExAcumulado = cast(0 as float),
				Mes
			into #tmpResult
			from #TMPProdTest
			group by NombreCampo,Mes

			

			

			
			

			
			--Calculo de Regalia Base
			update #tmpResult
			set Regalia = (isnull(TasaRegaliaBase,0) / 100) * (isnull(IngresosGas,0) + isnull(IngresosPetroleo,0) + isnull(IngresosCondensado,0))
			from #tmpResult t	


			--Calculo de Regalia Adicional
	update #tmpResult
	set RegaliaAdicional = (c.ValorRegaliaAdicional / 100) * (IngresosGas + IngresosPetroleo + IngresosCondensado)
	from #tmpResult t
	inner join CO_Contrato c on c.IdContrato = @pIdContrato

	--Calculo de Cuota Contractual
	update #tmpResult
	set CuotaContractual = c.CC * SuperficieKmPorCampo
	from #tmpResult t
	inner join #TMPCuotaContractual c on c.Mes = c.Mes
	inner join #tmpCamposActivos pa on pa.Mes = t.Mes


	--Calculo de Impuesto Fase Exploración
	update #tmpResult
	set ImpuestoFaseEx = c.CC * SuperficieKmPorCampo
	from #tmpResult t
	inner join #TMPCuotaContractual c on c.Mes = c.Mes
	inner join #tmpCamposActivos pa on pa.Mes = t.Mes


	/******Recalcular ingresos,regalias para meses pasados***************/
	UPDATE #tmpResult
	SET IngresosGas = ProduccionGas * p.PrecioGas,
		IngresosPetroleo = ProduccionPetroleo * p.precioPetroleo,
		IngresosCondensado = ProduccionCondensado * p.precioCondensado		
	FROM #tmpResult r
	inner join #tmpPrecios p on p.Mes = r.Mes
	where r.Mes <> @pMes


	/******Recalcular regalias para meses pasados***************/
	UPDATE #tmpResult
	SET Regalia = (IngresosGas + IngresosPetroleo + IngresosCondensado) * (isnull(p.TasaRegaliaBase,0)/100)
	FROM #tmpResult r
	inner join #tmpPrecios p on p.Mes = r.Mes
	where r.Mes <> @pMes


	/********Recalcular  Acumulados**************/
	update #tmpResult
	set ProduccionGasAcumulado = (select sum(ProduccionGas) from #tmpResult),
		ProduccionPetroleoAcumulado = (select sum(ProduccionPetroleo) from #tmpResult),
		ProduccionCondensadoAcumulado = (select sum(ProduccionCondensado) from #tmpResult),
		IngresosGasAcumulado = (select sum(IngresosGas) from #tmpResult),
		IngresosPetroleoAcumulado = (select sum(IngresosPetroleo) from #tmpResult),
		IngresosCondensadoAcumulado = (select sum(IngresosCondensado) from #tmpResult),
		RegaliaAcumulado = (select sum(Regalia) from #tmpResult),
		RegaliaAdicionalAcumulado = (select sum(RegaliaAdicional) from #tmpResult),
		CuotaContractualAcumulada = (select sum(CuotaContractual) from #tmpResult),
		ImpuestoFaseExAcumulado = (select sum(ImpuestoFaseEx) from #tmpResult)

	

	/**********OBTENER BALANCES*****************/
	select @costos = sum(isnull(Total,0)) 
	from #TMPCostos	

	select @costosAcumulados = sum(isnull(Acumulado,0))
	from #TMPCostos


	if isnull(@nombreCampo,'') = ''
		goto SinCampo

	/***********************************************/

	

	if exists (
		select 1
		from #tmpResult
		where Mes = @pMes
	)
	begin
		select PrecioGas= isnull(PrecioGas,0)   , 
		PrecioPetroleo = isnull(PrecioPetroleo,0),
		PrecioCondensado = isnull(PrecioCondensado ,0) ,
		TasaRegaliaBase = isnull(TasaRegaliaBase,0),
		ProduccionGas = isnull(ProduccionGas,0),
		ProduccionGasAcumulado =isnull(ProduccionGasAcumulado,0),
		ProduccionPetroleo = isnull(ProduccionPetroleo,0) ,
		ProduccionPetroleoAcumulado =isnull(ProduccionPetroleoAcumulado,0),
		ProduccionCondensado =  isnull(ProduccionCondensado,0),
		ProduccionCondensadoAcumulado =isnull(ProduccionCondensadoAcumulado,0),
		IngresosGas =isnull(IngresosGas,0),
		IngresosGasAcumulado =isnull(IngresosGasAcumulado,0),
		IngresosPetroleo =isnull(IngresosPetroleo,0) ,
		IngresosPetroleoAcumulado =isnull(IngresosPetroleoAcumulado,0),
		IngresosCondensado  =isnull(IngresosCondensado,0)	,
		IngresosCondensadoAcumulado = isnull(IngresosCondensadoAcumulado,0),
		Regalia = isnull(Regalia,0),	
		RegaliaAcumulado = isnull(RegaliaAcumulado,0),
		RegaliaAdicional =isnull(RegaliaAdicional,0),	
		RegaliaAdicionalAcumulado =isnull(RegaliaAdicionalAcumulado,0),	
		CuotaContractual =isnull(CuotaContractual,0),	
		CuotaContractualAcumulada = isnull(CuotaContractualAcumulada,0) ,	
		ImpuestoFaseEx =isnull(ImpuestoFaseEx,0),
		ImpuestoFaseExAcumulado =isnull(ImpuestoFaseExAcumulado,0) ,
		Mes=@pMes,
		Balance =ISNULL(IngresosGas,0) + ISNULL(IngresosPetroleo,0) +ISNULL(IngresosCondensado,0) - ISNULL(@costos,0),
		BalanceAcumulado = ISNULL(IngresosGasAcumulado,0)+ ISNULL(IngresosPetroleoAcumulado,0)+ISNULL(IngresosCondensadoAcumulado,0) - ISNULL(@costosAcumulados,0),
		TotalIngresos = ISNULL(IngresosGas,0) + ISNULL(IngresosPetroleo,0) +ISNULL(IngresosCondensado,0),
		TotalIngresosAcumulados = ISNULL(IngresosGasAcumulado,0)+ ISNULL(IngresosPetroleoAcumulado,0)+ISNULL(IngresosCondensadoAcumulado,0),
		BalanceCostos = ISNULL(Regalia,0) + ISNULL(RegaliaAdicional,0) +  ISNULL(CuotaContractual,0)+  ISNULL(ImpuestoFaseEx,0) + ISNULL(@costos,0),
		BalanceCostosAcumulado = ISNULL(RegaliaAcumulado,0) + ISNULL(RegaliaAdicionalAcumulado,0) +  
								ISNULL(CuotaContractualAcumulada,0)+  ISNULL(ImpuestoFaseExAcumulado,0) + 
								ISNULL(@costosAcumuladoS,0),
								NombreCampo = @nombreCampo
		from #tmpResult
		where Mes = @pMes
	end
	Else
	Begin

		
		SinCampo:

		Select TOP 1
		PrecioGas =  isnull(@precioGas,0) , 
		PrecioPetroleo = isnull(@precioPetroleo,0) ,
		PrecioCondensado = isnull(@precioCondensado,0) ,
		TasaRegaliaBase = isnull(@tasaRegalia,0),
		ProduccionGas =cast(0 as float),
		ProduccionGasAcumulado = isnull(ProduccionGasAcumulado,0),
		ProduccionPetroleo = cast(0 as float),
		ProduccionPetroleoAcumulado = isnull(ProduccionPetroleoAcumulado,0),
		ProduccionCondensado = cast(0 as float),
		ProduccionCondensadoAcumulado = isnull(ProduccionCondensadoAcumulado,0),
		IngresosGas = cast(0 as float),
		IngresosGasAcumulado,
		IngresosPetroleo = cast(0 as float),
		IngresosPetroleoAcumulado ,
		IngresosCondensado = cast(0 as float)	,
		IngresosCondensadoAcumulado = isnull(IngresosCondensadoAcumulado,0),
		Regalia = cast(0 as float),	
		RegaliaAcumulado = isnull(RegaliaAcumulado,0) ,
		RegaliaAdicional = cast(0 as float),	
		RegaliaAdicionalAcumulado =isnull(RegaliaAdicionalAcumulado,0),	
		CuotaContractual = cast(0 as float),	
		CuotaContractualAcumulada =isnull(CuotaContractualAcumulada,0),	
		ImpuestoFaseEx = cast(0 as float),
		ImpuestoFaseExAcumulado = isnull(ImpuestoFaseExAcumulado,0),
		Mes=@pMes,
		Balance =ISNULL(IngresosGas,0) + ISNULL(IngresosPetroleo,0) +ISNULL(IngresosCondensado,0) - ISNULL(@costos,0),
		BalanceAcumulado = ISNULL(IngresosGasAcumulado,0)+ ISNULL(IngresosPetroleoAcumulado,0)+ISNULL(IngresosCondensadoAcumulado,0) - ISNULL(@costosAcumulados,0),
		TotalIngresos = ISNULL(IngresosGas,0) + ISNULL(IngresosPetroleo,0) +ISNULL(IngresosCondensado,0),
		TotalIngresosAcumulados = ISNULL(IngresosGasAcumulado,0)+ ISNULL(IngresosPetroleoAcumulado,0)+ISNULL(IngresosCondensadoAcumulado,0),
		BalanceCostos = 0 + 0 +  0+  0 + ISNULL(@costos,0),
		BalanceCostosAcumulado = ISNULL(RegaliaAcumulado,0) + ISNULL(RegaliaAdicionalAcumulado,0) +  
								ISNULL(CuotaContractualAcumulada,0)+  ISNULL(ImpuestoFaseExAcumulado,0) + 
								ISNULL(@costosAcumuladoS,0)
								,
								NombreCampo = @nombreCampo
		from #tmpResult
	End


	--Select 
	--	PrecioGas =  cast(0 as float),
	--	PrecioPetroleo = cast(0 as float),
	--	PrecioCondensado = cast(0 as float),
	--	TasaRegaliaBase =cast(0 as float),
	--	ProduccionGas =cast(0 as float),
	--	ProduccionGasAcumulado = cast(0 as float),
	--	ProduccionPetroleo = cast(0 as float),
	--	ProduccionPetroleoAcumulado = cast(0 as float),
	--	ProduccionCondensado = cast(0 as float),
	--	ProduccionCondensadoAcumulado = cast(0 as float),
	--	IngresosGas = cast(0 as float),
	--	IngresosGasAcumulado= cast(0 as float),
	--	IngresosPetroleo = cast(0 as float),
	--	IngresosPetroleoAcumulado= cast(0 as float),
	--	IngresosCondensado = cast(0 as float)	,
	--	IngresosCondensadoAcumulado = cast(0 as float),
	--	Regalia = cast(0 as float),	
	--	RegaliaAcumulado= cast(0 as float),
	--	RegaliaAdicional = cast(0 as float),	
	--	RegaliaAdicionalAcumulado = cast(0 as float),
	--	CuotaContractual = cast(0 as float),	
	--	CuotaContractualAcumulada = cast(0 as float),
	--	ImpuestoFaseEx = cast(0 as float),
	--	ImpuestoFaseExAcumulado = cast(0 as float),
	--	Mes=getdate(),
	--	Balance =cast(0 as float),
	--	BalanceAcumulado = cast(0 as float),
	--	TotalIngresos = cast(0 as float),
	--	TotalIngresosAcumulados = cast(0 as float),
	--	BalanceCostos = cast(0 as float),
	--	BalanceCostosAcumulado = cast(0 as float)
	--							,
	--							NombreCampo = cast('' as varchar(500))