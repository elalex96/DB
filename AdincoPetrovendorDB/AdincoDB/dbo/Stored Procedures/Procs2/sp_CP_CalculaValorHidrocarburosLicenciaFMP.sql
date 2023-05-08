CREATE PROCEDURE  sp_CP_CalculaValorHidrocarburosLicenciaFMP
	@IdContrato INT  = 0,
	@Periodo    DATE
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017-01-01
-- Description:	Calcula valor de los hidrocarburos
-- =============================================
SET NOCOUNT ON
-- =============================================

SELECT
	'Condensado' AS Hidrocarburo,
	FORMAT(CONVERT(FLOAT,FMP.[Precio contractual: condensados (RM50_17)]),'$###,###,###.####','en-US') AS [Precio Contractual (USD)],
	--FMP.[Precio contractual: condensados (RM50_17)] AS [Precio Contractual (USD)],
	FORMAT(CONVERT(FLOAT,FMP.[Producción: Volumen contractual de condensados (RM50_11)]),'###,###,###.####','en-US') AS [Volumen (bls)],
	FORMAT(CONVERT(FLOAT,REPLACE(FMP.[Valor contractual: condensados (RM50_39)],',','')),'$###,###,###.####','en-US') AS [Valor Contractual (USD)]
FROM 
	RML_FMP_50_M	FMP
JOIN
	CO_Contrato	C
	ON	FMP.[ID del contrato asignado por CNH (RF01_01)] = C.NumeroContrato
WHERE
	C.IdContrato	=	@IdContrato
	AND	FMP.[Año de reporte (RM50_01)] = YEAR(@Periodo)
	AND	FMP.[Mes de reporte (RM50_00)] = MONTH(@Periodo)
UNION
SELECT
	'Metano' AS Hidrocarburo,
	FORMAT(CONVERT(FLOAT,FMP.[Precio contractual: metano (RM50_13)]),'$###,###,###.####','en-US') AS [Precio Contractual (USD)],
	--FMP.[Precio contractual: metano (RM50_13)] AS [Precio Contractual (USD)],
	FORMAT(CONVERT(FLOAT,FMP.[Volumen contractual: producción de metano de gas natural asociad]),'###,###,###.####','en-US') AS [Volumen (bls)],
	FORMAT(CONVERT(FLOAT,REPLACE(FMP.[Valor contractual: metano de gas natural asociado (RM50_31)],',','')),'$###,###,###.####','en-US') AS [Valor Contractual (USD)]
FROM 
	RML_FMP_50_M	FMP
JOIN
	CO_Contrato	C
	ON	FMP.[ID del contrato asignado por CNH (RF01_01)] = C.NumeroContrato
WHERE
	C.IdContrato	=	@IdContrato
	AND	FMP.[Año de reporte (RM50_01)] = YEAR(@Periodo)
	AND	FMP.[Mes de reporte (RM50_00)] = MONTH(@Periodo)
UNION
SELECT
	'Etano' AS Hidrocarburo,
	FORMAT(CONVERT(FLOAT,FMP.[Precio contractual: etano (RM50_14)]),'$###,###,###.####','en-US') AS [Precio Contractual (USD)],
	--FMP.[Precio contractual: etano (RM50_14)] AS [Precio Contractual (USD)],
	FORMAT(CONVERT(FLOAT,FMP.[Producción: Volumen contractual de etano de gas natural asociado]),'###,###,###.####','en-US') AS [Volumen (bls)],
	FORMAT(CONVERT(FLOAT,REPLACE(FMP.[Valor contractual: etano de gas natural asociado (RM50_32)],',','')),'$###,###,###.####','en-US') AS [Valor Contractual (USD)]
FROM 
	RML_FMP_50_M	FMP
JOIN
	CO_Contrato	C
	ON	FMP.[ID del contrato asignado por CNH (RF01_01)] = C.NumeroContrato
WHERE
	C.IdContrato	=	@IdContrato
	AND	FMP.[Año de reporte (RM50_01)] = YEAR(@Periodo)
	AND	FMP.[Mes de reporte (RM50_00)] = MONTH(@Periodo)
UNION
SELECT
	'Propano' AS Hidrocarburo,
	FORMAT(CONVERT(FLOAT,FMP.[Precio contractual: propano (RM50_15)]),'$###,###,###.####','en-US') AS [Precio Contractual (USD)],
	--FMP.[Precio contractual: propano (RM50_15)] AS [Precio Contractual (USD)],
	FORMAT(CONVERT(FLOAT,FMP.[Producción: Volumen contractual de propano de gas natural asocia]),'###,###,###.####','en-US') AS [Volumen (bls)],
	FORMAT(CONVERT(FLOAT,REPLACE(FMP.[Valor contractual: propano de gas natural asociado (RM50_33)],',','')),'$###,###,###.####','en-US') AS [Valor Contractual (USD)]
FROM 
	RML_FMP_50_M	FMP
JOIN
	CO_Contrato	C
	ON	FMP.[ID del contrato asignado por CNH (RF01_01)] = C.NumeroContrato
WHERE
	C.IdContrato	=	@IdContrato
	AND	FMP.[Año de reporte (RM50_01)] = YEAR(@Periodo)
	AND	FMP.[Mes de reporte (RM50_00)] = MONTH(@Periodo)
UNION
SELECT
	'Butano' AS Hidrocarburo,
	FORMAT(CONVERT(FLOAT,FMP.[Precio contractual: butano (RM50_16)]),'$###,###,###.####','en-US') AS [Precio Contractual (USD)],
	--FMP.[Precio contractual: butano (RM50_16)] AS [Precio Contractual (USD)],
	FORMAT(CONVERT(FLOAT,FMP.[Producción: Volumen contractual de butano de gas natural asociad]),'###,###,###.####','en-US') AS [Volumen (bls)],
	FORMAT(CONVERT(FLOAT,REPLACE(FMP.[Valor contractual: butano de gas natural asociado (RM50_34)],',','')),'$###,###,###.####','en-US') AS [Valor Contractual (USD)]
FROM 
	RML_FMP_50_M	FMP
JOIN
	CO_Contrato	C
	ON	FMP.[ID del contrato asignado por CNH (RF01_01)] = C.NumeroContrato
WHERE
	C.IdContrato	=	@IdContrato
	AND	FMP.[Año de reporte (RM50_01)] = YEAR(@Periodo)
	AND	FMP.[Mes de reporte (RM50_00)] = MONTH(@Periodo)
UNION
SELECT
	'Petroleo' AS Hidrocarburo,
	FORMAT(CONVERT(FLOAT,FMP.[Precio contractual: petróleo (RM50_12)]),'$###,###,###.####','en-US') AS [Precio Contractual (USD)],
	--FMP.[Precio contractual: petróleo (RM50_12)] AS [Precio Contractual (USD)],
	FORMAT(CONVERT(FLOAT,FMP.[Producción: Volumen contractual de petróleo (RM50_02)]),'###,###,###.####','en-US') AS [Volumen (bls)],
	FORMAT(CONVERT(FLOAT,REPLACE(FMP.[Valor contractual: petróleo (RM50_30)],',','')),'$###,###,###.####','en-US') AS [Valor Contractual (USD)]
FROM 
	RML_FMP_50_M	FMP
JOIN
	CO_Contrato	C
	ON	FMP.[ID del contrato asignado por CNH (RF01_01)] = C.NumeroContrato
WHERE
	C.IdContrato	=	@IdContrato
	AND	FMP.[Año de reporte (RM50_01)] = YEAR(@Periodo)
	AND	FMP.[Mes de reporte (RM50_00)] = MONTH(@Periodo)

END
