CREATE PROCEDURE [dbo].[SP_PC_SIPAC_ValidarVolumenesPrecios]
	@IdContrato INT,
	@MesReporte	DATE
AS
BEGIN
-- =============================================
-- Descripción:	Procedimiento que valida los volumenes y precios del archivo
--				de produccion compartida, para evitar errores al subir a SIPAC
-- Modulo:		Reportes
-- =============================================
-- 20180629	BAAC	Creación de sp
-- =============================================
SET NOCOUNT ON 
-- =============================================

DECLARE @GasNoAsociado BIT

CREATE TABLE #VolPreciosAsociadoVal
(
	IdContratista_RF_00	VARCHAR(20),
	IdContrato_RI_00		VARCHAR(30),
	NumeroContrato_RF01_01		VARCHAR(35),
	MesReporte_RMPCT32_00	INT,
	AnioReporte_RMPCT32_01	INT,
	VolPetroPtoMed_RMPCT32_02	INT,
	GradosAPI_RMPCT32_03		FLOAT,
	Azufre_RMPCT32_04			FLOAT,
	VolPetroAutoCon_RMPCT32_05	INT,
	VolMetanoPtoMed_RMPCT32_06	INT,
	VolEtanoPtoMed_RMPCT32_07	INT,
	VolPropanoPtoMed_RMPCT32_08	INT,
	VolButanoPtoMed_RMPCT32_09	INT,
	VolMetanoAutoCon_RMPCT32_10	INT,
	VolEtanoAutoCon_RMPCT32_11	INT,
	VolPropanoAutoCon_RMPCT32_12	INT,
	VolButanoAutoCon_RMPCT32_13	INT,
	VolCondensadosPtoMed_RMPCT32_14	INT,
	VolCondensadoAutocon_RMPCT32_15	INT,
	VolPetroVendido_RMPCT32_16	INT,
	VolMetanoVendido_RMPCT32_17	INT,
	VolEtanoVendido_RMPCT32_18	INT,
	VolPropanoVendido_RMPCT32_19	INT,
	VolButanoVendido_RMPCT32_20	INT,
	VolCondensadoVendido_RMPCT32_21	INT,
	PrecioPetro_RMPCT32_22 FLOAT,
	--PrecioMetano_RMPCT32_23 FLOAT,
	--PrecioEtano_RMPCT32_24 FLOAT,
	--PrecioPropano_RMPCT32_25 FLOAT,
	--PrecioButano_RMPCT32_26 FLOAT,
	--PrecioCondensado_RMPCT32_27 FLOAT,
	PrecioMetano_RMPCT32_23 VARCHAR(8),
	PrecioEtano_RMPCT32_24 VARCHAR(8),
	PrecioPropano_RMPCT32_25 VARCHAR(8),
	PrecioButano_RMPCT32_26 VARCHAR(8),
	PrecioCondensado_RMPCT32_27 VARCHAR(8),
	VolPetroContratistaReparticion_RMPCT32_28 INT,
	VolMetanoContratistaReparticion_RMPCT32_29 INT,
	VolEtanoContratistaReparticion_RMPCT32_30 INT,
	VolPropanoContratistaReparticion_RMPCT32_31 INT,
	VolButanoContratistaReparticion_RMPCT32_32 INT,
	VolCondensadoContratistaReparticion_RMPCT32_33 INT,
	VolPetroEstadoReparticion_RMPCT32_34 INT,
	VolMetanoEstadoReparticion_RMPCT32_35 INT,
	VolEtanoEstadoReparticion_RMPCT32_36 INT,
	VolPropanoEstadoReparticion_RMPCT32_37 INT,
	VolButanoEstadoReparticion_RMPCT32_38 INT,
	VolCondensadoEstadoReparticion_RMPCT32_39 INT,
	VolPetroContratistaCompensacion_RMPCT32_40 INT,
	VolMetanoContratistaCompensacion_RMPCT32_41 INT,
	VolEtanoContratistaCompensacion_RMPCT32_42 INT,
	VolPropanoContratistaCompensacion_RMPCT32_43 INT,
	VolButanoContratistaCompensacion_RMPCT32_44 INT,
	VolCondensadoContratistaCompensacion_RMPCT32_45 INT,
	VolPetroEstadoCompensacion_RMPCT32_46 INT,
	VolMetanoEstadoCompensacion_RMPCT32_47 INT,
	VolEtanoEstadoCompensacion_RMPCT32_48 INT,
	VolPropanoEstadoCompensacion_RMPCT32_49 INT,
	VolButanoEstadoCompensacion_RMPCT32_50 INT,
	VolCondensadoEstadoCompensacion_RMPCT32_51 INT
)

CREATE TABLE #VolPreciosNoAsociadoVal
(
	IdContratista_RF_00	VARCHAR(20),
	IdContrato_RI_00		VARCHAR(30),
	NumeroContrato_RF01_01		VARCHAR(35),
	MesReporte_RMPCT33_00	INT,
	AnioReporte_RMPCT33_01	INT,
	VolMetanoPtoMed_RMPCT33_02	INT,
	VolEtanoPtoMed_RMPCT33_03	INT,
	VolPropanoPtoMed_RMPCT33_04	INT,
	VolButanoPtoMed_RMPCT33_05	INT,
	VolMetanoAutoCon_RMPCT33_06	INT,
	VolEtanoAutoCon_RMPCT33_07	INT,
	VolPropanoAutoCon_RMPCT33_08	INT,
	VolButanoAutoCon_RMPCT33_09	INT,
	VolCondensadosPtoMed_RMPCT33_10	INT,
	VolCondensadoAutocon_RMPCT33_11	INT,
	VolMetanoVendido_RMPCT33_12	INT,
	VolEtanoVendido_RMPCT33_13	INT,
	VolPropanoVendido_RMPCT33_14	INT,
	VolButanoVendido_RMPCT33_15	INT,
	VolCondensadoVendido_RMPCT33_16	INT,
	PrecioMetano_RMPCT33_17 FLOAT,
	PrecioEtano_RMPCT33_18 FLOAT,
	PrecioPropano_RMPCT33_19 FLOAT,
	PrecioButano_RMPCT33_20 FLOAT,
	PrecioCondensado_RMPCT33_21 FLOAT,
	VolMetanoContratistaReparticion_RMPCT33_22 INT,
	VolEtanoContratistaReparticion_RMPCT33_23 INT,
	VolPropanoContratistaReparticion_RMPCT33_24 INT,
	VolButanoContratistaReparticion_RMPCT33_25 INT,
	VolCondensadoContratistaReparticion_RMPCT33_26 INT,
	VolMetanoEstadoReparticion_RMPCT33_27 INT,
	VolEtanoEstadoReparticion_RMPCT33_28 INT,
	VolPropanoEstadoReparticion_RMPCT33_29 INT,
	VolButanoEstadoReparticion_RMPCT33_30 INT,
	VolCondensadoEstadoReparticion_RMPCT33_31 INT,
	VolMetanoContratistaCompensacion_RMPCT33_32 INT,
	VolEtanoContratistaCompensacion_RMPCT33_33 INT,
	VolPropanoContratistaCompensacion_RMPCT33_34 INT,
	VolButanoContratistaCompensacion_RMPCT33_35 INT,
	VolCondensadoContratistaCompensacion_RMPCT33_36 INT,
	VolMetanoEstadoCompensacion_RMPCT33_37 INT,
	VolEtanoEstadoCompensacion_RMPCT33_38 INT,
	VolPropanoEstadoCompensacion_RMPCT33_39 INT,
	VolButanoEstadoCompensacion_RMPCT33_40 INT,
	VolCondensadoEstadoCompensacion_RMPCT33_41 INT
)

