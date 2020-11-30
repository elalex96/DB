-- =============================================
-- Author:		<DANIEL AC>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE [dbo].[SP_MM_FamiliaXSubFamilia] 
-- Add the parameters for the stored procedure here
      @IdGrupo   INT,
      @IdFamilia INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
 
         -- Insert statements for procedure here
		  CREATE TABLE #FamiliaSubfamilia(IdSubFamilia int, SubFamilia varchar(MAX))
		 INSERT INTO #FamiliaSubfamilia(IdSubFamilia, SubFamilia)VALUES(0,'-- Seleccione un SubFamilia --')
		 
		 INSERT INTO  #FamiliaSubfamilia
         SELECT a.IdSubFamilia , SubFamilia
         FROM MM_GrupoFamiliaSubFamiliaTipo AS a INNER JOIN MM_MaterialSubFamilia AS b ON a.IdSubFamilia = b.IdSubFamilia
         WHERE IdGrupo = @IdGrupo
               AND
               IdFamilia = @IdFamilia
               AND
               a.Activo = 1
         GROUP BY a.IdSubFamilia, SubFamilia
         ORDER BY SubFamilia ASC;

		  SELECT IdSubFamilia, SubFamilia FROM #FamiliaSubfamilia  ORDER BY SubFamilia ASC;
     END;
