-- =============================================  
-- Modificacion:Alexander Gomez  
-- Update date: 25-01-2019  
-- Description: Se agregan los pedidos de murphy por contrato  
-- =============================================  
-- =============================================  
-- Modificacion:Daniel AC  
-- Update date: 17/12/2019  
-- Description: Agregue validación para que solo se oculten las aprobaciones de tipo serial donde el aprobador 
-- anterior no ha aprobado su tarea y mostrar si se solicito carta de contenido nacional 
-- =============================================  
create PROCEDURE [dbo].[SP_PR_MM_ListaFacturasAprobacion_old ] @IdProveedor   INT, 
                                                         @Estatus       INT, 
                                                         @IdContrato    INT      = NULL, 
                                                         @IdUsuario     INT      = NULL, 
                                                         @FechaRegistro DATETIME = NULL
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @IDCONTRATO2 INT=
        (
            SELECT TOP 1 C.IdContrato
            FROM Adinco.dbo.CO_Contrato AS C
                 LEFT JOIN Adinco.dbo.CO_Contratista AS CON ON CON.IdContratista = C.IdContratista
                 LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
            WHERE PR.IdProveedor = @IdProveedor
        );
        DECLARE @PLANT NVARCHAR(10)=
        (
            SELECT TOP 1 P.Planta
            FROM Adinco.dbo.CO_Contrato AS C
                 LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS P ON P.IdContratista = C.IdContratista
            WHERE C.IdContrato = @IDCONTRATO2
        );

        --IF(ISNULL(@IdContrato,0) = 0)  
        --BEGIN  
        -- SET @IdContrato = 10039;  
        --END  

        DECLARE @PROVEDORRFC NVARCHAR(20)=
        (
            SELECT RFC
            FROM dbo.S_Proveedor
            WHERE IdProveedor = @IdProveedor
        );
        DECLARE @IDCONTRATISTA NVARCHAR(50)=
        (
            SELECT IdContratista
            FROM Adinco.dbo.CO_Contratista
            WHERE RFC = @PROVEDORRFC
        );
        DECLARE @FlujoSerial TABLE
        (IdOperacion INT, 
         NoSecuencia INT
        );
        DECLARE @OperacionNoAprobadas TABLE(IdOperacion INT);
        INSERT INTO @FlujoSerial
        (IdOperacion, 
         NoSecuencia
        )
               SELECT O.IdOperacion, 
                      t.NoSecuencia
               FROM dbo.TA_Operacion O
                    INNER JOIN dbo.MM_AceptacionFactura af ON af.IdAceptacionFactura = o.IdDocumento
                    INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                    INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                    INNER JOIN dbo.TA_Tarea t ON t.IdOperacion = O.IdOperacion
                    INNER JOIN dbo.TA_FlujoTarea FT ON FT.IdFlujoTarea = O.IdFlujoTarea
               WHERE O.IdTipoOperacion = 10
                     AND ISNULL(O.IdEstatusEliminado, 0) <> 1
                     AND t.IdAprobador = @IdUsuario
                     AND t.NoSecuencia > 1
                     AND t.Activo = 1
                     AND FT.IdTipoFlujo = 1 ---> SOLO DEBE APLICAR PARA LAS APROBACIONES SERIALES      
                     AND PE.IdProveedorCompras = @IdProveedor;
        INSERT INTO @OperacionNoAprobadas(IdOperacion)
               SELECT O.IdOperacion
               FROM dbo.TA_Operacion O
                    INNER JOIN @FlujoSerial f ON f.IdOperacion = O.IdOperacion
                    INNER JOIN dbo.TA_Tarea T ON T.IdOperacion = O.IdOperacion
                                                 AND T.NoSecuencia = (f.NoSecuencia - 1)
               WHERE O.IdTipoOperacion = 10
                     AND T.Activo = 1
                     AND T.IdEstatus <> 2;
        CREATE TABLE #AceptacionesPedido
        (IdAceptacionPedido INT NULL, 
         Pedido             NVARCHAR(MAX) NULL, 
         IdPedido           INT NULL, 
         FechaRegistro      DATETIME NULL, 
         Proveedor          NVARCHAR(100) NULL, 
         Nombre             NVARCHAR(100) NULL, 
         IdPedidoGeneral    INT NULL, 
         TipoPedido         NVARCHAR(MAX) NULL, 
         TotalPedido        MONEY NULL, 
         Moneda             NVARCHAR(100) NULL, 
         RFC                NVARCHAR(100) NULL, 
         IdSolicitudPedido  NVARCHAR(100) NULL, 
         span               NVARCHAR(100) NULL, 
         IdOperacion        INT NULL, 
         PedirCarta         BIT
        );
        IF @Estatus IN(1, 2, 3)
            BEGIN
                INSERT INTO #AceptacionesPedido
                       SELECT AF.IdAceptacionPedido, 
                              PG.IdPedido, 
                              Pe.IdPedido, 
                              O.FechaRegistro, 
                              PR.RazonSocial + ' ' + ISNULL(Pr.RegimenCapital, '') AS Proveedor, 
                              E.Nombre, 
                              PG.IdPedido AS IdPedidoGeneral, 
                              TP.TipoPedido, 
                              SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido, 
                              TM.TipoMonedaCorto AS Moneda, 
                              'RFC: ' + ISNULL(PR.RFC, 'SIN DATOS') + ' - UUID:' + ISNULL(fi.UUID, 'SIN DATOS'), 
                              PE.IdSolicitudPedido,
                              CASE
                                  WHEN E.IdEstatus = 2
                                  THEN 'label label-success'
                                  WHEN E.IdEstatus = 1
                                  THEN 'label label-primary'
                                  WHEN E.IdEstatus = 3
                                  THEN 'label label-danger'
                                  WHEN E.IdEstatus IS NULL
                                  THEN 'label label-default'
                              END, 
                              0, 
                              RC.PedirCarta
                       FROM MM_AceptacionFactura AS AF
                            INNER JOIN TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura --AND O.IdProveedor = @IdProveedor  
                            INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                            INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                            INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                                                          AND PE.IdSubcontratista = O.IdProveedor
                            INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
                            INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                                AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                            INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador
                                                           AND PG.IdProveedorCliente = @IdProveedor
                            INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
                            INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PE.IdMoneda
                            LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                            LEFT JOIN dbo.FI_Factura AS fi ON fi.IdFactura = AF.IdFactura
                            INNER JOIN dbo.TA_Tarea TA ON TA.IdOperacion = O.IdOperacion
                            LEFT JOIN dbo.RelacionCartaCNPedido RC ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
                       WHERE O.IdTipoOperacion = 10
                             AND TA.Activo = 1
                             AND PE.IdProveedorCompras = @IdProveedor
                             AND O.IdEstatusOperacion = @Estatus
                             AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                             AND O.IdOperacion NOT IN
                       (
                           SELECT IdOperacion
                           FROM @OperacionNoAprobadas
                       )  
                       ---AND TA.IdAprobador IN (@IdUsuario) ---> FILTRO POR USUARIO  
                       GROUP BY AF.IdAceptacionPedido, 
                                Pe.IdPedido, 
                                O.FechaRegistro, 
                                PR.RazonSocial, 
                                Pr.RegimenCapital, 
                                E.Nombre, 
                                PG.IdPedido, 
                                TP.TipoPedido, 
                                TM.TipoMonedaCorto, 
                                PR.RFC, 
                                PE.IdSolicitudPedido, 
                                E.IdEstatus, 
                                fi.UUID, 
                                RC.PedirCarta
                       ORDER BY AF.IdAceptacionPedido DESC;
                INSERT INTO #AceptacionesPedido
                       SELECT AF.IdAceptacionPedido, 
                              CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS), 
                              00, 
                              AF.CreadoEl, 
                              ISNULL(SV.VendorName, AP.IdSubContratista) AS Proveedor, 
                              E.Nombre, 
                              00, 
                              00,
                              CASE
                                  WHEN F.IdMoneda = 1
                                  THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
                                  ELSE F.SubTotal
                              END AS TotalPedido, 
                              APD.IdMoneda, 
                              SV.TaxID AS RFC, 
                              CONCAT('Reference Num:', AP.ReferenceNumber),
                              CASE
                                  WHEN E.IdEstatus = 2
                                  THEN 'label label-success'
                                  WHEN E.IdEstatus = 1
                                  THEN 'label label-primary'
                                  WHEN E.IdEstatus = 3
                                  THEN 'label label-danger'
                                  WHEN E.IdEstatus IS NULL
                                  THEN 'label label-default'
                              END, 
                              0, 
                              RC.PedirCarta
                       FROM MPY_MM_AceptacionFactura AS AF
                            LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus
                            LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                            LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                            LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista
                                                           AND PR.Activo = 1
                            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                         AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                                     AND SES.SESReferenceNumber = PSES.SAPSESNumber
                                                                     AND SES.SESNumber = PSES.SESN
                            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = AF.IdFactura
                            LEFT JOIN dbo.RelacionCartaCNPedido RC ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
                       WHERE --AP.IdProveedor = @IDCONTRATISTA  
                       AF.IdEstatus = @Estatus
                       AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                       AND PO.Plant = @PLANT
                       AND AF.IdEstatusXML != 4
                       AND AF.IdEstatusXML != 4
                       GROUP BY AF.IdAceptacionPedido, 
                                AP.IdPedido, 
                                AF.CreadoEl, 
                                PR.RazonSocial, 
                                Pr.RegimenCapital, 
                                E.Nombre, 
                                AP.IdSubContratista, 
                                PR.RFC, 
                                APD.IdMoneda, 
                                SV.TaxID, 
                                SV.VendorName, 
                                E.IdEstatus, 
                                SES.SESNumber, 
                                AP.ReferenceNumber, 
                                PSES.IdPRESES, 
                                F.SubTotal, 
                                F.IdMoneda, 
                                F.FechaTimbrado, 
                                RC.PedirCarta
                       ORDER BY AF.IdAceptacionPedido DESC;
        END;
        IF @Estatus = 0  --TODAS  
            BEGIN
                INSERT INTO #AceptacionesPedido
                       SELECT AF.IdAceptacionPedido, 
                              PG.IdPedido, 
                              Pe.IdPedido, 
                              O.FechaRegistro, 
                              PR.RazonSocial + ' ' + ISNULL(Pr.RegimenCapital, '') AS Proveedor, 
                              E.Nombre, 
                              PG.IdPedido AS IdPedidoGeneral, 
                              TP.TipoPedido, 
                              SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido, 
                              TM.TipoMonedaCorto AS Moneda, 
                              'RFC: ' + ISNULL(PR.RFC, 'SIN DATOS') + ' - UUID:' + ISNULL(fi.UUID, 'SIN DATOS'), 
                              PE.IdSolicitudPedido,
                              CASE
                                  WHEN E.IdEstatus = 2
                                  THEN 'label label-success'
                                  WHEN E.IdEstatus = 1
                                  THEN 'label label-primary'
                                  WHEN E.IdEstatus = 3
                                  THEN 'label label-danger'
                                  WHEN E.IdEstatus IS NULL
                                  THEN 'label label-default'
                              END, 
                              0, 
                              RC.PedirCarta
                       FROM MM_AceptacionFactura AS AF
                            INNER JOIN TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura  --AND O.IdProveedor = @IdProveedor   
                            INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                            INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                            INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                            INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                                                          AND PE.IdSubcontratista = O.IdProveedor
                            INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
                                                                  AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                            INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador
                                                           AND PG.IdProveedorCliente = @IdProveedor
                            INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
                            INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PE.IdMoneda
                            LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                            LEFT JOIN dbo.FI_Factura AS fi ON fi.IdFactura = AF.IdFactura
                            LEFT JOIN dbo.RelacionCartaCNPedido RC ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
                       WHERE O.IdTipoOperacion = 10
                             AND PE.IdProveedorCompras = @IdProveedor
                             AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                             AND O.IdOperacion NOT IN
                       (
                           SELECT IdOperacion
                           FROM @OperacionNoAprobadas
                       )
                             AND ISNULL(O.IdFlujoTarea, 0) <> 0 -- excluimos las facturas sin flujo de aprobación  
                       GROUP BY AF.IdAceptacionPedido, 
                                Pe.IdPedido, 
                                O.FechaRegistro, 
                                PR.RazonSocial, 
                                Pr.RegimenCapital, 
                                E.Nombre, 
                                PG.IdPedido, 
                                TP.TipoPedido, 
                                TM.TipoMonedaCorto, 
                                PR.RFC, 
                                AF.IdEstatusEliminado, 
                                PE.IdSolicitudPedido, 
                                E.IdEstatus, 
                                fi.UUID, 
                                RC.PedirCarta
                       ORDER BY AF.IdAceptacionPedido DESC;
                INSERT INTO #AceptacionesPedido
                       SELECT AF.IdAceptacionPedido, 
                              CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS), 
                              00, 
                              AF.CreadoEl, 
                              ISNULL(SV.VendorName, PR.RazonSocial) AS Proveedor, 
                              E.Nombre, 
                              00, 
                              00,
                              CASE
                                  WHEN F.IdMoneda = 1
                                  THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
                                  ELSE F.SubTotal
                              END AS TotalPedido, 
                              APD.IdMoneda, 
                              SV.TaxID AS RFC, 
                              CONCAT('Reference Num:', AP.ReferenceNumber),
                              CASE
                                  WHEN E.IdEstatus = 2
                                  THEN 'label label-success'
                                  WHEN E.IdEstatus = 1
                                  THEN 'label label-primary'
                                  WHEN E.IdEstatus = 3
                                  THEN 'label label-danger'
                                  WHEN E.IdEstatus IS NULL
                                  THEN 'label label-default'
                              END, 
                              0, 
                              RC.PedirCarta
                       FROM MPY_MM_AceptacionFactura AS AF
                            LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus
                            LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                            LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                            LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN ON APCN.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                               AND APCN.IdEstatus = 2
                            LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista
                                                           AND PR.Activo = 1
                            LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                         AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                                     AND SES.SESReferenceNumber = PSES.SAPSESNumber
                                                                     AND SES.SESNumber = PSES.SESN
                            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = AF.IdFactura
                            LEFT JOIN dbo.RelacionCartaCNPedido RC ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
                       WHERE --AP.IdContrato = @IdContrato  
                       --APCN.IdAceptacionCartaPCN IS NOT NULL  
                       ISNULL(AF.IdEstatusEliminado, 0) <> 1
                       AND PO.Plant = @PLANT
                       AND AF.IdEstatusXML != 4
                       AND AF.IdEstatusXML != 4
                       GROUP BY AF.IdAceptacionPedido, 
                                AP.IdPedido, 
                                PR.RazonSocial, 
                                Pr.RegimenCapital, 
                                E.Nombre, 
                                PR.RFC, 
                                AP.IdSubContratista, 
                                AF.IdEstatusEliminado, 
                                AF.CreadoEl, 
                                SV.VendorName, 
                                APD.IdMoneda, 
                                SV.TaxID, 
                                E.IdEstatus, 
                                SES.SESNumber, 
                                AP.ReferenceNumber, 
                                PSES.IdPRESES, 
                                F.SubTotal, 
                                F.IdMoneda, 
                                F.FechaTimbrado, 
                                F.FechaTimbrado, 
                                RC.PedirCarta
                       ORDER BY AF.IdAceptacionPedido DESC;
        END;
        IF @Estatus = 9 -- Facturas enviadas sin flujo de aprobación  
            BEGIN
                INSERT INTO #AceptacionesPedido
                       SELECT AF.IdAceptacionPedido, 
                              PG.IdPedido, 
                              Pe.IdPedido, 
                              O.FechaRegistro, 
                              PR.RazonSocial + ' ' + ISNULL(Pr.RegimenCapital, '') AS Proveedor, 
                              E.Nombre, 
                              PG.IdPedido AS IdPedidoGeneral, 
                              TP.TipoPedido, 
                              SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido, 
                              TM.TipoMonedaCorto AS Moneda, 
                              'RFC: ' + ISNULL(PR.RFC, 'SIN DATOS') + ' - UUID:' + ISNULL(fi.UUID, 'SIN DATOS'), 
                              PE.IdSolicitudPedido,
                              CASE
                                  WHEN E.IdEstatus = 2
                                  THEN 'label label-success'
                                  WHEN E.IdEstatus = 1
                                  THEN 'label label-primary'
                                  WHEN E.IdEstatus = 3
                                  THEN 'label label-danger'
                                  WHEN E.IdEstatus IS NULL
                                  THEN 'label label-default'
                              END, 
                              O.IdOperacion, 
                              RC.PedirCarta
                       FROM MM_AceptacionFactura AS AF
                            INNER JOIN TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura --AND O.IdProveedor = @IdProveedor  
                            INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                            INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                            INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                                                          AND PE.IdSubcontratista = O.IdProveedor
                            INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
                            INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                                AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                            INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador
                            INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
                            INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PE.IdMoneda
                            LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                            LEFT JOIN dbo.FI_Factura AS fi ON fi.IdFactura = AF.IdFactura
                            LEFT JOIN dbo.RelacionCartaCNPedido RC ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
                       --INNER JOIN dbo.TA_Tarea TA ON TA.IdOperacion=O.IdOperacion     
                       WHERE O.IdTipoOperacion = 10   
                             --AND TA.Activo=1  
                             AND PG.IdProveedorCliente = @IdProveedor
                             AND PE.IdProveedorCompras = @IdProveedor
                             AND O.IdEstatusOperacion = @Estatus
                             AND ISNULL(AF.IdEstatusEliminado, 0) <> 1  
                             --AND O.IdOperacion NOT IN (SELECT IdOperacion FROM @OperacionNoAprobadas)  
                             AND ISNULL(o.IdFlujoTarea, 0) = 0
                             AND ISNULL(o.IdEstadoFlujo, 0) = 0  
                       ---AND TA.IdAprobador IN (@IdUsuario) ---> FILTRO POR USUARIO  
                       GROUP BY AF.IdAceptacionPedido, 
                                Pe.IdPedido, 
                                O.FechaRegistro, 
                                PR.RazonSocial, 
                                Pr.RegimenCapital, 
                                E.Nombre, 
                                PG.IdPedido, 
                                TP.TipoPedido, 
                                TM.TipoMonedaCorto, 
                                PR.RFC, 
                                PE.IdSolicitudPedido, 
                                E.IdEstatus, 
                                fi.UUID, 
                                O.IdOperacion, 
                                RC.PedirCarta
                       ORDER BY AF.IdAceptacionPedido DESC;
                INSERT INTO #AceptacionesPedido
                       SELECT AF.IdAceptacionPedido, 
                              CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS), 
                              00, 
                              AF.CreadoEl, 
                              ISNULL(SV.VendorName, AP.IdSubContratista) AS Proveedor, 
                              E.Nombre, 
                              00, 
                              00,
                              CASE
                                  WHEN F.IdMoneda = 1
                                  THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
                                  ELSE F.SubTotal
                              END AS TotalPedido, 
                              APD.IdMoneda, 
                              SV.TaxID AS RFC, 
                              CONCAT('Reference Num:', AP.ReferenceNumber),
                              CASE
                                  WHEN E.IdEstatus = 2
                                  THEN 'label label-success'
                                  WHEN E.IdEstatus = 1
                                  THEN 'label label-primary'
                                  WHEN E.IdEstatus = 3
                                  THEN 'label label-danger'
                                  WHEN E.IdEstatus IS NULL
                                  THEN 'label label-default'
                              END, 
                              0, 
                              RC.PedirCarta
                       FROM MPY_MM_AceptacionFactura AS AF
                            LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus
                            LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                            LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                            LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista
                                                           AND PR.Activo = 1
                            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                         AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                                     AND SES.SESReferenceNumber = PSES.SAPSESNumber
                                                                     AND SES.SESNumber = PSES.SESN
                            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                            LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = AF.IdFactura
                            LEFT JOIN dbo.RelacionCartaCNPedido RC ON RC.IdAceptacionPedido = AP.IdAceptacionPedido
                       WHERE --AP.IdProveedor = @IDCONTRATISTA  
                       AF.IdEstatus = @Estatus
                       AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                       AND PO.Plant = @PLANT
                       AND AF.IdEstatusXML != 4
                       AND AF.IdEstatusXML != 4
                       GROUP BY AF.IdAceptacionPedido, 
                                AP.IdPedido, 
                                AF.CreadoEl, 
                                PR.RazonSocial, 
                                Pr.RegimenCapital, 
                                E.Nombre, 
                                AP.IdSubContratista, 
                                PR.RFC, 
                                APD.IdMoneda, 
                                SV.TaxID, 
                                SV.VendorName, 
                                E.IdEstatus, 
                                SES.SESNumber, 
                                AP.ReferenceNumber, 
                                PSES.IdPRESES, 
                                F.SubTotal, 
                                F.IdMoneda, 
                                F.FechaTimbrado, 
                                RC.PedirCarta
                       ORDER BY AF.IdAceptacionPedido DESC;
        END;
        SELECT ROW_NUMBER() OVER(
               ORDER BY FechaRegistro DESC) AS IdRow, 
               IdAceptacionPedido, 
               Pedido, 
               IdPedido, 
               FechaRegistro, 
               Proveedor, 
               Nombre, 
               IdPedidoGeneral, 
               TipoPedido, 
               TotalPedido, 
               Moneda, 
               RFC, 
               IdSolicitudPedido, 
               span, 
               IdOperacion,
               CASE
                   WHEN ISNULL(PedirCarta, 0) = 1
                   THEN 'Si'
                   ELSE 'No'
               END AS PedirCarta
        FROM #AceptacionesPedido
        GROUP BY IdAceptacionPedido, 
                 Pedido, 
                 IdPedido, 
                 FechaRegistro, 
                 Proveedor, 
                 Nombre, 
                 IdPedidoGeneral, 
                 TipoPedido, 
                 TotalPedido, 
                 Moneda, 
                 RFC, 
                 IdSolicitudPedido, 
                 span, 
                 IdOperacion, 
                 PedirCarta
        ORDER BY FechaRegistro DESC;
    END;