CREATE PROCEDURE [dbo].[SP_PC_ExcelesCagados]--10010,'2018-11-01',10090
	@IdContrato INT,
	@MesReporte NVARCHAR(10),
	@IdUsuario  INT
AS
BEGIN
-- ================================================================================
-- Author:		Manuel CD
-- Create date: 23-10-17
-- Description:	
-- ================================================================================
-- 20180731	BAAC	Se modifica sp para mostrar los archivos como cargados en cualquiera de los contratos en consorcio con Pemex
--					Si se trata de un contrato de licencia, se omite el archivo 53
-- ================================================================================
SET NOCOUNT ON
-- =============================================
SET LANGUAGE Spanish

--DECLARE @IdContratista INT

CREATE TABLE #Contratos
(
	IdContrato	INT
)

CREATE TABLE #UltimoExcel
(
	IdTipoExcelPemex	INT,
	IdExcelPemex	INT
)

CREATE TABLE #TablaTemp
(
	IdExcelPemex     INT,
	NombreArchivo    NVARCHAR(MAX),
	FechaReporte     DATETIME,
	NombreTipo       NVARCHAR(MAX),
	Nombre           NVARCHAR(MAX),
	Cargado          BIT,
	IdTipoExcelPemex INT,
--	IdContrato       INT,
	FechaCarga       DATETIME
)

DECLARE @RolNombre NVARCHAR(Max), @idContratista INT = 0;

SELECT @RolNombre=Rol FROM dbo.AP_PerfilUsuario
JOIN dbo.AP_Perfil ON AP_Perfil.IdPerfil = AP_PerfilUsuario.PerfilID
JOIN dbo.AP_Rol ON AP_Rol.IdRol = AP_Perfil.IdRol
WHERE UsuarioID=@IdUsuario 
AND IdContrato=@IdContrato

    SELECT @idContratista = IdContratista
    FROM dbo.CO_Contrato
    WHERE IdContrato = @IdContrato;

INSERT INTO #Contratos
(
    IdContrato
)
SELECT IdContrato
FROM dbo.PC_ContratoCampo
GROUP BY IdContrato

INSERT INTO #UltimoExcel
(
	IdTipoExcelPemex,
	IdExcelPemex
)
SELECT
    TEP.IdTipoExcelPemex,
    MAX(EP.IdExcelPemex)
FROM
	#Contratos	C
JOIN
	PC_ExcelPemex	EP
	ON	C.IdContrato	=	EP.IdContrato
JOIN
	PC_TipoExcelPemex AS TEP
	ON EP.IdTipoExcelPemex = TEP.IdTipoExcelPemex
WHERE
	CONVERT(VARCHAR(11), EP.FechaReporte, 103) = @MesReporte
	AND TEP.IdTipoExcelPemex <> 10005
GROUP BY
	TEP.IdTipoExcelPemex

-- SE REVISAN TODOS LOS FORMATOS COMPARTIDOS: DIST INGRESOS, VTAS X ASIG, COMERCIALIZACION, PMI, PTI
INSERT INTO #TablaTemp
SELECT
    EP.IdExcelPemex,
    EP.NombreArchivo AS 'Nombre del archivo',
    CONVERT(VARCHAR(11), EP.FechaReporte, 103) AS 'Mes del reporte',
    TEP.NombreTipo AS 'Tipo de archivo',
    U.Nombre AS 'Cargado por',
    CASE
        WHEN EP.ExcelArchivo IS NULL
        THEN 0
        ELSE 1
    END AS Cargado,
    TEP.IdTipoExcelPemex,
--    EP.IdContrato,
	EP.CreadoEn
FROM
	#UltimoExcel	C
JOIN
	PC_ExcelPemex	EP
	ON	C.IdExcelPemex	=	EP.IdExcelPemex
JOIN
	PC_TipoExcelPemex AS TEP
	ON EP.IdTipoExcelPemex = TEP.IdTipoExcelPemex