CREATE TABLE #OperacionesComercializacion
(
	IdContratista_RF_00	VARCHAR(20),
	IdContrato_RI_00		VARCHAR(30),
	NumeroContrato_RF01_01		VARCHAR(35),
	FechaTransaccion_RMPCT34_00 DATE,
	NumEventoComer_RMPCT34_01	INT,
	TipoHidrocarburo_RMPCT34_02	INT,
	VolVendido_RMPCT34_03	INT,
	PrecioVtaUnitario_RMPCT34_04	FLOAT,
	CtoUnitarioComer_RMPCT34_05	FLOAT,
	PrecioPtoMedicion_RMPCT34_06	FLOAT,
	FolioCFDI_RMPCT34_07	VARCHAR(50),
	IdDocFacturacion_RMPCT34_08	VARCHAR(50),
	NombreArchivo_RMPCT34_09 VARCHAR(50),
	NumFolioPedimento_RMPCT34_10 VARCHAR(50),
	EstudioPreciosTransfer_RMPCT34_11 BIT,
	OperBajoReglaMdo_RMPCT34_12	BIT,
	ClasificacionDocto_RMPCT34_13 INT
)

CREATE TABLE #ValidacionComercializaciones
(
	VolumenPetroleo		INT,
	VolumenMetano	INT,
	VolumenEtano	INT,
	VolumenPropano	INT,
	VolumenButano	INT,
	VolumenCondensado	INT,
	PrecioPetroleo	FLOAT,
	PrecioMetano	FLOAT,
	PrecioEtano		FLOAT,
	PrecioPropano	FLOAT,
	PrecioButano	FLOAT,
	PrecioCondensado	FLOAT
)

SELECT	@GasNoAsociado = ISNULL(GasNoAsociado,0)
FROM dbo.CO_Contrato
WHERE	IdContrato = @IdContrato


IF (@GasNoAsociado = 0) 
BEGIN 

	INSERT INTO #VolPreciosAsociadoVal
	(
		IdContratista_RF_00,
		IdContrato_RI_00,
		NumeroContrato_RF01_01,
		MesReporte_RMPCT32_00,
		AnioReporte_RMPCT32_01,
		VolPetroPtoMed_RMPCT32_02,
		GradosAPI_RMPCT32_03,
		Azufre_RMPCT32_04,
		VolPetroAutoCon_RMPCT32_05,
		VolMetanoPtoMed_RMPCT32_06,
		VolEtanoPtoMed_RMPCT32_07,
		VolPropanoPtoMed_RMPCT32_08,
		VolButanoPtoMed_RMPCT32_09,
		VolMetanoAutoCon_RMPCT32_10,
		VolEtanoAutoCon_RMPCT32_11,
		VolPropanoAutoCon_RMPCT32_12,
		VolButanoAutoCon_RMPCT32_13,
		VolCondensadosPtoMed_RMPCT32_14,
		VolCondensadoAutocon_RMPCT32_15,
		VolPetroVendido_RMPCT32_16,
		VolMetanoVendido_RMPCT32_17,
		VolEtanoVendido_RMPCT32_18,
		VolPropanoVendido_RMPCT32_19,
		VolButanoVendido_RMPCT32_20,
		VolCondensadoVendido_RMPCT32_21,
		PrecioPetro_RMPCT32_22,
		PrecioMetano_RMPCT32_23,
		PrecioEtano_RMPCT32_24,
		PrecioPropano_RMPCT32_25,
		PrecioButano_RMPCT32_26,
		PrecioCondensado_RMPCT32_27,
		VolPetroContratistaReparticion_RMPCT32_28,
		VolMetanoContratistaReparticion_RMPCT32_29,
		VolEtanoContratistaReparticion_RMPCT32_30,
		VolPropanoContratistaReparticion_RMPCT32_31,
		VolButanoContratistaReparticion_RMPCT32_32,
		VolCondensadoContratistaReparticion_RMPCT32_33,
		VolPetroEstadoReparticion_RMPCT32_34,
		VolMetanoEstadoReparticion_RMPCT32_35,
		VolEtanoEstadoReparticion_RMPCT32_36,
		VolPropanoEstadoReparticion_RMPCT32_37,
		VolButanoEstadoReparticion_RMPCT32_38,
		VolCondensadoEstadoReparticion_RMPCT32_39,
		VolPetroContratistaCompensacion_RMPCT32_40,
		VolMetanoContratistaCompensacion_RMPCT32_41,
		VolEtanoContratistaCompensacion_RMPCT32_42,
		VolPropanoContratistaCompensacion_RMPCT32_43,
		VolButanoContratistaCompensacion_RMPCT32_44,
		VolCondensadoContratistaCompensacion_RMPCT32_45,
		VolPetroEstadoCompensacion_RMPCT32_46,
		VolMetanoEstadoCompensacion_RMPCT32_47,
		VolEtanoEstadoCompensacion_RMPCT32_48,
		VolPropanoEstadoCompensacion_RMPCT32_49,
		VolButanoEstadoCompensacion_RMPCT32_50,
		VolCondensadoEstadoCompensacion_RMPCT32_51
	)
	EXEC SP_PC_SIPAC_VolumenesPreciosAsociados @IdContrato, @MesReporte
