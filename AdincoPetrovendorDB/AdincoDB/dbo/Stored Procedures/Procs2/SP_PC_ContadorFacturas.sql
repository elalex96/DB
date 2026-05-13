
CREATE PROCEDURE dbo.SP_PC_ContadorFacturas
	@IdContrato INT,
	@MesReporte NVARCHAR(10),
	@IdUsuario  INT
AS
BEGIN
-- ====================================================================================
-- Author:		Manuel CD
-- Create date: 07-11-17
-- Description:	
-- ====================================================================================
-- 20180731	BAAC	Se modifica sp para mostrar LAS FACTURAS como cargadas en cualquiera de los contratos en consorcio con Pemex
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #Contratos
(
	IdContrato	INT
)

DECLARE
	@IdContratista INT,
	@SUMA INT,
	@SUMAE INT

INSERT INTO #Contratos
(
    IdContrato
)
SELECT IdContrato
FROM dbo.PC_ContratoCampo
GROUP BY IdContrato

SELECT
	@SUMA	=	COUNT(PTI.UUID),
	@SUMAE	=	SUM(CASE WHEN ISNULL(F.IdFactura,0) = 0 THEN 0 ELSE 1 END)
FROM
	PC_PTI_V2	PTI
LEFT JOIN
	dbo.FI_Factura	F
	ON	PTI.UUID	=	F.UUID
LEFT JOIN
	#Contratos	C
	ON	F.IdContrato	=	C.IdContrato
WHERE
	CONVERT(VARCHAR(11), PTI.FechaReporte, 103) = @MesReporte

SELECT
	@SUMA = @SUMA + COUNT(PMI.UUID),
	@SUMAE	=	@SUMAE + SUM(CASE WHEN ISNULL(F.IdFactura,0) = 0 THEN 0 ELSE 1 END)
FROM
	PC_PMI_V2	PMI
LEFT JOIN
	dbo.FI_Factura	F
	ON	PMI.UUID	=	F.UUID
LEFT JOIN
	#Contratos	C
	ON	F.IdContrato	=	C.IdContrato
WHERE
	CONVERT(VARCHAR(11), PMI.FechaReporte, 103) = @MesReporte


SELECT
	'PTI' AS Layout,
	COUNT(PTI.UUID)	AS [Total],
	SUM(CASE WHEN ISNULL(F.IdFactura,0) = 0 THEN 0 ELSE 1 END)	AS [FacturasEncontrado],
	COUNT(PTI.UUID) - SUM(CASE WHEN ISNULL(F.IdFactura,0) = 0 THEN 0 ELSE 1 END)	AS [Diferencia],
	@SUMA	AS [SumaTotal],
	@SUMAE	AS [EncontradoTotal]
FROM
	PC_PTI_V2	PTI
LEFT JOIN
	dbo.FI_Factura	F
	ON	PTI.UUID	=	F.UUID
LEFT JOIN
	#Contratos	C
	ON	F.IdContrato	=	C.IdContrato
WHERE
	CONVERT(VARCHAR(11), PTI.FechaReporte, 103) = @MesReporte

UNION

SELECT
	'PMI' AS Layout,
	COUNT(PMI.UUID)	AS [Total],
	SUM(CASE WHEN ISNULL(F.IdFactura,0) = 0 THEN 0 ELSE 1 END)	AS [FacturasEncontrado],
	COUNT(PMI.UUID) - SUM(CASE WHEN ISNULL(F.IdFactura,0) = 0 THEN 0 ELSE 1 END)	AS [Diferencia],
	@SUMA	AS [SumaTotal],
	@SUMAE	AS [EncontradoTotal]
FROM
	PC_PMI_V2	PMI
LEFT JOIN
	dbo.FI_Factura	F
	ON	PMI.UUID	=	F.UUID
LEFT JOIN
	#Contratos	C
	ON	F.IdContrato	=	C.IdContrato
WHERE
	CONVERT(VARCHAR(11), PMI.FechaReporte, 103) = @MesReporte

END

