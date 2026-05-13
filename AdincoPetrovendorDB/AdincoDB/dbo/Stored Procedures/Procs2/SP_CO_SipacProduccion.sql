-- =============================================
-- Author:		Reyna Olvera
-- Create date: 08/02/2018
-- Description:	Nueva metodologia Sipac para Produccion
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_SipacProduccion]
	-- Add the parameters for the stored procedure here
@Idcontrato int,
@Año int,
@mes int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
					
--		Variables para petroleo
Declare @Petroleo20C float , --petroleo  a 20 grados °C
		@APIP float,
		@pKgM3 float,
		@alfa float,
		@CLT float,
		@Petroleo_bl15_56C float; --petroleo  a 15.56 grados °C


--Variables para Gas
Declare @Gasmmpc_20C float, --Gas(mmpc) a 20 grados °C
		@60F_R float = 519.67, -- 60 grados Fahrenheit a rankine
		@68F_R float = 527.67, --68  grados Fahrenheit a rankine
		@FactorCorr float,
		@Gasmmpc15_56C float;-- Gas(mmpc) a 15.56 grados °C


--Variables para Condensado
Declare @Condensado20C float,
@APIC float,
@Condensado_pKgM3 float,
@alfa_Condensado float,
@CTL_Condensado float,
@CondensadoBl15_56C float;


--Variables para sacar datos de cromatografia 

Declare @C1mol float,
@C2mol float,
@C3mol float,
@nC4mol float,
@iC4mol float,
@nC5mol float,
@iC5mol float,
@C6mol float,
@CO2mol float,
@h2sol float,
@N2mol float;


			-----Paso 2	Cálculo para corregir por temperatura de 20 °C  a 15.56 °C 

------Petróleo mediante el estándar API 11.1
			Select @Petroleo20C =Petroleo_bl 
			from CO_NMSipacProduccion 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes

			Select @APIP=API_Petroleo 
			from CO_NMSipacProduccion 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes


Select @C1mol=Metano_C1,@C2mol=Etano_C2,@C3mol=Propano_c3,
@nC4mol=Butano_nc4,@iC4mol=Butano_IC4,@nC5mol=Pentano_nc5,
@iC5mol=Pentano_IC5,@C6mol=Hexano_C6,@CO2mol=Mol_CO2,@h2sol=Mol_h2s,@N2mol=Mol_N2
from  CO_NMSipacProduccion where idContrato=10011 and Year(mes)=2018 and Month(mes)=01;

Select @pKgM3=(141.5/(@APIP+131.5))*999.012;

			Select @alfa=(341.0957/Power(@pKgM3,2))
			Select @CLT=Exp(-@alfa*8*(1+0.8*@alfa*8))
			Select @Petroleo_bl15_56C =@Petroleo20C*@CLT;

--Select @Petroleo20C,@APIP,Round (@pKgM3,1,1),Round (@alfa,5,1),Round (@CLT,7,1),@Petroleo_bl15_56C
			

-------------------------Gas mediante el estándar API 14.3.3 -------------------------
-------------------------Factor de Corrección por Temperatura-------------------------	
			Select @Gasmmpc_20C=Gas_mmpc from CO_NMSipacProduccion 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes
			Select @FactorCorr=@60F_R/@68F_R;
			Select @Gasmmpc15_56C=@Gasmmpc_20C*@FactorCorr;

--Select Round (@Gasmmpc_20C,2,1),Round(@FactorCorr,7,1),Round(@Gasmmpc15_56C,2,1);

			
-------------------------- Condensado mediante el estándar API 14.3.3-------------------------
--------------------------Factor de Corrección por Temperatura-------------------------	

			Select @Condensado20C = Condensado_bl from CO_NMSipacProduccion 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes

			Select @APIC= API_condensado from CO_NMSipacProduccion 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes
			
			Select @Condensado_pKgM3=(141.5/(@APIC+131.5))*999.012;

			Select @alfa_Condensado=(341.0957/Power(@Condensado_pKgM3,2));
			Select @CTL_Condensado=EXP(-@alfa_Condensado*8*(1+0.8*@alfa_Condensado*8));
			Select @CondensadoBl15_56C=@Condensado20C*@CTL_Condensado;


--Select  Round (@Condensado20C,2,1), Round (@APIC,2,1), Round (@Condensado_pKgM3,1), Round (@alfa_Condensado,5,1),
--Round (@CTL_Condensado,7,1), Round (@CondensadoBl15_56C,2,1);


