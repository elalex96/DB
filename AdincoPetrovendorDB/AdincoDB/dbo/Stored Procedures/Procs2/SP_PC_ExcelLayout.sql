-- =============================================
-- Author:		Manuel CD
-- Create date: 07-11-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ExcelLayout] 
	-- Add the parameters for the stored procedure here
@IdExcel    INT,
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here

             SELECT IdExcelPemex,
                    ExcelArchivo,
                    NombreArchivo,
                    RIGHT(RTRIM(NombreArchivo), 4) AS Exten,
                    FechaReporte
             FROM PC_ExcelPemex
             WHERE IdExcelPemex = @IdExcel;
         END;