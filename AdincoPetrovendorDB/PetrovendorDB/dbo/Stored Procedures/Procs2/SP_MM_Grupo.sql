-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE [dbo].[SP_MM_Grupo]
-- Add the parameters for the stored procedure here
      
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here

		 CREATE TABLE #Grupos(IdGrupo int, MaterialGrupo varchar(MAX))
		 INSERT INTO #Grupos(IdGrupo, MaterialGrupo)VALUES(0,'-- Seleccione un grupo --')
		 
		 INSERT INTO  #Grupos
         SELECT a.IdGrupo , b.MaterialGrupo
         FROM MM_GrupoFamiliaSubFamiliaTipo 
		 AS a INNER JOIN MM_MaterialGrupoDisciplina AS b ON a.IdGrupo = b.IdGrupoDisciplina
         WHERE 
               a.Activo = 1
         GROUP BY IdGrupo , b.MaterialGrupo
         ORDER BY MaterialGrupo ASC;

		 SELECT IdGrupo AS IdGrupoDisciplina, MaterialGrupo FROM #Grupos  ORDER BY MaterialGrupo ASC;
     END;
