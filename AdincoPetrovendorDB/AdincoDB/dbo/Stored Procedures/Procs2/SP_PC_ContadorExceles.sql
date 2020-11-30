
CREATE PROCEDURE dbo.SP_PC_ContadorExceles
	@IdContrato INT,
	@MesReporte NVARCHAR(10),
	@IdUsuario  INT
AS
BEGIN
-- =====================================================================================
-- Author:		Manuel CD
-- Create date: 25-10-2017
-- Description:	
-- =====================================================================================
-- 20180731	BAAC	Se modifica sp para mostrar los archivos como cargados en cualquiera de los contratos en consorcio con Pemex
--					se considera el archivo 53 como cargado para contratos de Licencia
-- =====================================================================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #Contratos
(
	IdContrato	INT
)

DECLARE @Total	INT

INSERT INTO #Contratos
(
    IdContrato
)
SELECT IdContrato
FROM dbo.PC_ContratoCampo
GROUP BY IdContrato

    SELECT
		@Total	=	COUNT( DISTINCT IdTipoExcelPemex)
    FROM
		#Contratos	C
	JOIN
		PC_ExcelPemex EP
		ON	C.IdContrato	=	EP.IdContrato
    WHERE
		CONVERT(VARCHAR(11), EP.FechaReporte, 103) = @MesReporte
		AND EP.IdTipoExcelPemex NOT IN ( 10006, 10008, 10005)

	SELECT
		@Total	=	@Total + COUNT(DISTINCT IdTipoExcelPemex)
	FROM
		PC_ExcelPemex
	WHERE
		IdContrato	=	@IdContrato
		AND	CONVERT(VARCHAR(11), FechaReporte, 103) = @MesReporte
		AND IdTipoExcelPemex = 10005

	-- si es contrato de licencia se suma un 1 correspondiente al archivo 53
	IF 3 = (SELECT IdTipoContrato
	FROM dbo.CO_Contrato
	WHERE IdContrato	=	@IdContrato)
	BEGIN
		SELECT @Total = @Total +1
	END 

	SELECT @Total
     
END

