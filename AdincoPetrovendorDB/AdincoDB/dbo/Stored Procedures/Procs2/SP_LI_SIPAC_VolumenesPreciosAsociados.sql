CREATE PROCEDURE [dbo].[SP_LI_SIPAC_VolumenesPreciosAsociados] 
	@Contrato INT, 
	@Mes      DATE,
	@IdUsuario	INT = 1
AS
BEGIN
--SP_LI_SIPAC_VolumenesPreciosAsociados 10001,'2018-12-01'
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-06-17
-- Description:	
-- =============================================
-- 20180801	BAAC	Se modifica para redondear los precios de los hidrocarburos a 2 decimales
-- 20180801	BAAC	Se modifica para agregar el volumen de Condensable (C5+) en el Condensado
-- 20190319	BAAC	Se modifica para agregar el usuario y solo obtener el porcentaje que corresponde a PEP,
--					cuando el usuario tenga el dominio @pemex.com
-- =============================================
SET NOCOUNT ON;
-- =============================================
CREATE TABLE #VolumenComercializado
(	tipohidrocarburo      INT, 
	VolumenComercializado INT, 
	PRIMARY KEY(tipohidrocarburo)
)

CREATE TABLE #Calculo
(	tipohidrocarburo INT, 
	Volumen          INT, 
	Precio           DECIMAL(16, 4), 
	PRIMARY KEY(tipohidrocarburo)
)

/* MANDAR A LAMAR SP'S CALCULO DE PRECIO CONTRACTUAL
EXEC [sp_CP_CalculaPrecioContractualPetroleo]
    @Contrato,
    @Mes;
EXEC [sp_CP_CalculaPrecioContractualGasNaturalLicencia]
    @Contrato,
    @Mes;
EXEC [sp_CP_CalculaPrecioContractualCondensadosLicencia]
    @Contrato,
    @Mes;
*/

/*Precio contractual del hidrocarburo y método de calculo*/
DECLARE
	@P1				MONEY, 
	@P2				MONEY,
	@P3				MONEY,
	@P4				MONEY,
	@P5				MONEY,
	@P6				MONEY,
	@IdMetodo1		INT,
	@IdMetodo2		INT,
	@IdMetodo3		INT,
	@IdMetodo4		INT,
	@IdMetodo5		INT,
	@IdMetodo6		INT,
	@NOASOCIADO		BIT,
	@VolCondPM		FLOAT	=	0,
	@VolPetroleoPM	FLOAT	=	0,
	@V2				FLOAT	=	0,
	@UsuarioPEP		BIT,
	@EsConsorcio	BIT,
	@Metano			DECIMAL(10, 2) = 0,
	@Etano			DECIMAL(10, 2) = 0,
	@Propano		DECIMAL(10, 2) = 0,
	@Butano			DECIMAL(10, 2) = 0,
	@VMetano		DECIMAL(10, 2) = 0,
	@VEtano			DECIMAL(10, 2) = 0,
	@VPropano		DECIMAL(10, 2) = 0,
	@VButano		DECIMAL(10, 2) = 0,
	@PorcentajeMinVta		FLOAT = 50

SELECT
	@UsuarioPEP	=	CASE WHEN Usuario LIKE '%@pemex.com%' THEN 1 ELSE 0	END
FROM
	dbo.AP_Usuario
WHERE
	UsuarioID	=	@IdUsuario
         --
