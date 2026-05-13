CREATE VIEW [dbo].[ReporteDePedidos]
AS
     SELECT C.NumeroContrato,
            AC.NombreAreaContractual,
            PC.RazonSocial AS Operadora,
            CASE
                WHEN APD.IdAceptacionPedido IS NULL
                THEN 'Aceptación en Espera'
                ELSE CAST(APD.IdAceptacionPedido AS NVARCHAR(MAX))
            END AS IdAceptacionPedido,
            PG.IdPedido,
            P.IdSolicitudPedido,
            P.CreadoEl AS CreadoEl,
            P.FechaEnvioPedido AS FechaEnvioPedido,
            SUM(PD.Subtotal) AS TotalPedido,
            ISNULL(PV.RazonSocial, '')+' '+ISNULL(PV.RegimenCapital, '') AS Proveedor,
            MA.DescripcionCorta,
            CASE
                WHEN P.RecepcionServicio = 1
                THEN 'Confirmación Aceptada'
                WHEN P.RecepcionServicio = 0
                THEN 'Confirmación Rechazada'
                WHEN P.RecepcionServicio IS NULL
                     AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                     AND O.IdEstatusOperacion = 2
                THEN 'Confirmación Vencida '
                WHEN P.RecepcionServicio IS NULL
                     AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                     AND O.IdEstatusOperacion = 2
                THEN 'En Confirmación'
                ELSE 'Confirmación No Iniciada '
            END AS RecepcionServicio,
            E.Nombre,
            P.Version,
            TM.TipoMonedaCorto AS TipoMoneda,
            PG.IdPedido AS IdPedidoGeneral,
            TP.TipoPedido,
            TP.IdTipoPedido
     FROM MM_Pedido AS P
          INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
          INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
          INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
          INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
          INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
          INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
          INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion = O.IdTipoOperacion
          INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
          INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
          INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
          INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador
                                         AND PG.IdProveedorCliente IN(606, 690)
          LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
          LEFT JOIN dbo.MM_AceptacionPedido AS APD ON APD.IdPedido = P.IdPedido
          LEFT JOIN dbo.MM_Material AS MA ON MA.IdMaterial = PD.IdMaterial
          JOIN dbo.S_Proveedor PC ON O.IdProveedor = PC.IdProveedor
          JOIN Adinco.dbo.CO_Contrato C ON C.IdContrato = P.IdContrato
          JOIN Adinco.dbo.CO_AreaContractual AC ON AC.IdAreaContractual = C.IdAreaContractual
     WHERE O.IdTipoOperacion = 9
           AND O.IdProveedor IN(606, 690)
     AND P.Version = O.NoVersion
     GROUP BY C.NumeroContrato,
              AC.NombreAreaContractual,
              PC.RazonSocial,
              IdAceptacionPedido,
              P.IdPedido,
              P.IdSolicitudPedido,
              P.FechaEnvioPedido,
              PV.RazonSocial,
              PV.RegimenCapital,
              P.RecepcionServicio,
              E.Nombre,
              P.Version,
              TM.TipoMonedaCorto,
              HV.FechaVigencia,
              O.IdEstatusOperacion,
              P.CreadoEl,
              PG.IdPedido,
              TP.TipoPedido,
              TP.IdTipoPedido,
              MA.DescripcionCorta;
