USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ObtenerHistorialFechaLimitePedido'
)
    DROP PROCEDURE SP_ObtenerHistorialFechaLimitePedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ObtenerHistorialFechaLimitePedido] --32691, 0
    @IdPedido INT,
    @IdProveedor INT
AS
BEGIN
	
	CREATE TABLE #HISTORIAL(
		Id_Historial INT IDENTITY(1,1),
		Nombre NVARCHAR(100),
		FechaEdicion DATETIME,
		Cambio NVARCHAR(MAX),
		Motivo NVARCHAR(MAX)
	);

	DECLARE @FechaActual DATETIME;

	SELECT @FechaActual = FechaVigencia
    FROM MM_HorasVigenciaPedido
    WHERE IdPedido = @IdPedido

	INSERT INTO #HISTORIAL(
		Nombre,
		FechaEdicion,
		Cambio,
		Motivo
	)
    SELECT Nombre,
           historial.FechaCreacion,
           'De: ' + CAST(historial.FechaVigencia AS NVARCHAR(200)) + ' A: ' + CAST(@FechaActual AS VARCHAR(200)),
           historial.Motivo
    FROM dbo.MM_HorasVigenciaPedidoHistorial historial (NOLOCK)
        LEFT JOIN dbo.S_Usuario usuario (NOLOCK)
            ON historial.IdUsuarioCreador = usuario.IdUsuario
    WHERE historial.IdPedido = @IdPedido;
	
	INSERT INTO #HISTORIAL(
		Nombre,
		FechaEdicion,
		Cambio
	)
	SELECT
		usuario.Nombre,
		PDH.ModificadoEl,
		'Modificación de la Partida: "' + M.DescripcionCorta + '" de Cantidad: ' + CAST(PDH.Cantidad AS NVARCHAR(200)) + ' a Nueva Cantidad: ' + CAST(ISNULL(PDH.NuevaCantidad,'') AS NVARCHAR(200))
	FROM dbo.MM_PedidoDetalleHistorico AS PDH (NOLOCK)
		JOIN dbo.S_Usuario usuario (NOLOCK)
            ON PDH.ModificadoPor = usuario.IdUsuario
		JOIN MM_Material AS M (NOLOCK)
			ON PDH.IdMaterial = M.IdMaterial
	WHERE PDH.IdPedido = @IdPedido
		AND PDH.NuevaCantidad IS NOT NULL
		AND PDH.NuevaCantidad <> PDH.Cantidad;

	SELECT
		Id_Historial,
		Nombre,
		FechaEdicion,
		Cambio,
		Motivo
	FROM #HISTORIAL
	ORDER BY FechaEdicion DESC

END