LEFT JOIN
	AP_Usuario AS U ON EP.CreadoPor = U.UsuarioID

-- SE REVISAR EL ARCHIVO 53 ESPECIFICO PARA CADA CONTRATO
INSERT INTO #TablaTemp
SELECT DISTINCT
        EP.IdExcelPemex,
        EP.NombreArchivo AS 'Nombre del archivo',
        CONVERT(VARCHAR(11), EP.FechaReporte, 103) AS 'Mes del reporte',
        TEP.NombreTipo AS 'Tipo de archivo',
        U.Nombre AS 'Cargado por',
        CASE
            WHEN EP.ExcelArchivo IS NULL
            THEN 0
            ELSE 1
        END AS Cargado,
        TEP.IdTipoExcelPemex,
        --EP.IdContrato,
	EP.CreadoEn
FROM PC_TipoExcelPemex AS TEP
LEFT JOIN
	PC_ExcelPemex AS EP 
	ON EP.IdTipoExcelPemex = TEP.IdTipoExcelPemex
LEFT JOIN
	AP_Usuario AS U 
	ON EP.CreadoPor = U.UsuarioID
LEFT JOIN
	CO_Contrato C 
	ON EP.IdContrato = C.IdContrato
WHERE C.IdContrato = @IdContrato
        AND CONVERT(VARCHAR(11), EP.FechaReporte, 103) = @MesReporte
	AND TEP.IdTipoExcelPemex = 10005

-- SI EL CONTRATO ES DE LICENCIA, SE PONE UN ARCHIVO 53 FICTICIO
IF 3 = (SELECT IdTipoContrato
	FROM dbo.CO_Contrato
	WHERE IdContrato	=	@IdContrato)
BEGIN
	INSERT INTO #TablaTemp
	SELECT
		0,
        'ARCHIVO NO NECESARIO' AS 'Nombre del archivo',
		CASE WHEN @MesReporte = '0' THEN NULL
		ELSE CONVERT(VARCHAR(11), @MesReporte, 103) END	'Mes del reporte',
        --@MesReporte AS 'Mes del reporte',
        '' AS 'Tipo de archivo',
        '' AS 'Cargado por',
        1 AS Cargado,
        10005,
		GETDATE()
END

IF(@RolNombre='Contratista SCOC' OR @idContratista=10020)
BEGIN 
SELECT
	TT.IdExcelPemex,
    TT.NombreArchivo AS 'Nombre del archivo',
    CONVERT(VARCHAR(11), TT.FechaReporte, 103) AS 'Mes del reporte',
    TEP.NombreTipo AS 'Tipo de archivo',
    TT.Nombre AS 'Cargado por',
    CASE
        WHEN TT.Cargado IS NULL
        THEN 0
        ELSE 1
    END AS Cargado,
    TEP.IdTipoExcelPemex,
--        TT.IdContrato,
	FechaCarga
FROM
	#TablaTemp TT
RIGHT JOIN
	dbo.PC_TipoExcelPemex TEP 
	ON TT.IdTipoExcelPemex = TEP.IdTipoExcelPemex
WHERE
	TEP.IdTipoExcelPemex =10005
END
ELSE
Begin
SELECT
	TT.IdExcelPemex,
    TT.NombreArchivo AS 'Nombre del archivo',
    CONVERT(VARCHAR(11), TT.FechaReporte, 103) AS 'Mes del reporte',
    TEP.NombreTipo AS 'Tipo de archivo',
    TT.Nombre AS 'Cargado por',
    CASE
        WHEN TT.Cargado IS NULL
        THEN 0
        ELSE 1
    END AS Cargado,
    TEP.IdTipoExcelPemex,
--        TT.IdContrato,
	FechaCarga
FROM
	#TablaTemp TT
RIGHT JOIN
	dbo.PC_TipoExcelPemex TEP 
	ON TT.IdTipoExcelPemex = TEP.IdTipoExcelPemex
WHERE
	TEP.IdTipoExcelPemex <> 10006
END
END