SELECT
	@P1			= SUM(CASE WHEN IdTipoHidrocarburo = 1 THEN precio ELSE 0 END), 
    @IdMetodo1	= SUM(CASE WHEN IdTipoHidrocarburo = 1 THEN IdMetodo ELSE 0 END), 
    @P2			= SUM(CASE WHEN IdTipoHidrocarburo = 2 THEN precio ELSE 0 END), 
    @IdMetodo2	= SUM(CASE WHEN IdTipoHidrocarburo = 2 THEN IdMetodo ELSE 0 END), 
    @P3			= SUM(CASE WHEN IdTipoHidrocarburo = 3 THEN precio ELSE 0 END), 
    @IdMetodo3	= SUM(CASE WHEN IdTipoHidrocarburo = 3 THEN IdMetodo ELSE 0 END), 
    @P4			= SUM(CASE WHEN IdTipoHidrocarburo = 4 THEN precio ELSE 0 END), 
    @IdMetodo4	= SUM(CASE WHEN IdTipoHidrocarburo = 4 THEN IdMetodo ELSE 0 END), 
    @P5			= SUM(CASE WHEN IdTipoHidrocarburo = 5 THEN precio ELSE 0 END), 
    @IdMetodo5	= SUM(CASE WHEN IdTipoHidrocarburo = 5 THEN IdMetodo ELSE 0 END), 
    @P6			= SUM(CASE WHEN IdTipoHidrocarburo = 6 THEN precio ELSE 0 END), 
    @IdMetodo6	= SUM(CASE WHEN IdTipoHidrocarburo = 6 THEN IdMetodo ELSE 0 END)
FROM
	dbo.CP_MetodoCalculoHidrocarburoMes
WHERE mes = @Mes
    AND IdContrato = @Contrato

/*Determinar si el contrato es con gas asociado y si es en consorcio*/
SELECT
	@NOASOCIADO = GasNoAsociado,
	@EsConsorcio	=	ISNULL(IsConsorcio,0)
FROM dbo.CO_CONTRATO
WHERE IdContrato = @Contrato

--IF @Contrato = 10014
--BEGIN
--	SELECT @NOASOCIADO = 0
--END

