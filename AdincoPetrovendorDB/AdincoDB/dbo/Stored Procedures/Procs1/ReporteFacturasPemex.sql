CREATE PROCEDURE dbo.ReporteFacturasPemex
	@MesReporte	DATE
AS
BEGIN

CREATE TABLE #facturas
(
	Factura	NVARCHAR (100),
	FechaFactura	nvarchar(12),
	FechaTimbrado	DATETIME,
	Denominacion NVARCHAR (510),
	Nombre1 NVARCHAR (510),
	CantidadFacturada FLOAT,
	UniMedidaVenta  NVARCHAR (510),
	Energía	float,
	subtotal NVARCHAR (100),
	Total	MONEY,
	Moneda nvarchar(100),
	SubTotalUSD NVARCHAR (100),
	TotalUSD NVARCHAR (100),
	UUID nvarchar(510),
	TipoCambio	NVARCHAR (100),
	ValorUnitario	NVARCHAR (100),
	Descripcion	nvarchar(max),
	unidad nvarchar(max),
	c6 varchar(20),
	nc5 varchar(20),
	ic5 varchar(20),
	nc4 varchar(20),
	ic4 varchar(20),
	c3 varchar(20),
	c2 varchar(20),
	c1 varchar(20)
)

INSERT INTO #facturas
SELECT Com.Factura,
       Com.FechaFactura,
	   DATEFROMPARTS( SUBSTRING( PMI.FechaTimbrado, 7, 4 ), SUBSTRING( PMI.FechaTimbrado, 4, 2 ), SUBSTRING( PMI.FechaTimbrado, 1, 2 ) ) AS [FechaTimbrado],
       --F.FechaTimbrado,
       Com.Denominación,
       Com.Nombre1,
       Com.CantidadFacturada,
       Com.UniMedidaVenta,
       Com.Energía,
       ISNULL(LTRIM(F.SubTotal),''),
       PMI.Total,
       PMI.Moneda,
       ISNULL(LTRIM(F.SubTotal / TCD.TipoCambio),'') AS SubTotalUSD,
       ISNULL(LTRIM(PMI.Total / TCD.TipoCambio),'') AS TotalUSD,
       PMI.UUID,
       ISNULL(LTRIM(TCD.TipoCambio),''),
       ISNULL(LTRIM(C.ValorUnitario),''),
       ISNULL(LTRIM(C.Descripcion),''),
       ISNULL(LTRIM(C.Unidad),''),
        ISNULL(CROMA.C6,'') AS 'C6', ISNULL(CROMA.NC5,'') AS [NC5], ISNULL(CROMA.IC5,'') AS [IC5], 
    ISNULL(CROMA.NC4,'') AS [NC4], ISNULL(CROMA.IC4,'') AS [IC4], ISNULL(CROMA.C3,'') AS [C3],
    ISNULL(CROMA.C2,'') AS [C2], ISNULL(CROMA.C1,'') AS [C1] 
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
	CONVERT(INT, SUBSTRING( PMI.FechaTimbrado, 7, 4 )) = YEAR(@MesReporte)
     AND CONVERT(INT,SUBSTRING( PMI.FechaTimbrado, 4, 2 )) = MONTH(@MesReporte)
     AND (Com.Factura LIKE '92%' OR Com.Factura LIKE '93%')


INSERT INTO #Facturas
SELECT Com.Factura,
       Com.FechaFactura,
	   DATEFROMPARTS( SUBSTRING( PMI.FechaTimbrado, 7, 4 ), SUBSTRING( PMI.FechaTimbrado, 4, 2 ), SUBSTRING( PMI.FechaTimbrado, 1, 2 ) ) AS [FechaTimbrado],
       --F.FechaTimbrado,
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
       ISNULL(CROMA.C6,'') AS 'C6', ISNULL(CROMA.NC5,'') AS [NC5], ISNULL(CROMA.IC5,'') AS [IC5], 
	ISNULL(CROMA.NC4,'') AS [NC4], ISNULL(CROMA.IC4,'') AS [IC4], ISNULL(CROMA.C3,'') AS [C3],
    ISNULL(CROMA.C2,'') AS [C2], ISNULL(CROMA.C1,'') AS [C1] 
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
	CONVERT(INT, SUBSTRING( PMI.FechaTimbrado, 7, 4 )) = YEAR(@MesReporte)
     AND CONVERT(INT,SUBSTRING( PMI.FechaTimbrado, 4, 2 )) = MONTH(@MesReporte)
     AND (Com.Factura LIKE '92%' OR Com.Factura LIKE '93%')

SELECT	*
FROM #Facturas
ORDER BY Factura

END
