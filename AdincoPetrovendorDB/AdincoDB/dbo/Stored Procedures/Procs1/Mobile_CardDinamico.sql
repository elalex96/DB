CREATE PROCEDURE [dbo].[Mobile_CardDinamico]
@IdContrato INT,
@IdUsuario INT,
@IdApp INT =0,
@Idioma INT =0
AS
BEGIN
DECLARE @CabtidadFacturas INT, @CantidadAprobacionPedido INT;
IF	@IdApp = 1
	BEGIN
		SELECT
		  AP.IdTipoAprobacion,
		  Tipo = REPLACE(TA.TipoAprobacion,'Aprobación ',''),
		  Cantiddad   = COUNT(1),
		  TA.Icon
		FROM AM_Aprobacion AP
		JOIN dbo.AM_TipoAprobacion AS TA ON TA.idTipoAprobacion = AP.IdTipoAprobacion
		WHERE 
		--AP.IdContrato = @IdContrato AND 
		AP.IdUsuario = @IdUsuario
		GROUP BY TA.Icon,AP.IdTipoAprobacion,TA.TipoAprobacion
		ORDER BY TA.TipoAprobacion
	END

IF	@IdApp = 2
BEGIN
CREATE TABLE #MenuDinamicoTempo
		(
		IdTipoAprobacion INT,
		Tipo VARCHAR(100),
		Cantiddad INT,
		Icon VARCHAR(200)
		)	
		INSERT INTO #MenuDinamicoTempo
		(
		    IdTipoAprobacion,
		    Tipo,
		    Cantiddad,
		    Icon
		)
		VALUES
		(   35,  -- IdTipoAprobacion - int
		    'Seguimiento de Pago [Facturas aprobadas]', -- Tipo - varchar(100)
		    1,  -- Cantidad - int
		    'aprofactura.png'  -- Icon - varchar(200)
		    )
INSERT INTO #MenuDinamicoTempo
		(
		    IdTipoAprobacion,
		    Tipo,
		    Cantiddad,
		    Icon
		)
		VALUES
		(   9,  -- IdTipoAprobacion - int
		    'Ordenes de compra', -- Tipo - varchar(100)
		    1,  -- Cantidad - int
		    'pedido.png'  -- Icon - varchar(200)
		    )
		
			SELECT * FROM #MenuDinamicoTempo
END	
IF	@IdApp = 3
	BEGIN
	CREATE TABLE #MenuDinamicoTemp
		(
		IdTipoAprobacion INT,
		Tipo VARCHAR(100),
		Cantiddad INT,
		Icon VARCHAR(200)
		)
	SET @CabtidadFacturas =(
					SELECT COUNT(aFact.IdFactura)
					FROM Adinco.dbo.FI_Factura aFact
							LEFT JOIN Petrovendor.dbo.FI_Factura pFact	ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
							LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
							INNER JOIN Petrovendor.dbo.MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
							INNER JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = acepPed.IdPedido
							LEFT JOIN Petrovendor.dbo.TA_Operacion TAO ON TAO.IdDocumento = acepFact.IdAceptacionFactura
							LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
					WHERE TE.IdEstatus = 2 --aprobadas
							  AND aFact.Activa = 1
							  AND pFact.Activa = 1
							  AND acepPed.IdProveedor = @IdContrato)
	
	SET @CantidadAprobacionPedido= (SELECT 
COUNT(o.IdProveedor)
FROM Petrovendor.dbo.TA_Tarea t
INNER JOIN Petrovendor.dbo.TA_Operacion o
ON o.IdOperacion = t.IdOperacion
AND o.IdTipoOperacion IN (9)
WHERE o.IdProveedor = @IdContrato)

	IF @CantidadAprobacionPedido >0
	BEGIN
	INSERT INTO #MenuDinamicoTemp
		(
		    IdTipoAprobacion,
		    Tipo,
		    Cantiddad,
		    Icon
		)
		VALUES
		(   9,  -- IdTipoAprobacion - int
		    'Ordenes de compra', -- Tipo - varchar(100)
		    @CantidadAprobacionPedido,  -- Cantidad - int
		    'pedido.png'  -- Icon - varchar(200)
		    )
    END
	IF	@CabtidadFacturas > 0
	BEGIN
		
		INSERT INTO #MenuDinamicoTemp
		(
		    IdTipoAprobacion,
		    Tipo,
		    Cantiddad,
		    Icon
		)
		VALUES
		(   35,  -- IdTipoAprobacion - int
		    'Seguimiento de Pago [Facturas aprobadas]', -- Tipo - varchar(100)
		    @CabtidadFacturas,  -- Cantidad - int
		    'aprofactura.png'  -- Icon - varchar(200)
		    )
			
		END



		SELECT * FROM #MenuDinamicoTemp
	END
END
