
CREATE PROCEDURE dbo.SP_PC_GenerarCFDICromatografia
    @IdContrato INT,
    @MesReporte DATE,
	@Usuario int
AS
BEGIN 
-- =============================================
-- Author:		Barbara Arrañaga
-- Create date: 2018-03-11
-- Description:	Proceso para OBTENER LA CROMATOGRAFIA CONTENIDA EN LA DESCRIPCION DEL CONCEPTO EN EL XML DE LA FACTURA
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- -----------------------------------------------------------
-- 20180521	BAAC	Se modifica para generar la cromatografia sin importar en que contrato se cargaron las facturas
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #PRUEBA
(
	idfactura INT,
	IdFacturaConcepto BIGINT,
    XML VARCHAR(6000),
    C6  VARCHAR(10),
    InicioC6	 INT,
    NC5  VARCHAR(10),
    InicioNC5	 INT,
    IC5  VARCHAR(10),
    InicioIC6	 INT,
    NC4  VARCHAR(10),
    InicioNC4	 INT,
    IC4  VARCHAR(10),
    InicioIC4	 INT,
    C3  VARCHAR(10),
    InicioC3	 INT,
    C2  VARCHAR(10),
    InicioC2	 INT,
    C1  VARCHAR(10),
    InicioC1	 INT
)

CREATE TABLE #Contratos
(
	IdContrato	INT
)

-- =============================================
DECLARE
	@FechaFin	DATETIME,
	@NumError	INT,
	@MensajeError	VARCHAR(500)

SELECT @FechaFin = DATEADD(DAY, -1 , DATEADD(MONTH,1,LTRIM(@MesReporte))) + '23:59'

INSERT INTO #Contratos
(
    IdContrato
)
SELECT
	IdContrato
FROM
	dbo.PC_ContratoCampo
GROUP BY
	IdContrato

INSERT INTO #PRUEBA
(
    idfactura,
	IdFacturaConcepto,
    XML
)
SELECT
	F.IdFactura,
	C.IdFacturaConcepto,
	C.Descripcion
FROM
	#Contratos	CO
JOIN
	dbo.FI_Factura F
	ON	CO.IdContrato	=	F.IdContrato
JOIN
	dbo.FI_CFDIConcepto	C
	ON F.IdFactura = C.IdFactura
WHERE
--	F.IdContrato =	@IdContrato		AND
	F.FechaTimbrado BETWEEN @MesReporte AND @FechaFin
	AND C.Descripcion LIKE 'GAS %'
	AND C.Descripcion NOT LIKE '%GAS LICUADO DE PETRÓLEO%'

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #PRUEBA'+
	'En el Stored Procedure: dbo.SP_PC_GenerarCFDICromatografia '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

UPDATE #PRUEBA
    SET InicioC6 = CASE WHEN CHARINDEX('C6+',XML,1) = 0 THEN 0
					ELSE CHARINDEX('C6+',XML,1)+3	END,
	   InicioNC5 = CASE WHEN CHARINDEX('NC5',XML,1) = 0 THEN 0
					ELSE CHARINDEX('NC5',XML,1)+3	END,
	   InicioIC6 = CASE WHEN CHARINDEX('IC5',XML,1) = 0 THEN 0
					ELSE CHARINDEX('IC5',XML,1)+3	END,
	   InicioNC4 = CASE WHEN CHARINDEX('NC4',XML,1) = 0 THEN 0
					ELSE CHARINDEX('NC4',XML,1)+3	END,
	   InicioIC4 = CASE WHEN CHARINDEX('IC4',XML,1) = 0 THEN 0
					ELSE CHARINDEX('IC4',XML,1)+3	END,
	   InicioC3 = CASE WHEN CHARINDEX('C3',XML,1) = 0	THEN 0
					ELSE CHARINDEX('C3',XML,1)+2	END,
	   InicioC2 = CASE WHEN CHARINDEX('C2',XML,1) = 0	THEN 0
					ELSE CHARINDEX('C2',XML,1)+2	END,
	   InicioC1 = CASE WHEN CHARINDEX('C1',XML,1) = 0	THEN 0
					ELSE CHARINDEX('C1',XML,1)+2	END

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al actualizar en #PRUEBA'+
	'En el Stored Procedure: dbo.SP_PC_GenerarCFDICromatografia '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

UPDATE #PRUEBA
    SET C6 = CASE WHEN InicioC6 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioC6,CHARINDEX(' ',XML,InicioC6+1)-InicioC6)) END,
	   NC5 = CASE WHEN InicioNC5 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioNC5,CHARINDEX(' ',XML,InicioNC5+1)-InicioNC5)) END,
	   IC5 = CASE WHEN InicioIC6 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioIC6,CHARINDEX(' ',XML,InicioIC6+1)-InicioIC6)) END,
	   NC4 = CASE WHEN InicioNC4 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioNC4,CHARINDEX(' ',XML,InicioNC4+1)-InicioNC4)) END,
	   IC4 = CASE WHEN InicioIC4 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioIC4,CHARINDEX(' ',XML,InicioIC4+1)-InicioIC4)) END,
	   C3 = CASE WHEN InicioC3 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioC3,CHARINDEX(' ',XML,InicioC3+1)-InicioC3)) END,
	   C2 = CASE WHEN InicioC2 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioC2,CHARINDEX(' ',XML,InicioC2+1)-InicioC2)) END,
	   C1 = CASE WHEN InicioC1 = 0 THEN '0'
				ELSE LTRIM(SUBSTRING(XML,InicioC1,CHARINDEX(' ',XML,InicioC1+1)-InicioC1)) END

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al actualizar en #PRUEBA'+
	'En el Stored Procedure: dbo.SP_PC_GenerarCFDICromatografia '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

-- SE BORRAN LOS REGISTROS QUE YA SE HAYAN PROCESADO
DELETE	CR
FROM
	#PRUEBA	TMP
JOIN
	dbo.FI_CFDICromatografia	CR
	ON	TMP.IdFacturaConcepto	=	CR.IdFacturaConcepto

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al eliminar en FI_CFDICromatografia'+
	'En el Stored Procedure: dbo.SP_PC_GenerarCFDICromatografia '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

-- SE INSERTAN LOS VALORES
INSERT INTO FI_CFDICromatografia
(
	IdFacturaConcepto,
	XML,
	C6,
	InicioC6,
	NC5,
	InicioNC5,
	IC5,
	InicioIC6,
	NC4,
	InicioNC4,
	IC4,
	InicioIC4,
	C3,
	InicioC3,
	C2,
	InicioC2,
	C1,
	InicioC1
)
SELECT 
	IdFacturaConcepto, 
	xml,
	C6,
	InicioC6,
	NC5,
	InicioNC5,
	IC5,
	InicioIC6,
	NC4,
	InicioNC4,
	IC4,
	InicioIC4,
	C3,
	InicioC3,
	C2,
	InicioC2,
	C1,
	InicioC1
FROM
	#PRUEBA

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en FI_CFDICromatografia'+
	'En el Stored Procedure: dbo.SP_PC_GenerarCFDICromatografia '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

GOTO FIN
-- -----------------------------------------------------------------------------------------
ERROR:
-- -----------------------------------------------------------------------------------------
RAISERROR(@MensajeError, 16, 1)
--RETURN 1	    -- Error
-- -----------------------------------------------------------------------------------------
FIN:
--RETURN 0
END

