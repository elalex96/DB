USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_AgregarCarpeta]    Script Date: 17/01/2022 02:41:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <11/01/2022>
-- Description:	<Agregado de carpetas en el visor de archivos V2>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_AgregarCarpeta]
	-- Add the parameters for the stored procedure here
	@IdPadre INT,
	@Nombre VARCHAR(500),
	@Nivel INT,
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
		Activo
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
		1
	);

	SELECT SCOPE_IDENTITY() AS IDCARPETA;

END
