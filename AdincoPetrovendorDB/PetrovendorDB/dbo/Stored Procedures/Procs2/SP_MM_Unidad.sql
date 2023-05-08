-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Unidad] 
-- Add the parameters for the stored procedure here
      
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
 
         -- Insert statements for procedure here

		 CREATE TABLE #Unidad(IdUnidad int, Unidad varchar(MAX))
		 INSERT INTO #Unidad(IdUnidad, Unidad)VALUES(0,'-- Seleccione una unidad --')
		 
		 INSERT INTO  #Unidad
         SELECT IdUnidad, Unidad
         FROM PV_MM_MaterialUnidad as T
         

		 SELECT IdUnidad, Unidad FROM #Unidad  ORDER BY IdUnidad ASC;
        
     END;