END
ELSE
BEGIN
	INSERT INTO #VolPreciosNoAsociadoVal
	(
	    IdContratista_RF_00,
	    IdContrato_RI_00,
	    NumeroContrato_RF01_01,
	    MesReporte_RMPCT33_00,
	    AnioReporte_RMPCT33_01,
	    VolMetanoPtoMed_RMPCT33_02,
	    VolEtanoPtoMed_RMPCT33_03,
	    VolPropanoPtoMed_RMPCT33_04,
	    VolButanoPtoMed_RMPCT33_05,
	    VolMetanoAutoCon_RMPCT33_06,
	    VolEtanoAutoCon_RMPCT33_07,
	    VolPropanoAutoCon_RMPCT33_08,
	    VolButanoAutoCon_RMPCT33_09,
	    VolCondensadosPtoMed_RMPCT33_10,
	    VolCondensadoAutocon_RMPCT33_11,
	    VolMetanoVendido_RMPCT33_12,
	    VolEtanoVendido_RMPCT33_13,
	    VolPropanoVendido_RMPCT33_14,
	    VolButanoVendido_RMPCT33_15,
	    VolCondensadoVendido_RMPCT33_16,
	    PrecioMetano_RMPCT33_17,
	    PrecioEtano_RMPCT33_18,
	    PrecioPropano_RMPCT33_19,
	    PrecioButano_RMPCT33_20,
	    PrecioCondensado_RMPCT33_21,
	    VolMetanoContratistaReparticion_RMPCT33_22,
	    VolEtanoContratistaReparticion_RMPCT33_23,
	    VolPropanoContratistaReparticion_RMPCT33_24,
	    VolButanoContratistaReparticion_RMPCT33_25,
	    VolCondensadoContratistaReparticion_RMPCT33_26,
	    VolMetanoEstadoReparticion_RMPCT33_27,
	    VolEtanoEstadoReparticion_RMPCT33_28,
	    VolPropanoEstadoReparticion_RMPCT33_29,
	    VolButanoEstadoReparticion_RMPCT33_30,
	    VolCondensadoEstadoReparticion_RMPCT33_31,
	    VolMetanoContratistaCompensacion_RMPCT33_32,
	    VolEtanoContratistaCompensacion_RMPCT33_33,
	    VolPropanoContratistaCompensacion_RMPCT33_34,
	    VolButanoContratistaCompensacion_RMPCT33_35,
	    VolCondensadoContratistaCompensacion_RMPCT33_36,
	    VolMetanoEstadoCompensacion_RMPCT33_37,
	    VolEtanoEstadoCompensacion_RMPCT33_38,
	    VolPropanoEstadoCompensacion_RMPCT33_39,
	    VolButanoEstadoCompensacion_RMPCT33_40,
	    VolCondensadoEstadoCompensacion_RMPCT33_41
	)
	EXEC SP_PC_SIPAC_VolumenesPreciosNoAsociados @IdContrato, @MesReporte
END

INSERT INTO #OperacionesComercializacion
(
    IdContratista_RF_00,
    IdContrato_RI_00,
    NumeroContrato_RF01_01,
    FechaTransaccion_RMPCT34_00,
    NumEventoComer_RMPCT34_01,
    TipoHidrocarburo_RMPCT34_02,
    VolVendido_RMPCT34_03,
    PrecioVtaUnitario_RMPCT34_04,
    CtoUnitarioComer_RMPCT34_05,
    PrecioPtoMedicion_RMPCT34_06,
    FolioCFDI_RMPCT34_07,
    IdDocFacturacion_RMPCT34_08,
    NombreArchivo_RMPCT34_09,
    NumFolioPedimento_RMPCT34_10,
    EstudioPreciosTransfer_RMPCT34_11,
    OperBajoReglaMdo_RMPCT34_12,
    ClasificacionDocto_RMPCT34_13
)
EXEC SP_PC_SIPAC_OperacionesComercialización @IdContrato, @MesReporte

