-- =============================================
-- Author:		<Daniel AC>
-- Create date: <10/02/2017 18:54:2>
-- Description:	<Description>
-- =============================================


create PROCEDURE [dbo].[SP_MMGrupoXFamilia]
-- Add the parameters for the stored procedure here
      @IdGrupo INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here
		  CREATE TABLE #GruposFamilia(IdFamilia int, Familia varchar(MAX))
		 INSERT INTO #GruposFamilia(IdFamilia, Familia)VALUES(0,'-- Seleccione un familia --')
		 
		 INSERT INTO  #GruposFamilia
         SELECT IdFamilia , Familia
         FROM MM_GrupoFamiliaSubFamiliaTipo AS a INNER JOIN MM_MaterialFamilia AS b ON a.IdFamilia = b.IdMaterialFamilia
         WHERE IdGrupo = @IdGrupo
               AND
               a.Activo = 1
         GROUP BY IdFamilia , Familia
         ORDER BY Familia ASC;

		  SELECT IdFamilia , Familia FROM #GruposFamilia  ORDER BY Familia ASC;
     END;