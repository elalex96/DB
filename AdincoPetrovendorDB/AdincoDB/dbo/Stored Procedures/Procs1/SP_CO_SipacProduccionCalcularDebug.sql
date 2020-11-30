CREATE PROCEDURE [dbo].[SP_CO_SipacProduccionCalcularDebug] --3,'20180701',1014,1
    @Idcontrato      INT,
    @fechaMesDiaAnio DATE,
    @puntoEntrega    INT,
	@Usuario	INT = 1
AS
BEGIN
--exec [SP_CO_SipacProduccionCalcular] 3,'2018-05-01',1014
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 08/02/2018
-- Description:	Nueva metodologia Sipac para Produccion
-- -------------------------------------------------
-- 20180405	BAAC	Modificación para guardar lo calculado en una tabla
-- 20180507	BAAC	Se modifica para no borrar las comercializaciones correspondientes a PEMEX
-- 20180606	BAAC	Se modifica para que las comercializaciones se generen con fecha del ultimo dia del mes
-- 20180704	BAAC	Se modifica para guardar un log de los parametros utilizados para el calculo
-- 20180816 Se modifica para identificar si es gas condensable y posteriormente ligar la factura en automático
-- =============================================
SET NOCOUNT ON
--************************************************************************************************
CREATE TABLE #DiasHabiles
(
	Fecha       DATETIME,
	Anio        INT,
	Mes         INT,
	Dia         INT,
	NumDiaHabil INT
)