-- si es gas asociado, se validan los resultados de la hoja 32
IF (@GasNoAsociado = 0) 
BEGIN 
	-- PETROLEO
	IF 0 <> (SELECT	VolPetroPtoMed_RMPCT32_02 - (VolPetroContratistaReparticion_RMPCT32_28 + 
											VolPetroEstadoReparticion_RMPCT32_34 +
											VolPetroContratistaCompensacion_RMPCT32_40 + 
											VolPetroEstadoCompensacion_RMPCT32_46)
			FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de PETROLEO. </BR> </BR>'+
		'Volumen Producido Petroleo: '+CONVERT(NVARCHAR(max),VolPetroPtoMed_RMPCT32_02)+ ' </BR>' +
		'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(max),VolPetroContratistaReparticion_RMPCT32_28)+' </BR>'+
		'Volumen Estado Reparticion Preliminar: '+ CONVERT(NVARCHAR(Max),VolPetroEstadoReparticion_RMPCT32_34 )+' </BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolPetroContratistaCompensacion_RMPCT32_40)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+ CONVERT(NVARCHAR(MAX),VolPetroEstadoCompensacion_RMPCT32_46)+'</BR>'+
		'Diferencia: '+ CONVERT
		(
		NVARCHAR(MAX),
			(
			VolPetroPtoMed_RMPCT32_02 - 
				(
				VolPetroContratistaReparticion_RMPCT32_28 + 
				VolPetroEstadoReparticion_RMPCT32_34 + 
				VolPetroContratistaCompensacion_RMPCT32_40 + 
				VolPetroEstadoCompensacion_RMPCT32_46
				)
			)
		)
		FROM
			#VolPreciosAsociadoVal
	END
	-- METANO
	IF 0 <> (SELECT	VolMetanoPtoMed_RMPCT32_06 - (VolMetanoContratistaReparticion_RMPCT32_29 + 
											VolMetanoEstadoReparticion_RMPCT32_35 +
											VolMetanoContratistaCompensacion_RMPCT32_41 + 
											VolMetanoEstadoCompensacion_RMPCT32_47)
			FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de METANO. </BR></BR>'+
		'Volumen Producido Metano: '+CONVERT(NVARCHAR(max),VolMetanoPtoMed_RMPCT32_06 )+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+ CONVERT(NVARCHAR(MAX),VolMetanoContratistaReparticion_RMPCT32_29)+ '</BR>'+
		'Volumen Estado Reparticion Preliminar'+ CONVERT(NVARCHAR(MAX),VolMetanoEstadoReparticion_RMPCT32_35)+ '</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolMetanoContratistaCompensacion_RMPCT32_41)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+ CONVERT(NVARCHAR(MAX),VolMetanoEstadoCompensacion_RMPCT32_47)+'</BR>'+
		'Diferencia: '+CONVERT
		(
		NVARCHAR(max),
		(
		VolMetanoPtoMed_RMPCT32_06 - 
				(
				VolMetanoContratistaReparticion_RMPCT32_29 + VolMetanoEstadoReparticion_RMPCT32_35 +
				VolMetanoContratistaCompensacion_RMPCT32_41 + VolMetanoEstadoCompensacion_RMPCT32_47
				)
			)
		)
		--SELECT	VolMetanoPtoMed_RMPCT32_06 AS [Volumen Producido Metano],
		--	VolMetanoContratistaReparticion_RMPCT32_29 AS [Volumen Contratista Reparticion Preliminar],
		--	VolMetanoEstadoReparticion_RMPCT32_35 AS [Volumen Estado Reparticion Preliminar],
		--	VolMetanoContratistaCompensacion_RMPCT32_41 AS [Volumen Contratista Compensacion Volumetrica],
		--	VolMetanoEstadoCompensacion_RMPCT32_47 AS [Volumen Estado Compensacion Volumetrica],
		--	VolMetanoPtoMed_RMPCT32_06 - (VolMetanoContratistaReparticion_RMPCT32_29 + VolMetanoEstadoReparticion_RMPCT32_35 +
		--						VolMetanoContratistaCompensacion_RMPCT32_41 + VolMetanoEstadoCompensacion_RMPCT32_47) AS [Diferencia]
		FROM
			#VolPreciosAsociadoVal
	END

	-- ETANO
	IF 0 <> (SELECT	VolEtanoPtoMed_RMPCT32_07 - (VolEtanoContratistaReparticion_RMPCT32_30 + 
											VolEtanoEstadoReparticion_RMPCT32_36 +
											VolEtanoContratistaCompensacion_RMPCT32_42 + 
											VolEtanoEstadoCompensacion_RMPCT32_48)
			FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de ETANO. </BR></BR> '+
		'Volumen Producido Etano: '+CONVERT(NVARCHAR(Max),VolEtanoPtoMed_RMPCT32_07) +'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+ CONVERT(NVARCHAR(Max),VolEtanoContratistaReparticion_RMPCT32_30)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+ CONVERT(NVARCHAR(Max),VolEtanoEstadoReparticion_RMPCT32_36)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(Max),VolEtanoContratistaCompensacion_RMPCT32_42)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(Max),VolEtanoEstadoCompensacion_RMPCT32_48)+'</BR>'+
		'Diferencia: '+ CONVERT(NVARCHAR(Max),(VolEtanoPtoMed_RMPCT32_07 - (VolEtanoContratistaReparticion_RMPCT32_30 + VolEtanoEstadoReparticion_RMPCT32_36 +
								VolEtanoContratistaCompensacion_RMPCT32_42 + VolEtanoEstadoCompensacion_RMPCT32_48)))
		
		--SELECT	VolEtanoPtoMed_RMPCT32_07				AS [Volumen Producido Etano],
		--	VolEtanoContratistaReparticion_RMPCT32_30	AS [Volumen Contratista Reparticion Preliminar],
		--	VolEtanoEstadoReparticion_RMPCT32_36		AS [Volumen Estado Reparticion Preliminar],
		--	VolEtanoContratistaCompensacion_RMPCT32_42	AS [Volumen Contratista Compensacion Volumetrica],
		--	VolEtanoEstadoCompensacion_RMPCT32_48		AS [Volumen Estado Compensacion Volumetrica],
		--	VolEtanoPtoMed_RMPCT32_07 - (VolEtanoContratistaReparticion_RMPCT32_30 + VolEtanoEstadoReparticion_RMPCT32_36 +
		--							VolEtanoContratistaCompensacion_RMPCT32_42 + VolEtanoEstadoCompensacion_RMPCT32_48) AS [Diferencia]
		FROM
			#VolPreciosAsociadoVal
	END

	-- PROPANO
	IF 0 <> (SELECT	VolPropanoPtoMed_RMPCT32_08 - (VolPropanoContratistaReparticion_RMPCT32_31 + 
											VolPropanoEstadoReparticion_RMPCT32_37 +
											VolPropanoContratistaCompensacion_RMPCT32_43 + 
											VolPropanoEstadoCompensacion_RMPCT32_49)
			FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de PROPANO. </BR> </BR>'+
		'Volumen Producido Propano: '+CONVERT(NVARCHAR(MAX),VolPropanoPtoMed_RMPCT32_08	) +'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolPropanoContratistaReparticion_RMPCT32_31) +'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolPropanoEstadoReparticion_RMPCT32_37) +'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolPropanoContratistaCompensacion_RMPCT32_43) +'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolPropanoEstadoCompensacion_RMPCT32_49	) +'</BR>'+
		'Diferencia: '+CONVERT(NVARCHAR(MAX),(VolPropanoPtoMed_RMPCT32_08 - (VolPropanoContratistaReparticion_RMPCT32_31 + VolPropanoEstadoReparticion_RMPCT32_37 +
		VolPropanoContratistaCompensacion_RMPCT32_43 + VolPropanoEstadoCompensacion_RMPCT32_49)))
		

			--SELECT	VolPropanoPtoMed_RMPCT32_08				AS [Volumen Producido Propano],
			--VolPropanoContratistaReparticion_RMPCT32_31	AS [Volumen Contratista Reparticion Preliminar],
			--VolPropanoEstadoReparticion_RMPCT32_37		AS [Volumen Estado Reparticion Preliminar],
			--VolPropanoContratistaCompensacion_RMPCT32_43	AS [Volumen Contratista Compensacion Volumetrica],
			--VolPropanoEstadoCompensacion_RMPCT32_49		AS [Volumen Estado Compensacion Volumetrica],
			--VolPropanoPtoMed_RMPCT32_08 - (VolPropanoContratistaReparticion_RMPCT32_31 + VolPropanoEstadoReparticion_RMPCT32_37 +
				--					VolPropanoContratistaCompensacion_RMPCT32_43 + VolPropanoEstadoCompensacion_RMPCT32_49) AS [Diferencia]
		FROM
			#VolPreciosAsociadoVal
	END

	-- BUTANO
	IF 0 <> (SELECT	VolButanoPtoMed_RMPCT32_09 - (VolButanoContratistaReparticion_RMPCT32_32 + 
											VolButanoEstadoReparticion_RMPCT32_38 +
											VolButanoContratistaCompensacion_RMPCT32_44 + 
											VolButanoEstadoCompensacion_RMPCT32_50)
			FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de BUTANO. </BR></BR>'+
		'Volumen Producido Butano: ' + CONVERT(NVARCHAR(Max),VolButanoPtoMed_RMPCT32_09)+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: ' + CONVERT(NVARCHAR(Max),VolButanoContratistaReparticion_RMPCT32_32)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: ' + CONVERT(NVARCHAR(Max),VolButanoEstadoReparticion_RMPCT32_38)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: ' + CONVERT(NVARCHAR(Max),VolButanoContratistaCompensacion_RMPCT32_44)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: ' + CONVERT(NVARCHAR(Max),VolButanoEstadoCompensacion_RMPCT32_50)+'</BR>'+
		'Diferencia: ' + CONVERT(NVARCHAR(Max),(		VolButanoPtoMed_RMPCT32_09 - (VolButanoContratistaReparticion_RMPCT32_32 + VolButanoEstadoReparticion_RMPCT32_38 +
									VolButanoContratistaCompensacion_RMPCT32_44 + VolButanoEstadoCompensacion_RMPCT32_50)))
			
			--						SELECT	VolButanoPtoMed_RMPCT32_09				AS [Volumen Producido Butano],
			--VolButanoContratistaReparticion_RMPCT32_32	AS [Volumen Contratista Reparticion Preliminar],
			--VolButanoEstadoReparticion_RMPCT32_38		AS [Volumen Estado Reparticion Preliminar],
			--VolButanoContratistaCompensacion_RMPCT32_44	AS [Volumen Contratista Compensacion Volumetrica],
			--VolButanoEstadoCompensacion_RMPCT32_50		AS [Volumen Estado Compensacion Volumetrica],
			--VolButanoPtoMed_RMPCT32_09 - (VolButanoContratistaReparticion_RMPCT32_32 + VolButanoEstadoReparticion_RMPCT32_38 +
			--						VolButanoContratistaCompensacion_RMPCT32_44 + VolButanoEstadoCompensacion_RMPCT32_50) AS [Diferencia]
		FROM
			#VolPreciosAsociadoVal
	END

	-- CONDENSADO
	IF 0 <> (SELECT	VolCondensadosPtoMed_RMPCT32_14 - (VolCondensadoContratistaReparticion_RMPCT32_33 + 
											VolCondensadoEstadoReparticion_RMPCT32_39 +
											VolCondensadoContratistaCompensacion_RMPCT32_45 + 
											VolCondensadoEstadoCompensacion_RMPCT32_51)
			FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de CONDENSADO. </BR></BR>'+
			'Volumen Producido Condensado: '+CONVERT(NVARCHAR(MAX),VolCondensadosPtoMed_RMPCT32_14)	+'</BR>'+
			'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolCondensadoContratistaReparticion_RMPCT32_33)+'</BR>'+
			'Volumen Estado Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolCondensadoEstadoReparticion_RMPCT32_39)	+'</BR>'+
			'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolCondensadoContratistaCompensacion_RMPCT32_45)	+'</BR>'+
			'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolCondensadoEstadoCompensacion_RMPCT32_51)	+'</BR>'+
			'Diferencia: '+CONVERT(NVARCHAR(MAX),(VolCondensadosPtoMed_RMPCT32_14 - (VolCondensadoContratistaReparticion_RMPCT32_33 + VolCondensadoEstadoReparticion_RMPCT32_39 +
								VolCondensadoContratistaCompensacion_RMPCT32_45 + VolCondensadoEstadoCompensacion_RMPCT32_51)))
			--SELECT	VolCondensadosPtoMed_RMPCT32_14				AS [Volumen Producido Condensado],
			--VolCondensadoContratistaReparticion_RMPCT32_33	AS [Volumen Contratista Reparticion Preliminar],
			--VolCondensadoEstadoReparticion_RMPCT32_39		AS [Volumen Estado Reparticion Preliminar],
			--VolCondensadoContratistaCompensacion_RMPCT32_45	AS [Volumen Contratista Compensacion Volumetrica],
			--VolCondensadoEstadoCompensacion_RMPCT32_51		AS [Volumen Estado Compensacion Volumetrica],
			--VolCondensadosPtoMed_RMPCT32_14 - (VolCondensadoContratistaReparticion_RMPCT32_33 + VolCondensadoEstadoReparticion_RMPCT32_39 +
			--					VolCondensadoContratistaCompensacion_RMPCT32_45 + VolCondensadoEstadoCompensacion_RMPCT32_51) AS [Diferencia]
		FROM
			#VolPreciosAsociadoVal
	END

	-- SE VALIDA QUE HAYA COMERCIALIZACIONES DE PETROLEO
	IF 0 = (SELECT ISNULL(VolPetroVendido_RMPCT32_16,0) FROM #VolPreciosAsociadoVal)
	BEGIN
		SELECT 'En el caso en que el valor del Volumen de petróleo sea cero, el Precio del petróleo deberá ser igual a NA, Validar comercializaciones de Petroleo.'
		+' </BR> </BR> '+
		'Volumen Vendido: '+ CONVERT(nvarchar(Max),VolPetroVendido_RMPCT32_16) 
		+' </BR> '+
		'Precio: '+ CONVERT(nvarchar(Max),PrecioPetro_RMPCT32_22)
		FROM #VolPreciosAsociadoVal
	END

	-- SE VALIDA QUE LOS VOLUMENES DE LAS COMERCIALIZACIONES CONCUERDEN CON LOS VOLUMENES GENERALES
	INSERT INTO #ValidacionComercializaciones
	(
		VolumenPetroleo,
		VolumenMetano,
		VolumenEtano,
		VolumenPropano,
		VolumenButano,
		VolumenCondensado,
		PrecioPetroleo,
		PrecioMetano,
		PrecioEtano	,
		PrecioPropano,
		PrecioButano,
		PrecioCondensado
	)
	SELECT 
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 1 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolPetroleo,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 3 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolMetano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 4 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolEtano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 5 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolPropano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 6 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolButano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 2 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolCondensado,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 1 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolPetroVendido_RMPCT32_16) ELSE 0 END),4) AS PrecioPetroleo,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 3 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolMetanoVendido_RMPCT32_17) ELSE 0 END),4) AS PrecioMetano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 4 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolEtanoVendido_RMPCT32_18) ELSE 0 END),4) AS PrecioEtano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 5 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolPropanoVendido_RMPCT32_19) ELSE 0 END),4) AS PrecioPropano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 6 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolButanoVendido_RMPCT32_20) ELSE 0 END),4) AS PrecioButano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 2 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolCondensadoVendido_RMPCT32_21) ELSE 0 END),4) AS PrecioCondensado
	FROM
		#OperacionesComercializacion	O
	CROSS JOIN
		#VolPreciosAsociadoVal	T
	WHERE
		 O.OperBajoReglaMdo_RMPCT34_12 = 1

	SELECT
		CASE	WHEN T.VolPetroVendido_RMPCT32_16 <> C.VolumenPetroleo 
			THEN 'El Volumen Vendido de PETROLEO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolMetanoVendido_RMPCT32_17 <> C.VolumenMetano 
			THEN 'El Volumen Vendido de METANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolEtanoVendido_RMPCT32_18 <> C.VolumenEtano 
			THEN  'El Volumen Vendido de ETANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolPropanoVendido_RMPCT32_19 <> C.VolumenPropano 
			THEN  'El Volumen Vendido de PROPANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolButanoVendido_RMPCT32_20 <> C.VolumenButano 
			THEN  'El Volumen Vendido de BUTANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolCondensadoVendido_RMPCT32_21 <> C.VolumenCondensado 
			THEN  'El Volumen Vendido de CONDENSADO reportado no coincide con las comercializaciones'
		END,
		CASE WHEN T.PrecioPetro_RMPCT32_22 <> C.PrecioPetroleo
			THEN 'El precio del PETROLEO reportado no coincide con el Ponderado de las comercializaciones'
		END,

		CASE WHEN CONVERT(FLOAT,REPLACE(T.PrecioMetano_RMPCT32_23,'NA',0)) <> C.PrecioMetano
			THEN 'El precio del METANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioMetano_RMPCT32_23) + ' - ' + LTRIM(C.PrecioMetano)
		END,
		CASE WHEN CONVERT(FLOAT,REPLACE(T.PrecioEtano_RMPCT32_24,'NA',0)) <> C.PrecioEtano
			THEN 'El precio del ETANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioEtano_RMPCT32_24) + ' - ' + LTRIM(C.PrecioEtano)
		END,
		CASE WHEN CONVERT(FLOAT,REPLACE(T.PrecioPropano_RMPCT32_25,'NA',0)) <> C.PrecioPropano
			THEN 'El precio del PROPANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioPropano_RMPCT32_25) + ' - ' + LTRIM(C.PrecioPropano)
		END,
		CASE WHEN CONVERT(FLOAT,REPLACE(T.PrecioButano_RMPCT32_26,'NA',0)) <> C.PrecioButano
			THEN 'El precio del BUTANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioButano_RMPCT32_26) + ' - ' + LTRIM(C.PrecioButano)
		END,
		CASE WHEN CONVERT(FLOAT,REPLACE(T.PrecioCondensado_RMPCT32_27,'NA',0)) <> C.PrecioCondensado
			THEN 'El precio del CONDENSADO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioCondensado_RMPCT32_27) + ' - ' + LTRIM(C.PrecioCondensado)
		END
	FROM
		#VolPreciosAsociadoVal	T
	CROSS JOIN
		#ValidacionComercializaciones	C
	WHERE
		( T.VolPetroVendido_RMPCT32_16 <> C.VolumenPetroleo OR T.VolMetanoVendido_RMPCT32_17 <> C.VolumenMetano 
		OR T.VolEtanoVendido_RMPCT32_18 <> C.VolumenEtano OR T.VolPropanoVendido_RMPCT32_19 <> C.VolumenPropano 
		OR T.VolButanoVendido_RMPCT32_20 <> C.VolumenButano OR T.VolCondensadoVendido_RMPCT32_21 <> C.VolumenCondensado 
		OR CONVERT(DECIMAL(10,4),T.PrecioPetro_RMPCT32_22) <> CONVERT(DECIMAL(10,4),C.PrecioPetroleo) 
		OR CONVERT(DECIMAL(10,4),REPLACE(T.PrecioMetano_RMPCT32_23,'NA',0)) <> CONVERT(DECIMAL(10,4),C.PrecioMetano)
		OR CONVERT(DECIMAL(10,4),REPLACE(T.PrecioEtano_RMPCT32_24,'NA',0)) <> CONVERT(DECIMAL(10,4),C.PrecioEtano) 
		OR CONVERT(DECIMAL(10,4),REPLACE(T.PrecioPropano_RMPCT32_25,'NA',0)) <> CONVERT(DECIMAL(10,4),C.PrecioPropano) 
		OR CONVERT(DECIMAL(10,4),REPLACE(T.PrecioButano_RMPCT32_26,'NA',0)) <> CONVERT(DECIMAL(10,4),C.PrecioButano) 
		OR CONVERT(DECIMAL(10,4),REPLACE(T.PrecioCondensado_RMPCT32_27,'NA',0)) <> CONVERT(DECIMAL(10,4),C.PrecioCondensado))

	-- SE VALIDA QUE NO EXISTAN COMERCIALIZACIONES CON UN PRECIO MAYOR A 999
	SELECT
		'El precio de la comercialización excede el maximo permitido con SIPAC (999), favor de revisar la factura: ' + LTRIM(FolioCFDI_RMPCT34_07)
	FROM
		#OperacionesComercializacion
	WHERE
		PrecioVtaUnitario_RMPCT34_04	> 999
	GROUP BY
		LTRIM(FolioCFDI_RMPCT34_07)
		

