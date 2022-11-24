CREATE PROCEDURE [dbo].[sp_ObtenArchivoPemex]--10659
	@IdExcelPemex INT
AS
BEGIN

SET NOCOUNT ON

SELECT
    ExcelArchivo
FROM
	PC_ExcelPemex
WHERE
	IdExcelPemex = @IdExcelPemex
END


