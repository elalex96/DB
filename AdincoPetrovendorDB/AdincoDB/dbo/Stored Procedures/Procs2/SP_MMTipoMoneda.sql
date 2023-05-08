-- =============================================
-- Author:		<Daniel AC>
-- Create date: <10/02/2017>
-- Description:	<Muestra Grupos>
-- =============================================


CREATE PROCEDURE [dbo].[SP_MMTipoMoneda] 
-- Add the parameters for the stored procedure here
      
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		CREATE TABLE #TipoMoneda(IdMoneda int, TipoMoneda varchar(MAX))
		 INSERT INTO #TipoMoneda(IdMoneda, TipoMoneda)VALUES(0,'-- Seleccione un Tipo de Moneda --')

         -- Insert statements for procedure here
		 INSERT INTO  #TipoMoneda
         SELECT IdMoneda,  TipoMoneda +   ' ('+TipoMonedaCorto+')'  as TipoMoneda
         FROM PV_TipoMoneda as T
         WHERE T.Eliminado = 1 AND TipoMonedaCorto IS NOT NULL
         ORDER BY T.TipoMoneda ASC
        
		SELECT IdMoneda, TipoMoneda FROM #TipoMoneda  ORDER BY TipoMoneda ASC;
     END;