-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11-04-18>
-- Description:	<Consulta el detalle de las nuevas actualizaciones>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Help_DetalleIteraciones]
@arrayIds NVARCHAR(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @contador INT = 1
	SET @ArrayIds = LEFT(@ArrayIds,(LEN(@ArrayIds) - 1))

		 CREATE TABLE #IdsTemp (IdRow INT, IdIteracion INT)
		 CREATE TABLE #IteracionDetalle (IdIteracion INT,DescripcionLarga NVARCHAR(MAX),ImagenVideo IMAGE)
           
		 INSERT INTO #IdsTemp
		 SELECT
		 ROW_NUMBER() OVER(ORDER BY Value ASC),
		 Value 
		 FROM  dbo.Split(@ArrayIds, ',')

		 DECLARE @CantidadIds INT = (SELECT COUNT(IdRow) FROM #IdsTemp)

		 WHILE (@contador <= @CantidadIds)
		 BEGIN
		 DECLARE @IdIteracion INT = (SELECT IdIteracion FROM #IdsTemp WHERE IdRow = @contador)
		 DECLARE @Exist NVARCHAR(15)
		 IF EXISTS (SELECT IdDetalleIteracion FROM dbo.RegistroIteracionesDetalle WHERE IdIteracion = @IdIteracion)
			 SET @Exist = 'existe'
	     ELSE
			 SET @Exist = 'no_existe'

			 IF(@Exist = 'existe')
			 BEGIN
			     INSERT INTO #IteracionDetalle
				 (
					 IdIteracion,
					 DescripcionLarga,
					 ImagenVideo
					 --FechaRegistro,
					 --FechaModificado,
					 --Modulo
				 )
				 SELECT 
					 IdIteracion,
					 DescripcionLarga,
					 ImagenVideo
					 --FechaRegistro,
					 --FechaModificado,
					 --Modulo
				 FROM dbo.RegistroIteracionesDetalle
				 WHERE IdIteracion = @IdIteracion
				 AND IsEliminado = 0
             END
			 ELSE
             BEGIN
			 	INSERT INTO #IteracionDetalle
				(
					IdIteracion,
					DescripcionLarga,
					ImagenVideo
					--FechaRegistro,
					--FechaModificado,
					--Modulo
				)
				VALUES
				(
					@IdIteracion,
					'Sin descripción',
					NULL
				)
             END 
             
		 SET @contador = @contador + 1

         END

	SELECT * FROM #IteracionDetalle



END
