CREATE PROCEDURE dbo.sp_CP_CalculaCuotaContractualeImpuesto
	@IdContratista INT,
	@FechaIni    DATE,
	@FechaFin    DATE
AS
BEGIN
-- =============================================
-- Author:		Barbara Arrañaga
-- Create date: 2018-06-07
-- Description:	Proceso para realizar el calculo de la cuota contractual e Impuesto Fase Exploración
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- ----------------------------------------------------------------------------------
-- BAAC	20191118	Se modifica ya que la cuota contractual no se cobra si ya se esta en desarrollo
-- =============================================
SET NOCOUNT ON
-- ------------------------------------------------------------------------------------
CREATE TABLE #Meses
(
	Fecha	DATE,
	IdContratista	INT
)

INSERT INTO #Meses
(
    Fecha, IdContratista
)
SELECT
	PrimerDiaMes, @IdContratista
FROM
	dbo.AP_Calendario
WHERE
	IdFecha	BETWEEN @FechaIni	AND @FechaFin
GROUP BY
	PrimerDiaMes

    SELECT
		M.Fecha	AS [Mes],
		CO.NumeroContrato,
		CASE 
            WHEN YEAR(M.Fecha) = 2015 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1150
            WHEN YEAR(M.Fecha) = 2016 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1175.42
            WHEN YEAR(M.Fecha) = 2017 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1214.20
			WHEN YEAR(M.Fecha) = 2018 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1294.71
			WHEN YEAR(M.Fecha) = 2019 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1355.82
			WHEN YEAR(M.Fecha) = 2020 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1396.09
			WHEN YEAR(M.Fecha) = 2021 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1442.58
			WHEN YEAR(M.Fecha) = 2022 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1548.88
			WHEN YEAR(M.Fecha) = 2023 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1669.53
			WHEN DATEDIFF(month, CO.FechaFirma, M.Fecha) >= 61 THEN 3992.39
            ELSE 1669.53
        END AS CuotaContractual,
        AC.SuperficieKm2,
        CASE 
            WHEN YEAR(M.Fecha) = 2015 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1150 * AC.SuperficieKm2,2)
            WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1175.42 * AC.SuperficieKm2,2)
            WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1214.20 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1294.71 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2019 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1355.82 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2020 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1396.09 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2021 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1442.58 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2022 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1548.88 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2023 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1669.53 * AC.SuperficieKm2,2)
			WHEN DATEDIFF(month, CO.FechaFirma, M.Fecha) >= 61 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(3992.39 * AC.SuperficieKm2,2)
            ELSE ROUND(1669.53 * AC.SuperficieKm2,2)
        END AS TotalCuotaContractual,
		CASE 
			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma <> 'Plan Desarrollo'
				THEN 1688.74
			WHEN YEAR(M.Fecha) = 2019 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 1768.45
			WHEN YEAR(M.Fecha) = 2020 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 6850.3
			WHEN YEAR(M.Fecha) = 2021 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 1881.60
			WHEN YEAR(M.Fecha) = 2022 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 2020.27
			WHEN YEAR(M.Fecha) = 2023 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 2177.64

			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 6754.99
			WHEN YEAR(M.Fecha) = 2019 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 7073.83
			WHEN YEAR(M.Fecha) = 2020 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 6850.3
			WHEN YEAR(M.Fecha) = 2021 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 7526.47
			WHEN YEAR(M.Fecha) = 2022 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 8081.17
			WHEN YEAR(M.Fecha) = 2023 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 8710.69
		END AS Impuesto,	-- Art. 55
		CASE 
			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma <> 'Plan Desarrollo'
				THEN 1688.74 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2019 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(1768.45 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2020 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(6850.3 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2021 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(1881.60 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2022 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(2020.27 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2023 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(2177.64 * AC.SuperficieKm2,2)

			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 6754.99 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2019 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(7073.83 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2020 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(6850.3 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2021 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(7526.47 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2022 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(8081.17 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2023 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(8710.69 * AC.SuperficieKm2,2)
		END AS TotalImpuesto
    FROM
		#Meses	M
	JOIN
		dbo.CO_Contrato	CO	(NOLOCK)
		ON	M.IdContratista	=	CO.IdContratista
		AND CO.Activo = 1
	JOIN
		CO_AreaContractual AC	(NOLOCK)
		ON CO.IdAreaContractual = AC.IdAreaContractual
	LEFT JOIN
		CO_PeriodoContrato	PC	(NOLOCK)
		ON	CO.IdContrato	=	PC.IdContrato
		AND M.Fecha	BETWEEN	PC.Inicio	AND PC.Fin
	LEFT JOIN
		CO_ProgramaActividad	PA
		ON	PC.IdPeriodo	=	PA.IdPeriodoContrato
	LEFT JOIN
		CO_TipoProgramaActividad	TIPO
		ON	PA.IdTipoProgramaActividad	=	TIPO.IdTipoProgramaActividad
	GROUP BY
		M.Fecha,
		CO.NumeroContrato,
		CASE 
            WHEN YEAR(M.Fecha) = 2015 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1150
            WHEN YEAR(M.Fecha) = 2016 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1175.42
            WHEN YEAR(M.Fecha) = 2017 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1214.20
			WHEN YEAR(M.Fecha) = 2018 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1294.71
			WHEN YEAR(M.Fecha) = 2019 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1355.82
			WHEN YEAR(M.Fecha) = 2020 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1396.09
			WHEN YEAR(M.Fecha) = 2021 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1442.58
			WHEN YEAR(M.Fecha) = 2022 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1548.88
			WHEN YEAR(M.Fecha) = 2023 AND DATEDIFF(month, CO.FechaFirma, M.Fecha) < 61	THEN 1669.53
			WHEN DATEDIFF(month, CO.FechaFirma, M.Fecha) >= 61 THEN 3992.39
            ELSE 1669.53
        END,
        AC.SuperficieKm2,
        CASE 
            WHEN YEAR(M.Fecha) = 2015 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1150 * AC.SuperficieKm2,2)
            WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1175.42 * AC.SuperficieKm2,2)
            WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1214.20 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1294.71 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2019 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1355.82 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2020 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1396.09 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2021 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1442.58 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2022 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1548.88 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2023 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(1669.53 * AC.SuperficieKm2,2)
			WHEN DATEDIFF(month, CO.FechaFirma, M.Fecha) >= 61 AND TIPO.TipoPrograma <> 'Plan Desarrollo' THEN ROUND(3992.39 * AC.SuperficieKm2,2)
            ELSE ROUND(1669.53 * AC.SuperficieKm2,2)
        END,
		CASE 
			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma <> 'Plan Desarrollo'
				THEN 1688.74
			WHEN YEAR(M.Fecha) = 2019 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 1768.45
			WHEN YEAR(M.Fecha) = 2020 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 6850.3
			WHEN YEAR(M.Fecha) = 2021 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 1881.60
			WHEN YEAR(M.Fecha) = 2022 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 2020.27
			WHEN YEAR(M.Fecha) = 2023 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN 2177.64

			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 6754.99
			WHEN YEAR(M.Fecha) = 2019 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 7073.83
			WHEN YEAR(M.Fecha) = 2020 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 6850.3
			WHEN YEAR(M.Fecha) = 2021 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 7526.47
			WHEN YEAR(M.Fecha) = 2022 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 8081.17
			WHEN YEAR(M.Fecha) = 2023 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 8710.69
		END,	-- Art. 55
		CASE 
			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma <> 'Plan Desarrollo'	-- FASE EXPLORACION
				THEN 1583.74 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma <> 'Plan Desarrollo'
				THEN 1688.74 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2019 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(1768.45 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2020 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(6850.3 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2021 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(1881.60 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2022 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(2020.27 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2023 AND ISNULL(TIPO.TipoPrograma,'') <> 'Plan Desarrollo'
				THEN ROUND(2177.64 * AC.SuperficieKm2,2)

			WHEN YEAR(M.Fecha) = 2016 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2017 AND TIPO.TipoPrograma = 'Plan Desarrollo'	-- FASE EXTRACCION
				THEN 6334.98 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2018 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN 6754.99 * AC.SuperficieKm2
			WHEN YEAR(M.Fecha) = 2019 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(7073.83 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2020 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(6850.3 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2021 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(7526.47 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2022 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(8081.17 * AC.SuperficieKm2,2)
			WHEN YEAR(M.Fecha) = 2023 AND TIPO.TipoPrograma = 'Plan Desarrollo'
				THEN ROUND(8710.69 * AC.SuperficieKm2,2)
		END
	ORDER BY
		M.Fecha,
		CO.NumeroContrato
END

