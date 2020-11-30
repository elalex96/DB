-- p_ReporteResultadosPozo 3,83,'20180901',1  
CREATE proc [dbo].[p_ReporteResultadosPozo]  
@pIdContrato int,  
@pIdPozo int,  
@pMes date,  
@pIdusuario int  
as  
  
 declare @precioGas float,  
   @precioPetroleo float,  
   @precioCondensado float,  
   @nombrePozo varchar(1000),  
   @IdContratista int,  
   @pMesIniAnio datetime,  
   @pMesAux datetime,  
   @tasaRegalia float,  
   @pozosActivosMes int,  
   @pozosActivosTot int,  
   @costos float,  
   @costosAcumulados float  
  
 select @nombrePozo = isnull(Nombre,'') from PR_pozo  
 where Id = @pIdPozo  
  
    
  
 select @IdContratista = IdContratista  
 from CO_Contrato   
 where IdContrato = @pIdContrato  
  
  
 --select @pMesIniAnio = dateadd(month,- (datepart(month,@pMes) -1 ), @pMes)   
   
 select @pMesIniAnio = min(InicioVigencia)  
 from CO_Contrato c   
 where c.IdContratista = @IdContratista   
  
  
 /******Temporales PARA SPS*************/  
 CREATE TABLE #TMPProdTest(  
  [ID Contrato o Asignación] [varchar](100) NOT NULL,  
  [Región Fiscal] [varchar](100) NULL,  
  [Nombre del Campo] [varchar](200) NULL,  
  [ID de Pozo SEGUN ANEXO 3 POZOS] [varchar](100) NULL,  
  [Nombre del Pozo SEGUN ANEXO 3 POZOS] [varchar](500) NULL,  
  [Fecha] [date] NULL,  
  [Días de Producción] [int] NOT NULL default 0,  
  [Tipo de Fluido] [varchar](500) NULL,  
  [Producción de Petróleo Bruto] [float] NOT NULL default 0,  
  [Producción de Petróleo Neto] [float] NOT NULL default 0,  
  [°API] [float] NULL,  
  [% AZUFRE] [float] NULL,  
  [SAL] [float] NULL,  
  [Producción de Condesado Neto] [float] NOT NULL default 0,  
  [Producción de Agua Neto] [float] NOT NULL default 0,  
  [Producción de Gas Asociado] [decimal](24, 8) NOT NULL default 0,  
  [Producción de Gas No Asociado] [decimal](24, 8) NOT NULL default 0,  
  [C1] [float] NOT NULL default 0,  
  [C2] [float] NOT NULL default 0,  
  [C3] [float] NOT NULL default 0,  
  [C4] [float] NOT NULL default 0,  
  [iC4] [float] NOT NULL default 0,  
  [C5] [float] NOT NULL default 0,  
  [iC5] [float] NOT NULL default 0,  
  [C6] [float] NOT NULL default 0,  
  [C7] [float] NOT NULL default 0,  
  [C8] [float] NOT NULL default 0,  
  [C9] [float] NOT NULL default 0,  
  [C10] [float] NOT NULL default 0,  
  [CO2] [float] NOT NULL default 0,  
  [H2S] [float] NOT NULL default 0,  
  [N2] [float] NOT NULL default 0,  
  [H2O] [float] NOT NULL default 0,  
  [O2] [float] NOT NULL default 0,  
  [Poder Calorífico del Gas] [float] NULL,  
  [Peso Molecular del Gas] [float] NULL,  
  [Energía de Gas] [float] NULL,  
  [RGA (ASIG-AC)] [float] NULL,  
  [API (ASIG-AC)] [float] NOT NULL default 0,  
  [% S (ASIG-AC)] [float] NOT NULL default 0,  
  [SAL (ASIG-AC)] [float] NOT NULL default 0,  
  [PODER CALORIFICO DE PETROLEO] [float] NOT NULL default 0,  
  [C1 (ASIG-AC)] [float] NOT NULL default 0,  
  [C2 (Asig - AC)] [float] NOT NULL default 0,  
  [C3 (Asig - AC)] [float] NOT NULL default 0,  
  [C4 (Asig - AC)] [float] NOT NULL default 0,  
  [IC4 (Asig - AC)] [float] NOT NULL default 0,  
  [C5 (Asig - AC)] [float] NOT NULL default 0,  
  [IC5 (Asig - AC)] [float] NOT NULL default 0,  
  [C6+ (Asig - AC)] [float] NOT NULL default 0,  
  [C7 (Asig - AC)] [float] NOT NULL default 0,  
  [C8 (Asig - AC)] [float] NOT NULL default 0,  
  [C9 (Asig - AC)] [float] NOT NULL default 0,  
  [C10 (Asig - AC)] [float] NOT NULL default 0,  
  [CO2 (Asig - AC)] [float] NOT NULL default 0,  
  [H2S (Asig - AC)] [float] NOT NULL default 0,  
  [N2 (Asig - AC)] [float] NOT NULL default 0,  
  [H2O (Asig - AC)] [float] NOT NULL default 0,  
  [O2 (Asig - AC)] [float] NOT NULL default 0,  
  [Energia C1 (Asig - AC)] [float] NOT NULL default 0,  
  [Energia C2 (Asig - AC)] [float] NOT NULL default 0,  
  [Energia C3 (Asig - AC)] [float] NOT NULL default 0,  
  [Energia C4 (Asig - AC)] [float] NOT NULL default 0,  
  [Poder Calorífico de Asiganción (Asig - AC)] [float] NOT NULL default 0,  
  [Energía de Gas (Asig - AC)] [float] NOT NULL default 0,  
  [Vol C5+ (Asig - AC)] [float] NOT NULL default 0,  
  [Poder Calorífico de C5+ (Asig - AC)] [float] NOT NULL default 0,  
  [Eventos] [varchar](5000) NULL,  
  Mes Date NULL  
)  
  
 CREATE TABLE #TMPCuotaContractual(  
  Mes Date,  
  NumeroContrato varchar(200),  
  CC float,  
  SuperficieKm float,  
  TotalCC float,  
  Impuesto float,  
  TotalImpuesto float  
 )  
  
 CREATE TABLE #TMPCostos  
 (  
  Servicio varchar(1000),  
  Total float,  
  Acumulado float  
 )  
  
  
 /********Obtener Costos ************/  
 INSERT INTO #TMPCostos(Servicio,Total,Acumulado)  
 exec p_ReporteResultadosPozo_Costos @pIdContrato ,@pIdPozo ,@pMes ,@pIdusuario   
  
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
  
  
   
  
 set @pMesAux =  @pMesIniAnio  
  
 while @pMesAux <= @pMes  
 begin  
    
  insert into #TMPProdTest(  
  [ID Contrato o Asignación] ,  [Región Fiscal] ,  [Nombre del Campo]  ,  [ID de Pozo SEGUN ANEXO 3 POZOS]  ,  
  [Nombre del Pozo SEGUN ANEXO 3 POZOS]  ,  [Fecha]  ,  [Días de Producción]  ,  [Tipo de Fluido]  ,  
  [Producción de Petróleo Bruto]  ,  [Producción de Petróleo Neto]  ,  [°API]  ,  [% AZUFRE]  ,  
  [SAL]  ,  [Producción de Condesado Neto]  ,  [Producción de Agua Neto]  ,  [Producción de Gas Asociado]   ,  
  [Producción de Gas No Asociado]   ,  [C1]  ,  [C2]  ,  [C3]  ,  [C4]  ,  
  [iC4]  ,  [C5]  ,  [iC5]  ,  [C6]  , C7, C8, C9, C10,  [CO2]  ,  
  [H2S]  ,  [N2]  , H2O, O2,  [Poder Calorífico del Gas]  ,  [Peso Molecular del Gas]  ,  [Energía de Gas]  ,  
  [RGA (ASIG-AC)]  ,  [API (ASIG-AC)]  ,  [% S (ASIG-AC)]  ,  [SAL (ASIG-AC)]  ,  [PODER CALORIFICO DE PETROLEO]  ,  
  [C1 (ASIG-AC)]  ,  [C2 (Asig - AC)]  ,  [C3 (Asig - AC)]  ,  [C4 (Asig - AC)]  ,  [IC4 (Asig - AC)]  ,  
  [C5 (Asig - AC)]  ,  [IC5 (Asig - AC)]  ,  [C6+ (Asig - AC)]  , [C7 (Asig - AC)], [C8 (Asig - AC)], [C9 (Asig - AC)], [C10 (Asig - AC)],  
  [CO2 (Asig - AC)]  ,  [H2S (Asig - AC)]  , [N2 (Asig - AC)]  , [H2O (Asig - AC)], [O2 (Asig - AC)],  
  [Energia C1 (Asig - AC)] , [Energia C2 (Asig - AC)], [Energia C3 (Asig - AC)], [Energia C4 (Asig - AC)],  
  [Poder Calorífico de Asiganción (Asig - AC)]  ,  
  [Energía de Gas (Asig - AC)]  ,  [Vol C5+ (Asig - AC)]  ,  [Poder Calorífico de C5+ (Asig - AC)]  ,  [Eventos] )  
  exec [sp_CNH_Reporte_I_CNH_DGM_VHP] @pIdContrato,@pMesAux,@pIdUsuario,0,1  
  
    
  
  update #TMPProdTest  
  set Mes = @pMesAux  
  where MES IS NULL  
  
  set @pMesAux = dateadd(month,1,@pMesAux)  
  
  
 end  
  
  
 if not exists(  
  select 1  
  from #TMPProdTest  
 )  
 begin  
    
  insert into #TMPProdTest([ID Contrato o Asignación],[Nombre del Pozo SEGUN ANEXO 3 POZOS],Fecha)  
  select NumeroContrato, p.Nombre,@pMes  
  from PR_Pozo p  
  inner join CO_PuntosdeEntregacontrato pec on pec.PuntoEntregaID = p.PuntoEntregaID  
  inner join CO_Contrato c on c.IdContrato = pec.IdContrato  
  where p.id = @pIdPozo  
 end  
  
   
   
   
 /*********ANTES DE ELIMINAR LA PRODUCCIÓN DE LOS DEMÁS POZOS, OBTENER LOS POZOS ACTIVOS POR MES******************/  
 select Mes,  
    Pozos = count(distinct [Nombre del Pozo SEGUN ANEXO 3 POZOS]),  
    SuperficieKmPorPozo = SuperficieKm2 / count(distinct [Nombre del Pozo SEGUN ANEXO 3 POZOS]),  
    ac.SuperficieKm2  
 into #tmpPozosActivos  
 from #TMPProdTest  
 inner join CO_Contrato c on c.IdContrato = @pidContrato  
 inner join CO_AreaContractual ac on ac.IdAreaContractual = c.IdAreaContractual   
 group by Mes,SuperficieKm2  
  
   
  
   
  
   
  
 delete #TMPProdTest  
 where rtrim([Nombre del Pozo SEGUN ANEXO 3 POZOS]) <> rtrim(@nombrePozo)   
  
   
  
   
  
  
  
 select distinct  
  PrecioGas =  @precioGas ,   
  PrecioPetroleo = @precioPetroleo ,  
  PrecioCondensado = @precioCondensado ,  
  TasaRegaliaBase = @tasaRegalia,  
  ProduccionGas = isnull([Producción de Gas Asociado],0),  
  ProduccionGasAcumulado = cast(0 as float),  
  ProduccionPetroleo = isnull([Producción de Petróleo Neto] ,0),  
  ProduccionPetroleoAcumulado = cast(0 as float),  
  ProduccionCondensado = isnull([Producción de Condesado Neto],0),  
  ProduccionCondensadoAcumulado = cast(0 as float),  
  IngresosGas = isnull([Producción de Gas Asociado],0) * isnull(p.PrecioGas,@PrecioGas),  
  IngresosGasAcumulado = cast(0 as float),  
  IngresosPetroleo =  isnull([Producción de Petróleo Neto],0) * isnull(p.precioPetroleo,@precioPetroleo),  
  IngresosPetroleoAcumulado = cast(0 as float),  
  IngresosCondensado = isnull([Producción de Condesado Neto],0) * isnull(p.precioCondensado,@precioCondensado) ,  
  IngresosCondensadoAcumulado = cast(0 as float),  
  Regalia = cast(0 as float),   
  RegaliaAcumulado = cast(0 as float),  
  RegaliaAdicional = cast(0 as float),   
  RegaliaAdicionalAcumulado = cast(0 as float),   
  CuotaContractual = cast(0 as float),   
  CuotaContractualAcumulada = cast(0 as float),   
  ImpuestoFaseEx = cast(0 as float),  
  ImpuestoFaseExAcumulado = cast(0 as float),  
  r.Mes  
 into #tmpResult  
 from #TMPProdTest r  
 left join #tmpPrecios p on p.Mes = r.Mes  
  
  
   
  
  
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
 set CuotaContractual = c.CC * SuperficieKmPorPozo  
 from #tmpResult t  
 inner join #TMPCuotaContractual c on c.Mes = c.Mes  
 inner join #tmpPozosActivos pa on pa.Mes = t.Mes  
  
  
 --Calculo de Impuesto Fase Exploración  
 update #tmpResult  
 set ImpuestoFaseEx = c.CC * SuperficieKmPorPozo  
 from #tmpResult t  
 inner join #TMPCuotaContractual c on c.Mes = c.Mes  
 inner join #tmpPozosActivos pa on pa.Mes = t.Mes  
  
   
   
  
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
  
  
 if isnull(@nombrePozo,'') = ''  
  goto SinPOzo  
  
 /***********************************************/  
   
 if exists (  
  select 1  
  from #tmpResult  
  where Mes = @pMes  
 )  
 begin  
  select '1',PrecioGas  ,   
  PrecioPetroleo  ,  
  PrecioCondensado  ,  
  TasaRegaliaBase ,  
  ProduccionGas ,  
  ProduccionGasAcumulado ,  
  ProduccionPetroleo ,  
  ProduccionPetroleoAcumulado ,  
  ProduccionCondensado ,  
  ProduccionCondensadoAcumulado ,  
  IngresosGas ,  
  IngresosGasAcumulado ,  
  IngresosPetroleo ,  
  IngresosPetroleoAcumulado ,  
  IngresosCondensado  ,  
  IngresosCondensadoAcumulado ,  
  Regalia ,   
  RegaliaAcumulado ,  
  RegaliaAdicional ,   
  RegaliaAdicionalAcumulado ,   
  CuotaContractual ,   
  CuotaContractualAcumulada ,   
  ImpuestoFaseEx ,  
  ImpuestoFaseExAcumulado ,  
  Mes=@pMes,  
  Balance =ISNULL(IngresosGas,0) + ISNULL(IngresosPetroleo,0) +ISNULL(IngresosCondensado,0) - ISNULL(@costos,0),  
  BalanceAcumulado = ISNULL(IngresosGasAcumulado,0)+ ISNULL(IngresosPetroleoAcumulado,0)+ISNULL(IngresosCondensadoAcumulado,0) - ISNULL(@costosAcumulados,0),  
  TotalIngresos = ISNULL(IngresosGas,0) + ISNULL(IngresosPetroleo,0) +ISNULL(IngresosCondensado,0),  
  TotalIngresosAcumulados = ISNULL(IngresosGasAcumulado,0)+ ISNULL(IngresosPetroleoAcumulado,0)+ISNULL(IngresosCondensadoAcumulado,0),  
  BalanceCostos = ISNULL(Regalia,0) + ISNULL(RegaliaAdicional,0) +  ISNULL(CuotaContractual,0)+  ISNULL(ImpuestoFaseEx,0) + ISNULL(@costos,0),  
  BalanceCostosAcumulado = ISNULL(RegaliaAcumulado,0) + ISNULL(RegaliaAdicionalAcumulado,0) +    
        ISNULL(CuotaContractualAcumulada,0)+  ISNULL(ImpuestoFaseExAcumulado,0) +   
        ISNULL(@costosAcumuladoS,0),  
        NombrePozo = @nombrePozo  
  from #tmpResult  
  where Mes = @pMes  
 end  
 Else  
 Begin  
  
  SinPozo:  
    
  Select TOP 1  
  '2',  
  PrecioGas =  isnull(@precioGas,0) ,   
  PrecioPetroleo = isnull(@precioPetroleo,0) ,  
  PrecioCondensado = isnull(@precioCondensado,0) ,  
  TasaRegaliaBase = isnull(@tasaRegalia,0),  
  ProduccionGas =cast(0 as float),  
  ProduccionGasAcumulado =isnull(ProduccionGasAcumulado,0),  
  ProduccionPetroleo = cast(0 as float),  
  ProduccionPetroleoAcumulado = isnull(ProduccionPetroleoAcumulado,0),  
  ProduccionCondensado = cast(0 as float),  
  ProduccionCondensadoAcumulado = isnull(ProduccionCondensadoAcumulado,0),  
  IngresosGas = cast(0 as float),  
  IngresosGasAcumulado,  
  IngresosPetroleo = cast(0 as float),  
  IngresosPetroleoAcumulado ,  
  IngresosCondensado = cast(0 as float) ,  
  IngresosCondensadoAcumulado ,  
  Regalia = cast(0 as float),   
  RegaliaAcumulado ,  
  RegaliaAdicional = cast(0 as float),   
  RegaliaAdicionalAcumulado ,   
  CuotaContractual = cast(0 as float),   
  CuotaContractualAcumulada ,   
  ImpuestoFaseEx = cast(0 as float),  
  ImpuestoFaseExAcumulado,  
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
        NombrePozo = @nombrePozo  
  from #tmpResult  
 End  