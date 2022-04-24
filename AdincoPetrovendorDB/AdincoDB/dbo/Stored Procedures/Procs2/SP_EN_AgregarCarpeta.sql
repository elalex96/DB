USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_AgregarCarpeta]    Script Date: 22/04/2022 12:21:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <11/01/2022>
-- Description:	<Agregado de carpetas en el visor de archivos V2>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_AgregarCarpeta]
	-- Add the parameters for the stored procedure here
	@IdPadre INT,
	@Nombre VARCHAR(500),
	@Nivel INT,
	@IdUsuario INT,
	@IdContrato INT,
	@Limitador INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @LIMITADOR_GUARDADO INT = (SELECT TOP 1 Limitador FROM EN_CarpetasArchivosVisor WHERE IdElemento = @IdPadre);

	SET @LIMITADOR_GUARDADO = ((ISNULL(@LIMITADOR_GUARDADO,0)) + 1);

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
		Limitador
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
		@LIMITADOR_GUARDADO
	);

	SELECT SCOPE_IDENTITY() AS IDCARPETA;

END
