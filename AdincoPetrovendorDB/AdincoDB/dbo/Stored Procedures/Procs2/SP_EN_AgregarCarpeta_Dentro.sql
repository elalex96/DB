USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_AgregarCarpeta_Dentro]    Script Date: 06/07/2022 03:59:19 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <11/01/2022>
-- Description:	<Agregado de carpetas en el visor de archivos V2>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: <25/03/2022>
-- Description:	Se agrego parametro de Nivel y CarpetaId del padre de la nueva carpeta
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_AgregarCarpeta_Dentro] --'','PRUEBA',0,2,18,3,1
	-- Add the parameters for the stored procedure here
	@Ruta VARCHAR(MAX),
	@Nombre NVARCHAR(500),
	@IdUsuario INT,
	@NivelPadre INT,
	@CarpetaPadreId INT,
	@IdContrato INT,
	@Limitador INT,
	@Etapa INT, 
	@IdReceptorEntregable INT, 
	@IsPozo BIT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdPadre INT,
			@Nivel INT,
			@Frecuencia INT,
			@IdNuevaCarpeta INT;

	DECLARE @LIMITADOR_GUARDADO INT = (SELECT TOP 1 Limitador FROM EN_CarpetasArchivosVisor WHERE IdElemento = @IdPadre);
	DECLARE @CARPETA_EXISTENTE INT = (SELECT TOP 1 IdElemento FROM EN_CarpetasArchivosVisor WHERE Nombre = @Nombre AND Nivel = @NivelPadre AND IdPadre = @CarpetaPadreId AND IdContrato = @IdContrato AND Activo = 1);
	SET @LIMITADOR_GUARDADO = ((ISNULL(@LIMITADOR_GUARDADO,0)) + 1);
			
	--VALIDACION DE CARPETA EXISTENTE DENTRO DE LA MISMA RUTA
	IF ISNULL(@CARPETA_EXISTENTE,0) = 0
	BEGIN
		
		-- Insert statements for procedure here
		INSERT INTO EN_CarpetasArchivosVisor
		(
			[IsCarpeta],
			[IsArchivo],
			[Nombre],
			[IdPadre],
			[CreadoPor],
			[CreadoEl],
			Nivel,
			Activo,
			IdContrato,
			Limitador,
			Etapa,
			IdReceptorEntregable,
			IsPozo
		)
		VALUES
		(
			1,
			0,
			@Nombre,
			@CarpetaPadreId,
			@IdUsuario,
			GETDATE(),
			@NivelPadre,
			1,
			@IdContrato,
			@LIMITADOR_GUARDADO,
			@Etapa,
			@IdReceptorEntregable,
			@IsPozo
		);

		SET @IdNuevaCarpeta = (SELECT SCOPE_IDENTITY());

		SELECT TOP 1
			'SUCCESS',
			IdCarpeta,
			Frecuencia,
			IsCarpetaUsuario,
			IdReceptorEntregable,
			IsPozo,
			Etapa,
			AnioMes,
			Nivel,
			ISNULL(IdEntregable,0) AS IdEntregable
		FROM EN_SecuenciaCarpetas
		WHERE IdCarpeta = @CarpetaPadreId
		AND Nivel = @NivelPadre
		AND Activo = 1;

		SELECT @CARPETA_EXISTENTE

	END
	ELSE
	BEGIN
		SELECT 'ERROR CARPETA EXISTENTE',0,0,0,0,0,0,0,0,0;
	END
    

END
