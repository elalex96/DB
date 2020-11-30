
-- =============================================    
-- Author:  <Jose Roman>    
-- Create date: <04-09-2018>    
-- Description: <Se permite capturar una Factura si no se solicita una carta de CN>    
-- =============================================    
-- Author:  <Alexander Gomez>    
-- Create date: <04-12-2018>    
-- Description: <agregado los registros de adecuaciones para murphy>    
-- =============================================    
-- =============================================  
-- Author:           Daniel AC  
-- Create date: 26-09-2019  
-- Description: Agregue columna de UUID para el filtro de todas las facturas  
-- =============================================  
-- =============================================  
-- Author:           Abel Rivera  
-- Create date: 10-12-19  
-- Description: Se consulto la nacionalidad del proveedor, para las aceptaciones que tiene el campo IdNacionalidadProvedor nulo  
-- =============================================  
-- [SP_PR_MM_AceptacionCNFactura] 761,1  
-- SP_PR_MM_AceptacionCNFactura
CREATE PROCEDURE [dbo].[SP_PR_MM_AceptacionCNFactura] --44,4    
    -- Add the parameters for the stored procedure here    
    @IdProveedor INT,  
    @Estatus INT  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from    
    -- interfering with SELECT statements.    
    SET NOCOUNT ON;  
    SET LANGUAGE Español;  
    -- Insert statements for procedure here    
  
  
    DECLARE @SAPVENDOR NVARCHAR(50) =  
            (  
                SELECT TOP 1  
                       VendorIDSAP  
                FROM Adinco.dbo.CO_SAPVendor AS SV  
                    LEFT JOIN dbo.S_Proveedor AS PR  
                        ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS  
                WHERE PR.IdProveedor = @IdProveedor  
                      AND SV.Activo = 1  
            );  
  
 -- consulta la nacionalidad del proveedor  
 DECLARE @IdNacionalidad INT = (SELECT ISNULL(IdNacionalidad,1) FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)  
  
    CREATE TABLE #AceptacionesPedido  
    (  
        IdAceptacionPedido INT NULL,  
        IdPedido INT NULL,  
        FechaAperturaCarga NVARCHAR(50) NULL,  
        Cliente NVARCHAR(100) NULL,  
        EstatusCarga NVARCHAR(100) NULL,  
        IdOperacion INT NULL,  
        IdPedidoGeneral INT NULL,  
        TipoPedido NVARCHAR(100) NULL,  
        Pedido NVARCHAR(MAX) NULL,  
        span NVARCHAR(100) NULL,  
        UUID NVARCHAR(MAX)  
    );  
  
    IF @Estatus = 0  
    BEGIN  
  
        INSERT INTO #AceptacionesPedido  
        SELECT AP.IdAceptacionPedido,  
               AP.IdPedido,  
               CASE  
                   WHEN APC.FechaEvaluacion IS NULL THEN  
                       'Sin carta'  
                   ELSE  
                       CONVERT(VARCHAR(50), APC.FechaEvaluacion, 103)  
               END AS FechaAperturaCarga,  
               CONCAT(PV.RazonSocial, ' ', ISNULL(PV.RegimenCapital, '')) AS Cliente,  
               ISNULL(E.Nombre, 'Sin Iniciar Aprobación') AS EstatusCarga,  
               O.IdOperacion,  
               AP.IdPedido AS IdPedidoGeneral,  
               TP.TipoPedido,  
               PG.IdPedido,  
               CASE  
                   WHEN E.IdEstatus = 2 THEN  
                       'label label-success'  
                   WHEN E.IdEstatus = 1 THEN  
                       'label label-primary'  
                   WHEN E.IdEstatus = 3 THEN  
                       'label label-danger'  
                   WHEN E.IdEstatus IS NULL THEN  
                       'label label-default'  
               END,  
               '' AS UUID  
        FROM dbo.MM_Pedido P  
            INNER JOIN dbo.MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
            INNER JOIN dbo.MM_AceptacionPedido AS AP  
                ON AP.IdPedido = P.IdPedido  
            LEFT JOIN dbo.MM_AceptacionCartaPCN AS APC  
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND (APC.IdAceptacionCartaPCN IS NOT NULL) --Si no se solicita una CN, se muestra una aceptacion de servicio    
            INNER JOIN dbo.S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            LEFT JOIN dbo.MM_AceptacionFactura AS AF  
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 ---> LA ACEPTACIÓN DE FACTURA NO DEBE ESTAR ELIMINADA PARA MOSTRARSE    
            LEFT JOIN dbo.TA_Operacion AS O  
                ON O.IdDocumento = AF.IdAceptacionFactura  
                   AND P.IdSubcontratista = O.IdProveedor  
            LEFT JOIN dbo.TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
            LEFT JOIN dbo.RelacionCartaCNPedido rel  
                ON rel.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND rel.IdPedido = P.IdPedido  
                   AND rel.PedirCarta = 0  
   --LEFT JOIN FI_AceptacionPedido_PedimentoComprobante APCC -- relacion aceptacion/pedimento comprobante  
   --ON APCC.IdAceptacionPedido = AP.IdAceptacionPedido  
        WHERE P.IdSubcontratista = @IdProveedor  
              AND  
              (  
                  APC.IdEstatus = 2  
                  OR rel.PedirCarta = 0  
              )  
              AND O.IdOperacion IS NULL  
              AND  
              (  
                  APC.FechaEvaluacion IS NOT NULL  
                  OR rel.PedirCarta = 0  
              )  
              AND ISNULL(APC.IdEstatusEliminado, 0) <> 1 --> SI LA CARTA CONTENIDO ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA  
     AND ISNULL(AP.IdNacionalidadProveedor,@IdNacionalidad) = 1   
        GROUP BY AP.IdAceptacionPedido,  
                 AP.IdPedido,  
                 PV.RazonSocial,  
                 PV.RegimenCapital,  
                 APC.FechaEvaluacion,  
                 E.Nombre,  
                 O.IdOperacion,  
                 PG.IdPedido,  
                 TP.TipoPedido,  
                 E.IdEstatus  
        ORDER BY AP.IdAceptacionPedido DESC;  
  
  
        INSERT INTO #AceptacionesPedido  
        SELECT AP.IdAceptacionPedido,  
               00,  
               CONVERT(VARCHAR(50), APC.FechaEvaluacion, 103) AS FechaAperturaCarga,  
               ISNULL(CO.RazonSocial, AP.IdProveedor) AS Cliente,  
               'Sin Iniciar Aprobación' AS EstatusCarga,  
               00,  
               00,  
               00,  
               CONCAT(  
                         'PO Number:',  
                         AP.IdPedido COLLATE Modern_Spanish_CI_AS,  
                         ' ',  
                         '- SES Number: ',  
                         SES.SESNumber COLLATE Modern_Spanish_CI_AS,  
                         ' - Proforma Number:',  
                         CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS,  
                         ' - Reference Number:',  
                         AP.ReferenceNumber  
                     ),  
               'label label-default',  
               '' AS UUID  
        FROM dbo.MPY_MM_AceptacionPedido AS AP  
            LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APC  
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.S_Proveedor AS PV  
                ON PV.RFC = AP.IdProveedor  
                   AND PV.Activo = 1  
            LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF  
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 ---> LA ACEPTACIÓN DE FACTURA NO DEBE ESTAR ELIMINADA PARA MOSTRARSE    
            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES  
                ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.IdEstatus = 2 --solo aprobadas  
            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  
                ON SES.PO_SAPNumer = PSES.SAPPONumber  
                   AND SES.SESReferenceNumber = PSES.SAPSESNumber  
                   AND SES.SESNumber = PSES.SESN  
            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  
                ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
            LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL  
                ON PL.Planta = PO.Plant  
            LEFT JOIN Adinco.dbo.CO_Contratista AS CO  
                ON CO.IdContratista = PL.IdContratista  
        WHERE AP.IdSubContratista = @SAPVENDOR  
              AND AF.IdEstatus is null   
              AND APC.IdEstatus = 2  
              AND APC.FechaEvaluacion IS NOT NULL  
              AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> SI LA CARTA CONTENIDO ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA    
        GROUP BY AP.IdAceptacionPedido,  
                 AP.IdPedido,  
                 PV.RazonSocial,  
                 PV.RegimenCapital,  
                 APC.FechaEvaluacion,  
                 AP.IdProveedor,  
                 CO.RazonSocial,  
                 SES.SESNumber,  
                 PSES.IdPRESES,  
                 AP.ReferenceNumber  
        ORDER BY AP.IdAceptacionPedido DESC;  
  
    END;  
  
    IF @Estatus IN ( 1, 2, 3, 10 )  
    BEGIN  
  
        INSERT INTO #AceptacionesPedido  
        SELECT AP.IdAceptacionPedido,  
               AP.IdPedido,  
               CASE  
                   WHEN APC.FechaEvaluacion IS NULL THEN  
                       'Sin carta'  
                   ELSE  
                       CONVERT(VARCHAR(50), APC.FechaEvaluacion, 103)  
               END AS FechaAperturaCarga,  
               CONCAT(PV.RazonSocial, ' ', ISNULL(PV.RegimenCapital, '')) AS Cliente,  
               ISNULL(E.Nombre, 'Sin Iniciar Aprobación') AS EstatusCarga,  
               O.IdOperacion,  
               PG.IdPedido AS IdPedidoGeneral,  
               TP.TipoPedido,  
               PG.IdPedido,  
               CASE  
                   WHEN E.IdEstatus = 2 THEN  
                       'label label-success'  
                   WHEN E.IdEstatus = 1 THEN  
                       'label label-primary'  
                   WHEN E.IdEstatus = 3 THEN  
                       'label label-danger'  
                   WHEN E.IdEstatus IS NULL THEN  
                       'label label-default'  
               END,  
               '' AS UUID  
        FROM dbo.MM_Pedido P  
            INNER JOIN dbo.MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
            INNER JOIN dbo.MM_AceptacionPedido AS AP  
                ON AP.IdPedido = P.IdPedido  
            LEFT JOIN dbo.MM_AceptacionCartaPCN AS APC  
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND (APC.IdAceptacionCartaPCN IS NOT NULL) --Si no se solicita una CN, se muestra una aceptacion de servicio       
            INNER JOIN dbo.MM_AceptacionFactura AS AF  
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
            INNER JOIN dbo.TA_Operacion AS O  
                ON O.IdDocumento = AF.IdAceptacionFactura  
                   AND P.IdSubcontratista = O.IdProveedor  
            INNER JOIN dbo.TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN dbo.S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
            LEFT JOIN dbo.RelacionCartaCNPedido rel  
                ON rel.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND rel.IdPedido = P.IdPedido  
                   AND rel.PedirCarta = 0  
        WHERE P.IdSubcontratista = @IdProveedor  
              AND  
              (  
                  APC.IdEstatus = 2  
                  OR rel.PedirCarta = 0  
              )  
              AND O.IdTipoOperacion = 10  
              AND O.IdEstatusOperacion = @Estatus  
     --CASE WHEN @Estatus = 1 THEN 9 ELSE 1 END )  -- se agrego el estatus 9 para mostrar las facturas sin flujo envidas, en aprobacion  
              AND  
              (  
                  APC.FechaEvaluacion IS NOT NULL  
                  OR rel.PedirCarta = 0  
              )  
              AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> SI LA ACEPTACION DE FACTURA ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA EN FILTRO, SE MUESTRA EN TODAS CON ESTATUS/INACTIVO    
     AND ISNULL(AP.IdNacionalidadProveedor,@IdNacionalidad) = 1  
        GROUP BY AP.IdAceptacionPedido,  
                 AP.IdPedido,  
                 PV.RazonSocial,  
                 PV.RegimenCapital,  
                 APC.FechaEvaluacion,  
                 E.Nombre,  
                 O.IdOperacion,  
                 PG.IdPedido,  
                 TP.TipoPedido,  
                 APC.IdEstatusEliminado,  
                 O.IdDocumento,  
                 AF.IdEstatusEliminado,  
                 E.IdEstatus  
        ORDER BY AP.IdAceptacionPedido DESC;  
  
        INSERT INTO #AceptacionesPedido  
        SELECT AP.IdAceptacionPedido,  
               00,  
               CONVERT(VARCHAR(50), APC.FechaEvaluacion, 103) AS FechaAperturaCarga,  
               ISNULL(CO.RazonSocial, AP.IdProveedor) AS Cliente,  
               ISNULL(TVDF.TipoValidacion, 'Sin Iniciar Aprobación') AS EstatusCarga,  
               00,  
               00,  
               00,  
               CONCAT(  
                         'PO Number:',  
                         AP.IdPedido COLLATE Modern_Spanish_CI_AS,  
                         ' ',  
                         '- SES Number: ',  
                         SES.SESNumber COLLATE Modern_Spanish_CI_AS,  
                         ' - Proforma Number:',  
                         CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS,  
                         ' - Reference Number:',  
                         AP.ReferenceNumber  
                     ),  
               CASE  
                   WHEN TVDF.IdTipoValidacionDoc = 2 THEN  
                       'label label-success'  
                   WHEN TVDF.IdTipoValidacionDoc = 1 THEN  
                       'label label-primary'  
                   WHEN TVDF.IdTipoValidacionDoc = 3 THEN  
                       'label label-danger'  
                   WHEN TVDF.IdTipoValidacionDoc IS NULL THEN  
                       'label label-default'  
               END,  
               '' AS UUID  
        FROM dbo.MPY_MM_AceptacionPedido AS AP  
            LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APC  
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF  
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.S_TipoValidacionDoc AS TVDF  
                ON TVDF.IdTipoValidacionDoc = AF.IdEstatusXML  
            LEFT JOIN dbo.S_Proveedor AS PV  
                ON PV.RFC = AP.IdProveedor  
                   AND PV.Activo = 1  
            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES  
                ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.IdEstatus = 2 --solo aprobadas  
            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  
                ON SES.PO_SAPNumer = PSES.SAPPONumber  
                   AND SES.SESReferenceNumber = PSES.SAPSESNumber  
                   AND SES.SESNumber = PSES.SESN  
            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  
                ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
            LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL  
                ON PL.Planta = PO.Plant  
            LEFT JOIN Adinco.dbo.CO_Contratista AS CO  
                ON CO.IdContratista = PL.IdContratista  
        WHERE AP.IdSubContratista = @SAPVENDOR  
              AND AF.IdEstatus = @Estatus  
              AND APC.IdEstatus = 2  
              AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> SI LA ACEPTACION DE FACTURA ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA EN FILTRO, SE MUESTRA EN TODAS CON ESTATUS/INACTIVO    
  
        GROUP BY AP.IdAceptacionPedido,  
                 AP.IdPedido,  
                 PV.RazonSocial,  
                 PV.RegimenCapital,  
                 APC.FechaEvaluacion,  
                 APC.IdEstatusEliminado,  
                 AF.IdEstatusEliminado,  
                 AF.IdAceptacionFactura,  
                 TVDF.TipoValidacion,  
                 AP.IdProveedor,  
                 CO.RazonSocial,  
                 TVDF.IdTipoValidacionDoc,  
                 SES.SESNumber,  
                 PSES.IdPRESES,  
                 AP.ReferenceNumber  
        ORDER BY AP.IdAceptacionPedido DESC  
  
    END;  
    ---APC.IdEstatus=2 EStatus Aprobado     
  
    IF @Estatus = 4 ---Todas las aceptaciones que requieren de una factura y estatus de aprobación    
    BEGIN  
  
  
        INSERT INTO #AceptacionesPedido  
        SELECT AP.IdAceptacionPedido,  
               AP.IdPedido,  
               CASE  
                   WHEN APC.FechaEvaluacion IS NULL THEN  
                       'Sin carta'  
                   ELSE  
                       CONVERT(VARCHAR(50), APC.FechaEvaluacion, 103)  
               END AS FechaAperturaCarga,  
               CONCAT(PV.RazonSocial, ' ', ISNULL(PV.RegimenCapital, '')) AS Cliente,  
               ISNULL(E.Nombre, 'Sin Iniciar Aprobación') AS EstatusCarga,  
               O.IdOperacion,  
               PG.IdPedido AS IdPedidoGeneral,  
               TP.TipoPedido,  
               PG.IdPedido,  
               CASE  
                   WHEN E.IdEstatus = 2 THEN  
                       'label label-success'  
                   WHEN E.IdEstatus = 1 THEN  
                       'label label-primary'  
                   WHEN E.IdEstatus = 3 THEN  
                       'label label-danger'  
                   WHEN E.IdEstatus IS NULL THEN  
                       'label label-default'  
               END,  
               F.UUID  
        FROM dbo.MM_Pedido P  
            INNER JOIN dbo.MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
            INNER JOIN dbo.MM_AceptacionPedido AS AP  
                ON AP.IdPedido = P.IdPedido  
            LEFT JOIN dbo.MM_AceptacionCartaPCN AS APC  
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND (APC.IdAceptacionCartaPCN IS NOT NULL) --Si no se solicita una CN, se muestra una aceptacion de servicio     
                   AND ISNULL(APC.IdEstatusEliminado, 0) <> 1 --> Que no esten eliminadas     
            INNER JOIN dbo.S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            LEFT JOIN dbo.MM_AceptacionFactura AS AF  
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> Que no esten eliminadas     
            LEFT JOIN dbo.TA_Operacion AS O  
                ON O.IdDocumento = AF.IdAceptacionFactura  
                   AND P.IdSubcontratista = O.IdProveedor  
            LEFT JOIN dbo.TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            LEFT JOIN dbo.FI_Factura F  
                ON F.IdFactura = AF.IdFactura  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
            LEFT JOIN dbo.RelacionCartaCNPedido rel  
                ON rel.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND rel.IdPedido = P.IdPedido  
                   AND rel.PedirCarta = 0  
        WHERE P.IdSubcontratista = @IdProveedor  
              AND  
              (  
                  APC.IdEstatus = 2  
                  OR rel.PedirCarta = 0  
              )  
              AND  
              (  
                  O.IdOperacion IS NULL  
                  OR O.IdTipoOperacion = 10  
              )  
              AND  
              (  
                  APC.FechaEvaluacion IS NOT NULL  
                  OR rel.PedirCarta = 0  
              )  
     AND ISNULL(AP.IdNacionalidadProveedor,@IdNacionalidad) = 1  
        GROUP BY AP.IdAceptacionPedido,  
                 AP.IdPedido,  
                 PV.RazonSocial,  
                 PV.RegimenCapital,  
                 APC.FechaEvaluacion,  
                 E.Nombre,  
                 O.IdOperacion,  
                 PG.IdPedido,  
                 TP.TipoPedido,  
                 APC.IdEstatusEliminado,  
                 O.IdDocumento,  
                 AF.IdEstatusEliminado,  
                 E.IdEstatus,  
                 F.UUID  
        ORDER BY AP.IdAceptacionPedido DESC;  
  
        INSERT INTO #AceptacionesPedido  
        SELECT AP.IdAceptacionPedido,  
               00,  
               CONVERT(VARCHAR(50), APC.FechaEvaluacion, 103) AS FechaAperturaCarga,  
               ISNULL(CO.RazonSocial, AP.IdProveedor) AS Cliente,  
               ISNULL(TVDF.TipoValidacion, 'Sin Iniciar Aprobación') AS EstatusCarga,  
               00,  
               00,  
               00,  
               CONCAT(  
                         'PO Number:',  
                         AP.IdPedido COLLATE Modern_Spanish_CI_AS,  
                         ' ',  
                         '- SES Number: ',  
                         SES.SESNumber COLLATE Modern_Spanish_CI_AS,  
                         ' - Proforma Number:',  
                         CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS,  
                         ' - Reference Number:',  
                         AP.ReferenceNumber  
                     ),  
               CASE  
                   WHEN TVDF.IdTipoValidacionDoc = 2 THEN  
                       'label label-success'  
                   WHEN TVDF.IdTipoValidacionDoc = 1 THEN  
                       'label label-primary'  
                   WHEN TVDF.IdTipoValidacionDoc = 3 THEN  
                       'label label-danger'  
                   WHEN TVDF.IdTipoValidacionDoc IS NULL THEN  
                       'label label-default'  
               END,  
               F.UUID  
        FROM dbo.MPY_MM_AceptacionPedido AS AP  
            LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APC  
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF  
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.S_TipoValidacionDoc AS TVDF  
                ON TVDF.IdTipoValidacionDoc = AF.IdEstatusXML  
            LEFT JOIN dbo.FI_Factura F  
                ON F.IdFactura = AF.IdFactura  
            LEFT JOIN dbo.S_Proveedor AS PV  
                ON PV.RFC = AP.IdProveedor  
                   AND PV.Activo = 1  
            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES  
                ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.IdEstatus = 2 --solo aprobadas  
            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  
                ON SES.PO_SAPNumer = PSES.SAPPONumber  
                   AND SES.SESReferenceNumber = PSES.SAPSESNumber  
                   AND SES.SESNumber = PSES.SESN  
            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  
                ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL  
                ON PL.Planta = PO.Plant  
            LEFT JOIN Adinco.dbo.CO_Contratista AS CO  
                ON CO.IdContratista = PL.IdContratista  
        WHERE AP.IdSubContratista = @SAPVENDOR  
              AND APC.IdEstatus = 2  
              AND APC.FechaEvaluacion IS NOT NULL  
              AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> SI LA ACEPTACION DE FACTURA ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA EN FILTRO, SE MUESTRA EN TODAS CON ESTATUS/INACTIVO    
        GROUP BY AP.IdAceptacionPedido,  
                 AP.IdPedido,  
                 PV.RazonSocial,  
                 PV.RegimenCapital,  
                 APC.FechaEvaluacion,  
                 APC.IdEstatusEliminado,  
                 TVDF.TipoValidacion,  
                 AF.IdAceptacionFactura,  
                 AP.IdProveedor,  
                 CO.RazonSocial,  
                 TVDF.IdTipoValidacionDoc,  
                 SES.SESNumber,  
                 PSES.IdPRESES,  
                 AP.ReferenceNumber,  
                 F.UUID  
        ORDER BY AP.IdAceptacionPedido DESC;  
  
  
    END;  
  
    SELECT ROW_NUMBER() OVER (ORDER BY FechaAperturaCarga DESC) AS IdRow,  
           IdAceptacionPedido,  
           IdPedido,  
           FechaAperturaCarga,  
           Cliente,  
           EstatusCarga,  
           IdOperacion,  
           IdPedidoGeneral,  
           TipoPedido,  
           Pedido,  
           span,  
           UUID  
    FROM #AceptacionesPedido  
 GROUP BY IdAceptacionPedido,  
             IdPedido,  
             FechaAperturaCarga,  
             Cliente,  
             EstatusCarga,  
             IdOperacion,  
             IdPedidoGeneral,  
             TipoPedido,  
             Pedido,  
             span,  
             UUID  
    ORDER BY IdAceptacionPedido DESC;  
  
END;  
  
  