/*Si contrato es con gas asociado procede con el select del llenado de la hoja*/
IF @NOASOCIADO = 0
BEGIN

	--IF @Contrato = 10014
	--BEGIN
	--	INSERT INTO #VolumenComercializado
	--	(
	--		tipohidrocarburo, 
	--		VolumenComercializado
	--	)
	--	SELECT TH.TipoHidrocarburo, 
	--			SUM(ROUND(VolumenVendido, 0))
	--	FROM dbo.COM_OperacionComercializacion AS OP
	--			JOIN dbo.FI_Factura F ON OP.IdFactura = F.IdFactura
	--			JOIN dbo.CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
	--	WHERE OP.MesReporte = @Mes
	--			AND OP.IdContrato = @Contrato
	--			AND OP.OperacionBajoReglasMercado = 1
	--			AND OP.IdTipoHidrocarburo = 10000
	--	GROUP BY TH.tipohidrocarburo	

	--END
	--ELSE
	--BEGIN
		INSERT INTO #VolumenComercializado
		(
			tipohidrocarburo, 
			VolumenComercializado
		)
		SELECT TH.TipoHidrocarburo, 
				SUM(ROUND(VolumenVendido, 0))
		FROM dbo.COM_OperacionComercializacion AS OP
				JOIN dbo.FI_Factura F ON OP.IdFactura = F.IdFactura
				JOIN dbo.CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
		WHERE OP.MesReporte = @Mes
				AND OP.IdContrato = @Contrato
				AND OP.OperacionBajoReglasMercado = 1
		GROUP BY TH.tipohidrocarburo
	--END
    --
    INSERT INTO #Calculo
    (
		tipohidrocarburo, 
		Volumen, 
		Precio
    )
    SELECT TH.tipohidrocarburo, 
            SUM(ROUND(OP.VolumenVendido, 0)),
            --SUM(OP.PrecioVentaUnitario * CONVERT( DECIMAL(14, 0), OP.VolumenVendido) / VC.VolumenComercializado)
            SUM((ROUND(OP.PrecioVentaUnitario, 4) - ROUND(OP.CostoUnitarioComercializacion, 4)) * ROUND(OP.VolumenVendido, 0) / VC.VolumenComercializado)
    FROM dbo.COM_OperacionComercializacion AS OP
            JOIN dbo.FI_Factura F ON OP.IdFactura = F.IdFactura
            JOIN dbo.CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
            JOIN #VolumenComercializado VC ON TH.tipohidrocarburo = VC.tipohidrocarburo
    WHERE OP.MesReporte = @Mes
            AND OP.IdContrato = @Contrato
            AND OP.OperacionBajoReglasMercado = 1
    GROUP BY TH.tipohidrocarburo


    SELECT @Contrato AS idcontrato, 
        @Mes AS mesreporte, 
        *
    INTO #Volumen
    FROM
    (   SELECT tipohidrocarburo, 
            volumen
        FROM #Calculo
    ) AS SourceTable 
	PIVOT(SUM(Volumen) FOR tipohidrocarburo IN([1], 
                                    [2], 
                                    [3], 
                                    [4], 
                                    [5], 
                                    [6])) AS PivotTable


    SELECT @Contrato AS idcontrato, 
        @Mes AS mesreporte, 
        *
    INTO #Precio
    FROM
	(   SELECT tipohidrocarburo, 
            precio
        FROM #Calculo
    ) AS SourceTable 
	PIVOT(SUM(precio) FOR tipohidrocarburo IN([1], 
                                    [2], 
                                    [3], 
                                    [4], 
                                    [5], 
                                    [6])) AS PivotTable

	/*Determinar columna RMLCT25 27 y 45 */
    SELECT @VolCondPM = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND((ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion, 0), 0)) * (ISNULL(PC.PorcentajePemex,100)/100),0)
							ELSE ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion, 0), 0)
						END,
        @V2 = ISNULL(V.[2], 0), 
        @Metano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPPG.MetanoC1, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPPG.MetanoC1, 0)
				END,
        @Etano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPPG.EtanoC2, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPPG.EtanoC2, 0)
				END,
        @Propano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPPG.PropanoC3, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPPG.PropanoC3, 0)
				END,
        @Butano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPPG.ButanoC4, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPPG.ButanoC4, 0)
				END,
        @VMetano = ISNULL(V.[3], 0), 
        @VEtano = ISNULL(V.[4], 0), 
    @VPropano = ISNULL(V.[5], 0), 
        @VButano = ISNULL(V.[6], 0),
		@VolPetroleoPM = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPPG.VolumenPetroleoPuntoMedicion, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPPG.VolumenPetroleoPuntoMedicion, 0)
				END
    FROM dbo.PR_VolumenMensualProduccionPetroleo VMPPG
        JOIN dbo.CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
        JOIN dbo.CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
        JOIN #Precio P ON C.IdContrato = P.IdContrato
        JOIN #Volumen V ON C.IdContrato = V.IdContrato
		LEFT JOIN dbo.CO_PorcentajesContrato	PC
			ON	VMPPG.IdContrato	=	PC.idContrato
    WHERE VMPPG.IdContrato = @Contrato
        AND VMPPG.MesReporte = @Mes

            /**/

	--IF @Contrato = 10014
	--BEGIN
	--	SELECT @VolCondPM = 0, @V2 = 0, @Metano = 0, @VMetano = 0, @Etano = 0, @VEtano = 0, @Propano = 0, @VPropano = 0, @Metano = 0, @VMetano = 0
	--END

    IF(ISNULL(@VolCondPM,0) = 0
    AND ISNULL(@V2,0) = 0
    AND ISNULL(@Metano,0) <> 0
    AND ISNULL(@VMetano,0) <> 0
    AND ISNULL(@Etano,0) <> 0
    AND ISNULL(@VEtano,0) <> 0
    AND ISNULL(@Propano,0) <> 0
    AND ISNULL(@VPropano,0) <> 0
    AND ISNULL(@Metano,0) <> 0
    AND ISNULL(@VMetano,0) <> 0)
	BEGIN
        SELECT Ca.IDSIPAC AS RF_00, 
            C.IdRegFiducidiario AS RI_00, 
            C.NumeroContrato AS RF01_01, 
            MONTH(VMPPG.MesReporte) AS RMLCT25_00, --LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPPG.MesReporte))))+LTRIM(MONTH(VMPPG.MesReporte))
            YEAR(VMPPG.MesReporte) AS RMLCT25_01, 
            CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
				ELSE ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0)
			END												AS RMLCT25_02,
            CONVERT(DECIMAL(3, 1), VMPPG.GradosAPI)			AS RMLCT25_03, 
            CONVERT(DECIMAL(6, 2), VMPPG.ContenidoAzufre)	AS RMLCT25_04, 
            ROUND(ISNULL(VMPPG.VolumenPetroleoAutoconsumo, 0), 0) AS RMLCT25_05, 
			CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.MetanoC1, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
				ELSE ROUND(ISNULL(VMPPG.MetanoC1, 0), 0)
			END												AS RMLCT25_06,
            CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.EtanoC2, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
				ELSE ROUND(ISNULL(VMPPG.EtanoC2, 0), 0) 
			END												AS RMLCT25_07, 
            CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.PropanoC3, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
				ELSE ROUND(ISNULL(VMPPG.PropanoC3, 0), 0) 
			END												AS RMLCT25_08,
			CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.ButanoC4, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
				ELSE ROUND(ISNULL(VMPPG.ButanoC4, 0), 0)
			END												AS RMLCT25_09, 
            ROUND(ISNULL(VMPPG.MetanoC1Autoconsumo, 0), 0)	AS RMLCT25_10, 
            ROUND(ISNULL(VMPPG.EtanoC2Autoconsumo, 0), 0)	AS RMLCT25_11, 
            ROUND(ISNULL(VMPPG.PropanoC3Autoconsumo, 0), 0) AS RMLCT25_12, 
            ROUND(ISNULL(VMPPG.ButanoC4Autoconsumo, 0), 0)	AS RMLCT25_13, 
			CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( (ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion,0),0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0)) * (ISNULL(PC.PorcentajePemex,100)/100),0)
				ELSE ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion, 0), 0)
			END												AS RMLCT25_14, 
            ROUND(ISNULL(VMPPG.VolumenCondensadoAutoconsumo, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensableAutoconsumo, 0), 0) AS RMLCT25_15, 
            ROUND(ISNULL(V.[1], 0), 0) AS RMLCT25_16, 
            ROUND(ISNULL(V.[3], 0), 0) AS RMLCT25_17, 
            ROUND(ISNULL(V.[4], 0), 0) AS RMLCT25_18, 
            ROUND(ISNULL(V.[5], 0), 0) AS RMLCT25_19, 
            ROUND(ISNULL(V.[6], 0), 0) AS RMLCT25_20, 
            ROUND(ISNULL(V.[2], 0), 0) AS RMLCT25_21,
            CASE
				WHEN(V.[1] * 100) / ROUND(@VolPetroleoPM, 0) >= @PorcentajeMinVta
				THEN ROUND(ISNULL(P.[1], 0), 4)
                ELSE ROUND(@P1, 4)
            END AS RMLCT25_22,
            CASE
                WHEN(V.[3] * 100) / ROUND(@Metano, 0) >= @PorcentajeMinVta
                THEN ROUND(ISNULL(P.[3], 0), 4)
                ELSE ROUND(@P3, 4)
            END AS RMLCT25_23,
            CASE
                WHEN(V.[4] * 100) / ROUND(@Etano, 0) >= @PorcentajeMinVta
                THEN ROUND(ISNULL(P.[4], 0), 4)
                ELSE ROUND(@P4, 4)
            END AS RMLCT25_24,
            CASE
                WHEN(V.[5] * 100) / ROUND(@Propano, 0) >= @PorcentajeMinVta
                THEN ROUND(ISNULL(P.[5], 0), 4)
    ELSE ROUND(@P5, 4)
            END AS RMLCT25_25,
            CASE
                WHEN(V.[6] * 100) / ROUND(@Butano, 0) >= @PorcentajeMinVta
                THEN ROUND(ISNULL(P.[6], 0), 4)
                ELSE ROUND(@P6, 4)
            END AS RMLCT25_26, 
            'NA' AS RMLCT25_27,
            CASE
                WHEN @IdMetodo1 <> 1 AND @IdMetodo1 <> 3
                THEN 2
                ELSE @IdMetodo1
            END AS RMLCT25_28,
            CASE
                WHEN @IdMetodo3 <> 1
                THEN 2
                ELSE @IdMetodo3
            END AS RMLCT25_29,
            CASE
                WHEN @IdMetodo4 <> 1
                THEN 2
                ELSE @IdMetodo4
            END AS RMLCT25_30,
            CASE
                WHEN @IdMetodo5 <> 1
                THEN 2
                ELSE @IdMetodo5
            END AS RMLCT25_31,
            CASE
                WHEN @IdMetodo6 <> 1
                THEN 2
                ELSE @IdMetodo6
            END AS RMLCT25_32, 
            'NA' AS RMLCT25_33,
            CASE WHEN @IdMetodo1 = 4 THEN 1 ELSE 0 END AS RMLCT25_34,
            CASE WHEN @IdMetodo3 = 4 THEN 1 ELSE 0 END AS RMLCT25_35,
			CASE WHEN @IdMetodo4 = 4 THEN 1 ELSE 0 END AS RMLCT25_36,
            CASE WHEN @IdMetodo5 = 4 THEN 1 ELSE 0 END AS RMLCT25_37,
            CASE WHEN @IdMetodo6 = 4 THEN 1 ELSE 0 END AS RMLCT25_38,
            CASE WHEN @IdMetodo2 = 4 THEN 1 ELSE 0 END AS RMLCT25_39, 
            ROUND(ISNULL(P.[1], 0), 4) AS RMLCT25_40, 
            ROUND(ISNULL(P.[3], 0), 4) AS RMLCT25_41, 
            ROUND(ISNULL(P.[4], 0), 4) AS RMLCT25_42, 
            ROUND(ISNULL(P.[5], 0), 4) AS RMLCT25_43, 
            ROUND(ISNULL(P.[6], 0), 4) AS RMLCT25_44, 
            'NA' AS RMLCT25_45
        FROM dbo.PR_VolumenMensualProduccionPetroleo VMPPG
            JOIN dbo.CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
            JOIN dbo.CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
            JOIN #Precio P ON C.IdContrato = P.IdContrato
            JOIN #Volumen V ON C.IdContrato = V.IdContrato
			LEFT JOIN dbo.CO_PorcentajesContrato	PC
				ON	VMPPG.IdContrato	=	PC.idContrato
        WHERE VMPPG.IdContrato = @Contrato
            AND VMPPG.MesReporte = @Mes
    END
	ELSE
	BEGIN
		IF(ISNULL(@VolCondPM,0) = 0
		AND ISNULL(@V2,0) = 0
		AND ISNULL(@Metano,0) = 0
		AND ISNULL(@VMetano,0) = 0
		AND ISNULL(@Etano,0) = 0
		AND ISNULL(@VEtano,0) = 0
		AND ISNULL(@Propano,0) = 0
		AND ISNULL(@VPropano,0) = 0
		AND ISNULL(@Metano,0) = 0
		AND ISNULL(@VMetano,0) = 0)
		BEGIN
            SELECT Ca.IDSIPAC			AS RF_00, 
                C.IdRegFiducidiario		AS RI_00, 
                C.NumeroContrato		AS RF01_01, 
                MONTH(VMPPG.MesReporte) AS RMLCT25_00, --LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPPG.MesReporte))))+LTRIM(MONTH(VMPPG.MesReporte))
                YEAR(VMPPG.MesReporte)	AS RMLCT25_01, 
                CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0)
				END						AS RMLCT25_02, 
                CONVERT(DECIMAL(3, 1), VMPPG.GradosAPI)			AS RMLCT25_03, 
                CONVERT(DECIMAL(6, 2), VMPPG.ContenidoAzufre)	AS RMLCT25_04, 
                ROUND(ISNULL(VMPPG.VolumenPetroleoAutoconsumo, 0), 0) AS RMLCT25_05, 
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.MetanoC1, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.MetanoC1, 0), 0)
				END												AS RMLCT25_06,
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.EtanoC2, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.EtanoC2, 0), 0) 
				END												AS RMLCT25_07, 
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.PropanoC3, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.PropanoC3, 0), 0) 
				END												AS RMLCT25_08,
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.ButanoC4, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.ButanoC4, 0), 0)
				END												AS RMLCT25_09, 
                ROUND(ISNULL(VMPPG.MetanoC1Autoconsumo, 0), 0)	AS RMLCT25_10, 
                ROUND(ISNULL(VMPPG.EtanoC2Autoconsumo, 0), 0)	AS RMLCT25_11, 
                ROUND(ISNULL(VMPPG.PropanoC3Autoconsumo, 0), 0) AS RMLCT25_12, 
                ROUND(ISNULL(VMPPG.ButanoC4Autoconsumo, 0), 0)	AS RMLCT25_13, 
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( (ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion,0),0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0)) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion, 0), 0)
				END												AS RMLCT25_14, 
                ROUND(ISNULL(VMPPG.VolumenCondensadoAutoconsumo, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensableAutoconsumo, 0), 0) AS RMLCT25_15, 
                ROUND(ISNULL(V.[1], 0), 0) AS RMLCT25_16, 
                ROUND(ISNULL(V.[3], 0), 0) AS RMLCT25_17, 
                ROUND(ISNULL(V.[4], 0), 0) AS RMLCT25_18, 
                ROUND(ISNULL(V.[5], 0), 0) AS RMLCT25_19, 
                ROUND(ISNULL(V.[6], 0), 0) AS RMLCT25_20, 
                ROUND(ISNULL(V.[2], 0), 0) AS RMLCT25_21,
                CASE
                    WHEN(V.[1] * 100) / ROUND(@VolPetroleoPM, 0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[1], 0), 4)
                    ELSE ROUND(@P1, 4)
                END AS RMLCT25_22, 
                'NA' AS RMLCT25_23, 
                'NA' AS RMLCT25_24, 
                'NA' AS RMLCT25_25, 
                'NA' AS RMLCT25_26, 
                'NA' AS RMLCT25_27,
                CASE
                    WHEN @IdMetodo1 <> 1 AND @IdMetodo1 <> 3
                    THEN 2
                    ELSE @IdMetodo1
                END AS RMLCT25_28, 
                'NA' AS RMLCT25_29, 
                'NA' AS RMLCT25_30, 
                'NA' AS RMLCT25_31, 
                'NA' AS RMLCT25_32, 
                'NA' AS RMLCT25_33,
                CASE WHEN @IdMetodo1 = 4 THEN 1 ELSE 0 END AS RMLCT25_34,
                CASE WHEN @IdMetodo3 = 4 THEN 1 ELSE 0 END AS RMLCT25_35,
                CASE WHEN @IdMetodo4 = 4 THEN 1 ELSE 0 END AS RMLCT25_36,
                CASE WHEN @IdMetodo5 = 4 THEN 1 ELSE 0 END AS RMLCT25_37,
                CASE WHEN @IdMetodo6 = 4 THEN 1 ELSE 0 END AS RMLCT25_38,
                CASE WHEN @IdMetodo2 = 4 THEN 1 ELSE 0 END AS RMLCT25_39, 
                ROUND(ISNULL(P.[1], 0), 4) AS RMLCT25_40, 
                'NA' AS RMLCT25_41, 
                'NA' AS RMLCT25_42, 
                'NA' AS RMLCT25_43, 
                'NA' AS RMLCT25_44, 
                'NA' AS RMLCT25_45
            FROM dbo.PR_VolumenMensualProduccionPetroleo VMPPG
                JOIN dbo.CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
                JOIN dbo.CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
                LEFT JOIN #Precio P ON C.IdContrato = P.IdContrato
                LEFT JOIN #Volumen V ON C.IdContrato = V.IdContrato
				LEFT JOIN dbo.CO_PorcentajesContrato	PC
					ON	VMPPG.IdContrato	=	PC.idContrato
            WHERE VMPPG.IdContrato = @Contrato
                AND VMPPG.MesReporte = @Mes
        END
        ELSE
        BEGIN
            SELECT Ca.IDSIPAC AS RF_00, 
                C.IdRegFiducidiario AS RI_00, 
                C.NumeroContrato AS RF01_01, 
                MONTH(VMPPG.MesReporte) AS RMLCT25_00, --LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPPG.MesReporte))))+LTRIM(MONTH(VMPPG.MesReporte))
                YEAR(VMPPG.MesReporte) AS RMLCT25_01,
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0)
				END						AS RMLCT25_02, 
                CONVERT(DECIMAL(3, 1), VMPPG.GradosAPI) AS RMLCT25_03, 
                CONVERT(DECIMAL(6, 2), VMPPG.ContenidoAzufre) AS RMLCT25_04, 
                ROUND(ISNULL(VMPPG.VolumenPetroleoAutoconsumo, 0), 0) AS RMLCT25_05, 
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.MetanoC1, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.MetanoC1, 0), 0)
				END												AS RMLCT25_06,
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.EtanoC2, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.EtanoC2, 0), 0) 
				END												AS RMLCT25_07, 
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.PropanoC3, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.PropanoC3, 0), 0) 
				END												AS RMLCT25_08,
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ROUND(ISNULL(VMPPG.ButanoC4, 0), 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.ButanoC4, 0), 0)
				END												AS RMLCT25_09, 
                ROUND(ISNULL(VMPPG.MetanoC1Autoconsumo, 0), 0) AS RMLCT25_10, 
                ROUND(ISNULL(VMPPG.EtanoC2Autoconsumo, 0), 0) AS RMLCT25_11, 
                ROUND(ISNULL(VMPPG.PropanoC3Autoconsumo, 0), 0) AS RMLCT25_12, 
                ROUND(ISNULL(VMPPG.ButanoC4Autoconsumo, 0), 0) AS RMLCT25_13, 
				CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( (ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion,0),0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0)) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ROUND(ISNULL(VMPPG.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion, 0), 0)
				END												AS RMLCT25_14, 
                ROUND(ISNULL(VMPPG.VolumenCondensadoAutoconsumo, 0), 0) + ROUND(ISNULL(VMPPG.VolumenCondensableAutoconsumo, 0), 0) AS RMLCT25_15, 
                ROUND(ISNULL(V.[1], 0), 0) AS RMLCT25_16, 
                ROUND(ISNULL(V.[3], 0), 0) AS RMLCT25_17, 
                ROUND(ISNULL(V.[4], 0), 0) AS RMLCT25_18, 
                ROUND(ISNULL(V.[5], 0), 0) AS RMLCT25_19, 
                ROUND(ISNULL(V.[6], 0), 0) AS RMLCT25_20, 
                ROUND(ISNULL(V.[2], 0), 0) AS RMLCT25_21,
                CASE
                    WHEN(V.[1] * 100) / ROUND(@VolPetroleoPM, 0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[1], 0), 4)
                    ELSE ROUND(@P1, 4)
                END AS RMLCT25_22,
                CASE
                    WHEN(V.[3] * 100) / ROUND(@Metano, 0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[3], 0), 4)
                    ELSE ROUND(@P3, 4)
                END AS RMLCT25_23,
                CASE
                    WHEN(V.[4] * 100) / ROUND(@Etano, 0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[4], 0), 4)
                    ELSE ROUND(@P4, 4)
				END AS RMLCT25_24,
                CASE
                    WHEN(V.[5] * 100) / ROUND(@Propano, 0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[5], 0), 4)
                    ELSE ROUND(@P5, 4)
                END AS RMLCT25_25,
                CASE
                    WHEN(V.[6] * 100) / ROUND(@Butano, 0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[6], 0), 4)
                    ELSE ROUND(@P6, 4)
                END AS RMLCT25_26,
                CASE
                    WHEN(V.[2] * 100) / ROUND(@VolCondPM,0) >= @PorcentajeMinVta
                    THEN ROUND(ISNULL(P.[2], 0), 4)
                    ELSE ROUND(@P2, 4)
                END AS RMLCT25_27,
                CASE
                    WHEN @IdMetodo1 <> 1 AND @IdMetodo1 <> 3
                    THEN 2
            ELSE @IdMetodo1
                END AS RMLCT25_28,
                CASE
                    WHEN @IdMetodo3 <> 1
                    THEN 2
                    ELSE @IdMetodo3
                END AS RMLCT25_29,
                CASE
                    WHEN @IdMetodo4 <> 1
                    THEN 2
                    ELSE @IdMetodo4
                END AS RMLCT25_30,
                CASE
                    WHEN @IdMetodo5 <> 1
                    THEN 2
                    ELSE @IdMetodo5
                END AS RMLCT25_31,
                CASE
                    WHEN @IdMetodo6 <> 1
                    THEN 2
                    ELSE @IdMetodo6
                END AS RMLCT25_32,
                CASE
                    WHEN @IdMetodo2 <> 1 AND @IdMetodo2 <> 3
                    THEN 2
                    ELSE @IdMetodo2
                END AS RMLCT25_33,
                CASE WHEN @IdMetodo1 = 4 THEN 1 ELSE 0 END AS RMLCT25_34,
                CASE WHEN @IdMetodo3 = 4 THEN 1 ELSE 0 END AS RMLCT25_35,
                CASE WHEN @IdMetodo4 = 4 THEN 1 ELSE 0 END AS RMLCT25_36,
                CASE WHEN @IdMetodo5 = 4 THEN 1 ELSE 0 END AS RMLCT25_37,
                CASE WHEN @IdMetodo6 = 4 THEN 1 ELSE 0 END AS RMLCT25_38,
                CASE WHEN @IdMetodo2 = 4 THEN 1 ELSE 0 END AS RMLCT25_39, 
                ROUND(ISNULL(P.[1], 0), 4) AS RMLCT25_40, 
                ROUND(ISNULL(P.[3], 0), 4) AS RMLCT25_41, 
                ROUND(ISNULL(P.[4], 0), 4) AS RMLCT25_42, 
                ROUND(ISNULL(P.[5], 0), 4) AS RMLCT25_43, 
                ROUND(ISNULL(P.[6], 0), 4) AS RMLCT25_44, 
                ROUND(ISNULL(P.[2], 0), 4) AS RMLCT25_45
            FROM dbo.PR_VolumenMensualProduccionPetroleo VMPPG
                JOIN dbo.CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
                JOIN dbo.CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
                JOIN #Precio P ON C.IdContrato = P.IdContrato
                JOIN #Volumen V ON C.IdContrato = V.IdContrato
				LEFT JOIN dbo.CO_PorcentajesContrato	PC
					ON	VMPPG.IdContrato	=	PC.idContrato
            WHERE VMPPG.IdContrato = @Contrato
                AND VMPPG.MesReporte = @Mes
        END
	END
