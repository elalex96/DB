-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_TipoMoneda] 
-- Add the parameters for the stored procedure here
      
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
 
         -- Insert statements for procedure here

		 CREATE TABLE #Moneda(IdMoneda int, TipoMoneda varchar(MAX))
		 INSERT INTO #Moneda(IdMoneda, TipoMoneda)VALUES(0,'-- Seleccione un Tipo Moneda --')
		 
		 INSERT INTO  #Moneda
         SELECT IdMoneda,  TipoMoneda +   ' ('+TipoMonedaCorto+')'  as TipoMoneda
         FROM PV_TipoMoneda as T
         WHERE T.Eliminado = 1 AND TipoMonedaCorto IS NOT NULL
         ORDER BY T.TipoMoneda ASC

		 SELECT IdMoneda, TipoMoneda FROM #Moneda  ORDER BY TipoMoneda ASC;
        
     END;
