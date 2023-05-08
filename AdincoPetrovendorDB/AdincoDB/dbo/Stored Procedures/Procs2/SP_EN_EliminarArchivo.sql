-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/01/2022>
-- Description:	<Eliminar archivo cargado en visor V2>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_EliminarArchivo]-- 1207
	-- Add the parameters for the stored procedure here
	@Id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ISCARPETA INT,
			@Ruta VARCHAR(MAX),
			@RutaAnterior VARCHAR(MAX),
			@IdContrato INT,
			@RutaInterna VARCHAR(MAX);

	UPDATE EN_CarpetasArchivosVisor
	SET Activo = 0,
		FechaEliminado = GETDATE(),
		Ruta = NULL
	WHERE IdElemento = @Id;

	UPDATE EN_CarpetasArchivosVisor
	SET Activo = 0,
		FechaEliminado = GETDATE(),
		Ruta = NULL
	WHERE IdPadre = @Id;

	SELECT 
		@ISCARPETA = ISNULL(IsCarpeta,0),
		@IdContrato = IdContrato
	FROM EN_CarpetasArchivosVisor 
	WHERE IdElemento = @Id;

	SELECT 
		@Ruta = REPLACE(REPLACE(Ruta,'Etapas ->',''),' ->','/'),
		@RutaInterna = Ruta
	FROM EN_SecuenciaCarpetas
	WHERE IdCarpeta = @Id
	AND IdContrato = @IdContrato
	AND IsCarpetaUsuario = 1
	AND Activo = 1;

	--VALIDACION SI EL ARCHIVO QUE SE VA ELIMINAR ES UNA CARPETA, ELIMINAR TODO EL CONTENIDO
	IF @ISCARPETA = 1
	BEGIN

		--ELIMINADO DE ARCHIVOS DENTRO DE LAS CARPETAS EN ESA RUTA
		UPDATE EN_CarpetasArchivosVisor
		SET Activo = 0,
			FechaEliminado = GETDATE()
		WHERE Ruta LIKE '%' + @Ruta + '%' 
			AND Activo = 1;

		--ELIMINADO DE LA SECUENCIA 
		UPDATE EN_SecuenciaCarpetas
		SET Activo = 0
		WHERE IdCarpeta = @ID 
			AND Ruta LIKE '%' + @RutaInterna + '%' 
			AND Activo = 1;

	END

	SELECT 
		Activo 
	FROM EN_CarpetasArchivosVisor 
	WHERE IdElemento = @Id;

END