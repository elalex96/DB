-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <12/02/2018>
-- Description:	<Desclasifica una lista de materiales seleccionado por el usuario que tienen relacion con algun material del catalogo maestro>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_DesclasificarMateriales]
@arrayIds NVARCHAR(max),

@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @ArrayIds = LEFT(@ArrayIds,(LEN(@ArrayIds) - 1))

		 CREATE TABLE #IdsTemp (IdRow INT, IdMaterial INT)

		 INSERT INTO #IdsTemp
		 SELECT
		 ROW_NUMBER() OVER(ORDER BY Value ASC),
		 Value 
		 FROM  dbo.Split(@ArrayIds, ',')

		 DECLARE @cantIds  INT = (SELECT COUNT(IdMaterial) FROM #IdsTemp),
				 @contador INT = 1
		 WHILE (@contador <= @cantIds)
		 BEGIN
		     DECLARE @idMaterialTemp INT = (SELECT IdMaterial FROM #IdsTemp WHERE IdRow = @contador)

			 UPDATE dbo.MM_Material
			 SET 
			 IdMaestro            = NULL,
			 IsClasificionMaestro = 0,
			 FechaActualizacion   = GETDATE()
			 WHERE IdMaterial     = @idMaterialTemp

			 SET @contador = @contador + 1
		 END

		 SELECT COUNT(IdMaterial) FROM #IdsTemp 


END
