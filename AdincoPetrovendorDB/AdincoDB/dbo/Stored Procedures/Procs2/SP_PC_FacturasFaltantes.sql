CREATE PROCEDURE dbo.SP_PC_FacturasFaltantes
	@IdContrato   INT,
	@IdTipoExcel  INT,
	@FechaReporte DATE,
	@IdUsuario    INT
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 06-11-17
-- Description:	
-- FECHA	NOMBRE	COMENTARIO
-- 20180913	BAAC	Se modifica para optimizar la consulta
-- =============================================
SET NOCOUNT ON

CREATE TABLE #CONTRATOS
(
	IdContrato	INT,
	PRIMARY KEY(IdContrato)
)

CREATE TABLE #Facturas
(
	FechaReporte	DATE,
    Serie	NVARCHAR(510),
	Factura	NVARCHAR (510),
	Folio NVARCHAR (510),
	Subtotal	MONEY,
	Impuestos	MONEY,
	Total	MONEY,
	Moneda	NVARCHAR(100),
	UUID	NVARCHAR(510),
	FechaExpedicion	NVARCHAR(100),
	FechaTimbrado NVARCHAR(100),
	FechaFactura NVARCHAR(100),
	--PRIMARY KEY (UUID)
)

INSERT INTO #CONTRATOS
(
    IdContrato
)
SELECT	IdContrato
FROM	dbo.PC_ContratoCampo
GROUP BY IdContrato

IF(@IdTipoExcel = 10002)
BEGIN

	INSERT INTO #Facturas
	(
		FechaReporte,
		Serie,
		Factura,
		Folio,
		Subtotal,
		Impuestos,
		Total,
		Moneda,
		UUID,
		FechaExpedicion,
		FechaTimbrado,
		FechaFactura
	)
	SELECT
		FechaReporte,
		SERIE,
		FACTURA,
		FOLIO,
		SUBTOTAL,
		IMPUESTOS,
		TOTAL,
		MONEDA,
		UUID,
		[FECHAEXPEDICION],
		[FECHATIMBRADO],
		[FECHAFACTURA]
	FROM
		PC_PMI_V2
	WHERE
		CONVERT(INT,SUBSTRING(FechaTimbrado,7,4))	=	YEAR(@FechaReporte)
		AND
		CONVERT(INT,SUBSTRING(FechaTimbrado,4,2))	=	MONTH(@FechaReporte)
END 

IF(@IdTipoExcel = 10003)
BEGIN

	INSERT INTO #Facturas
	(
		FechaReporte,
		Serie,
		Factura,
		Folio,
		Subtotal,
		Impuestos,
		Total,
		Moneda,
		UUID,
		FechaExpedicion,
		FechaTimbrado,
		FechaFactura
	)
	SELECT
		FechaReporte,
		SERIE,
		FACTURA,
		FOLIO,
		SUBTOTAL,
		IMPUESTOS,
		TOTAL,
		MONEDA,
		UUID,
		[FECHAEXPEDICION],
		[FECHATIMBRADO],
		[FECHAFACTURA]
	FROM
		PC_PTI_V2
	WHERE
		CONVERT(INT,SUBSTRING(FechaTimbrado,7,4))	=	YEAR(@FechaReporte)
		AND
		CONVERT(INT,SUBSTRING(FechaTimbrado,4,2))	=	MONTH(@FechaReporte)

END

-- SE BORRAN LAS FACTURAS QUE SI CUENTEN CON XML CARGADO EN FI_FACTURA
DELETE F
FROM
	#Facturas	F
JOIN
	dbo.FI_Factura	FI
	ON	F.UUID	=	FI.UUID

-- LAS FACTURAS RESTANTES SON LAS QUE HACEN FALTA DE CARGAR
SELECT
	FechaReporte,
	Serie	AS [SERIE],
	Factura	AS [FACTURA],
	Folio AS [FOLIO],
	Subtotal	AS [SUBTOTAL],
	Impuestos	AS [IMPUESTOS],
	Total		AS [TOTAL],
	Moneda		AS [MONEDA],
	UUID,
	FechaExpedicion	AS [FECHAEXPEDICION],
	FechaTimbrado	AS [FECHATIMBRADO],
	FechaFactura	AS [FECHAFACTURA],
	0	AS IdFactura
FROM
	#Facturas

END
