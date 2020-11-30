  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- =============================================  
-- Author:  Daniel Cruz  
-- Update date: 23-03-2018  
-- Description: No mostrar aceptaciones de pedido de nacionalidad extranjera ya su proceso no requiere aprobación de carta de contenido nacional  
-- Author:  Daniel Cruz  
-- Update date: 31-05-2018  
-- Description: Actualizar consultas para ocultar aprobaciones de carta de contenido nacional eliminadas con el pedido, aceptacion, o solicitud  de pedido  
-- Author:  Alexander Gomez  
-- Update date: 03-12-2018  
-- Description: Se agregaron los registros de adecuaciones para murphy  
-- Author:  Alexander Gomez  
-- Update date: 25-06-2019  
-- Description: Se modifico el campo de tabla temporal, el campo de NombreUsuarioEntrega para recibir mas de 100 caracteres.  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentas] --670,4  
 -- Add the parameters for the stored procedure here  
@IdProveedor INT,  
@Estatus INT  
AS  
     BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
         SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
 DECLARE @SAPVENDOR NVARCHAR(50) = (SELECT TOP 1 VendorIDSAP   
          FROM Adinco.dbo.CO_SAPVendor AS SV  
          LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS  
          WHERE PR.IdProveedor = @IdProveedor );  
   
 CREATE TABLE #AceptacionesPedido(  
 IdAceptacionPedido INT null,  
 Pedido NVARCHAR(max) null,  
 IdPedido INT null,  
 Creado DATETIME null,  
 NombreUsuarioEntrega NVARCHAR(max) null,  
 Cliente NVARCHAR(max) null,  
 IdPedidoGeneral INT null,  
 IdAceptacionCartaPCN INT null,  
 IdTipoPedido INT null,  
 EstatusAprobacion NVARCHAR(100) NULL,  
 span NVARCHAR(100) NULL  
 );  
  
 IF @Estatus=0  
 BEGIN  
  INSERT INTO #AceptacionesPedido  
        SELECT   
   A.IdAceptacionPedido,  
   CAST(PG.IdPedido AS NVARCHAR(50)) AS Pedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,  
   PG.IdPedido AS IdPedidoGeneral,  
   AC.IdAceptacionCartaPCN,  
   TP.IdTipoPedido,  
   '',  
   CASE  
    WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
    WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
    WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
    WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
   END  
         FROM dbo.MM_Pedido AS P   
   INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras  AND PG.IdTipoPedido in (2,4, 6)
   INNER JOIN MM_AceptacionPedido AS A ON A.IdPedido=P.IdPedido     
   LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
   LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus  
   INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdProveedorCompras   
   LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido  
   INNER JOIN dbo.RelacionCartaCNPedido rel ON rel.IdAceptacionPedido = A.IdAceptacionPedido   
   AND rel.IdPedido = P.IdPedido AND rel.PedirCarta = 1  
         WHERE P.IdSubcontratista = @IdProveedor   
   AND AC.IdAceptacionCartaPCN IS NULL   
   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2--> NACIONALIDAD EXTRANJERA  
   AND ISNULL(A.IdEstatusEliminado,0) <> 1  --> OCULTAR SOLICITUDES DE CARTA DE CONTENIDO NACIONAL DONDE ACEPTACIOND E PEDIDO ESTE ELIMINADO LOGICAMENTE ESTATUS DE ELIMINACION LOGICA =1  
   GROUP BY   
   A.IdAceptacionPedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   PV.RazonSocial,  
   PV.RegimenCapital,  
   PG.IdPedido ,  
   AC.IdAceptacionCartaPCN,  
   TP.IdTipoPedido,  
   TV.IdTipoValidacionDoc  
   ORDER BY A.IdAceptacionPedido DESC;  
     
   INSERT INTO #AceptacionesPedido  
   SELECT   
   A.IdAceptacionPedido,  
   CONCAT('PO Number:', A.IdPedido COLLATE Modern_Spanish_CI_AS,' ','- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS ,' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS) AS Pedido,  
   0 AS IdPedido,  
   A.Creado,  
   CONCAT('Reference Num:', A.ReferenceNumber)  AS NombreUsuarioEntrega,  
   CC.RazonSocial AS Cliente,  
   00 AS IdPedidoGeneral,  
   AC.IdAceptacionCartaPCN,  
   00 AS IdTipoPedido,  
   '',  
   CASE  
    WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
    WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
    WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
    WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
   END  
         FROM dbo.MPY_MM_AceptacionPedido AS A     
   LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
   LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus  
   LEFT JOIN dbo.S_Proveedor AS PV ON PV.RFC = A.IdProveedor AND PV.Activo = 1  
   LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES   
   ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN  
  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL ON PL.Planta = PO.Plant  
   LEFT JOIN Adinco.dbo.CO_Contratista AS CC ON CC.IdContratista = PL.IdContratista  
   WHERE A.IdSubContratista = @SAPVENDOR  
   AND AC.IdAceptacionCartaPCN IS NULL  
   AND PSES.IdEstatus = 2  
   AND EXISTS (SELECT 1 FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD WHERE APD.IdAceptacionPedido = A.IdAceptacionPedido)  
   GROUP BY   
   A.IdAceptacionPedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   PV.RazonSocial,  
   PV.RegimenCapital,  
   A.IdProveedor,  
   AC.IdAceptacionCartaPCN,  
   A.VendorsName,  
   CC.RazonSocial,  
   TV.IdTipoValidacionDoc,  
   A.ReferenceNumber,  
   SES.SESNumber,  
   PSES.IdPRESES  
   ORDER BY A.IdAceptacionPedido DESC  
       END     
  
  
 IF @Estatus IN (1,2,3)  
 BEGIN  
  INSERT INTO #AceptacionesPedido  
  SELECT   
   A.IdAceptacionPedido,  
   CAST(PG.IdPedido AS NVARCHAR(50)) AS Pedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,  
   PG.IdPedido AS IdPedidoGeneral,  
   AC.IdAceptacionCartaPCN,  
   TP.IdTipoPedido,  
   ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
   CASE  
    WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
    WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
    WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
    WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
   END   
         FROM dbo.MM_Pedido AS P   
   INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras  AND PG.IdTipoPedido in (2,4, 6)
   INNER JOIN MM_AceptacionPedido AS A ON A.IdPedido=P.IdPedido     
   LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido   
   LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus  
   INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdProveedorCompras   
   LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido  
   INNER JOIN dbo.RelacionCartaCNPedido rel ON rel.IdAceptacionPedido = A.IdAceptacionPedido   
    AND rel.IdPedido = P.IdPedido AND rel.PedirCarta = 1  
         WHERE P.IdSubcontratista = @IdProveedor  
   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
   AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN  
   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
            FROM dbo.MM_AceptacionCartaPCN A_PCN   
            WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido   
            ORDER BY A_PCN.CreadoEl DESC)        
   ) AND AC.IdEstatus =@Estatus AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA  
   GROUP BY     
   A.IdAceptacionPedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   PV.RazonSocial,  
   PV.RegimenCapital,  
   PG.IdPedido ,  
   AC.IdAceptacionCartaPCN,  
   TV.TipoValidacion,  
   TP.IdTipoPedido,  
   TV.IdTipoValidacionDoc  
   ORDER BY A.IdAceptacionPedido DESC;  
     
   INSERT INTO #AceptacionesPedido  
   SELECT   
   A.IdAceptacionPedido,  
   CONCAT('PO Number:', A.IdPedido COLLATE Modern_Spanish_CI_AS,' ','- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS ,' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS) AS Pedido,  
   00 AS IdPedido,  
   A.Creado,  
    CONCAT('Reference Num:', A.ReferenceNumber)  AS NombreUsuarioEntrega,  
   CC.RazonSocial AS Cliente,  
   00 AS IdPedidoGeneral,  
   AC.IdAceptacionCartaPCN,  
   00 AS IdTipoPedido,  
   ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
   CASE  
    WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
    WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
    WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
    WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
   END  
         FROM dbo.MPY_MM_AceptacionPedido AS A     
   LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
   LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus  
   LEFT JOIN dbo.S_Proveedor AS PV ON PV.RFC = A.IdProveedor AND PV.Activo = 1  
   LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES   
   ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS   
   AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN  
  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO   
  ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL ON PL.Planta = PO.Plant  
   LEFT JOIN Adinco.dbo.CO_Contratista AS CC ON CC.IdContratista = PL.IdContratista  
   WHERE A.IdSubContratista = @SAPVENDOR  
   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
   AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN  
   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
            FROM dbo.MPY_MM_AceptacionCartaPCN A_PCN   
            WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido   
            ORDER BY A_PCN.CreadoEl DESC)        
   ) AND AC.IdEstatus =@Estatus AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA  
   AND PSES.IdEstatus = 2  
   AND EXISTS (SELECT 1 FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD WHERE APD.IdAceptacionPedido = A.IdAceptacionPedido)  
   GROUP BY     
   A.IdAceptacionPedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   PV.RazonSocial,  
   PV.RegimenCapital,  
   A.IdProveedor,  
   AC.IdAceptacionCartaPCN,  
   TV.TipoValidacion,  
   CC.RazonSocial,  
   TV.IdTipoValidacionDoc,  
   A.ReferenceNumber,  
   SES.SESNumber,  
   PSES.IdPRESES  
   ORDER BY A.IdAceptacionPedido DESC  
       END    
  
 IF @Estatus =4  
 BEGIN  
     
  -- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL    
  INSERT INTO #AceptacionesPedido  
  SELECT   
   A.IdAceptacionPedido,  
   CAST(PG.IdPedido AS NVARCHAR(50)) AS Pedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,  
   PG.IdPedido AS IdPedidoGeneral,  
   AC.IdAceptacionCartaPCN,  
   TP.IdTipoPedido,  
   ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
   CASE  
    WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
    WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
    WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
    WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
   END  
         FROM dbo.MM_Pedido AS P   
   INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras  AND PG.IdTipoPedido in (2,4, 6)
   INNER JOIN MM_AceptacionPedido AS A ON A.IdPedido=P.IdPedido     
   LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido AND ISNULL(AC.IdEstatusEliminado,0)<>1  
   LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus  
   INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdProveedorCompras   
   LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido  
   INNER JOIN dbo.RelacionCartaCNPedido rel ON rel.IdAceptacionPedido = A.IdAceptacionPedido   
   AND rel.IdPedido = P.IdPedido AND rel.PedirCarta = 1  
         WHERE P.IdSubcontratista = @IdProveedor  
   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
            FROM dbo.MM_AceptacionCartaPCN A_PCN   
            WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido   
            ORDER BY A_PCN.CreadoEl DESC)   
     OR AC.IdAceptacionCartaPCN IS NULL  
   )   
   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA     
   GROUP BY     
   A.IdAceptacionPedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   PV.RazonSocial,  
   PV.RegimenCapital,  
   PG.IdPedido ,  
   AC.IdAceptacionCartaPCN,  
   TV.TipoValidacion,  
   TP.IdTipoPedido,  
   A.IdEstatusEliminado,  
   TV.IdTipoValidacionDoc  
   ORDER BY A.IdAceptacionPedido DESC  
  
  INSERT INTO #AceptacionesPedido  
   SELECT   
   A.IdAceptacionPedido,  
   CONCAT('PO Number:', A.IdPedido COLLATE Modern_Spanish_CI_AS,' ','- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS ,' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS) AS Pedido,  
   00 AS IdPedido,  
   A.Creado,  
   CONCAT('Reference Num:', A.ReferenceNumber)  AS NombreUsuarioEntrega,  
   CC.RazonSocial AS Cliente,  
   00 AS IdPedidoGeneral,  
   AC.IdAceptacionCartaPCN,  
   00 AS IdTipoPedido,  
   ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
   CASE  
    WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
    WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
    WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
    WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
   END  
         FROM dbo.MPY_MM_AceptacionPedido AS A     
   LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
   LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus  
   LEFT JOIN dbo.S_Proveedor AS PV ON PV.RFC = A.IdProveedor AND PV.Activo = 1  
   LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN  
  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL ON PL.Planta = PO.Plant  
   LEFT JOIN Adinco.dbo.CO_Contratista AS CC ON CC.IdContratista = PL.IdContratista  
         WHERE A.IdSubContratista = @SAPVENDOR  
   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
            FROM dbo.MPY_MM_AceptacionCartaPCN A_PCN   
            WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido   
            ORDER BY A_PCN.CreadoEl DESC)   
     OR AC.IdAceptacionCartaPCN IS NULL  
   )   
   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA   
   AND PSES.IdEstatus = 2    
   AND EXISTS (SELECT 1 FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD WHERE APD.IdAceptacionPedido = A.IdAceptacionPedido)  
   GROUP BY     
   A.IdAceptacionPedido,  
   A.IdPedido,  
   A.Creado,  
   A.NombreUsuarioEntrega,  
   PV.RazonSocial,  
   PV.RegimenCapital,  
   A.IdProveedor,  
   AC.IdAceptacionCartaPCN,  
   TV.TipoValidacion,  
   A.IdEstatusEliminado,  
   CC.RazonSocial,  
   TV.IdTipoValidacionDoc,  
   A.ReferenceNumber,  
   SES.SESNumber,  
   PSES.IdPRESES  
   ORDER BY A.IdAceptacionPedido DESC  
       END    
  
      
  
    SELECT  
  ROW_NUMBER() OVER(ORDER BY Creado DESC) AS IdRow,  
  IdAceptacionPedido,  
  Pedido,  
  IdPedido,  
  Creado,  
  NombreUsuarioEntrega,  
  Cliente,  
  IdPedidoGeneral,  
  IdAceptacionCartaPCN,  
  IdTipoPedido,  
  EstatusAprobacion,  
  span  
    FROM #AceptacionesPedido  
    ORDER BY Creado DESC;  
  END;  
  
  
  