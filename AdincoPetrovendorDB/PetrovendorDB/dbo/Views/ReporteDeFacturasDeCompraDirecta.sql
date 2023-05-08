CREATE VIEW [dbo].[ReporteDeFacturasDeCompraDirecta]
AS
     SELECT ACC.NumeroContrato,
            AAC.NombreAreaContractual,
            PC.RazonSocial AS Operadora,
            SOLPED.IdSolicitudPedido AS NCompra,
            PV.RazonSocial,
            FAC.IdFactura AS NPedido,
            FAC.FechaTimbrado AS FechaCreacion,
            CC.CentroCosto,
            CCG.Descripcion AS CuentaContable,
            CSH.Descripcion AS CuentaSectorHid,
            FAC.SubTotal AS MontoFactura,
            FAC.MontoConIva AS MontoTotalPagar,
            CR.MontoRegistro AS MontoEjercido,
            CR.InicioEjecucion,
            CR.FinEjecucion,
            INC.NombreInstalacion,
            TM.TipoMonedaCorto AS Moneda,
            TAP.NombreOperacion AS TipoOperacion,
            ES.Nombre AS EstatusCompra,
			CASE WHEN ISNULL(FAC.Serie,'') = '' THEN ISNULL(FAC.Folio,'')
				ELSE ISNULL(FAC.Serie,'') + '-' + ISNULL(FAC.Folio,'') END AS NumeroFactura,
			FAC.Moneda	AS MonedaFactura
     FROM dbo.FI_Factura AS FAC
          LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdFactura = FAC.IdFactura
          LEFT JOIN dbo.TA_Operacion AS TAO ON TAO.IdDocumento = FAC.IdFactura
          LEFT JOIN dbo.MM_Pedidos AS POS ON POS.IdIdentificador = FAC.IdFactura
          LEFT JOIN MM_Pedido AS PO ON PO.IdPedido = POS.IdPedido
          LEFT JOIN dbo.MM_SolicitudPedido AS SOLPED ON SOLPED.IdSolicitudPedido = PO.IdSolicitudPedido
          LEFT JOIN dbo.CO_Registro AS CR ON CR.IdFactura = FAC.IdFactura
          LEFT JOIN dbo.S_Proveedor AS PV ON PV.IdProveedor = FAC.IdSubcontratista
          LEFT JOIN dbo.CO_Instalacion AS INC ON INC.IdInstalacion = CR.IdInstalacion
          LEFT JOIN dbo.CC_CentroCosto AS CC ON CC.IdCentroCosto = CR.CentroCostos
          LEFT JOIN dbo.DG_CuentaContable AS CCG ON CCG.Id = CR.CuentaContable
          LEFT JOIN dbo.CO_CatalogoCuentaSH AS CSH ON CSH.IdCatalogoCuentasSH = CR.IdCatalogoCuentasSH
          LEFT JOIN dbo.TA_TipoOperacion AS TAP ON TAP.IdTipoOperacion = TAO.IdTipoOperacion
          LEFT JOIN dbo.TA_Estatus AS ES ON ES.IdEstatus = TAO.IdEstatusOperacion
          LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = FAC.IdMoneda
          LEFT JOIN Adinco.dbo.CO_Contrato AS ACC ON ACC.IdContrato = FAC.IdContrato
          LEFT JOIN Adinco.dbo.CO_AreaContractual AS AAC ON AAC.IdAreaContractual = ACC.IdAreaContractual
          JOIN Adinco.dbo.CO_Contratista CCC ON CCC.IdContratista = ACC.IdContratista
          JOIN dbo.S_Proveedor PC ON PC.RFC = CCC.RFC COLLATE Modern_Spanish_CI_AS
     WHERE TAO.IdTipoOperacion = 14
           AND POS.IdProveedorCliente IN(606, 690);