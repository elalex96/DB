-- =============================================
-- Author:		<ABEL RIVERA>
-- Create date: <02/08/18>
-- Description:	<Obtiene la descripcion de los materiales de un arreglo de ids>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerDescCortaXId]
@ArrayIds NVARCHAR(MAX) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @ArrayIds = LEFT(@ArrayIds,(LEN(@ArrayIds) - 1))

		 CREATE TABLE #IdsTemp (IdRow INT, IdMaterial INT)
		 CREATE TABLE #MaterialesTemp(IdMaterial INT, Descripcion NVARCHAR(MAX))

		 INSERT INTO #IdsTemp
		 SELECT
		 ROW_NUMBER() OVER(ORDER BY Value ASC),
		 Value 
		 FROM  dbo.Split(@ArrayIds, ',')

		 DECLARE @cantIds  INT = (SELECT COUNT(IdMaterial) FROM #IdsTemp),
				 @contador INT = 1
	     DECLARE @DescripcionClass NVARCHAR(MAX) = ''

		 WHILE (@contador <= @cantIds)
		 BEGIN

		 DECLARE @IdMaterialTemp INT = (SELECT IdMaterial FROM #IdsTemp WHERE IdRow = @contador)
		 DECLARE @Descripcion NVARCHAR(MAX) = (SELECT DescripcionCorta FROM dbo.MM_Material WHERE IdMaterial = @IdMaterialTemp)
		 SET @Descripcion = REPLACE(@Descripcion,'''','\''')		 
	    SET @DescripcionClass = @DescripcionClass + '<li class=\"list-group-item\">' +  @Descripcion + '</li>'

		 --INSERT INTO #MaterialesTemp
		 --(
		 --    IdMaterial,
		 --    Descripcion
		 --)
		 --VALUES
		 --(   
			-- @IdMaterialTemp,  -- IdMaterial - int
		 --    @Descripcion      -- Descripcion - nvarchar(max)
		 --)

		 SET @contador = @contador + 1

		 END

		 SELECT @DescripcionClass
         

END
