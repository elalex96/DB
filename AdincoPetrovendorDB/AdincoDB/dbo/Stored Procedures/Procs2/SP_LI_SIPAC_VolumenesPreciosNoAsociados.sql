CREATE PROCEDURE [dbo].[SP_LI_SIPAC_VolumenesPreciosNoAsociados] 
	@Contrato INT, 
	@Mes      DATE,
	@IdUsuario	INT = 1
AS
BEGIN
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
SET NOCOUNT ON
-- =============================================
CREATE TABLE #VolumenComercializado
(	tipohidrocarburo      INT, 
	VolumenComercializado INT, 
	PRIMARY KEY(tipohidrocarburo)
)
--
CREATE TABLE #Calculo
(	tipohidrocarburo INT, 
	Volumen          INT, 
	Precio           DECIMAL(16, 4), 
	PRIMARY KEY(tipohidrocarburo)
)

DECLARE
	@P2 MONEY,
	@P3 MONEY,
	@P4 MONEY,
	@P5 MONEY,
	@P6 MONEY,
	@IdMetodo2 INT,
	@IdMetodo3 INT,
	@IdMetodo4 INT,
	@IdMetodo5 INT,
	@IdMetodo6 INT,
	@NOASOCIADO BIT,
	@UsuarioPEP		BIT,
	@EsConsorcio	BIT,
	@PorcentajeMinVta		FLOAT = 50,
	@VolCondPM		FLOAT,
	@Metano			DECIMAL(10, 2),
	@Etano			DECIMAL(10, 2),
	@Propano		DECIMAL(10, 2),
	@Butano			DECIMAL(10, 2)

SELECT
	@UsuarioPEP	=	CASE WHEN Usuario LIKE '%@pemex.com%' THEN 1 
					ELSE 0	END
FROM
	dbo.AP_Usuario
WHERE
	UsuarioID	=	@IdUsuario
         --

/* MANDAR A LAMAR SP'S CALCULO DE PRECIO CONTRACTUAL

    EXEC [sp_CP_CalculaPrecioContractualGasNaturalLicencia]
        @Contrato,
        @Mes;
    EXEC [sp_CP_CalculaPrecioContractualCondensadosLicencia]
        @Contrato,
        @Mes;
*/
/*Precio contractual del hidrocarburo y método de calculo*/
--
SELECT @P2			= SUM(CASE WHEN IdTipoHidrocarburo = 2 THEN precio ELSE 0 END), 
    @IdMetodo2	= SUM(CASE WHEN IdTipoHidrocarburo = 2 THEN IdMetodo ELSE 0 END), 
    @P3			= SUM(CASE WHEN IdTipoHidrocarburo = 3 THEN precio ELSE 0 END), 
    @IdMetodo3	= SUM(CASE WHEN IdTipoHidrocarburo = 3 THEN IdMetodo ELSE 0 END), 
    @P4			= SUM(CASE WHEN IdTipoHidrocarburo = 4 THEN precio ELSE 0 END), 
    @IdMetodo4	= SUM(CASE WHEN IdTipoHidrocarburo = 4 THEN IdMetodo ELSE 0 END), 
    @P5			= SUM(CASE WHEN IdTipoHidrocarburo = 5 THEN precio ELSE 0 END), 
    @IdMetodo5	= SUM(CASE WHEN IdTipoHidrocarburo = 5 THEN IdMetodo ELSE 0 END), 
    @P6			= SUM(CASE WHEN IdTipoHidrocarburo = 6 THEN precio ELSE 0 END), 
    @IdMetodo6	= SUM(CASE WHEN IdTipoHidrocarburo = 6 THEN IdMetodo ELSE 0 END)
FROM dbo.CP_MetodoCalculoHidrocarburoMes
WHERE mes = @Mes
    AND IdContrato = @Contrato

/*Determinar si el contrato es con gas no asociado*/
--
SELECT @NOASOCIADO = GasNoAsociado,
	@EsConsorcio	=	ISNULL(IsConsorcio,0)
FROM dbo.CO_CONTRATO
WHERE IdContrato = @Contrato
         --