END
-- si es gas no asociado, se validan los resultados de la hoja 33
ELSE
BEGIN
	-- METANO
	IF 0 <> (SELECT	VolMetanoPtoMed_RMPCT33_02 - (VolMetanoContratistaReparticion_RMPCT33_22 + 
											VolMetanoEstadoReparticion_RMPCT33_27 +
											VolMetanoContratistaCompensacion_RMPCT33_32 + 
											VolMetanoEstadoCompensacion_RMPCT33_37)
			FROM #VolPreciosNoAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de METANO. </BR></BR>'+
		'Volumen Producido Metano: '+CONVERT(NVARCHAR(MAX),VolMetanoPtoMed_RMPCT33_02)+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolMetanoContratistaReparticion_RMPCT33_22)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolMetanoEstadoReparticion_RMPCT33_27)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolMetanoContratistaCompensacion_RMPCT33_32)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolMetanoEstadoCompensacion_RMPCT33_37)+'</BR>'+
		'Diferencia: '+CONVERT(NVARCHAR(MAX),(VolMetanoPtoMed_RMPCT33_02 - (VolMetanoContratistaReparticion_RMPCT33_22 + VolMetanoEstadoReparticion_RMPCT33_27 +
								VolMetanoContratistaCompensacion_RMPCT33_32 + VolMetanoEstadoCompensacion_RMPCT33_37)))


			--SELECT	VolMetanoPtoMed_RMPCT33_02				AS [Volumen Producido Metano],
			--VolMetanoContratistaReparticion_RMPCT33_22	AS [Volumen Contratista Reparticion Preliminar],
			--VolMetanoEstadoReparticion_RMPCT33_27		AS [Volumen Estado Reparticion Preliminar],
			--VolMetanoContratistaCompensacion_RMPCT33_32	AS [Volumen Contratista Compensacion Volumetrica],
			--VolMetanoEstadoCompensacion_RMPCT33_37		AS [Volumen Estado Compensacion Volumetrica],
			--VolMetanoPtoMed_RMPCT33_02 - (VolMetanoContratistaReparticion_RMPCT33_22 + VolMetanoEstadoReparticion_RMPCT33_27 +
			--					VolMetanoContratistaCompensacion_RMPCT33_32 + VolMetanoEstadoCompensacion_RMPCT33_37) AS [Diferencia]
		FROM
			#VolPreciosNoAsociadoVal
	END

	-- ETANO
	IF 0 <> (SELECT	VolEtanoPtoMed_RMPCT33_03 - (VolEtanoContratistaReparticion_RMPCT33_23 + 
											VolEtanoEstadoReparticion_RMPCT33_28 +
											VolEtanoContratistaCompensacion_RMPCT33_33 + 
											VolEtanoEstadoCompensacion_RMPCT33_38)
			FROM #VolPreciosNoAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de ETANO. </BR></BR>'+
		'Volumen Producido Etano: '+CONVERT(NVARCHAR(MAX),VolEtanoPtoMed_RMPCT33_03)+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolEtanoContratistaReparticion_RMPCT33_23)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+CONVERT(NVARCHAR(MAX),VolEtanoEstadoReparticion_RMPCT33_28)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolEtanoContratistaCompensacion_RMPCT33_33)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(MAX),VolEtanoEstadoCompensacion_RMPCT33_38)+'</BR>'+
		'Diferencia: '+CONVERT(NVARCHAR(MAX),(VolEtanoPtoMed_RMPCT33_03 - (VolEtanoContratistaReparticion_RMPCT33_23 + VolEtanoEstadoReparticion_RMPCT33_28 +
								VolEtanoContratistaCompensacion_RMPCT33_33 + VolEtanoEstadoCompensacion_RMPCT33_38) ))
	
			--SELECT	VolEtanoPtoMed_RMPCT33_03				AS [Volumen Producido Etano],
			--VolEtanoContratistaReparticion_RMPCT33_23	AS [Volumen Contratista Reparticion Preliminar],
			--VolEtanoEstadoReparticion_RMPCT33_28		AS [Volumen Estado Reparticion Preliminar],
			--VolEtanoContratistaCompensacion_RMPCT33_33	AS [Volumen Contratista Compensacion Volumetrica],
			--VolEtanoEstadoCompensacion_RMPCT33_38		AS [Volumen Estado Compensacion Volumetrica],
			--VolEtanoPtoMed_RMPCT33_03 - (VolEtanoContratistaReparticion_RMPCT33_23 + VolEtanoEstadoReparticion_RMPCT33_28 +
			--					VolEtanoContratistaCompensacion_RMPCT33_33 + VolEtanoEstadoCompensacion_RMPCT33_38) AS [Diferencia]
		FROM
			#VolPreciosNoAsociadoVal
	END
    
	-- PROPANO
	IF 0 <> (SELECT	VolPropanoPtoMed_RMPCT33_04 - (VolPropanoContratistaReparticion_RMPCT33_24 + 
											VolPropanoEstadoReparticion_RMPCT33_29 +
											VolPropanoContratistaCompensacion_RMPCT33_34 + 
											VolPropanoEstadoCompensacion_RMPCT33_39)
			FROM #VolPreciosNoAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de PROPANO. </BR></BR>'+
		'Volumen Producido Propano: '+CONVERT(NVARCHAR(max),VolPropanoPtoMed_RMPCT33_04)+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(max),VolPropanoContratistaReparticion_RMPCT33_24)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+CONVERT(NVARCHAR(max),VolPropanoEstadoReparticion_RMPCT33_29)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(max),VolPropanoContratistaCompensacion_RMPCT33_34)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(max),VolPropanoEstadoCompensacion_RMPCT33_39)+'</BR>'+
		'Diferencia: '+CONVERT(NVARCHAR(max),(VolPropanoPtoMed_RMPCT33_04 - (VolPropanoContratistaReparticion_RMPCT33_24 + VolPropanoEstadoReparticion_RMPCT33_29 +
									VolPropanoContratistaCompensacion_RMPCT33_34 + VolPropanoEstadoCompensacion_RMPCT33_39)))

			--						SELECT	VolPropanoPtoMed_RMPCT33_04				AS [Volumen Producido Propano],
			--VolPropanoContratistaReparticion_RMPCT33_24	AS [Volumen Contratista Reparticion Preliminar],
			--VolPropanoEstadoReparticion_RMPCT33_29		AS [Volumen Estado Reparticion Preliminar],
			--VolPropanoContratistaCompensacion_RMPCT33_34	AS [Volumen Contratista Compensacion Volumetrica],
			--VolPropanoEstadoCompensacion_RMPCT33_39		AS [Volumen Estado Compensacion Volumetrica],
			--VolPropanoPtoMed_RMPCT33_04 - (VolPropanoContratistaReparticion_RMPCT33_24 + VolPropanoEstadoReparticion_RMPCT33_29 +
			--						VolPropanoContratistaCompensacion_RMPCT33_34 + VolPropanoEstadoCompensacion_RMPCT33_39) AS [Diferencia]
		FROM
			#VolPreciosNoAsociadoVal
	END

	-- BUTANO
	IF 0 <> (SELECT	VolButanoPtoMed_RMPCT33_05 - (VolButanoContratistaReparticion_RMPCT33_25 + 
											VolButanoEstadoReparticion_RMPCT33_30 +
											VolButanoContratistaCompensacion_RMPCT33_35 + 
											VolButanoEstadoCompensacion_RMPCT33_40)
			FROM #VolPreciosNoAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de BUTANO. </BR></BR>'+
		'Volumen Producido Butano: '+ CONVERT(NVARCHAR(MAX),VolButanoPtoMed_RMPCT33_05)+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+ CONVERT(NVARCHAR(MAX),VolButanoContratistaReparticion_RMPCT33_25)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+ CONVERT(NVARCHAR(MAX),VolButanoEstadoReparticion_RMPCT33_30)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+ CONVERT(NVARCHAR(MAX),VolButanoContratistaCompensacion_RMPCT33_35)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+ CONVERT(NVARCHAR(MAX),VolButanoEstadoCompensacion_RMPCT33_40)+'</BR>'+
		'Diferencia: '+ CONVERT(NVARCHAR(MAX),(VolButanoPtoMed_RMPCT33_05 - (VolButanoContratistaReparticion_RMPCT33_25 + VolButanoEstadoReparticion_RMPCT33_30 +
									VolButanoContratistaCompensacion_RMPCT33_35 + VolButanoEstadoCompensacion_RMPCT33_40)))
			--SELECT	VolButanoPtoMed_RMPCT33_05				AS [Volumen Producido Propano],
			--VolButanoContratistaReparticion_RMPCT33_25	AS [Volumen Contratista Reparticion Preliminar],
			--VolButanoEstadoReparticion_RMPCT33_30		AS [Volumen Estado Reparticion Preliminar],
			--VolButanoContratistaCompensacion_RMPCT33_35	AS [Volumen Contratista Compensacion Volumetrica],
			--VolButanoEstadoCompensacion_RMPCT33_40		AS [Volumen Estado Compensacion Volumetrica],
			--VolButanoPtoMed_RMPCT33_05 - (VolButanoContratistaReparticion_RMPCT33_25 + VolButanoEstadoReparticion_RMPCT33_30 +
			--						VolButanoContratistaCompensacion_RMPCT33_35 + VolButanoEstadoCompensacion_RMPCT33_40) AS [Diferencia]
		FROM
			#VolPreciosNoAsociadoVal
	END

	-- CONDENSADO
	IF 0 <> (SELECT	VolCondensadosPtoMed_RMPCT33_10 - (VolCondensadoContratistaReparticion_RMPCT33_26 + 
											VolCondensadoEstadoReparticion_RMPCT33_31 +
											VolCondensadoContratistaCompensacion_RMPCT33_36 + 
											VolCondensadoEstadoCompensacion_RMPCT33_41)
			FROM #VolPreciosNoAsociadoVal)
	BEGIN
		SELECT 'La suma de volumenes entregados no corresponde con el volumen producido de CONDENSADO. </BR></BR>'+
		'Volumen Producido Condensado: '+CONVERT(NVARCHAR(max), VolCondensadosPtoMed_RMPCT33_10)+'</BR>'+
		'Volumen Contratista Reparticion Preliminar: '+CONVERT(NVARCHAR(max), VolCondensadoContratistaReparticion_RMPCT33_26)+'</BR>'+
		'Volumen Estado Reparticion Preliminar: '+CONVERT(NVARCHAR(max), VolCondensadoEstadoReparticion_RMPCT33_31)+'</BR>'+
		'Volumen Contratista Compensacion Volumetrica: '+CONVERT(NVARCHAR(max), VolCondensadoContratistaCompensacion_RMPCT33_36)+'</BR>'+
		'Volumen Estado Compensacion Volumetrica: '+CONVERT(NVARCHAR(max), VolCondensadoEstadoCompensacion_RMPCT33_41)+'</BR>'+
		'Diferencia: '+CONVERT(NVARCHAR(max),(VolCondensadosPtoMed_RMPCT33_10 - (VolCondensadoContratistaReparticion_RMPCT33_26 + VolCondensadoEstadoReparticion_RMPCT33_31 +
									VolCondensadoContratistaCompensacion_RMPCT33_36 + VolCondensadoEstadoCompensacion_RMPCT33_41)))
		--SELECT	VolCondensadosPtoMed_RMPCT33_10				AS [Volumen Producido Propano],
		--	VolCondensadoContratistaReparticion_RMPCT33_26	AS [Volumen Contratista Reparticion Preliminar],
		--	VolCondensadoEstadoReparticion_RMPCT33_31		AS [Volumen Estado Reparticion Preliminar],
		--	VolCondensadoContratistaCompensacion_RMPCT33_36	AS [Volumen Contratista Compensacion Volumetrica],
		--	VolCondensadoEstadoCompensacion_RMPCT33_41		AS [Volumen Estado Compensacion Volumetrica],
		--	VolCondensadosPtoMed_RMPCT33_10 - (VolCondensadoContratistaReparticion_RMPCT33_26 + VolCondensadoEstadoReparticion_RMPCT33_31 +
		--							VolCondensadoContratistaCompensacion_RMPCT33_36 + VolCondensadoEstadoCompensacion_RMPCT33_41) AS [Diferencia]
		FROM
			#VolPreciosNoAsociadoVal
	END

	-- SE VALIDA QUE LOS VOLUMENES DE LAS COMERCIALIZACIONES CONCUERDEN CON LOS VOLUMENES GENERALES
	INSERT INTO #ValidacionComercializaciones
	(
		VolumenMetano,
		VolumenEtano,
		VolumenPropano,
		VolumenButano,
		VolumenCondensado,
		PrecioMetano,
		PrecioEtano	,
		PrecioPropano,
		PrecioButano,
		PrecioCondensado
	)
	SELECT  
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 3 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolMetano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 4 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolEtano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 5 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolPropano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 6 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolButano,
		SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 2 THEN O.VolVendido_RMPCT34_03 ELSE 0 END) AS VolCondensado,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 3 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolMetanoVendido_RMPCT33_12) ELSE 0 END),4) AS PrecioMetano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 4 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolEtanoVendido_RMPCT33_13) ELSE 0 END),4) AS PrecioEtano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 5 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolPropanoVendido_RMPCT33_14) ELSE 0 END),4) AS PrecioPropano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 6 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolButanoVendido_RMPCT33_15) ELSE 0 END),4) AS PrecioButano,
		ROUND(SUM(CASE WHEN O.TipoHidrocarburo_RMPCT34_02 = 2 THEN O.VolVendido_RMPCT34_03 * (O.PrecioPtoMedicion_RMPCT34_06/ T.VolCondensadoVendido_RMPCT33_16) ELSE 0 END),4) AS PrecioCondensado
	FROM
		#OperacionesComercializacion	O
	CROSS JOIN
		#VolPreciosNoAsociadoVal	T
	WHERE
		 O.OperBajoReglaMdo_RMPCT34_12= 1

	SELECT
		CASE	WHEN T.VolMetanoVendido_RMPCT33_12 <> C.VolumenMetano 
			THEN 'El Volumen Vendido de METANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolEtanoVendido_RMPCT33_13 <> C.VolumenEtano 
			THEN  'El Volumen Vendido de ETANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolPropanoVendido_RMPCT33_14 <> C.VolumenPropano 
			THEN  'El Volumen Vendido de PROPANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolButanoVendido_RMPCT33_15 <> C.VolumenButano
			THEN  'El Volumen Vendido de BUTANO reportado no coincide con las comercializaciones'
		END,
		CASE	WHEN T.VolCondensadoVendido_RMPCT33_16 <> C.VolumenCondensado 
			THEN  'El Volumen Vendido de CONDENSADO reportado no coincide con las comercializaciones'
		END,
		CASE WHEN T.PrecioMetano_RMPCT33_17 <> C.PrecioMetano
			THEN 'El precio del METANO reportado no coincide con el Ponderado de las comercializaciones: ' 
				+ LTRIM(T.PrecioMetano_RMPCT33_17) + ' - ' + LTRIM(C.PrecioMetano)
		END,
		CASE WHEN T.PrecioEtano_RMPCT33_18 <> C.PrecioEtano
			THEN 'El precio del ETANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioEtano_RMPCT33_18) + ' - ' + LTRIM(C.PrecioEtano)
		END,
		CASE WHEN T.PrecioPropano_RMPCT33_19 <> C.PrecioPropano
			THEN 'El precio del PROPANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioPropano_RMPCT33_19) + ' - ' + LTRIM(C.PrecioPropano)
		END,
		CASE WHEN T.PrecioButano_RMPCT33_20 <> C.PrecioButano
			THEN 'El precio del BUTANO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioButano_RMPCT33_20) + ' - ' + LTRIM(C.PrecioButano)
		END,
		CASE WHEN T.PrecioCondensado_RMPCT33_21 <> C.PrecioCondensado
			THEN 'El precio del CONDENSADO reportado no coincide con el Ponderado de las comercializaciones: '
				+ LTRIM(T.PrecioCondensado_RMPCT33_21) + ' - ' + LTRIM(C.PrecioCondensado)
		END
	FROM
		#VolPreciosNoAsociadoVal	T
	CROSS JOIN
		#ValidacionComercializaciones	C
	WHERE
		( T.VolMetanoVendido_RMPCT33_12 <> C.VolumenMetano OR T.VolEtanoVendido_RMPCT33_13 <> C.VolumenEtano
		OR T.VolPropanoVendido_RMPCT33_14 <> C.VolumenPropano OR T.VolButanoVendido_RMPCT33_15 <> C.VolumenButano
		OR T.VolCondensadoVendido_RMPCT33_16 <> C.VolumenCondensado 
		OR CONVERT(DECIMAL(10,4),T.PrecioMetano_RMPCT33_17) <> CONVERT(DECIMAL(10,4),C.PrecioMetano)
		OR CONVERT(DECIMAL(10,4),T.PrecioEtano_RMPCT33_18) <> CONVERT(DECIMAL(10,4),C.PrecioEtano)
		OR CONVERT(DECIMAL(10,4),T.PrecioPropano_RMPCT33_19) <> CONVERT(DECIMAL(10,4),C.PrecioPropano) 
		OR CONVERT(DECIMAL(10,4),T.PrecioButano_RMPCT33_20) <> CONVERT(DECIMAL(10,4),C.PrecioButano)
		OR CONVERT(DECIMAL(10,4),T.PrecioCondensado_RMPCT33_21) <> CONVERT(DECIMAL(10,4),C.PrecioCondensado))

		-- SE VALIDA QUE NO EXISTAN COMERCIALIZACIONES CON UN PRECIO MAYOR A 999
	SELECT
		'El precio de la comercialización excede el máximo permitido con SIPAC (999), favor de revisar la factura: ' + LTRIM(FolioCFDI_RMPCT34_07)
	FROM
		#OperacionesComercializacion
	WHERE
		PrecioVtaUnitario_RMPCT34_04	> 999
	GROUP BY
		LTRIM(FolioCFDI_RMPCT34_07)
END

END