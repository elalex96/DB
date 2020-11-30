create PROCEDURE [dbo].[Mobile_ConsultaPagosProveedor]
@IdProveedor INT= null,
@IdContrato    INT = null,
@IdUsuario     INT = null
AS
BEGIN
	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM Petrovendor.dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);
	
	CREATE TABLE #SEGUIMIENTOPAGOS(
	IdFactura INT NULL,
	IdFacturaPet INT NULL,
	IdSolicitudPedido VARCHAR(20) NULL,
	Receptor NVARCHAR(200) NULL,
	Fecha DATETIME NULL,
	Serie NVARCHAR(MAX) NULL,
	Folio NVARCHAR(MAX) NULL,
	Total MONEY,
	UUID VARCHAR(500) NULL,
	Moneda VARCHAR(10) NULL,
	Proceso VARCHAR(100) NULL,
	TieneArchivo BIT NULL,
	IdAceptacionPedido INT NULL,
	ReceptorRFC VARCHAR(500)
	);
	
	---------------------------------------------------
	INSERT INTO #SEGUIMIENTOPAGOS
	SELECT aFact.IdFactura,
           pFact.IdFactura IdFacturaPet,
		   p.IdSolicitudPedido, 
           prov.RazonSocial AS Receptor,
           aFact.Fecha,
           aFact.Serie,
           aFact.Folio,
           aFact.MontoConIva AS Total,
           aFact.UUID,
           M.TipoMonedaCorto AS Moneda,
           Proceso = CASE
                         WHEN transf.PDF IS NULL THEN
                             'No pagado'
                         WHEN transf.PDF IS NOT NULL THEN
                             'Pagado'
                         WHEN aFact.IdFactura IS NULL THEN
                             'En proceso'
                     END,
           TieneArchivo = CAST(CASE
                                   WHEN transf.PDF IS NULL THEN
                                       0
                                   ELSE
                                       1
                               END AS BIT),
           acepFact.IdAceptacionPedido,
		   aFact.Receptor
    FROM Adinco.dbo.FI_Factura aFact
        LEFT JOIN Petrovendor.dbo.FI_Factura pFact	ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
        LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
		INNER JOIN Petrovendor.dbo.MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
		INNER JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = acepPed.IdPedido
        LEFT JOIN Petrovendor.dbo.TA_Operacion TAO ON TAO.IdDocumento = acepFact.IdAceptacionFactura
        LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
        INNER JOIN Petrovendor.dbo.S_Proveedor prov ON prov.RFC = aFact.Receptor COLLATE Modern_Spanish_CI_AS
        LEFT JOIN Adinco.dbo.PV_TipoMoneda M ON M.IdMoneda = aFact.IdMoneda
        LEFT JOIN Adinco.dbo.FI_TransferFactura transFac ON transFac.IdFactura = aFact.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer transf ON transf.IdTransferencia = transFac.IdTransfer
    WHERE TE.IdEstatus = 2 --aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
          AND prov.Activo = 1
          AND acepPed.IdProveedor = @IdProveedor
		  AND ISNULL(prov.IsEliminado, 0) = 0

	SELECT * FROM #SEGUIMIENTOPAGOS
END
