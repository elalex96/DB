-- =============================================
-- Author:		Marcos Garcia
-- Create date: 07-02-2020
-- Description:	Genera los Años desde el 2017 hasta el actual
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaAniosInicioPCN]
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         SET NOCOUNT ON;
         CREATE TABLE #anios(anio INT);
         DECLARE @anioactual INT= YEAR(GETDATE());         
         DECLARE @anioinicio INT= 2017;
         WHILE(@anioinicio <= @anioactual)
             BEGIN
                 INSERT INTO #anios(anio)
             VALUES(@anioinicio);
                 SET @anioinicio = @anioinicio + 1;
             END;
         SELECT anio
         FROM #anios;
     END;
