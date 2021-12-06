USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_EliminarCarpeta]    Script Date: 02/12/2021 11:44:22 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/11/2021
-- Description:	Eliminar una carpeta
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_EliminarCarpeta]
	-- Add the parameters for the stored procedure here
	@ID INT,
	@IdPadre INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @CONTNIVEL1 INT = 1,
			@CONTTOTAL1 INT = 0,
			@CONTNIVEL2 INT = 1,
			@CONTTOTAL2 INT = 0,
			@ID_1 INT = @ID,
			@IDPADRE_1 INT = @IdPadre,
			@ID_2 INT = 0,
			@IDPADRE_2 INT = 0;


		--PRIMER NIVEL DE ELIMINADO
		--ELIMINADO DE LA CARPETA
		UPDATE CarpetasDocumentosEntregables
		SET Activo = 0
		WHERE ID = @ID;

		--ELIMINADO DE LOS ARCHIVOS EN LA CARPETA
		UPDATE CarpetasDocumentosEntregables
		SET Activo = 0
		WHERE IDPadre = @IdPadre AND TipoArchivo = 'Archivo general';

		SET @CONTTOTAL1 = (SELECT COUNT(1) FROM CarpetasDocumentosEntregables WHERE IdDocPadre = @ID AND TipoArchivo = 'Carpeta'  AND Activo = 1)

		--RECORRIDO DE CARPETAS Y ARCHIVOS EN CASO DE QUE EXISTAN
		WHILE @CONTNIVEL1 <= @CONTTOTAL1
		BEGIN

			SET @ID_1 = (SELECT TOP 1 ID FROM CarpetasDocumentosEntregables WHERE IdDocPadre = @ID AND TipoArchivo = 'Carpeta' AND Activo = 1 ORDER BY ID DESC);

			--ELIMINADO DE LA CARPETA NIVEL 2
			UPDATE CarpetasDocumentosEntregables
			SET Activo = 0
			WHERE ID = @ID_1;  

			--ELIMINADO DE LOS ARCHIVOS EN LA CARPETA NIVEL 2
			UPDATE CarpetasDocumentosEntregables
			SET Activo = 0
			WHERE IdDocPadre = @ID_1 AND TipoArchivo = 'Archivo general';

			SET @CONTTOTAL2 = (SELECT COUNT(1) FROM CarpetasDocumentosEntregables WHERE IdDocPadre = @ID_1 AND TipoArchivo = 'Carpeta' AND Activo = 1)
			
			----ELIMINADO NIVEL 3
			WHILE @CONTNIVEL2 <= @CONTTOTAL2
			BEGIN
				
				SET @ID_2 = (SELECT TOP 1 ID FROM CarpetasDocumentosEntregables WHERE IdDocPadre = @ID_1 AND TipoArchivo = 'Carpeta' AND Activo = 1 ORDER BY ID DESC);

				--ELIMINADO DE LA CARPETA
				UPDATE CarpetasDocumentosEntregables
				SET Activo = 0
				WHERE ID = @ID_2; 

				--ELIMINADO DE LOS ARCHIVOS EN LA CARPETA
				UPDATE CarpetasDocumentosEntregables
				SET Activo = 0
				WHERE IdDocPadre = @ID_1 AND TipoArchivo = 'Archivo general';
				
				SET @CONTNIVEL2 = @CONTNIVEL2 + 1;
			END


			SET @CONTNIVEL1 = @CONTNIVEL1 + 1;

		END


	SELECT @ID;

END
