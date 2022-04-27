USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_ValidarArchivoCarga]    Script Date: 27/04/2022 03:28:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/04/2022>
-- Description:	<Validacion al cargar los archivos para no cargar archivos iguales>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_ValidarArchivoCarga]
	-- Add the parameters for the stored procedure here
	@ContratoId INT,
	@Nivel INT,
	@IdCarpeta INT,
	@NombreArchivo VARCHAR(2000),
	@Ruta VARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RUTA_GUARDADA NVARCHAR(MAX) = (SELECT TOP 1
												Ruta
											FROM EN_SecuenciaCarpetas 
											WHERE IdCarpeta = @IdCarpeta
												AND Nivel = @Nivel
												AND IdContrato = @ContratoId
											ORDER BY Ruta ASC);

	SET @RUTA_GUARDADA = REPLACE(@RUTA_GUARDADA,'Etapas ->','');
	SET @RUTA_GUARDADA = REPLACE(@RUTA_GUARDADA,' ->','/');
	SET @RUTA_GUARDADA = REPLACE(@RUTA_GUARDADA,' ->','/') + @NombreArchivo;

	--COMPARARLA CON LA RUTA RECIBIDA PARA VALIDAR QUE SEA LA MISMA
	IF (@RUTA_GUARDADA <> @Ruta)
	BEGIN
		--ESTABLECER LA RUTA GUARDADA
		SET @Ruta = @RUTA_GUARDADA;
	END

    -- Insert statements for procedure here
	DECLARE @EXISTE_ARCHIVO INT = (SELECT TOP 1 IdElemento FROM EN_CarpetasArchivosVisor WHERE Nombre = @NombreArchivo AND IdPadre = @IdCarpeta AND Nivel = @Nivel AND IdContrato = @ContratoId AND Ruta = @Ruta);

	IF ISNULL(@EXISTE_ARCHIVO,0) = 0
	BEGIN
		SELECT 'SUCCESS REGISTRAR ARCHIVO'
	END
	ELSE
	BEGIN
		SELECT 'ERROR ARCHIVO EXISTENTE'
	END

END
