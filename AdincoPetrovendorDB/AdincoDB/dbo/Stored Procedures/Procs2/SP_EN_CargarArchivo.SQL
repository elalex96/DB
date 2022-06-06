USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_CargarArchivo]    Script Date: 05/06/2022 03:18:05 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/01/2022>
-- Description:	<Agregar un archivo al visor V2>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_CargarArchivo] 
	-- Add the parameters for the stored procedure here
	@ContratoId INT,
	@IdUsuario INT,
	@Nivel INT,
	@IdCarpeta INT,
	@Frecuencia INT,
	@Bucket VARCHAR(1000),
	@Folder VARCHAR(2000),
	@UUIDAmazon VARCHAR(1000),
	@NombreArchivo VARCHAR(2000),
	@Meta VARCHAR(1000),
	@SizeBytes FLOAT,
	@Ruta VARCHAR(MAX),
	@IdEntregable INT,
	@AnioMes NVARCHAR(100),
	@Etapa INT, 
	@IdReceptorEntregable INT, 
	@IsPozo BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--RECUPERAR LA RUTA GUARDADA AL ENTRAR A LA CARPETA
	--DECLARE @RUTA_GUARDADA NVARCHAR(MAX) = (SELECT TOP 1
	--											Ruta
	--										FROM EN_SecuenciaCarpetas 
	--										WHERE IdCarpeta = @IdCarpeta
	--											AND Nivel = @Nivel
	--											AND Frecuencia = @Frecuencia
	--											AND IdContrato = @ContratoId
	--										ORDER BY Ruta ASC);

	--SET @RUTA_GUARDADA = REPLACE(@RUTA_GUARDADA,'Etapas ->','');
	--SET @RUTA_GUARDADA = REPLACE(@RUTA_GUARDADA,' ->','/');
	--SET @RUTA_GUARDADA = REPLACE(@RUTA_GUARDADA,' ->','/') + @NombreArchivo;

	----COMPARARLA CON LA RUTA RECIBIDA PARA VALIDAR QUE SEA LA MISMA
	--IF ISNULL(@RUTA_GUARDADA,'') <> ''
	--BEGIN

	--	IF (@RUTA_GUARDADA <> @Ruta)
	--	BEGIN
	--		--ESTABLECER LA RUTA GUARDADA
	--		SET @Ruta = @RUTA_GUARDADA;
	--	END

	--END

    -- Insert statements for procedure here
	INSERT INTO EN_CarpetasArchivosVisor (
		IsArchivo,
		Nombre,
		IdPadre,
		CreadoPor,
		CreadoEl,
		Nivel,
		Activo,
		Frecuencia,
		Bucket,
		Folder,
		UUIDAmazon,
		Meta,
		SizeBytes,
		IdContrato,
		Ruta,
		IdEntregable,
		AnioMes,
		Etapa,
		IdReceptorEntregable,
		IsPozo
	)
	VALUES
	(
		1,
		@NombreArchivo,
		@IdCarpeta,
		@IdUsuario,
		GETDATE(),
		@Nivel,
		1,
		@Frecuencia,
		@Bucket,
		@Folder,
		@UUIDAmazon,
		@Meta,
		@SizeBytes,
		@ContratoId,
		@Ruta,
		@IdEntregable,
		@AnioMes,
		@Etapa,
		@IdReceptorEntregable,
		@IsPozo
	);

	SELECT SCOPE_IDENTITY() AS IDDOCUMENTO;

END