IF @NOASOCIADO = 1
BEGIN
    --
    INSERT INTO #VolumenComercializado
    (tipohidrocarburo, 
    VolumenComercializado
    )
    SELECT TH.TipoHidrocarburo, 
            SUM(ROUND(OP.VolumenVendido, 0))
    FROM dbo.COM_OperacionComercializacion AS OP
            JOIN dbo.FI_Factura F ON OP.IdFactura = F.IdFactura
            JOIN dbo.CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
    WHERE OP.MesReporte = @Mes
            AND OP.IdContrato = @Contrato
            AND OP.OperacionBajoReglasMercado = 1
    GROUP BY TH.tipohidrocarburo

    --
    INSERT INTO #Calculo
    (tipohidrocarburo, 
    Volumen, 
    Precio
    )
    SELECT TH.tipohidrocarburo, 
            SUM(ROUND(OP.VolumenVendido, 0)), 
            SUM((ROUND(OP.PrecioVentaUnitario, 4) - ROUND(OP.CostoUnitarioComercializacion, 4)) * ROUND(OP.VolumenVendido, 0) / VC.VolumenComercializado)
    FROM dbo.COM_OperacionComercializacion AS OP
            JOIN dbo.FI_Factura F ON OP.IdFactura = F.IdFactura
            JOIN dbo.CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
            JOIN #VolumenComercializado VC ON TH.tipohidrocarburo = VC.tipohidrocarburo
    WHERE OP.MesReporte = @Mes
            AND OP.IdContrato = @Contrato
            AND OP.OperacionBajoReglasMercado = 1
            AND VC.VolumenComercializado > 0
    GROUP BY TH.tipohidrocarburo

    --
    SELECT @Contrato AS idcontrato, 
        @Mes AS mesreporte, 
        *
    INTO #Volumen
    FROM
    (
        SELECT tipohidrocarburo, 
            volumen
        FROM #Calculo
    ) AS SourceTable PIVOT(SUM(Volumen) FOR tipohidrocarburo IN([2], 
                                                                [3], 
                                                                [4], 
                                                                [5], 
                                                                [6])) AS PivotTable
    --

    SELECT @Contrato AS idcontrato, 
        @Mes AS mesreporte, 
        *
    INTO #Precio
    FROM
    (
        SELECT tipohidrocarburo, 
            precio
        FROM #Calculo
    ) AS SourceTable PIVOT(SUM(precio) FOR tipohidrocarburo IN([2], 
                                                            [3], 
                                                            [4], 
                                                            [5], 
                                                            [6])) AS PivotTable

    SELECT @VolCondPM = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND((ROUND(ISNULL(VMPGN.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPGN.VolumenCondensablePuntoMedicion, 0), 0)) * (ISNULL(PC.PorcentajePemex,100)/100),0)
							ELSE ROUND(ISNULL(VMPGN.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPGN.VolumenCondensablePuntoMedicion, 0), 0)
						END,
        @Metano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.MetanoC1, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPGN.MetanoC1, 0)
				END,
        @Etano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.EtanoC2, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPGN.EtanoC2, 0)
				END,
        @Propano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.PropanoC3, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPGN.PropanoC3, 0)
				END,
        @Butano = CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.ButanoC4, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
					ELSE ISNULL(VMPGN.ButanoC4, 0)
				END
	FROM dbo.PR_VolumenMensualProduccionPetroleo VMPGN
    JOIN dbo.CO_Contrato C ON VMPGN.IdContrato = C.IdContrato
    JOIN dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
    JOIN #Precio P ON VMPGN.IdContrato = P.IdContrato
    JOIN #Volumen V ON VMPGN.IdContrato = V.IdContrato
	LEFT JOIN dbo.CO_PorcentajesContrato	PC
		ON	VMPGN.IdContrato	=	PC.idContrato
	WHERE VMPGN.IdContrato = @Contrato
    AND VMPGN.MesReporte = @Mes


    /**/
    SELECT CC.IDSIPAC				AS RF_00, 
        C.IDRegFiducidiario			AS RI_00, 
        C.NumeroContrato			AS RF01_01, 
		MONTH(VMPGN.MesReporte)		AS RMLCT26_00, --LTRIM(REPLICATE('0', 2-LEN(MONTH(VMPGN.MesReporte))))+LTRIM(MONTH(VMPGN.MesReporte))
        YEAR(VMPGN.MesReporte)		AS RMLCT26_01, 
		CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.MetanoC1, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
			ELSE ROUND(ISNULL(VMPGN.MetanoC1, 0), 0)
		END												AS RMLCT26_02,
		CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.EtanoC2, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
			ELSE ROUND(ISNULL(VMPGN.EtanoC2, 0), 0)
		END												AS RMLCT26_03, 

		CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.PropanoC3, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
			ELSE ROUND(ISNULL(VMPGN.PropanoC3, 0), 0)
		END												AS RMLCT26_04,

		CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( ISNULL(VMPGN.ButanoC4, 0) * (ISNULL(PC.PorcentajePemex,100)/100),0)
			ELSE ROUND(ISNULL(VMPGN.ButanoC4, 0), 0)
		END												AS RMLCT26_05, 
        ROUND(ISNULL(VMPGN.MetanoC1Autoconsumo, 0), 0)	AS RMLCT26_06, 
        ROUND(ISNULL(VMPGN.EtanoC2Autoconsumo, 0), 0)	AS RMLCT26_07, 
        ROUND(ISNULL(VMPGN.PropanoC3Autoconsumo, 0), 0) AS RMLCT26_08, 
        ROUND(ISNULL(VMPGN.ButanoC4Autoconsumo, 0), 0)	AS RMLCT26_09,
		CASE WHEN @EsConsorcio = 1 AND @UsuarioPEP = 1 THEN ROUND( (ROUND(ISNULL(VMPGN.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPGN.VolumenCondensablePuntoMedicion, 0), 0)) * (ISNULL(PC.PorcentajePemex,100)/100),0)
			ELSE ROUND(ISNULL(VMPGN.VolumenCondensadoPuntoMedicion, 0), 0) + ROUND(ISNULL(VMPGN.VolumenCondensablePuntoMedicion, 0), 0)
		END												AS RMLCT26_10, 
        ROUND(ISNULL(VMPGN.VolumenCondensadoAutoconsumo, 0), 0) + ROUND(ISNULL(VMPGN.VolumenCondensableAutoconsumo, 0), 0) AS RMLCT26_11, 
        ROUND(ISNULL(V.[3], 0), 0) AS RMLCT26_12, 
        ROUND(ISNULL(V.[4], 0), 0) AS RMLCT26_13, 
        ROUND(ISNULL(V.[5], 0), 0) AS RMLCT26_14, 
        ROUND(ISNULL(V.[6], 0), 0) AS RMLCT26_15, 
        ROUND(ISNULL(V.[2], 0), 0) AS RMLCT26_16,
        CASE
            WHEN(V.[3] * 100) / ROUND(@Metano,0) >= @PorcentajeMinVta
            THEN ROUND(ISNULL(P.[3], 0), 4)
            ELSE ROUND(@P3, 4)
        END AS RMLCT26_17,
        CASE
            WHEN(V.[4] * 100) / ROUND(@Etano,0) >= @PorcentajeMinVta
            THEN ROUND(ISNULL(P.[4], 0), 4)
            ELSE ROUND(@P4, 4)
        END AS RMLCT26_18,
        CASE
            WHEN(V.[5] * 100) / ROUND(@Propano,0) >= @PorcentajeMinVta
            THEN ROUND(ISNULL(P.[5], 0), 4)
            ELSE ROUND(@P5, 4)
        END AS RMLCT26_19,
        CASE
            WHEN(V.[6] * 100) / ROUND(@Butano,0) >= @PorcentajeMinVta
            THEN ROUND(ISNULL(P.[6], 0), 4)
            ELSE ROUND(@P6, 4)
        END AS RMLCT26_20,
        CASE
            WHEN(V.[2] * 100) / ROUND(@VolCondPM,0) >= @PorcentajeMinVta
            THEN ROUND(ISNULL(P.[2], 0), 4)
            ELSE ROUND(@P2, 4)
        END AS RMLCT26_21,
        CASE
            WHEN @IdMetodo3 <> 1
            THEN 2
            ELSE @IdMetodo3
        END AS RMLCT26_22,
        CASE
            WHEN @IdMetodo4 <> 1
            THEN 2
            ELSE @IdMetodo4
        END AS RMLCT26_23,
        CASE
            WHEN @IdMetodo5 <> 1
            THEN 2
            ELSE @IdMetodo5
        END AS RMLCT26_24,
        CASE
            WHEN @IdMetodo6 <> 1
            THEN 2
            ELSE @IdMetodo6
        END AS RMLCT26_25,
        CASE
            WHEN @IdMetodo2 <> 1 AND @IdMetodo2 <> 3
            THEN 2
            ELSE @IdMetodo2
        END AS RMLCT26_26,
        CASE WHEN @IdMetodo3 = 4 THEN 1 ELSE 0 END AS RMLCT26_27,
        CASE WHEN @IdMetodo4 = 4 THEN 1 ELSE 0 END AS RMLCT26_28,
        CASE WHEN @IdMetodo5 = 4 THEN 1 ELSE 0 END AS RMLCT26_29,
        CASE WHEN @IdMetodo6 = 4 THEN 1 ELSE 0 END AS RMLCT26_30,
        CASE WHEN @IdMetodo2 = 4 THEN 1 ELSE 0 END AS RMLCT26_31, 
        ROUND(ISNULL(P.[3], 0), 4) AS RMLCT26_32, 
        ROUND(ISNULL(P.[4], 0), 4) AS RMLCT26_33, 
        ROUND(ISNULL(P.[5], 0), 4) AS RMLCT26_34, 
        ROUND(ISNULL(P.[6], 0), 4) AS RMLCT26_35, 
        ROUND(ISNULL(P.[2], 0), 4) AS RMLCT26_36
    FROM dbo.PR_VolumenMensualProduccionPetroleo VMPGN
        JOIN dbo.CO_Contrato C ON VMPGN.IdContrato = C.IdContrato
        JOIN dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista --PR_VolumenMensualProduccionGasNoAsoc
        JOIN #Precio P ON VMPGN.IdContrato = P.IdContrato
        JOIN #Volumen V ON VMPGN.IdContrato = V.IdContrato
		LEFT JOIN dbo.CO_PorcentajesContrato	PC
			ON	VMPGN.IdContrato	=	PC.idContrato
    WHERE VMPGN.IdContrato = @Contrato
        AND VMPGN.MesReporte = @Mes
