CREATE VIEW [dbo].[VistaFacturaManualesJaguar]
AS

SELECT F.IdFactura, 
       S.RazonSocial, 
       S.RFC, 
       F.Serie, 
       F.Folio, 
       F.SubTotal, 
       F.Moneda, 
       F.MontoConIva, 
       F.UUID, 
       C.NumeroContrato, 
       F.FechaTimbrado, 
       ISNULL(GR.Descripcion, '') AS Rubro, 
       ISNULL(CCSH.Descripcion, '') AS [Catalogo Bienes/Servicios Sector Hidrocarburos], 
       CONVERT(DATE, T.FechaPago) AS [Fecha Transferencia], 
       CONVERT(DATE, F.Fecha) AS [Fecha para Reporte],
       CASE
           WHEN FP.IdFactura IS NOT NULL
                AND ACP.IdEstatus = 2
                AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
           THEN 'Si tiene carta'
           WHEN DADA.IdDocAdinco IS NOT NULL
           THEN 'Si tiene carta'
           ELSE 'NO TIENE CARTA'
       END AS CartaContenidoNacional
FROM dbo.FI_Factura AS F WITH(NOLOCK)
     INNER JOIN dbo.PV_Subcontratista AS S WITH(NOLOCK) ON F.Emisor = S.RFC
     INNER JOIN dbo.CO_Contrato AS C WITH(NOLOCK) ON F.IdContrato = C.IdContrato
     LEFT OUTER JOIN dbo.CO_Registro AS R WITH(NOLOCK) ON F.IdFactura = R.IdFactura
     LEFT OUTER JOIN dbo.CO_GastosRubro AS GR WITH(NOLOCK) ON R.IdGastoRubro = GR.IdGastoRubro
     LEFT OUTER JOIN dbo.CO_CatalogoCuentaSH AS CCSH WITH(NOLOCK) ON R.IdCatalogoCuentasSH = CCSH.IdCatalogoCuentasSH
     LEFT OUTER JOIN dbo.FI_TransferFactura AS TF WITH(NOLOCK) ON F.IdFactura = TF.IdFactura
     LEFT OUTER JOIN dbo.FI_Transfer AS T WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
     LEFT OUTER JOIN dbo.AWS_DocAwsDocAdinco AS DADA WITH(NOLOCK) ON F.IdFactura = DADA.IdDocAdinco
     LEFT OUTER JOIN Petrovendor.dbo.FI_Factura AS FP WITH(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
                                                                      AND FP.UUID IS NOT NULL
                                                                      AND FP.Activa = 1
                                                                      AND ISNULL(FP.IsEliminado, 0) <> 1
     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF WITH(NOLOCK) ON FP.IdFactura = AF.IdFactura
     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP WITH(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP WITH(NOLOCK) ON AP.IdAceptacionPedido = ACP.IdAceptacionPedido
                                                                                  AND ACP.IdEstatus = 2
                                                                                  AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
WHERE(F.Receptor IN('JSE1601292U8', 'JEP1709042B1', 'PEP170906DI5', 'JEP1502264H1'))
	 AND F.IdContrato IN (10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024, 10043, 10052)
     AND fp.IdFactura IS NULL
GROUP BY F.IdFactura, 
         S.RazonSocial, 
         S.RFC, 
         F.Serie, 
         F.Folio, 
         F.SubTotal, 
         F.Moneda, 
         F.MontoConIva, 
         F.UUID, 
         C.NumeroContrato, 
         F.FechaTimbrado, 
         ISNULL(GR.Descripcion, ''), 
         ISNULL(CCSH.Descripcion, ''), 
         CONVERT(DATE, T.FechaPago), 
         CONVERT(DATE, F.Fecha),
         CASE
             WHEN FP.IdFactura IS NOT NULL
                  AND ACP.IdEstatus = 2
                  AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
             THEN 'Si tiene carta'
             WHEN DADA.IdDocAdinco IS NOT NULL
             THEN 'Si tiene carta'
             ELSE 'NO TIENE CARTA'
         END 



