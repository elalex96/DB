USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_EliminarCarpeta]    Script Date: 04/02/2022 08:31:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/01/2022>
-- Description:	<Eliminar archivo cargado en visor V2>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_EliminarCarpeta]-- 'Etapas>Exploración>Nueva Carpeta para descargar>',0,3
	-- Add the parameters for the stored procedure here
	@Ruta NVARCHAR(MAX),
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ID INT,
			@RutaAnterior NVARCHAR(MAX);

	SELECT TOP 1
		@ID = IdCarpeta,
		@RutaAnterior = RutaAnterior
	FROM EN_SecuenciaCarpetas
	WHERE Ruta = @Ruta
	AND IdContrato = @IdContrato
	AND Activo = 1;

	--ELIMINADO DE ARCHIVOS DENTRO DE LAS CARPETAS EN ESA RUTA
	UPDATE EN_CarpetasArchivosVisor
	SET Activo = 0,
		FechaEliminado = GETDATE()
	WHERE IdPadre IN (SELECT IdCarpeta FROM EN_SecuenciaCarpetas WHERE Ruta LIKE '%' + @Ruta + '%') 
		AND Activo = 1;

	--ELIMINADO DE CARPETAS DENTRO DE LAS CARPETAS EN ESA RUTA
	UPDATE EN_CarpetasArchivosVisor
	SET Activo = 0,
		FechaEliminado = GETDATE()
	WHERE IdElemento IN (SELECT IdCarpeta FROM EN_SecuenciaCarpetas WHERE Ruta LIKE '%' + @Ruta + '%') 
		AND Activo = 1;

	--ELIMINADO DE LA CARPETA PADRE
	UPDATE EN_CarpetasArchivosVisor
	SET Activo = 0,
		FechaEliminado = GETDATE()
	WHERE IdElemento = @ID 
		AND Activo = 1;

	--ELIMINADO DE LA SECUENCIA 
	UPDATE EN_SecuenciaCarpetas
	SET Activo = 0
	WHERE IdCarpeta = @ID 
		AND Ruta LIKE '%' + @Ruta + '%' 
		AND Activo = 1;

	UPDATE EN_SecuenciaCarpetas
	SET Activo = 0
	WHERE IdCarpeta = @ID 
		AND Ruta = @Ruta 
		AND Activo = 1;

	--SE DEVUELVE LA CARPETA ANTERIOR
	SELECT
		SC.IdCarpeta,
		SC.Nivel,
		SC.Frecuencia,
		SC.IsCarpetaUsuario,
		SC.Ruta,
		CA.Nombre
	FROM EN_SecuenciaCarpetas AS SC
	LEFT JOIN EN_CarpetasArchivosVisor AS CA
		ON SC.IdCarpeta = CA.IdElemento
	WHERE SC.Ruta = @RutaAnterior
	AND SC.Activo = 1
	AND SC.IdContrato = @IdContrato;

END
