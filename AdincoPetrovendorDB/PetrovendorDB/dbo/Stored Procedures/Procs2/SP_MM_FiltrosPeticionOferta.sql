-- =============================================
-- Author:      <Alexander Gomez>
-- Create date: <25/02/2020>
-- Description: <Consulta de filtros para la peticion oferta>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_FiltrosPeticionOferta]
    -- Add the parameters for the stored procedure here
    @PROCESO NVARCHAR(50) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
    
    SELECT
        Valor,
        Filtro
    FROM dbo.MM_FiltrosPeticionOferta
    WHERE Proceso = @PROCESO
END