--------------------------------------------------------- 
		Declare @FactorPetroleo float,
		@FactorGas float,
		@factorCondensado float;

		set @FactorPetroleo=@CLT;
		Set @FactorGas=@FactorCorr;
		set @factorCondensado=@CTL_Condensado

--Select @FactorPetroleo,@FactorGas,@factorCondensado
-----------------------------------------------------------

------------------------------Correcion por Temperatura del  Reporte de volúmenes de PEP a 15.56 °C--------------------------------------------------
		Declare
		@PEP15_56Petroleo float,
		@PEP15_56Gas  float,
		@PEP15_56Condensado float;


		Set @PEP15_56Petroleo=@Petroleo_bl15_56C;
		set @PEP15_56Gas=@Gasmmpc_20C*@FactorGas;
		Set @PEP15_56Condensado=@Condensado20C*@factorCondensado;
	
--Select @PEP15_56Petroleo,@PEP15_56Gas,@PEP15_56Condensado
												----------Paso 3-------
---------------------------Cálculo para convertir volumen de gas a equivalente energético usando el poder calorífico bruto de la norma GPA 2145 (Conversion de Energía MMBTU´S)-------------------------

-----------------------------Conversion de Energía BTUGN cj @ GPA 2145--------------------------------------------------
			Declare @C1_mmbtu float,
			@C2_mmbtu float,
			@C3_mmbtu float,
			@n_C4_mmbtu float,
			@i_C4_mmbtu float,
			@n_C5_mmbtu float,
			@i_C5_mmbtu float,
			@C6_mmbtu float;
		
		

		
				Select @C1_mmbtu= Convert(int,C1*@PEP15_56Gas*@C1mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C2_mmbtu= Convert(int,C2*@PEP15_56Gas*@C2mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C3_mmbtu= Convert(int,C3*@PEP15_56Gas*@C3mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @n_C4_mmbtu= Convert(int,C4*@PEP15_56Gas*@nC4mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @i_C4_mmbtu= Convert(int,IC4*@PEP15_56Gas*@iC4mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @n_C5_mmbtu=Convert(int,C5*@PEP15_56Gas*@nC5mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @i_C5_mmbtu= Convert(int,IC5*@PEP15_56Gas*@iC5mol/100) from  [CO_PoderCaloríficoBrutoGPA2145]
			Select @C6_mmbtu= Convert(int,C6*@PEP15_56Gas*@C6mol/100) from  [CO_PoderCaloríficoBrutoGPA2145]
--Select @C1_mmbtu,@C2_mmbtu,@C3_mmbtu,@n_C4_mmbtu,@i_C4_mmbtu,@n_C5_mmbtu,@i_C5_mmbtu,@C6_mmbtu----

------------------------------------------------------Conversion de Energía BTUGN cj @ GPA 2145 Por Gas(mmpc)--------------------------------------------------
			Declare @C1_mmbtuxGasmmpc float,
			@C2_mmbtuxGasmmpc float,
			@C3_mmbtuxGasmmpc float,
			@n_C4_mmbtuxGasmmpc float,
			@i_C4_mmbtuxGasmmpc float,
			@n_C5_mmbtuxGasmmpc float,
			@i_C5_mmbtuxGasmmpc float,
			@C6_mmbtuxGasmmpc float;
		


			Select @C1_mmbtuxGasmmpc= Convert(int,C1*@Gasmmpc_20C*@C1mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C2_mmbtuxGasmmpc=Convert(int,C2*@Gasmmpc_20C*@C2mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C3_mmbtuxGasmmpc= Convert(int,C3*@Gasmmpc_20C*@C3mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @n_C4_mmbtuxGasmmpc= Convert(int,C4*@Gasmmpc_20C*@nC4mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @i_C4_mmbtuxGasmmpc= Convert(int,IC4*@Gasmmpc_20C*@iC4mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @n_C5_mmbtuxGasmmpc= Convert(int,C5*@Gasmmpc_20C*@nC5mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @i_C5_mmbtuxGasmmpc= Convert(int,IC5*@Gasmmpc_20C*@iC5mol/100) from  [CO_PoderCaloríficoBrutoGPA2145]
			Select @C6_mmbtuxGasmmpc= Convert(int,C6*@Gasmmpc_20C*@C6mol/100) from  [CO_PoderCaloríficoBrutoGPA2145]
			

--Select @C1_mmbtuxGasmmpc,@C2_mmbtuxGasmmpc,@C3_mmbtuxGasmmpc,@n_C4_mmbtuxGasmmpc,@i_C4_mmbtuxGasmmpc,@n_C5_mmbtuxGasmmpc
--,@i_C5_mmbtuxGasmmpc,@C6_mmbtuxGasmmpc;

												-----------Paso 4-----------
------------------------- Para calcular la Conversion de Energía BTUGN cj @ GPA 2145 el Condesado  ( C5+ Eq. (bl) mediante estándar API 14.4-------------------------

--------------------------------------------------Caluco del Yi* PMi (lb/mol)--------------------------------------------------
--DROP TABLE IF EXISTS  #Caluco_Yi_PMi;
Drop table #Caluco_Yi_PMi;

Select
		@idContrato as IdContrato,
		@C1mol *C1 /100  as C1,
	   @C2mol*c2/100 as C2,
	   @C3mol*c3/100 as C3,
	   @nC4mol*nC4/100 as nC4,
	   @iC4mol*IC4/100 as iC4,
	   @nC5mol*nC5/100 as nC5,
	   @iC5mol*Ic5/100 as IC5,
	   @C6mol*C6/100 as C6,
	   @CO2mol * CO2/100 as CO2,
		@h2sol *H2S/100 as H2S,
		@N2mol *N2/100 as N2
		into #Caluco_Yi_PMi
		From  CO_PesoMolecularGPA2145

Declare @PM_Mezcla float;
		
		Select @PM_Mezcla =c1+c2+c3+nc4+ic4+nc5+ic5+c6+co2+H2S+N2 
		from #Caluco_Yi_PMi

		--DROP TABLE IF EXISTS  #MezclaAire;
		Drop table #MezclaAire

		Select
		@idContrato as IdContrato,
		@PM_Mezcla as PMMezcla,
		@PM_Mezcla/PmAire as DensRel,
		(@PM_Mezcla/PmAire)*DenSaire as DensMezcla,
		@PEP15_56Gas*((@PM_Mezcla/PmAire)*DenSaire)*1000 as MtGas 
		into #MezclaAire
		From CO_DatosAire


--------------------------------------------------Calculo Calculo Xi = Yi*Pmi / Sum (Yi*PM)--------------------------------------------------
--DROP TABLE IF EXISTS  #CalculoXi
		Drop table #CalculoXi
		Select
		@idContrato as IdContrato,
		 C1/@PM_Mezcla as C1,
		C2/@PM_Mezcla as C2,
		C3/@PM_Mezcla as C3,
		nC4/@PM_Mezcla as nC4,
		iC4/@PM_Mezcla as iC4,
		nC5 /@PM_Mezcla as nC5,
		iC5/@PM_Mezcla as  iC5,
		C6/@PM_Mezcla as  C6,
		CO2 /@PM_Mezcla as CO2,
		H2S /@PM_Mezcla as H2S,
		N2/@PM_Mezcla as  N2
		into #CalculoXi
		from #Caluco_Yi_PMi



--------------------------------------------------Calculo de la Masa (lb)--------------------------------------------------
--DROP TABLE IF EXISTS  #CalculoMasa

		Drop table #CalculoMasa

		Select 
		MA.idcontrato,
		C1*MtGas as C1,
		C2*MtGas as C2,
		C3*MtGas as C3,
		nC4*MtGas as nC4,
		iC4*MtGas as iC4,
		nC5 *MtGas as nC5,
		iC5*MtGas as  iC5,
		C6*MtGas as  C6,
		CO2*MtGas as CO2,
		H2S*MtGas as H2S,
		N2*MtGas as  N2
		into #CalculoMasa
		From #CalculoXi xi
		Join #MezclaAire Ma on MA.IdContrato= xi.IdContrato

--------------------------------------------------Calculo del Volumen  (lb)--------------------------------------------------
--DROP TABLE IF EXISTS  #CalculoVolumen 
		Drop table #CalculoVolumen  
		Select 
		CM.idContrato as idContrato,
		(CM.C1/Dens.C1)/42 as C1,
		(CM.C2/Dens.C2)/42 as C2,
		(CM.C3/Dens.C3)/42 as C3,
		(CM.nC4/Dens.nC4)/42 as nC4,
		(CM.iC4/Dens.iC4)/42 as iC4,
		(CM.nC5/Dens.nC5)/42 as nC5,
		(CM.iC5/Dens.iC5)/42 as iC5,
		(CM.C6/Dens.C6)/42 as C6,
		(CM.CO2/Dens.CO2)/42 as CO2,
		(CM.H2S/Dens.H2S)/42 as H2S,
		(CM.N2/Dens.N2)/42 as N2
		into #CalculoVolumen
		From #CalculoMasa CM
		Join CO_DensidadGPA2145 Dens on CM.idContrato= Dens.Idcontrato
	
		--Select * from CO_DensidadGPA2145
		--Select * from #CalculoVolumen


		Declare @C5Eq float
		Select  @C5Eq= nC5+iC5+C6
		from #CalculoVolumen;


		Declare @PoderCalorificoTodos float;
		Select @PoderCalorificoTodos=+(C1*@C1_mmbtu)+(C2*@C2_mmbtu)+(C3*@C3_mmbtu)+(C4*@n_C4_mmbtu)+(IC4+@i_C4_mmbtu)
		+(C5*@n_C5_mmbtu)+(IC5*@i_C5_mmbtu)+(C6*@C6_mmbtu)
		from  [CO_PoderCaloríficoBrutoGPA2145] 
	--	Select @PoderCalorificoTodos;

		Declare @ImporteGas float;
		Select @ImporteGas=ImporteGas
from  CO_NMSipacProduccion where idContrato=10011 and Year(mes)=2018 and Month(mes)=01;

	Declare @C1CalculoPrecio float,@C2CalculoPrecio float,@C3CalculoPrecio float,@nC4CalculoPrecio float,
	@IC4CalculoPrecio float, @C4CalculoPrecio float,@IngresosC1_c2_c3_c4 float,@IngresosCondensados float, @Condensado float;
		Select
		@C1CalculoPrecio= (C1/@PoderCalorificoTodos)*@ImporteGas,
		@C2CalculoPrecio=(C2/@PoderCalorificoTodos)*@ImporteGas,
		@C3CalculoPrecio=(C3/@PoderCalorificoTodos)*@ImporteGas ,
		@nC4CalculoPrecio=(C4/@PoderCalorificoTodos)*@ImporteGas,
		@IC4CalculoPrecio=(IC4/@PoderCalorificoTodos)*@ImporteGas,
		@C4CalculoPrecio=((@nC4CalculoPrecio*@nC4mol)+(@iC4mol*@IC4CalculoPrecio))/(@nC4mol+@iC4mol),
		@IngresosC1_c2_c3_c4=+((@C1CalculoPrecio/1)*@C1_mmbtu)+((@C2CalculoPrecio*1)*@C2_mmbtu)+(@C3CalculoPrecio)*@C3_mmbtu+(@C4CalculoPrecio*((@n_C4_mmbtu+@i_C4_mmbtu)*1)),
		@IngresosCondensados=@ImporteGas-@IngresosC1_c2_c3_c4,
		@Condensado=@IngresosCondensados/@C5Eq

		From [CO_PoderCaloríficoBrutoGPA2145]
	
	--Select @C1CalculoPrecio,@C2CalculoPrecio,@C3CalculoPrecio,@nC4CalculoPrecio,@IC4CalculoPrecio,@C4CalculoPrecio,@IngresosC1_c2_c3_c4,
	-- @IngresosCondensados,@Condensado;


		
	
-------------------------Paso 7 Valores de produccion Sipac-------------------------
--DROP TABLE IF EXISTS  #SipacVenta
	Drop table #SipacVenta
	Select 
	@PEP15_56Petroleo as Petroleo,
	@C1_mmbtu as C1,
	@C2_mmbtu as c2,
	@C3_mmbtu as C3,
	@n_C4_mmbtu+@i_C4_mmbtu as c4,
	Round(@PEP15_56Condensado+@C5Eq,2,1) as Condensado
	into #SipacVenta


	--DROP TABLE IF EXISTS  #SipacProduccion
	Drop table #SipacProduccion
	Select
	 @C1_mmbtuxGasmmpc as C1,
	@C2_mmbtuxGasmmpc as C2,
	@C3_mmbtuxGasmmpc as C3,
	@n_C4_mmbtuxGasmmpc+@i_C4_mmbtuxGasmmpc as C4,
	Round(@Condensado20C+@C5Eq,2,1) as Condensado
	into #SipacProduccion


	--DROP TABLE IF EXISTS  #Precios
	Drop table #Precios
	Select
	Round( @C1CalculoPrecio,2,1) as C1,
	Round(@C2CalculoPrecio,2,1) as C2,
	Round(@C3CalculoPrecio,2,1) as C3,
	Round(@C4CalculoPrecio,2,1) as C4,
	Round(@Condensado,2,1) as Condensado

	Into #Precios

--------------------------------------------------
	Select * from #SipacVenta
	Select * from #SipacProduccion
	Select * from #Precios
--------------------------------------------------

END
