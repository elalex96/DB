USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_CargarArchivo]    Script Date: 03/06/2022 09:35:22 a. m. ******/
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
	@AnioMes NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
		AnioMes
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
		@AnioMes
	);

	SELECT SCOPE_IDENTITY() AS IDDOCUMENTO;

END
