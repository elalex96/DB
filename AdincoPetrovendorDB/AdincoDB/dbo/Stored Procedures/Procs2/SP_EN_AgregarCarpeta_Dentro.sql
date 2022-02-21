USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_AgregarCarpeta_Dentro]    Script Date: 18/02/2022 04:09:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <11/01/2022>
-- Description:	<Agregado de carpetas en el visor de archivos V2>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_AgregarCarpeta_Dentro]
	-- Add the parameters for the stored procedure here
	@Ruta VARCHAR(MAX),
	@Nombre NVARCHAR(500),
	@IdUsuario INT,
	@IdContrato INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdPadre INT,
			@Nivel INT,
			@Frecuencia INT;

	SELECT TOP 1
		@IdPadre = IdCarpeta,
		@Nivel = Nivel
	FROM EN_SecuenciaCarpetas
	WHERE Ruta = @Ruta;

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
		IdContrato
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
		@IdContrato
	);

	SELECT SCOPE_IDENTITY() AS IDCARPETA;

END
