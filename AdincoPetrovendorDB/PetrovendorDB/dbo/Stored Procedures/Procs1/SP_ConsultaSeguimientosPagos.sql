CREATE PROCEDURE SP_ConsultaSeguimientosPagos @IdProveedor INT
AS
BEGIN

    SET LANGUAGE Español
    SELECT aFact.IdFactura,
           pFact.IdFactura IdFacturaPet,
           prov.RazonSocial AS Receptor,
           aFact.Fecha,
           aFact.Serie,
           aFact.Folio,
           aFact.SubTotal,
           aFact.Descuento,
           aFact.TipoCambio,
           aFact.MontoConIva AS Total,
           YEAR(aFact.Fecha) AS Año,
           CONCAT(RIGHT('00' + CAST(MONTH(aFact.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, aFact.Fecha)) AS Mes,
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
           acepFact.IdAceptacionPedido
    FROM Adinco.dbo.FI_Factura aFact
        LEFT JOIN Petrovendor.dbo.FI_Factura pFact
            ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
        LEFT JOIN dbo.MM_AceptacionFactura acepFact
            ON acepFact.IdFactura = pFact.IdFactura
        LEFT JOIN Petrovendor.dbo.TA_Operacion TAO
            ON TAO.IdDocumento = acepFact.IdAceptacionFactura
        LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE
            ON TE.IdEstatus = TAO.IdEstatusOperacion
        INNER JOIN Petrovendor.dbo.S_Proveedor prov
            ON prov.RFC = aFact.Receptor COLLATE Modern_Spanish_CI_AS
        LEFT JOIN Adinco.dbo.PV_TipoMoneda M
            ON M.IdMoneda = aFact.IdMoneda
        LEFT JOIN Adinco.dbo.FI_TransferFactura transFac
            ON transFac.IdFactura = aFact.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer transf
            ON transf.IdTransferencia = transFac.IdTransfer
    WHERE TE.IdEstatus = 2 --aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
          AND prov.Activo = 1
          AND TAO.IdProveedor = @IdProveedor

END