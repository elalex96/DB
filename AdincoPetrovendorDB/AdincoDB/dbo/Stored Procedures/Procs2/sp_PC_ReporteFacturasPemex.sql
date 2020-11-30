CREATE PROCEDURE dbo.sp_PC_ReporteFacturasPemex
	@IdContrato   INT,
	@FechaReporte DATE,
	@IdUsuario    INT
AS
BEGIN
-- ================================================================
-- Modulo:	SCOC --> Comercializacion
-- Objetivo: Mostrar un resumen de la carga de facturas
--			 como validación antes de generar las comercializaciones de los hidrocarburos
-- Entradas:	Contrato, Mes reporte y Usuario
-- Salida:	facturas cargadas en la tabla PC_PMI_V2 y PC_PTI_V2
-- ================================================================
-- 20180730	BAAC	Creación de sp
-- ================================================================
SET NOCOUNT ON
-- ================================================================
CREATE TABLE #facturas
(
	Factura	NVARCHAR (100),
	FechaFactura	nvarchar(30),
	FechaTimbrado	DATETIME,
	Denominacion NVARCHAR (1000),
	Nombre1 NVARCHAR (1000),
	CantidadFacturada FLOAT,
	UniMedidaVenta  NVARCHAR (1000),
	Energia	float,
	Subtotal NVARCHAR (200),
	Total	MONEY,
	Moneda nvarchar(100),
	SubTotalUSD NVARCHAR (200),
	TotalUSD NVARCHAR (200),
	UUID nvarchar(510),
	TipoCambio	NVARCHAR (100),
	ValorUnitario	NVARCHAR (200),
	Descripcion	nvarchar(max),
	Unidad nvarchar(2000),
	C1 varchar(200),
	C2 varchar(200),
	C3 varchar(200),
	iC4 varchar(200),
	nC4 varchar(200),
	iC5 varchar(200),
	nC5 varchar(200),
	C6 varchar(200)
)

-- SE EJECUTA PROCEDIMIENTO	QUE GUARDA CROMATOGRAFIA DE LA FACTURA PARA QUE SALGAN LOS DATOS EN EL REPORTE
EXEC SP_PC_GenerarCFDICromatografia @IdContrato, @FechaReporte, @IdUsuario

INSERT INTO #facturas
SELECT
	Com.Factura,
	Com.FechaFactura,
	DATEFROMPARTS( SUBSTRING( PMI.FechaTimbrado, 7, 4 ), SUBSTRING( PMI.FechaTimbrado, 4, 2 ), SUBSTRING( PMI.FechaTimbrado, 1, 2 ) ) AS [FechaTimbrado],
	Com.Denominación,
	Com.Nombre1,
	Com.CantidadFacturada,
	Com.UniMedidaVenta,
	Com.Energía,
	ISNULL(LTRIM(F.SubTotal),''),
	PMI.Total,
	PMI.Moneda,
	ISNULL(LTRIM(F.SubTotal / TCD.TipoCambio),''),
	ISNULL(LTRIM(PMI.Total / TCD.TipoCambio),''),
	PMI.UUID,
	ISNULL(LTRIM(TCD.TipoCambio),''),
	ISNULL(LTRIM(C.ValorUnitario),''),
	ISNULL(LTRIM(C.Descripcion),''),
	ISNULL(LTRIM(C.Unidad),''),
	ISNULL(CROMA.C1,''),
	ISNULL(CROMA.C2,''),
	ISNULL(CROMA.C3,''),
	ISNULL(CROMA.IC4,''),
	ISNULL(CROMA.NC4,''),
	ISNULL(CROMA.IC5,''),
	ISNULL(CROMA.NC5,''),
	ISNULL(CROMA.C6,'')
FROM
	PC_PMI_V2   PMI (nolock)
LEFT JOIN
	FI_Factura AS F (nolock)
	ON PMI.UUID = F.UUID
LEFT JOIN
	FI_CFDIConcepto AS C (nolock) 
	 ON F.IdFactura = C.IdFactura 
LEFT JOIN
	PC_Comercializacion_V2 AS Com (nolock) 
	ON CONVERT(INT,Com.Factura) = CONVERT(INT,PMI.Factura)
LEFT JOIN
	dbo.PV_TipoMoneda TMF 
	ON TMF.IdMoneda = F.IdMoneda
LEFT JOIN
	dbo.CO_TipoCambioDiario TCD 
	ON TCD.IdMoneda = TMF.IdMoneda
	AND YEAR(TCD.Fecha) = CONVERT(INT,SUBSTRING( COM.FechaFactura, 7, 4 ))
    AND MONTH(TCD.Fecha) = CONVERT(INT,SUBSTRING( COM.FechaFactura, 4, 2 ))
    AND DAY(TCD.Fecha) = CONVERT(INT,SUBSTRING( COM.FechaFactura, 1, 2 ))