END
ELSE
BEGIN
    SELECT NULL RF_00, 
        NULL AS RI_00, 
        NULL AS RF01_01, 
        NULL AS RMLCT25_00, 
        NULL AS RMLCT25_01, 
        NULL AS RMLCT25_02, 
        NULL AS RMLCT25_03, 
        NULL AS RMLCT25_04, 
        NULL AS RMLCT25_05, 
        NULL AS RMLCT25_06, 
        NULL AS RMLCT25_07, 
        NULL AS RMLCT25_08, 
        NULL AS RMLCT25_09, 
        NULL AS RMLCT25_10, 
        NULL AS RMLCT25_11, 
        NULL AS RMLCT25_12, 
        NULL AS RMLCT25_13, 
        NULL AS RMLCT25_14, 
        NULL AS RMLCT25_15, 
        NULL AS RMLCT25_16, 
        NULL AS RMLCT25_17, 
        NULL AS RMLCT25_18, 
        NULL AS RMLCT25_19, 
        NULL AS RMLCT25_20, 
        NULL AS RMLCT25_21, 
        NULL AS RMLCT25_22, 
        NULL AS RMLCT25_23, 
        NULL AS RMLCT25_24, 
        NULL AS RMLCT25_25, 
        NULL AS RMLCT25_26, 
       NULL AS RMLCT25_27, 
        NULL AS RMLCT25_28, 
        NULL AS RMLCT25_29, 
        NULL AS RMLCT25_30, 
        NULL AS RMLCT25_31, 
        NULL AS RMLCT25_32, 
        NULL AS RMLCT25_33, 
        NULL AS RMLCT25_34, 
        NULL AS RMLCT25_35, 
        NULL AS RMLCT25_36, 
        NULL AS RMLCT25_37, 
        NULL AS RMLCT25_38, 
        NULL AS RMLCT25_39, 
        NULL AS RMLCT25_40, 
        NULL AS RMLCT25_41, 
        NULL AS RMLCT25_42, 
        NULL AS RMLCT25_43, 
        NULL AS RMLCT25_44, 
        NULL AS RMLCT25_45
END
END
