
CREATE PROCEDURE [dbo].[SP_PC_ContColumns]
	-- Add the parameters for the stored procedure here
@IdTipoExcel INT,
@IdContrato  INT,
@IdUsuario   INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 19-01-2019
-- Description:	

    SET NOCOUNT ON;

            SELECT CountColumnas
            FROM dbo.PC_TipoExcelPemex WHERE IdTipoExcelPemex=@IdTipoExcel
                
END