LEFT JOIN
   dbo.FI_CFDICromatografia   CROMA
        ON C.IdFacturaConcepto     =      CROMA.IdFacturaConcepto
WHERE
	CONVERT(INT, SUBSTRING( PMI.FechaTimbrado, 7, 4 )) = YEAR(@FechaReporte)
     AND CONVERT(INT,SUBSTRING( PMI.FechaTimbrado, 4, 2 )) = MONTH(@FechaReporte)
     AND (Com.Factura LIKE '92%' OR Com.Factura LIKE '93%')


INSERT INTO #Facturas
SELECT
	Com.Factura,
	Com.FechaFactura,
	DATEFROMPARTS( SUBSTRING( PMI.FechaTimbrado, 7, 4 ), SUBSTRING( PMI.FechaTimbrado, 4, 2 ), SUBSTRING( PMI.FechaTimbrado, 1, 2 ) ) AS [FechaTimbrado],
	Com.Denominación,
	Com.Nombre1,
	Com.CantidadFacturada,
	Com.UniMedidaVenta,
	Com.Energía,
	ISNULL(LTRIM(f.SubTotal),''),
	PMI.Total,
	PMI.Moneda,
	ISNULL(LTRIM(F.SubTotal / TCD.TipoCambio),'') AS SubTotalUSD,
	ISNULL(LTRIM(PMI.Total / TCD.TipoCambio),'') AS TotalUSD,
	PMI.UUID,
	ISNULL(LTRIM(TCD.TipoCambio),''),
	ISNULL(LTRIM(C.ValorUnitario),''),
	ISNULL(LTRIM(C.Descripcion),''),
	ISNULL(LTRIM(C.Unidad),''),
	ISNULL(CROMA.C1,'') AS [C1],
	ISNULL(CROMA.C2,'') AS [C2],
	ISNULL(CROMA.C3,'') AS [C3],
	ISNULL(CROMA.IC4,'') AS [IC4],
	ISNULL(CROMA.NC4,'') AS [NC4],
	ISNULL(CROMA.IC5,'') AS [IC5],
	ISNULL(CROMA.NC5,'') AS [NC5],
	ISNULL(CROMA.C6,'') AS [C6]
FROM
	PC_PTI_V2 AS PMI	(nolock)
LEFT JOIN 
	 FI_Factura AS F (nolock)
	 ON F.UUID	=	PMI.UUID
LEFT JOIN
	FI_CFDIConcepto AS C (nolock) 
	ON F.IdFactura = C.IdFactura 
LEFT JOIN
	PC_Comercializacion_V2 AS Com (nolock) 
	ON CONVERT(INT,Com.Factura) = CONVERT(INT,PMI.Factura)
LEFT JOIN
	PV_TipoMoneda AS TMF (nolock) 
	ON TMF.IdMoneda = F.IdMoneda
LEFT JOIN
	CO_TipoCambioDiario AS TCD (nolock) 
	ON TCD.IdMoneda = TMF.IdMoneda
	AND YEAR(TCD.Fecha) = CONVERT(INT,SUBSTRING( COM.FechaFactura, 7, 4 ))
    AND MONTH(TCD.Fecha) = CONVERT(INT,SUBSTRING( COM.FechaFactura, 4, 2 ))
    AND DAY(TCD.Fecha) = CONVERT(INT,SUBSTRING( COM.FechaFactura, 1, 2 ))
LEFT JOIN
   dbo.FI_CFDICromatografia       CROMA
	ON C.IdFacturaConcepto     =      CROMA.IdFacturaConcepto
WHERE
	CONVERT(INT, SUBSTRING( PMI.FechaTimbrado, 7, 4 )) = YEAR(@FechaReporte)
     AND CONVERT(INT,SUBSTRING( PMI.FechaTimbrado, 4, 2 )) = MONTH(@FechaReporte)
     AND (Com.Factura LIKE '92%' OR Com.Factura LIKE '93%')


SELECT
	Factura,
	FechaFactura,
	FechaTimbrado,
	Denominacion,
	Nombre1,
	CantidadFacturada,
	UniMedidaVenta,
	Energia,
	CONVERT(MONEY,Subtotal) AS [Subtotal],
	Total,
	Moneda,
	CONVERT(MONEY,SubTotalUSD) AS [SubTotalUSD],
	CONVERT(MONEY,TotalUSD)	AS [TotalUSD],
	UUID,
	CONVERT(MONEY,TipoCambio)	AS [TipoCambio],
	CONVERT(MONEY,ValorUnitario)	AS [ValorUnitario],
	Descripcion,
	Unidad,
	C1,
	C2,
	C3,
	iC4,
	nC4,
	iC5,
	nC5,
	C6
FROM #Facturas
ORDER BY Factura

END
