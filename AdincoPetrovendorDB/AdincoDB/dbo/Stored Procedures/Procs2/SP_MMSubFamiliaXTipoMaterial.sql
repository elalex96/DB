-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MMSubFamiliaXTipoMaterial] 
-- Add the parameters for the stored procedure here
@Grupo        INT,
@Familia      INT,
@IdSubFamilia INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		CREATE TABLE #SubFamiliaTipo(IdTipoMaterial int, TipoMaterial varchar(MAX))
		INSERT INTO #SubFamiliaTipo(IdTipoMaterial, TipoMaterial)VALUES(0,'-- Seleccione un Tipo de Material --')
	  
         -- Insert statements for procedure here
		 INSERT INTO  #SubFamiliaTipo
         SELECT a.IdTipoMaterial,
                b.TipoMaterial
         FROM MM_GrupoFamiliaSubFamiliaTipo a
              INNER JOIN MM_MaterialTipo b ON a.IdTipoMaterial = b.IdTipoMaterial
         WHERE IdGrupo = @Grupo
               AND IdFamilia = @Familia
               AND IdSubFamilia = @IdSubFamilia
               AND a.Activo = 1
         GROUP BY a.IdTipoMaterial,
                  b.TipoMaterial
         ORDER BY TipoMaterial ASC;

		  SELECT IdTipoMaterial, TipoMaterial FROM #SubFamiliaTipo  ORDER BY TipoMaterial ASC;
     END;