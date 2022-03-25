USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_AgregarCarpeta_Dentro'
)
    DROP PROCEDURE SP_EN_AgregarCarpeta_Dentro;
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_AgregarCarpeta_Dentro]    Script Date: 24/03/2022 08:56:15 p. m. ******/
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
CREATE PROCEDURE [dbo].[SP_EN_AgregarCarpeta_Dentro]
	-- Add the parameters for the stored procedure here
	@Ruta VARCHAR(MAX),
	@Nombre NVARCHAR(500),
	@IdUsuario INT,
	@NivelPadre INT,
	@CarpetaPadreId INT,
	@IdContrato INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdPadre INT,
			@Nivel INT,
			@Frecuencia INT,
			@IdNuevaCarpeta INT;
			

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
		@CarpetaPadreId,
		@IdUsuario,
		GETDATE(),
		@NivelPadre,
		1,
		@IdContrato
	);

	SET @IdNuevaCarpeta = (SELECT SCOPE_IDENTITY());

	SELECT TOP 1
		IdCarpeta,
		Frecuencia,
		IsCarpetaUsuario,
		IdReceptorEntregable,
		IsPozo,
		Etapa,
		AnioMes,
		Nivel
	FROM EN_SecuenciaCarpetas
	WHERE IdCarpeta = @CarpetaPadreId
	AND Nivel = @NivelPadre
	AND Activo = 1;

END