END
ELSE
BEGIN
    SELECT NULL AS RF_00, 
        NULL AS RI_00, 
        NULL AS RF01_01, 
        NULL AS RMLCT26_00, 
        NULL AS RMLCT26_01, 
        NULL AS RMLCT26_02, 
        NULL AS RMLCT26_03, 
        NULL AS RMLCT26_04, 
        NULL AS RMLCT26_05, 
        NULL AS RMLCT26_06, 
        NULL AS RMLCT26_07, 
        NULL AS RMLCT26_08, 
        NULL AS RMLCT26_09, 
        NULL AS RMLCT26_10, 
        NULL AS RMLCT26_11, 
        NULL AS RMLCT26_12, 
        NULL AS RMLCT26_13, 
        NULL AS RMLCT26_14, 
        NULL AS RMLCT26_15, 
        NULL AS RMLCT26_16, 
        NULL AS RMLCT26_17, 
        NULL AS RMLCT26_18, 
        NULL AS RMLCT26_19, 
        NULL AS RMLCT26_20, 
        NULL AS RMLCT26_21, 
        NULL AS RMLCT26_22, 
        NULL AS RMLCT26_23, 
        NULL AS RMLCT26_24, 
        NULL AS RMLCT26_25, 
        NULL AS RMLCT26_26, 
        NULL AS RMLCT26_27, 
        NULL AS RMLCT26_28, 
        NULL AS RMLCT26_29, 
        NULL AS RMLCT26_30, 
        NULL AS RMLCT26_31, 
        NULL AS RMLCT26_32, 
        NULL AS RMLCT26_33, 
        NULL AS RMLCT26_34, 
        NULL AS RMLCT26_35, 
        NULL AS RMLCT26_36
END
END
