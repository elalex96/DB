USE Adinco
GO
DROP PROC IF EXISTS Mobile_sp_TipoAprobacionesPorUsuario
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Alexander Gomez 
-- Create date: 27/06/2023
-- Description:	Consultar los tipos de aprobaciones por usuario
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 10/01/2024
-- Description:	Issue #268, se cambian las descripciones a Max para no tener error de truncated
-- =============================================
CREATE PROCEDURE Mobile_sp_TipoAprobacionesPorUsuario --10203
	-- Add the parameters for the stored procedure here
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DROP TABLE IF EXISTS #OperacionesUsuario
	CREATE TABLE #OperacionesUsuario(
		IdOperacion INT,
		IdContrato INT,
		NumeroContrato NVARCHAR(MAX),
		TipoAprobacion NVARCHAR(100),
		idTipoAprobacion INT,
		FechaCreacion NVARCHAR(100),
		ComentarioDoc NVARCHAR(MAX),
		ComentarioApr NVARCHAR(MAX),
		Estatus NVARCHAR(100),
		IdStatusAprobacionM INT,
		IdTareaOrigen INT,
		NoVersion INT,
		IdPedido INT,
		DisplayMember INT,
		IdDocumento INT,
		TipoFlujo INT,
		UsuarioPetro INT
	);

	DROP TABLE IF EXISTS #Mobile_TipoAprobaciones
	CREATE TABLE #Mobile_TipoAprobaciones(
		Id INT,
		Menu VARCHAR(200) NULL,
		IdTitulo VARCHAR(200) NULL,
		Icon VARCHAR(200) NULL,
		IdTipoAprobacion INT NULL
	);

	INSERT INTO #OperacionesUsuario
	EXEC dbo.[Mobile_sp_AprobacionesPorUsuario] @IdUsuario,2;--REQUISIONES

	INSERT INTO #OperacionesUsuario
	EXEC dbo.[Mobile_sp_AprobacionesPorUsuario] @IdUsuario,9;--PEDIDO

	INSERT INTO #OperacionesUsuario
	EXEC dbo.[Mobile_sp_AprobacionesPorUsuario] @IdUsuario,14;--COMPRA DIRECTA

	INSERT INTO #OperacionesUsuario
	EXEC dbo.[Mobile_sp_AprobacionesPorUsuario] @IdUsuario,19;--PEDIMENTO COMPROBANTE

	IF EXISTS (SELECT * FROM #OperacionesUsuario WHERE idTipoAprobacion = 2)
	BEGIN

		INSERT INTO #Mobile_TipoAprobaciones (Id,
		Menu,
		IdTitulo,
		Icon,
		IdTipoAprobacion)
		SELECT
			Id,
			Menu,
			IdTitulo,
			Icon,
			IdTipoAprobacion
		FROM Mobile_TipoAprobaciones
		WHERE IdTitulo = 'REQUI_TTL';

	END

	IF EXISTS (SELECT * FROM #OperacionesUsuario WHERE idTipoAprobacion = 9)
	BEGIN

		INSERT INTO #Mobile_TipoAprobaciones (Id,
		Menu,
		IdTitulo,
		Icon,
		IdTipoAprobacion)
		SELECT
			Id,
			Menu,
			IdTitulo,
			Icon,
			IdTipoAprobacion
		FROM Mobile_TipoAprobaciones
		WHERE IdTitulo = 'PEDIDO_TTL';

	END

	IF EXISTS (SELECT * FROM #OperacionesUsuario WHERE idTipoAprobacion = 14)
	BEGIN

		INSERT INTO #Mobile_TipoAprobaciones (Id,
		Menu,
		IdTitulo,
		Icon,
		IdTipoAprobacion)
		SELECT
			Id,
			Menu,
			IdTitulo,
			Icon,
			IdTipoAprobacion
		FROM Mobile_TipoAprobaciones
		WHERE IdTitulo = 'COMPRADIRECTA_TTL';

	END

	IF EXISTS (SELECT * FROM #OperacionesUsuario WHERE idTipoAprobacion = 19)
	BEGIN

		INSERT INTO #Mobile_TipoAprobaciones (Id,
		Menu,
		IdTitulo,
		Icon,
		IdTipoAprobacion)
		SELECT
			Id,
			Menu,
			IdTitulo,
			Icon,
			IdTipoAprobacion
		FROM Mobile_TipoAprobaciones
		WHERE IdTitulo = 'PEDIMENTO_COMPROBANTE_TTL';

	END

	SELECT
		Id,
		Menu,
		IdTitulo,
		Icon,
		IdTipoAprobacion
	FROM #Mobile_TipoAprobaciones;

END
