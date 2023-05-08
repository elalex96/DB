-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <11/01/2022>
-- Description:	<Agregado de carpetas en el visor de archivos V2>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/04/2022>
-- Description:	<VALIDACION DE CARPETA EXISTENTE DENTRO DE LA MISMA RUTA>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- update date: <02/12/2022>
-- Description:	Se agrega columna @IdEtapaContrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_AgregarCarpeta]
	-- Add the parameters for the stored procedure here
	@IdPadre INT,
	@Nombre VARCHAR(500),
	@Nivel INT,
	@IdUsuario INT,
	@IdContrato INT,
	@Limitador INT,
	@Etapa INT, 
	@IdReceptorEntregable INT, 
	@IsPozo BIT,
	@IdEtapaContrato INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @LIMITADOR_GUARDADO INT = (SELECT TOP 1 Limitador FROM EN_CarpetasArchivosVisor WHERE IdElemento = @IdPadre);
	DECLARE @CARPETA_EXISTENTE INT = (SELECT TOP 1 IdElemento FROM EN_CarpetasArchivosVisor WHERE Nombre = @Nombre AND Nivel = @Nivel AND IdPadre = @IdPadre AND IdContrato = @IdContrato AND Activo = 1);

	SET @LIMITADOR_GUARDADO = ((ISNULL(@LIMITADOR_GUARDADO,0)) + 1);

	--VALIDACION DE CARPETA EXISTENTE DENTRO DE LA MISMA RUTA
	IF ISNULL(@CARPETA_EXISTENTE,0) = 0
	BEGIN
		
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
			IsPozo,
			IdEtapaContrato
		)
		VALUES
		(
			1,
			0,
			@Nombre,
			@IdPadre,
			@IdUsuario,
			GETDATE(),
			@Nivel,
			1,
			@IdContrato,
			@LIMITADOR_GUARDADO,
			@Etapa,
			@IdReceptorEntregable,
			@IsPozo,
			@IdEtapaContrato
		);

		SELECT SCOPE_IDENTITY() AS IDCARPETA,'SUCCESS';

	END
	ELSE
	BEGIN
		
		SELECT 0,'ERROR CARPETA EXISTENTE'

	END

END
