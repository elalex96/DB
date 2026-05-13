-- =============================================
-- Author:		Reyna Olvera
-- Create date: 08/02/2018
-- Description:	Nueva metodologia Sipac para ventas
-- =============================================
CREATE PROCEDURE [dbo].[Sp_CO_VentaSipac] 
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
	
										--Venta--
--Cálculo para corregir por temperatura de 20 °C  a 15.56 °C 
--Petróleo mediante el estándar API 11.1
--Factor de Corrección por Temperatura	

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

			Select @Petroleo20C =Petroleo_bl 
			from CO_NMSipacVenta 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes

			Select @APIP=API_Petroleo 
			from CO_NMSipacVenta 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes

			Select @pKgM3=(141.5/(@APIP+131.5))*999.012;

			Select @alfa=(341.0957/Power(@pKgM3,2))
			Select @CLT=Exp(-@alfa*8*(1+0.8*@alfa*8))
			Select @Petroleo_bl15_56C =@Petroleo20C*@CLT;

			--Select @Petroleo20C,@APIP,Round (@pKgM3,1,1),Round (@alfa,5,1),Round (@CLT,7,1),@Petroleo_bl15_56C
			

					-- Gas mediante el estándar API 14.3.3
					--Factor de Corrección por Temperatura		


			Select @Gasmmpc_20C=Gas_mmpc from CO_NMSipacVenta 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes
			Select @FactorCorr=@60F_R/@68F_R;
			Select @Gasmmpc15_56C=@Gasmmpc_20C*@FactorCorr;

			--Select Round (@Gasmmpc_20C,2,1),Round(@FactorCorr,7,1),Round(@Gasmmpc15_56C,2,1);

			
					-- Condensado mediante el estándar API 14.3.3
					--Factor de Corrección por Temperatura		

			Select @Condensado20C = Condensado_bl from CO_NMSipacVenta 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes

			Select @APIC= API_condensado from CO_NMSipacVenta 
			where idContrato=@idContrato and Year(mes)=@año and Month(mes)=@mes
			
			Select @Condensado_pKgM3=(141.5/(@APIC+131.5))*999.012;

			Select @alfa_Condensado=(341.0957/Power(@Condensado_pKgM3,2));
			Select @CTL_Condensado=EXP(-@alfa_Condensado*8*(1+0.8*@alfa_Condensado*8));
			Select @CondensadoBl15_56C=@Condensado20C*@CTL_Condensado;


		--	Select  Round (@Condensado20C,2,1), Round (@APIC,2,1), Round (@Condensado_pKgM3,1), Round (@alfa_Condensado,5,1),
		--	 Round (@CTL_Condensado,7,1), Round (@CondensadoBl15_56C,2,1);

		Declare @FactorPetroleo float,
		@FactorGas float;
	Declare	@factorCondensado float;

		set @FactorPetroleo=@CLT;
		Set @FactorGas=@FactorCorr;


		If(@APIC=51.3)
			Begin 
			
				set @FactorCondensado=@CTL_Condensado;
			End
				Else
					Begin
		
				set @FactorCondensado=0;
					End
		

		Declare
		@PEP15_56Petroleo float,
		@PEP15_56Gas  nvarchar(Max),
		@PEP15_56Condensado float;


		Set @PEP15_56Petroleo=@Petroleo20C;
		Set @PEP15_56Condensado=@Condensado20C
		
		If(@PEP15_56Condensado=@Gasmmpc_20C)
			Begin 
				set @PEP15_56Gas='True';
	
			End
				Else
					Begin
					Set @PEP15_56Gas='False';
		
					End
		
		--Select @PEP15_56Petroleo,@PEP15_56Condensado,@PEP15_56Gas;

		--Tabla de Poder Calorífico Bruto GPA 2145 (btu/pc)
	
	--	Conversion de Energía BTUGN cj @ GPA 2145
	--GPA2145
	Declare @C1_mmbtu float,
			@C2_mmbtu float,
			@C3_mmbtu float,
			@n_C4_mmbtu float,
			@i_C4_mmbtu float,
			@n_C5_mmbtu float,
			@i_C5_mmbtu float,
			@C6_mmbtu float;

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


			
Select @C1mol=Metano_C1,@C2mol=Etano_C2,@C3mol=Propano_c3,
@nC4mol=Butano_nc4,@iC4mol=Butano_IC4,@nC5mol=Pentano_nc5,
@iC5mol=Pentano_IC5,@C6mol=Hexano_C6,@CO2mol=Mol_CO2,@h2sol=Mol_h2s,@N2mol=Mol_N2
from  CO_NMSipacVenta where idContrato=10011 and Year(mes)=2018 and Month(mes)=01;

			if(@PEP15_56Gas='true')
			begin
			Select @C1_mmbtu= Floor(C1*@C1mol/100)from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C2_mmbtu= Floor(C2*@C2mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C3_mmbtu= Floor(C3*@C3mol/100)from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @n_C4_mmbtu= Floor(C4*@nC4mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @i_C4_mmbtu= Floor(IC4*@iC4mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @n_C5_mmbtu= Floor(C5*@nC5mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @i_C5_mmbtu= Floor(IC5*@iC5mol/100)from  [CO_PoderCaloríficoBrutoGPA2145] 
			Select @C6_mmbtu= Floor(C6*@C6mol/100) from  [CO_PoderCaloríficoBrutoGPA2145] 

			
			end

			else 
			Begin
			Select @C1_mmbtu= 0;
			Select @C2_mmbtu= 0;
			Select @C3_mmbtu=0;
			Select @n_C4_mmbtu=0;
			Select @i_C4_mmbtu= 0;
			Select @n_C5_mmbtu= 0;
			Select @i_C5_mmbtu=0;
			Select @C6_mmbtu=0;
			End


			--Sipac Venta
			--DROP TABLE IF EXISTS #SipacVenta;
			DROP TABLE #SipacVenta
		Select @PEP15_56Petroleo as Petroleo,@C1_mmbtu as C1,@C2_mmbtu as C2,@C3_mmbtu as C3,
			   @n_C4_mmbtu+@i_C4_mmbtu as C4,Floor(@Condensado20C) as Condensado
		into #SipacVenta

		
		Select * from #SipacVenta;




END