CREATE TABLE #Calculo_Yi_PMi
(
	IdContrato	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #MezclaAire
(
	IdContrato	INT,
	PMMezcla	FLOAT,
	DensRel		FLOAT,
	DensMezcla	FLOAT,
	MtGas		FLOAT,
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #CalculoXi
(
	IdContrato	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #CalculoMasa
(
	IdContrato	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #CalculoVolumen
(
	IdContrato	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #SipacVenta
(
	idContrato	INT,
	Petroleo_Venta	FLOAT,
	C1Venta	FLOAT,
	C2Venta	FLOAT,
	C3Venta	FLOAT,
	C4Venta	FLOAT,
	Condensado_Venta FLOAT,
	Condensable_Venta FLOAT
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #SipacProduccion
(
	idContrato	INT,
	PetroleoProduccion	FLOAT,
	C1Produccion	FLOAT,
	C2Produccion	FLOAT,
	C3Produccion	FLOAT,
	C4Produccion	FLOAT,
	Condensado_Produccion FLOAT,
	Condensable_Produccion FLOAT
	PRIMARY KEY (IdContrato)
)

CREATE TABLE #Precios
(
	idContrato		INT,
	Petroleo_Precio	FLOAT,
	C1Precios		FLOAT,
	C2Precios		FLOAT,
	C3Precios		FLOAT,
	C4Precios		FLOAT,
	Condensado_Precios	FLOAT,
	PRIMARY KEY (IdContrato)
)

DECLARE
	@FechaLimite DATETIME,
    @Año INT,
    @mes INT,
	-- Variables para petroleo
    @Petroleo20C       FLOAT = 0, --petroleo  a 20 grados °C
    @APIP              FLOAT = 0,
    @pKgM3             FLOAT,
    @alfa              FLOAT,
    @CLT               FLOAT,
    @Petroleo_bl15_56C FLOAT, --petroleo  a 15.56 grados °C
    --Variables para Gas
    @Gasmmpc_20C   FLOAT = 0, --Gas(mmpc) a 20 grados °C
    @60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
    @FactorCorr    FLOAT,
    @Gasmmpc15_56C FLOAT, -- Gas(mmpc) a 15.56 grados °C
	--Variables para Condensado
    @Condensado20C      FLOAT = 0,
    @APIC               FLOAT = 0,
    @Condensado_pKgM3   FLOAT,
    @alfa_Condensado    FLOAT,
    @CTL_Condensado     FLOAT,
    @CondensadoBl15_56C FLOAT,
    --Variables para sacar datos de cromatografia 
    @C1mol  FLOAT,
    @C2mol  FLOAT,
    @C3mol  FLOAT,
    @nC4mol FLOAT,
    @iC4mol FLOAT,
  @nC5mol FLOAT,
    @iC5mol FLOAT,
    @C6mol  FLOAT,
    @CO2mol FLOAT,
    @h2sol  FLOAT,
    @N2mol  FLOAT,
    @FactorPetroleo   FLOAT,
    @FactorGas        FLOAT,
    @factorCondensado FLOAT,
    @PEP15_56Petroleo   FLOAT,
    @PEP15_56Gas        FLOAT,
    @PEP15_56Condensado FLOAT,
	-----Conversion de Energía BTUGN cj @ GPA 2145--------------------------
    @C1_mmbtu   FLOAT,
    @C2_mmbtu   FLOAT,
    @C3_mmbtu   FLOAT,
    @n_C4_mmbtu FLOAT,
    @i_C4_mmbtu FLOAT,
    @n_C5_mmbtu FLOAT,
    @i_C5_mmbtu FLOAT,
    @C6_mmbtu   FLOAT,
    @C1_mmbtuxGasmmpc   FLOAT,
    @C2_mmbtuxGasmmpc   FLOAT,
    @C3_mmbtuxGasmmpc   FLOAT,
    @n_C4_mmbtuxGasmmpc FLOAT,
    @i_C4_mmbtuxGasmmpc FLOAT,
    @n_C5_mmbtuxGasmmpc FLOAT,
	@i_C5_mmbtuxGasmmpc FLOAT,
    @C6_mmbtuxGasmmpc   FLOAT,
	@PM_Mezcla FLOAT,
	------Calculo del Volumen  (lb)--------------------
    @DescC1  FLOAT,
    @DescC2  FLOAT,
    @DescC3  FLOAT,
    @DescnC4 FLOAT,
    @DescIC4 FLOAT,
    @DescnC5 FLOAT,
    @DescIC5 FLOAT,
    @DescC6  FLOAT,
    @DescCO2 FLOAT,
    @DescH2S FLOAT,
    @DescN2  FLOAT,
	@C5Eq	FLOAT,
	@PoderCalorificoTodos FLOAT,
	@ImporteGas FLOAT,
	@ImportePetroleo FLOAT,
	@C1CalculoPrecio     FLOAT,
    @C2CalculoPrecio     FLOAT,
    @C3CalculoPrecio     FLOAT,
    @nC4CalculoPrecio    FLOAT,
    @IC4CalculoPrecio    FLOAT,
    @C4CalculoPrecio     FLOAT,
    @IngresosC1_c2_c3_c4 FLOAT,
    @IngresosCondensados FLOAT,
    @Condensado          FLOAT,
	@Azufre				FLOAT,
	@PromAPI			FLOAT,
	@PromAzufre			FLOAT,
	@UniMedidaBl		INT,
	@UniMedidaBTU		INT,
	@RegistrosActualizados	INT,
	@TotalVolumenPetroleo	FLOAT

-- SE VALIDA QUE EL REPORTE SE ESTE GENERANDO DURANTE LOS PRIMEROS 10 DIAS HABILES DEL SIGUIENTE MES
INSERT INTO #DiasHabiles
(
	Fecha,
	Anio,
	Mes,
	Dia,
	NumDiaHabil
)
SELECT
	IdFecha,
	Anio,
	Mes,
	Dia,
	ROW_NUMBER() OVER (ORDER BY Dia) AS NumDiaHabil
FROM
	dbo.AP_Calendario
WHERE
	PrimerDiaMes  = DATEADD( MONTH, 1, @fechaMesDiaAnio )
	AND NombreDia NOT IN ( 'Sábado', 'Domingo' )
	AND DiaFeriado <> 1
ORDER BY
	Dia

SELECT
	@FechaLimite = DATEADD( MINUTE, 59, DATEADD( HOUR, 23, Fecha ))
FROM
	#DiasHabiles
WHERE
	NumDiaHabil = 10

--Calculo del volumen de crudo a vender basado en reparticion preliminar
SELECT	@UniMedidaBl = idUnidadMedida
FROM dbo.CO_UnidadMedida
WHERE	Abreviatura = 'BL'

SELECT	@UniMedidaBTU = idUnidadMedida
FROM dbo.CO_UnidadMedida
WHERE	Abreviatura = 'MMBTU'
-- HACER CALCULOS AQUI
-----Paso 2	Cálculo para corregir por temperatura de 20 °C  a 15.56 °C 

------Petróleo mediante el estándar API 11.1
Select * from [PR_ProduccionMensualSipac]
--***************************************************************
SELECT
    @Petroleo20C = VolumenProgramado
FROM
    PR_ProduccionMensualSipac
WHERE
    idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
    AND idHidrocarburo = 1001
    AND PuntoEntregaID = @puntoEntrega

--Select @APIP=GradosApi 
--	from [PR_ProduccionMensualSipac] 
--	where idContrato=@idContrato
--	and idFecha=@fechaMesDiaAnio 
--	and idHidrocarburo=1001 
--	and PuntoEntregaId=@puntoEntrega

--************************************Checar esta tabla de cromatografia********************************************
--******************************************************************************
--Select @C1mol=Metano_C1,@C2mol=Etano_C2,@C3mol=Propano_c3,
--@nC4mol=Butano_nc4,@iC4mol=Butano_IC4,@nC5mol=Pentano_nc5,
--@iC5mol=Pentano_IC5,@C6mol=Hexano_C6,@CO2mol=Mol_CO2,@h2sol=Mol_h2s,@N2mol=Mol_N2
--from  CO_NMSipacProduccion where idSipacProduccion=1000

SELECT
	@APIP = ISNULL(CV.GradosAPI,0),
	@Azufre	=	ISNULL(CV.Azufre,0),
    @C1mol  = ISNULL(CV.C1,0),
    @C2mol  = ISNULL(CV.C2,0),
    @C3mol  = ISNULL(CV.C3,0),
    @nC4mol = ISNULL(CV.nC4,0),
    @iC4mol = ISNULL(CV.lC4,0),
    @nC5mol = ISNULL(CV.nC5,0),
    @iC5mol = ISNULL(CV.lC5,0),
    @C6mol  = ISNULL(CV.C6_plus,0),
    @CO2mol = ISNULL(CV.MOL_CO2,0),
    @h2sol  = ISNULL(CV.MOL_h2S,0),
    @N2mol  = ISNULL(CV.MOL_N2,0),
	@ImportePetroleo = ISNULL(CV.PrecioPetroleo,0),
    @ImporteGas      = ISNULL(CV.PrecioGas,0)
FROM
    CO_Cromatografia             C
JOIN
    CO_CromatografiaValores      CV
    ON C.IdCromatografia     = CV.IdCromatografia
JOIN
    CO_PuntosdeEntregaContrato	 PEC
    ON c.IdContrato	=	PEC.idContrato
	AND CV.IdPuntoEntregaContrato = PEC.PuntoEntregaContratoID
WHERE
    C.IdContrato                 = @Idcontrato
    AND Mes                  = MONTH( @fechaMesDiaAnio )
    AND Anio                      = YEAR( @fechaMesDiaAnio )
    AND PEC.PuntoEntregaID		= @puntoEntrega

SELECT
	@TotalVolumenPetroleo	=	SUM(VolumenProgramado)
FROM
    PR_ProduccionMensualSipac
WHERE
    idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
    AND idHidrocarburo = 1001


SELECT
	@PromAPI = SUM((ISNULL(CV.GradosAPI,0) * P.VolumenProgramado)/@TotalVolumenPetroleo),
	@PromAzufre	=	SUM((ISNULL(CV.Azufre,0) * P.VolumenProgramado)/@TotalVolumenPetroleo)
FROM
	PR_ProduccionMensualSipac	P
JOIN
    CO_Cromatografia             C
	ON	P.idContrato	=	C.IdContrato
	AND YEAR( P.idFecha )	=	C.Anio
	AND MONTH( P.idFecha )	=	C.Mes
JOIN
    CO_CromatografiaValores      CV
    ON C.IdCromatografia         = CV.IdCromatografia
JOIN
    CO_PuntosdeEntregaContrato	 PEC
    ON	C.IdContrato		=	PEC.idContrato
	AND CV.IdPuntoEntregaContrato = PEC.PuntoEntregaContratoID
WHERE
    P.IdContrato                 = @Idcontrato
    AND P.idFecha                = @fechaMesDiaAnio
	AND P.idHidrocarburo = 1001

--********************************************************************************
--******************************************************************************
SELECT
    @pKgM3 = (141.5 / (@APIP + 131.5)) * 999.012
SELECT
    @alfa = (341.0957 / POWER( @pKgM3, 2 ))
SELECT
    @CLT = EXP( -@alfa * 8 * (1 + 0.8 * @alfa * 8))
SELECT
    @Petroleo_bl15_56C = @Petroleo20C * @CLT

--Select @Petroleo20C,@APIP,Round (@pKgM3,1,1),Round (@alfa,5,1),Round (@CLT,7,1),@Petroleo_bl15_56C

-------------------------Gas mediante el estándar API 14.3.3 -------------------------
-------------------------Factor de Corrección por Temperatura-------------------------	
SELECT
    @Gasmmpc_20C = ISNULL(VolumenProgramado,0)
FROM
    [PR_ProduccionMensualSipac]
WHERE
    idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
    AND idHidrocarburo = 1000
    AND PuntoEntregaID = @puntoEntrega

SELECT
    @FactorCorr = @60F_R / @68F_R
SELECT
    @Gasmmpc15_56C = @Gasmmpc_20C * @FactorCorr

--Select Round (@Gasmmpc_20C,2,1),Round(@FactorCorr,7,1),Round(@Gasmmpc15_56C,2,1)

-------------------------- Condensado mediante el estándar API 14.3.3-------------------------
--------------------------Factor de Corrección por Temperatura-------------------------	
SELECT
    @Condensado20C = ISNULL(VolumenProgramado,0)
FROM
    PR_ProduccionMensualSipac
WHERE
    idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
    AND idHidrocarburo = 1002
    AND PuntoEntregaID = @puntoEntrega

SELECT
    @APIC = 0
--*************Se comento Por que el condensado por ser calculado, más no real, yt es condensado de gas no tiene grados API***********
--GradosApi 
--		  From CO_Cromatografia C
--JOIN CO_CromatografiaValores CV on C.idCromatografia =CV.idCromatografia
--JOIN [CO_PuntosdeEntregaContrato] PEC on CV.idPuntoEntregacontrato=PEC.PuntoEntregaContratoID
--where c.idContrato=@idContrato AND MES=MONTH(@fechaMesDiaAnio) AND Anio=YEAR(@fechaMesDiaAnio)
--AND CV.idPuntoEntregacontrato=@puntoEntregaContratoId
--************************************************************************************************

SELECT
    @Condensado_pKgM3 = (141.5 / (@APIC + 131.5)) * 999.012

SELECT
    @alfa_Condensado = (341.0957 / POWER( @Condensado_pKgM3, 2 ))
SELECT
    @CTL_Condensado = EXP( -@alfa_Condensado * 8 * (1 + 0.8 * @alfa_Condensado * 8))
SELECT
    @CondensadoBl15_56C = @Condensado20C * @CTL_Condensado


--Select  Round (@Condensado20C,2,1), Round (@APIC,2,1), Round (@Condensado_pKgM3,1), Round (@alfa_Condensado,5,1),
--Round (@CTL_Condensado,7,1), Round (@CondensadoBl15_56C,2,1)
--------------------------------------------------------- 

SELECT
	@FactorPetroleo = @CLT,
	@FactorGas = @FactorCorr,
	@factorCondensado = @CTL_Condensado

--Select @FactorPetroleo,@FactorGas,@factorCondensado
-----------------------------------------------------------
------------------------------Correcion por Temperatura del  Reporte de volúmenes de PEP a 15.56 °C--------------------------------------------------
SELECT
	@PEP15_56Petroleo = @Petroleo_bl15_56C,
	@PEP15_56Gas = @Gasmmpc_20C * @FactorGas,
	@PEP15_56Condensado = @Condensado20C * @factorCondensado

--Select @PEP15_56Petroleo,@PEP15_56Gas,@PEP15_56Condensado
----------Paso 3-------
---------------------------Cálculo para convertir volumen de gas a equivalente energético usando el poder calorífico bruto de la norma GPA 2145 (Conversion de Energía MMBTU´S)-------------------------

SELECT
    @C1_mmbtu = C1 * @PEP15_56Gas * @C1mol / 100,
	@C2_mmbtu = C2 * @PEP15_56Gas * @C2mol / 100,
	@C3_mmbtu = C3 * @PEP15_56Gas * @C3mol / 100,
	@n_C4_mmbtu = C4 * @PEP15_56Gas * @nC4mol / 100,
	@i_C4_mmbtu = IC4 * @PEP15_56Gas * @iC4mol / 100,
	@n_C5_mmbtu = C5 * @PEP15_56Gas * (@nC5mol+@iC5mol +@C6mol) / 100,
	@i_C5_mmbtu = IC5 * @PEP15_56Gas * @iC5mol / 100,
	@C6_mmbtu = C6 * @PEP15_56Gas * @C6mol / 100
FROM
    [CO_PoderCaloríficoBrutoGPA2145]

--Select @C1_mmbtu,@C2_mmbtu,@C3_mmbtu,@n_C4_mmbtu,@i_C4_mmbtu,@n_C5_mmbtu,@i_C5_mmbtu,@C6_mmbtu----
------------------------------------------------------Conversion de Energía BTUGN cj @ GPA 2145 Por Gas(mmpc)--------------------------------------------------
SELECT
    @C1_mmbtuxGasmmpc =( C1 * @Gasmmpc_20C * @C1mol / 100),
	@C2_mmbtuxGasmmpc = (C2 * @Gasmmpc_20C * @C2mol / 100),
	@C3_mmbtuxGasmmpc =( C3 * @Gasmmpc_20C * @C3mol / 100),
	@n_C4_mmbtuxGasmmpc =( C4 * @Gasmmpc_20C * @nC4mol / 100),
	@i_C4_mmbtuxGasmmpc = (IC4 * @Gasmmpc_20C * @iC4mol / 100),
	@n_C5_mmbtuxGasmmpc = (C5 * @Gasmmpc_20C * @nC5mol / 100),
	@i_C5_mmbtuxGasmmpc =( IC5 * @Gasmmpc_20C * @iC5mol / 100),
	@C6_mmbtuxGasmmpc = (C6 * @Gasmmpc_20C * @C6mol / 100)
FROM
    [CO_PoderCaloríficoBrutoGPA2145]

--Select @C1_mmbtuxGasmmpc,@C2_mmbtuxGasmmpc,@C3_mmbtuxGasmmpc,@n_C4_mmbtuxGasmmpc,@i_C4_mmbtuxGasmmpc,@n_C5_mmbtuxGasmmpc
--,@i_C5_mmbtuxGasmmpc,@C6_mmbtuxGasmmpc

-----------Paso 4-----------
------------------------- Para calcular la Conversion de Energía BTUGN cj @ GPA 2145 el Condesado  ( C5+ Eq. (bl) mediante estándar API 14.4-------------------------
--------------------------------------------------Caluco del Yi* PMi (lb/mol)--------------------------------------------------
--DROP TABLE IF EXISTS  #Caluco_Yi_PMi
INSERT INTO #Calculo_Yi_PMi
(
	IdContrato,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
    @Idcontrato         AS IdContrato,
    @C1mol * C1 / 100   AS C1,
    @C2mol * C2 / 100   AS C2,
    @C3mol * C3 / 100   AS C3,
    @nC4mol * nC4 / 100 AS nC4,
    @iC4mol * IC4 / 100 AS iC4,
    @nC5mol * nC5 / 100 AS nC5,
    @iC5mol * IC5 / 100 AS IC5,
    @C6mol * C6 / 100   AS C6,
    @CO2mol * CO2 / 100 AS CO2,
    @h2sol * H2S / 100  AS H2S,
    @N2mol * N2 / 100   AS N2
FROM
    CO_PesoMolecularGPA2145

--select * from #Calculo_Yi_PMi

SELECT
    @PM_Mezcla = C1 + C2 + C3 + nC4 + iC4 + nC5 + IC5 + C6 + CO2 + H2S + N2
FROM
    #Calculo_Yi_PMi


INSERT INTO #MezclaAire
(
	IdContrato,
	PMMezcla,
	DensRel,
	DensMezcla,
	MtGas
)
SELECT
    @Idcontrato                                              AS IdContrato,
    @PM_Mezcla                                               AS PMMezcla,
    @PM_Mezcla / PMaire                                      AS DensRel,
    (@PM_Mezcla / PMaire) * Densaire                         AS DensMezcla,
    @PEP15_56Gas * ((@PM_Mezcla / PMaire) * Densaire) * 1000 AS MtGas
FROM
    CO_DatosAire

--------------------------------------------------Calculo Calculo Xi = Yi*Pmi / Sum (Yi*PM)--------------------------------------------------
INSERT INTO #CalculoXi
(
	IdContrato,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
	@Idcontrato      AS IdContrato,
	C1 / @PM_Mezcla  AS C1,
	C2 /@PM_Mezcla	AS C2,
	C3 /  @PM_Mezcla  AS C3,
	nC4 / @PM_Mezcla AS nC4,
	iC4 / @PM_Mezcla AS iC4,
	nC5 /@PM_Mezcla AS nC5,
	IC5 / @PM_Mezcla AS iC5,
	C6 / @PM_Mezcla  AS C6,
	CO2 /  @PM_Mezcla AS CO2,
	H2S / @PM_Mezcla AS H2S,
	N2 / @PM_Mezcla  AS N2
FROM
    #Calculo_Yi_PMi

--------------------------------------------------Calculo de la Masa (lb)--------------------------------------------------
INSERT INTO #CalculoMasa
(
	IdContrato,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
    Ma.IdContrato,
    C1 * MtGas  AS C1,
    C2 * MtGas  AS C2,
    C3 * MtGas  AS C3,
    nC4 * MtGas AS nC4,
    iC4 * MtGas AS iC4,
    nC5 * MtGas AS nC5,
    iC5 * MtGas AS iC5,
    C6 * MtGas  AS C6,
    CO2 * MtGas AS CO2,
    H2S * MtGas AS H2S,
    N2 * MtGas  AS N2
FROM
    #CalculoXi  xi
JOIN
    #MezclaAire Ma
    ON Ma.IdContrato = xi.IdContrato

--------------------------------------------------Calculo del Volumen  (lb)--------------------------------------------------
SELECT
	@DescC1  = C1,
	@DescC2  = C2,
	@DescC3  = C3,
	@DescnC4 = nC4,
	@DescIC4 = IC4,
	@DescnC5 = nC5,
	@DescIC5 = IC5,
	@DescC6  = C6,
	@DescCO2 = CO2,
	@DescH2S = H2S,
	@DescN2  = N2
FROM
    CO_DensidadGPA2145

INSERT INTO #CalculoVolumen
(
	IdContrato,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
    CM.IdContrato            AS idContrato,
    (CM.C1 / @DescC1) / 42   AS C1,
    (CM.C2 / @DescC2) / 42   AS C2,
    (CM.C3 / @DescC3) / 42   AS C3,
    (CM.nC4 / @DescnC4) / 42 AS nC4,
    (CM.iC4 / @DescIC4) / 42 AS iC4,
    (CM.nC5 / @DescnC5) / 42 AS nC5,
    (CM.iC5 / @DescIC5) / 42 AS iC5,
    (CM.C6 / @DescC6) / 42   AS C6,
    (CM.CO2 / @DescCO2) / 42 AS CO2,
    (CM.H2S / @DescH2S) / 42 AS H2S,
    (CM.N2 / @DescN2) / 42   AS N2
FROM
    #CalculoMasa CM


SELECT
    @C5Eq = ISNULL(nC5 + iC5 + C6,0)
FROM
    #CalculoVolumen
    
SELECT
    @PoderCalorificoTodos	= + (C1 * @C1_mmbtu) + (C2 * @C2_mmbtu) + (C3 * @C3_mmbtu) + (C4 * @n_C4_mmbtu)
							+ (IC4 * @i_C4_mmbtu) + (C5 * @n_C5_mmbtu) + (IC5 * @i_C5_mmbtu) + (C6 * @C6_mmbtu)
FROM
    [CO_PoderCaloríficoBrutoGPA2145]
--	Select @PoderCalorificoTodos

    ---****************************************************************************
    ---*************************OCUPA EL IMPORTE***********************************
 --   SELECT
 --       @puntoEntregaContratoId = PuntoEntregaContratoID
	--FROM
 --       [CO_PuntosdeEntregaContrato]
 --   WHERE
 --       PuntoEntregaID = @puntoEntrega
 --       AND idContrato  = @Idcontrato

    --Select @ImporteGas=ImporteGas
   --from CO_NMSipacProduccion where idContrato=10011 and Year(mes)=2018 and Month(mes)=01

    --Select @ImportePetroleo=Importe_Petroleo
    --from  CO_NMSipacProduccion where idContrato=10011 and Year(mes)=2018 and Month(mes)=01

--******************************************************************************
--******************************************************************************
SELECT
    @C1CalculoPrecio     =  ISNULL((C1 /NULLIF(@PoderCalorificoTodos,0)),0) * @ImporteGas,
    @C2CalculoPrecio     =  ISNULL((C2 /NULLIF( @PoderCalorificoTodos,0)),0) * @ImporteGas,
    @C3CalculoPrecio     = ISNULL((C3 / NULLIF(@PoderCalorificoTodos,0)),0) * @ImporteGas,
    @nC4CalculoPrecio    = ISNULL((C4 / NULLIF(@PoderCalorificoTodos,0)),0) * @ImporteGas,
    @IC4CalculoPrecio    =  ISNULL((IC4 /  NULLIF(@PoderCalorificoTodos,0)),0) * @ImporteGas,
    @C4CalculoPrecio     = CASE WHEN (@nC4mol+@iC4mol) = 0 THEN 0
							ELSE (((@nC4CalculoPrecio * @nC4mol) + (@iC4mol * @IC4CalculoPrecio)) / (@nC4mol+@iC4mol))
							END,
    @IngresosC1_c2_c3_c4 = + ((@C1CalculoPrecio / 1) * @C1_mmbtu) + ((@C2CalculoPrecio * 1) * @C2_mmbtu)
                            + (@C3CalculoPrecio) * @C3_mmbtu + (@C4CalculoPrecio * ((@n_C4_mmbtu + @i_C4_mmbtu) * 1)),
    @IngresosCondensados = @ImporteGas - @IngresosC1_c2_c3_c4,
    @Condensado          = ISNULL( @IngresosCondensados / NULLIF(@C5Eq, 0), 0 )
    --@Condensado=@IngresosCondensados/@C5Eq
FROM
    [CO_PoderCaloríficoBrutoGPA2145]

    --Select @C1CalculoPrecio,@C2CalculoPrecio,@C3CalculoPrecio,@nC4CalculoPrecio,@IC4CalculoPrecio,@C4CalculoPrecio,@IngresosC1_c2_c3_c4,
    -- @IngresosCondensados,@Condensado

/*SE MOVIO INSERT DE LA TABLA TEMPORAL #SipacVenta DENTRO DEL IF EN EL ELSE*/

	/*Determinar si la factura es condensable
	Si en el calculo de @C5Eq  es mayor a 0 significa que hay Gas Condensable
	Al insertar el calculo en la tabla COM_OperacionComercializacion se marca con un Bit = 1 la columna EsCondensable, para despues ligar la factura en automático*/
	DECLARE @BitCondensable BIT
		IF ISNULL(@C5Eq,0) > 0
		BEGIN
		INSERT INTO #SipacVenta
		(
			idContrato,
			Petroleo_Venta,
			C1Venta,
			C2Venta,
			C3Venta,
			C4Venta,
			Condensado_Venta,
			Condensable_Venta /*Se agrego columna para condensable venta*/
		)
		SELECT
			@Idcontrato               AS idContrato,
			@PEP15_56Petroleo         AS Petroleo_Venta,
			@C1_mmbtu                 AS C1Venta,
			@C2_mmbtu                 AS C2Venta,
			@C3_mmbtu                 AS C3Venta,
			@n_C4_mmbtu + @i_C4_mmbtu AS C4Venta,
			@PEP15_56Condensado       AS Condensado_Venta,
			@C5Eq					  AS Condensable_Venta /*Se agrego columna para condensable venta, toma el valor de C5Eq*/

			SET @BitCondensable = 1
		END
		ELSE
		BEGIN
		    -------------------------Paso 7 Valores de produccion Sipac-------------------------
		INSERT INTO #SipacVenta
		(
			idContrato,
			Petroleo_Venta,
			C1Venta,
			C2Venta,
			C3Venta,
			C4Venta,
			Condensado_Venta,
			Condensable_Venta /*Se agrego columna para condensable venta*/
		)
		SELECT
			@Idcontrato               AS idContrato,
			@PEP15_56Petroleo         AS Petroleo_Venta,
			@C1_mmbtu                 AS C1Venta,
			@C2_mmbtu                 AS C2Venta,
			@C3_mmbtu                 AS C3Venta,
			@n_C4_mmbtu + @i_C4_mmbtu AS C4Venta,
			/*CASE
				WHEN @C5Eq IS NULL THEN @PEP15_56Condensado
				ELSE @PEP15_56Condensado + @C5Eq
			END                       */
			@PEP15_56Condensado       AS Condensado_Venta,
			0						  AS Condensable_Venta /*Se agrego valor para condensable venta, 0 cuanto no contenga*/
			
			SET @BitCondensable = 0
		END

INSERT INTO #SipacProduccion
(
	idContrato,
	PetroleoProduccion,
	C1Produccion,
	C2Produccion,
	C3Produccion,
	C4Produccion,
	Condensado_Produccion,
	Condensable_Produccion /*Se agrego columna para condensable produccion*/
)
SELECT
    @Idcontrato                               AS idContrato,
	@Petroleo20C							  AS PetroleoProduccion,
    @C1_mmbtuxGasmmpc                         AS C1Produccion,
    @C2_mmbtuxGasmmpc                         AS C2Produccion,
    @C3_mmbtuxGasmmpc                         AS C3Produccion,
    @n_C4_mmbtuxGasmmpc + @i_C4_mmbtuxGasmmpc AS C4Produccion,
    @Condensado20C		                      AS Condensado_Produccion,
	@C5Eq									  AS Condensable_Produccion /*Se agrego columna para condensable produccion*/


INSERT INTO #Precios
(
	idContrato,
	Petroleo_Precio,
	C1Precios,
	C2Precios,
	C3Precios,
	C4Precios,
	Condensado_Precios
)
SELECT
    @Idcontrato                                             AS idContrato,
    ISNULL( @ImportePetroleo / NULLIF(@Petroleo20C, 0), 0 ) AS Petroleo_Precio,
    @C1CalculoPrecio                                        AS C1Precios,
    @C2CalculoPrecio                                        AS C2Precios,
    @C3CalculoPrecio                                        AS C3Precios,
    @C4CalculoPrecio                                        AS C4Precios,
    @Condensado                                             AS Condensado_Precios

 --------------------------------------------------
    --*******************Para checar tablas individuales ************************
    --Select * from #SipacVenta
    --Select * from #SipacProduccion
    --Select * from #Precios
    ----*****************************************************************************************
    --***********************Para la vista en web con el grid con bandas descomentar las dos linesa en la consulta*************************
    --*************************Para cambio en tablas producido con venta(Cambio enviado al Correo 22/03/18)***********
SELECT
    SV.idContrato,
    Petroleo_Venta,
    C1Venta,
    C2Venta,
    C3Venta,
    C4Venta,
    Condensado_Venta,
    --PetroleoProduccion,C1Produccion,C2Produccion,C3Produccion,C4Produccion,Condensado_Produccion,
    Petroleo_Precio,
    C1Precios,
    C2Precios,
    C3Precios,
    C4Precios,
    Condensado_Precios
FROM
    #SipacVenta SV
--  JOIN
	--#SipacProduccion SP 
	--ON SV.idContrato=SP.idContrato
JOIN
    #Precios    P
    ON SV.idContrato = P.idContrato

IF @FechaLimite >= GETDATE()
BEGIN
	-- SE GUARDAR UN REGISTRO DE LOS VALORES UTILIZADOS EN EL CALCULO
	-- CROMATOGRAFIA Y VOLUMENES
	-- SI YA EXISTE UN REGISTRO CON LOS MISMO VALORES, SOLO SE ACTUALIZA LA FECHA Y EL USUARIO
	UPDATE LOG_CalculoProduccionMensual
		SET UsuarioID	=	@Usuario,
			FecMovto	=	GETDATE()
	WHERE
		IdContrato	=	@Idcontrato
		AND MesReporte	=	@fechaMesDiaAnio
		AND PuntoEntregaID	=	@puntoEntrega
		AND VolumenPetroleo	=	@Petroleo20C
		AND VolumenGas	=	@Gasmmpc_20C
		AND VolumenCondensado	=	@Condensado20C
		AND GradosAPI	=	@APIP
		AND Azufre	=	@Azufre
		AND Cromatografia_C1	=	@C1mol
		AND Cromatografia_C2	=	@C2mol
		AND Cromatografia_C3	=	@C3mol
		AND Cromatografia_nC4	=	@nC4mol
		AND Cromatografia_iC4	=	@iC4mol
		AND Cromatografia_nC5	=	@nC5mol
		AND Cromatografia_iC5	=	@iC5mol
		AND Cromatografia_C6	=	@C6mol
		AND Cromatografia_CO2	=	@CO2mol
		AND Cromatografia_H2S	=	@h2sol
		AND Cromatografia_N2	=	@N2mol
		AND ImportePetroleo	=	@ImportePetroleo
		AND ImporteGas	=	@ImporteGas

	SELECT @RegistrosActualizados = @@ROWCOUNT

	IF @RegistrosActualizados = 0
	BEGIN
		INSERT INTO LOG_CalculoProduccionMensual
		(
			IdContrato,
			MesReporte,
			PuntoEntregaID,
			VolumenPetroleo,
			VolumenGas,
			VolumenCondensado,
			GradosAPI,
			Azufre,
			Cromatografia_C1,
			Cromatografia_C2,
			Cromatografia_C3,
			Cromatografia_nC4,
			Cromatografia_iC4,
			Cromatografia_nC5,
			Cromatografia_iC5,
			Cromatografia_C6,
			Cromatografia_CO2,
			Cromatografia_H2S,
			Cromatografia_N2,
			ImportePetroleo,
			ImporteGas,
			UsuarioID,
			FecMovto
		)
		SELECT
			@Idcontrato,
			@fechaMesDiaAnio,
			@puntoEntrega,
			@Petroleo20C,
			@Gasmmpc_20C,
			@Condensado20C,
			@APIP,
			@Azufre,
			@C1mol,
			@C2mol,
			@C3mol,
			@nC4mol,
			@iC4mol,
			@nC5mol,
			@iC5mol,
			@C6mol,
			@CO2mol,
			@h2sol,
			@N2mol,
			@ImportePetroleo,
			@ImporteGas,
			@Usuario,
			GETDATE()
	END


	-- SE BORRA LA INFORMACION DEL MES ACTUAL
	DELETE FROM dbo.PR_ProduccionMensualPtoEntrega
	WHERE IdContrato	=	@Idcontrato
		AND IdFecha	=	@fechaMesDiaAnio
		AND	PuntoEntregaID	=	@puntoEntrega
	

	-- SE INSERTA LA INFORMACIÓN EN LA TABLA
	INSERT INTO dbo.PR_ProduccionMensualPtoEntrega
	(
		IdContrato,
		IdFecha,
		PuntoEntregaID,
		IdTipoHidrocarburo,
		VolumenProducido,
		VolumenVendido,
		idUnidadMedida,
		CreadoPor,
		CreadoEl,
		Precio
	)
	SELECT
		SV.idContrato,
		@fechaMesDiaAnio,
		@puntoEntrega,
		TH.IdTipoHidrocarburo,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN SP.PetroleoProduccion
			WHEN 10001	THEN SP.Condensado_Produccion
			WHEN 10002	THEN SP.C1Produccion
			WHEN 10003	THEN SP.C2Produccion
			WHEN 10004	THEN SP.C3Produccion
			WHEN 10005	THEN SP.C4Produccion
		END	AS	VolumenProducido,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN SV.Petroleo_Venta
			WHEN 10001	THEN SV.Condensado_Venta
			WHEN 10002	THEN SV.C1Venta
			WHEN 10003	THEN SV.C2Venta
			WHEN 10004	THEN SV.C3Venta
			WHEN 10005	THEN SV.C4Venta
		END	AS	VolumenVendido,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN @UniMedidaBl		-- BARRILES
			WHEN 10001	THEN @UniMedidaBl		-- BARRILES
			WHEN 10002	THEN @UniMedidaBTU		-- MMBTU
			WHEN 10003	THEN @UniMedidaBTU		-- MMBTU
			WHEN 10004	THEN @UniMedidaBTU		-- MMBTU
			WHEN 10005	THEN @UniMedidaBTU		-- MMBTU
		END	AS	idUnidadMedida,
		@Usuario,
		GETDATE(),
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN P.Petroleo_Precio
			WHEN 10001	THEN P.Condensado_Precios
			WHEN 10002	THEN P.C1Precios
			WHEN 10003	THEN P.C2Precios
			WHEN 10004	THEN P.C3Precios
			WHEN 10005	THEN P.C4Precios
		END	AS	Precio
	FROM
        #SipacVenta SV
    JOIN
		#SipacProduccion SP 
		ON SV.idContrato=SP.idContrato
    JOIN
        #Precios    P
        ON SV.idContrato = P.idContrato
	CROSS JOIN
		dbo.CO_TipoHidrocarburo	TH

	-- SE BORRAN LAS COMERCIALIZACIONES EXISTENTES PARA EL CONTRATO, MES, PTO ENTREGA, QUE NO PERTENEZCAN A PEMEX
	DELETE	OC
	FROM COM_OperacionComercializacion	OC
		JOIN	dbo.FI_Factura	F
			ON	OC.IdFactura	=	F.IdFactura
	WHERE	OC.IdContrato	=	@Idcontrato
		AND OC.MesReporte	=	@fechaMesDiaAnio
		AND	OC.PuntoEntregaID	=	@puntoEntrega
		AND	F.Emisor	<>	'PEP9207167XA'

	-- SE BORRAN LAS COMERCIALIZACIONES EXISTENTES PARA EL CONTRATO, MES, PTO ENTREGA, QUE AUN NO TIENEN LIGADA UNA FACTURA
	DELETE	OC
	FROM COM_OperacionComercializacion	OC
	WHERE	OC.IdContrato	=	@Idcontrato
		AND OC.MesReporte	=	@fechaMesDiaAnio
		AND	OC.PuntoEntregaID	=	@puntoEntrega
		AND	OC.IdFactura = 0

	-- SE GENERAN LAS COMERCIALIZACIONES EQUIVALENTES
	INSERT INTO dbo.COM_OperacionComercializacion
	(
	   IdContrato,
	    MesReporte,
	    FechaTransaccion,
	    IdTipoHidrocarburo,
	    VolumenVendido,
	    PrecioVentaUnitario,
	    CostoUnitarioComercializacion,
	    PrecioPuntoMedicion,
	    IdFactura,
	    NumeroFolioPedimento,
	    EPT,
	    OperacionBajoReglasMercado,
	    ClasificacionDocumentoSoporte,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    Activo,
	    NuevoPrecioVentaUnitario,
	    PVUAnterior,
	    PPMAnterior,
		PuntoEntregaID,
		EsCondensable
	)
	SELECT
		IdContrato,
		IdFecha	AS [MesReporte],
		DATEADD(DAY,-1,DATEADD(MONTH,1,IdFecha))		AS [FechaTransaccion],
		IdTipoHidrocarburo,
		VolumenVendido,
		Precio,	--PrecioVentaUnitario,
		0,	--   CostoUnitarioComercializacion,
		Precio,	--   PrecioPuntoMedicion,
		0,	--	IdFactura
		'NA',
		0,
		1,
		2,
		@Usuario,
		GETDATE(),
		@Usuario,
		GETDATE(),
		1, ---Activo
		0,
		0,
		0,
		PuntoEntregaID,
		CASE WHEN @BitCondensable = 1 AND IdTipoHidrocarburo = 10001
			THEN 1
			ELSE 0
		END
	FROM
		PR_ProduccionMensualPtoEntrega
	WHERE
		IdContrato		=	@Idcontrato
		AND IdFecha		=	@fechaMesDiaAnio
		AND	PuntoEntregaID	=	@puntoEntrega

	-- SE BORRA EL VOLUMEN ANTERIORMENTE GENERADO
	DELETE	dbo.PR_VolumenMensualProduccionPetroleo
	WHERE	IdContrato	=	@Idcontrato
		AND MesReporte	=	@fechaMesDiaAnio

	-- SE INSERTA LA INFORMACION EN LA TABLA DE PRODUCCION FINAL
	INSERT INTO dbo.PR_VolumenMensualProduccionPetroleo
	(
	    IdContrato,
	    MesReporte,
	    VolumenPetroleoPuntoMedicion,
	    GradosAPI,
	    ContenidoAzufre,
	    VolumenPetroleoAutoconsumo,
	    MetanoC1,
	    EtanoC2,
	    PropanoC3,
	    ButanoC4,
	    MetanoC1Autoconsumo,
	    EtanoC2Autoconsumo,
	    PropanoC3Autoconsumo,
	    ButanoC4Autoconsumo,
	    VolumenCondensadoPuntoMedicion,
	    VolumenCondensadoAutoconsumo,
	    Bit_CasoFortuito,
	    CantDiasCasoFortuito,
	    OtrosIngresosUsoCompartidoInfraestructura,
	    VolumenPetroleoContratistaReparticion,
	    VolumenMetanoC1ContratistaReparticion,
	    VolumenEtanoC2ContratistaReparticion,
	    VolumenPropanoC3ContratistaReparticion,
	    VolumenButanoC4ContratistaReparticion,
	    VolumenCondensadosContratistaReparticion,
	    VolumenPetroleoEstadoReparticion,
	    VolumenMetanoC1EstadoReparticion,
	    VolumenEtanoC2EstadoReparticion,
	    VolumenPropanoC3EstadoReparticion,
	    VolumenButanoC4EstadoReparticion,
	    VolumenCondensadosEstadoReparticion,
	    VolumenPetroleoContratistaCompensacion,
	    VolumenMetanoC1ContratistaCompensacion,
	    VolumenEtanoC2ContratistaCompensacion,
	    VolumenPropanoC3ContratistaCompensacion,
	    VolumenButanoC4ContratistaCompensacion,
	    VolumenCondensadosContratistaCompensacion,
	    VolumenPetroleoEstadoCompensacion,
	    VolumenMetanoC1EstadoCompensacion,
	    VolumenEtanoC2EstadoCompensacion,
	    VolumenPropanoC3EstadoCompensacion,
	    VolumenButanoC4EstadoCompensacion,
	    VolumenCondensadosEstadoCompensacion,
	    AcumuladoCostosRecuperablesInsolutos
	)
	SELECT
		IdContrato,
		IdFecha,
		SUM(CASE	IdTipoHidrocarburo
			WHEN 10000	THEN VolumenVendido	ELSE 0
		END)	VolumenPetroleoPuntoMedicion,
		@PromAPI,
		@PromAzufre,
		0,--	VolumenPetroleoAutoconsumo,
		SUM(CASE	IdTipoHidrocarburo
			WHEN 10002	THEN VolumenVendido	ELSE 0
		END)	MetanoC1,
		SUM(CASE	IdTipoHidrocarburo
			WHEN 10003	THEN VolumenVendido	ELSE 0
		END)	EtanoC2,
		SUM(CASE	IdTipoHidrocarburo
			WHEN 10004	THEN VolumenVendido	ELSE 0
		END)	PropanoC3,
		SUM(CASE	IdTipoHidrocarburo
			WHEN 10005	THEN VolumenVendido	ELSE 0
		END)	ButanoC4,
		0,--		MetanoC1Autoconsumo,
		0,--	    EtanoC2Autoconsumo,
		0,--	    PropanoC3Autoconsumo,
		0,--	    ButanoC4Autoconsumo,
		SUM(CASE	IdTipoHidrocarburo
			WHEN 10001	THEN VolumenVendido	ELSE 0
		END)	VolumenCondensadoPuntoMedicion,
		0,--		VolumenCondensadoAutoconsumo,
		0,
		0,
		0,
	    0,--VolumenPetroleoContratistaReparticion,
	    0,--VolumenMetanoC1ContratistaReparticion,
	    0,--VolumenEtanoC2ContratistaReparticion,
	    0,--VolumenPropanoC3ContratistaReparticion,
	    0,--VolumenButanoC4ContratistaReparticion,
	    0,--VolumenCondensadosContratistaReparticion,
	    0,--VolumenPetroleoEstadoReparticion,
	    0,--VolumenMetanoC1EstadoReparticion,
	    0,--VolumenEtanoC2EstadoReparticion,
	    0,--VolumenPropanoC3EstadoReparticion,
	    0,--VolumenButanoC4EstadoReparticion,
	    0,--VolumenCondensadosEstadoReparticion,
	    0,--VolumenPetroleoContratistaCompensacion,
	    0,--VolumenMetanoC1ContratistaCompensacion,
	    0,--VolumenEtanoC2ContratistaCompensacion,
	    0,--VolumenPropanoC3ContratistaCompensacion,
	    0,--VolumenButanoC4ContratistaCompensacion,
	    0,--VolumenCondensadosContratistaCompensacion,
	    0,--VolumenPetroleoEstadoCompensacion,
	    0,--VolumenMetanoC1EstadoCompensacion,
	    0,--VolumenEtanoC2EstadoCompensacion,
	    0,--VolumenPropanoC3EstadoCompensacion,
	    0,--VolumenButanoC4EstadoCompensacion,
	    0,--VolumenCondensadosEstadoCompensacion,
	    0--AcumuladoCostosRecuperablesInsolut
	FROM
		PR_ProduccionMensualPtoEntrega
	WHERE
		IdContrato		=	@Idcontrato
		AND IdFecha		=	@fechaMesDiaAnio
	GROUP BY
		IdContrato,
		IdFecha
	
--****************************************************************************************************
END
--************************************************************************************************
END