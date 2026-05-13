
CREATE PROCEDURE dbo.sp_PC_ReporteComercializaciones
	@IdContrato INT,
	@MesReporte NVARCHAR(10),
	@IdUsuario  INT
AS
BEGIN
-- ================================================================
-- Modulo:	SCOC --> Comercializacion
-- Objetivo: Mostrar un resumen de las comercializaciones generadas
--			 como validación despues de generar las comercializaciones de los hidrocarburos
-- Entradas:	Contrato, Mes reporte y Usuario
-- Salida:	registros en COM_OperacionComercializacion
-- ================================================================
-- 20180730	BAAC	Creación de sp
-- ================================================================
SET NOCOUNT ON
-- ================================================================
SELECT
	COM.IdTipoHidrocarburo,
	H.Hidrocarburo,
	SUBSTRING(C.Descripcion,1,CHARINDEX(' ',C.Descripcion,1))	AS [TipoFactura],
	SUM(COM.VolumenVendido)	AS [Volumen],
	COUNT(COM.IdOperacionComercializacion)	AS [Comercializaciones],
	ISNULL(P.PrecioUnitario,'')		AS [Precio]
FROM
	dbo.COM_OperacionComercializacion	COM
JOIN
	dbo.FI_CFDIConcepto	C
	ON	COM.IdFactura	=	C.IdFactura
JOIN
	dbo.CO_TipoHidrocarburo	H
	ON	COM.IdTipoHidrocarburo	= H.IdTipoHidrocarburo
LEFT JOIN
	dbo.COM_PreciosObjetivosHidroCarburos	P
	ON	COM.IdContrato	=	P.IdContrato
	AND	COM.MesReporte	=	P.Mes
	AND	COM.IdTipoHidrocarburo	=	P.IdTipoHidrocarburo
WHERE
	COM.IdContrato	=	@IdContrato
	AND
	CONVERT(VARCHAR(11), COM.MesReporte, 103)	=	@MesReporte
GROUP BY
	COM.IdTipoHidrocarburo,
	H.Hidrocarburo,
	SUBSTRING(C.Descripcion,1,CHARINDEX(' ',C.Descripcion,1)),
	ISNULL(P.PrecioUnitario,'')
END

