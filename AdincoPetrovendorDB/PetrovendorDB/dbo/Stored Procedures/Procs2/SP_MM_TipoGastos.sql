-- =============================================
-- Author:		Daniel Cruz
-- Create date: 06-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_TipoGastos]
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here Descripcion
		 
		 CREATE TABLE #Gasto (IdTipoGasto int,TipoGasto nvarchar(300))

		 --INSERT INTO #Gasto (IdTipoGasto,TipoGasto) values(0, '-- Seleccione un opción ---')

		 INSERT INTO #Gasto 
         SELECT IdTipoGasto,
                TipoGasto
		FROM MM_TipoGastos
		 ORDER BY IdTipoGasto ASC 

		 SELECT * FROM #Gasto 

     END;

