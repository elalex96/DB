USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_PR_MM_AceptacionPedidoProveedorVentas') IS NOT NULL
BEGIN
DROP PROCEDURE SP_PR_MM_AceptacionPedidoProveedorVentas;
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- =============================================  
-- Author:  Daniel Cruz  
-- Update date: 31-05-2018  
-- Description: Actualizar consultas para ocultar aprobaciones de carta de contenido nacional eliminadas con el pedido, aceptacion, o solicitud  de pedido  
-- Author:  Alexander Gomez  
-- Update date: 03-12-2018  
-- Description: Se agregaron los registros de adecuaciones para murphy  
-- Author:  Daniel Cruz  
-- Update date: 31-05-2018  
-- Description: Se agrega consumo de sp que trae las cartas solicitadas para aprobadores extranjeros
-- =============================================  
-- Author:  Alexander Gomez 
-- Update date: 13-11-2025  
-- Description: se agrega filtro de fechas y todos los registros
-- =============================================  
CREATE PROCEDURE [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentas]   
 -- Add the parameters for the stored procedure here  
	@IdProveedor	INT,  
	@Estatus		INT,
	@FechaInicio	DATETIME = NULL,
	@FechaFin		DATETIME = NULL,
	@Todos			BIT = 0
AS  
     BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
    SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
	DECLARE @SAPVENDOR NVARCHAR(50) = (SELECT TOP 1 VendorIDSAP   
										FROM		Adinco.dbo.CO_SAPVendor SV  
										LEFT JOIN	dbo.S_Proveedor			PR 
											ON		SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS = PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS  
										WHERE		PR.IdProveedor	=	@IdProveedor 
										);  
   
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
	   JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND P.IdProveedorCompras = PG.IdProveedorCliente 
			AND PG.IdTipoPedido in (2,4, 6) --> CTE PEDIDOS 
	   JOIN MM_AceptacionPedido AS A 
			ON P.IdPedido = A.IdPedido    
	   JOIN S_Proveedor AS PV 
			ON P.IdProveedorCompras = PV.IdProveedor
		JOIN dbo.RelacionCartaCNPedido rel 
			ON A.IdAceptacionPedido = rel.IdAceptacionPedido   
			AND P.IdPedido = rel.IdPedido
			AND rel.PedirCarta = 1  --> CTE
	   LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido  = AC.IdAceptacionPedido  
			AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
	   LEFT JOIN dbo.S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus  = TV.IdTipoValidacionDoc     
	   LEFT  JOIN dbo.MM_TipoPedido AS TP 
			ON PG.IdTipoPedido   = TP.IdTipoPedido   
	   WHERE P.IdSubcontratista = @IdProveedor   
	   AND AC.IdAceptacionCartaPCN IS NULL   
	   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2--> NACIONALIDAD EXTRANJERA  
	   AND ISNULL(A.IdEstatusEliminado,0) <> 1  --> OCULTAR SOLICITUDES DE CARTA DE CONTENIDO NACIONAL DONDE ACEPTACIOND E PEDIDO ESTE ELIMINADO LOGICAMENTE ESTATUS DE ELIMINACION LOGICA =1  
	   AND (@Todos = 1 OR (A.Creado BETWEEN @FechaInicio AND @FechaFin))
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
	   JOIN  dbo.MPY_MM_AceptacionPedidoDetalle AS APD 
			ON  A.IdAceptacionPedido = APD.IdAceptacionPedido
	   LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido  = AC.IdAceptacionPedido 
			AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
	   LEFT JOIN dbo.S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus   = TV.IdTipoValidacionDoc
	   LEFT JOIN dbo.S_Proveedor AS PV 
			ON A.IdProveedor = PV.RFC 
			AND PV.Activo = 1  
	   LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES   
			ON A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
			AND A.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS   = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS
	  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES 
			ON  PSES.SAPPONumber  = SES.PO_SAPNumer
			AND PSES.SAPSESNumber  = SES.SESReferenceNumber 
			AND PSES.SESN = SES.SESNumber  
	  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO 
			ON  A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
	  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL 
			ON  PO.Plant  = PL.Planta 
	  LEFT JOIN Adinco.dbo.CO_Contratista AS CC 
			ON PL.IdContratista  = CC.IdContratista    
	  WHERE A.IdSubContratista = @SAPVENDOR  
	  AND AC.IdAceptacionCartaPCN IS NULL  
	  AND PSES.IdEstatus = 2  --> CTE 
	  AND (@Todos = 1 OR (A.Creado BETWEEN @FechaInicio AND @FechaFin))
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
	   JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND  P.IdProveedorCompras  = PG.IdProveedorCliente
			AND PG.IdTipoPedido in (2,4, 6) --> CTE PEDIDOS 
	   JOIN MM_AceptacionPedido AS A 
			ON P.IdPedido = A.IdPedido     
	   JOIN S_Proveedor AS PV 
			ON P.IdProveedorCompras   = PV.IdProveedor 
	   JOIN dbo.RelacionCartaCNPedido rel 
			ON  A.IdAceptacionPedido   = rel.IdAceptacionPedido 
			AND  P.IdPedido = rel.IdPedido 
			AND rel.PedirCarta = 1  --> CTE
	   LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido  = AC.IdAceptacionPedido 
	   LEFT JOIN dbo.S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus  = TV.IdTipoValidacionDoc   
	   LEFT  JOIN dbo.MM_TipoPedido AS TP 
			ON PG.IdTipoPedido = TP.IdTipoPedido    
	   WHERE P.IdSubcontratista = @IdProveedor  
	   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
	   AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN  
	   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
				FROM dbo.MM_AceptacionCartaPCN A_PCN   
				WHERE A.IdAceptacionPedido = A_PCN.IdAceptacionPedido  
				ORDER BY A_PCN.CreadoEl DESC)        
	   ) 
	   AND AC.IdEstatus =@Estatus 
	   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> CTE NACIONALIDAD EXTRANJERA  
	   AND (@Todos = 1 OR (AC.CreadoEl BETWEEN @FechaInicio AND @FechaFin))
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
	   JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD 
			ON A.IdAceptacionPedido = APD.IdAceptacionPedido
	   LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido  = AC.IdAceptacionPedido  
			AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
	   LEFT JOIN dbo.S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus = TV.IdTipoValidacionDoc
	   LEFT JOIN dbo.S_Proveedor AS PV 
			ON A.IdProveedor = PV.RFC 
			AND PV.Activo = 1  --> CTE
	   LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES   
			ON A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS    = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
			AND A.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS 
	  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES 
			ON PSES.SAPPONumber = SES.PO_SAPNumer 
			AND PSES.SAPSESNumber = SES.SESReferenceNumber
			AND PSES.SESN  = SES.SESNumber 
	  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO   
			ON A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS   = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
	  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL 
			ON PO.Plant  = PL.Planta  
	  LEFT JOIN Adinco.dbo.CO_Contratista AS CC 
			ON PL.IdContratista  = CC.IdContratista     
	   WHERE A.IdSubContratista = @SAPVENDOR  
	   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
	   AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN  
	   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
				FROM dbo.MPY_MM_AceptacionCartaPCN A_PCN   
				WHERE A.IdAceptacionPedido = A_PCN.IdAceptacionPedido  
				ORDER BY A_PCN.CreadoEl DESC)        
	   ) AND AC.IdEstatus =@Estatus AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA  
	   AND PSES.IdEstatus = 2  --> CTE
	   AND (@Todos = 1 OR (AC.CreadoEl BETWEEN @FechaInicio AND @FechaFin))
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
	   JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND P.IdProveedorCompras  = PG.IdProveedorCliente 
			AND PG.IdTipoPedido in (2,4,6) --> CTE PEDIDOS
	   JOIN MM_AceptacionPedido AS A 
			ON P.IdPedido = A.IdPedido   
	   JOIN S_Proveedor AS PV 
			ON  P.IdProveedorCompras  = PV.IdProveedor  
	   JOIN dbo.RelacionCartaCNPedido rel 
			ON A.IdAceptacionPedido   = rel.IdAceptacionPedido  
			AND P.IdPedido = rel.IdPedido  
			AND rel.PedirCarta = 1 
	   LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido = AC.IdAceptacionPedido 
			AND ISNULL(AC.IdEstatusEliminado,0)<>1  
	   LEFT JOIN dbo.S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus  = TV.IdTipoValidacionDoc	   
	   LEFT  JOIN dbo.MM_TipoPedido AS TP 
			ON PG.IdTipoPedido  = TP.IdTipoPedido 	   
	   WHERE P.IdSubcontratista = @IdProveedor  
	   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
				FROM dbo.MM_AceptacionCartaPCN A_PCN   
				WHERE A.IdAceptacionPedido = A_PCN.IdAceptacionPedido 
				ORDER BY A_PCN.CreadoEl DESC)   
		 OR AC.IdAceptacionCartaPCN IS NULL  
	   )   
	   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
	   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA     
	   AND (@Todos = 1 OR (A.Creado BETWEEN @FechaInicio AND @FechaFin))
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
	   JOIN	dbo.MPY_MM_AceptacionPedidoDetalle APD
			ON A.IdAceptacionPedido = APD.IdAceptacionPedido  
	   LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido = AC.IdAceptacionPedido 
			AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1  
	   LEFT JOIN dbo.S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus = TV.IdTipoValidacionDoc
	   LEFT JOIN dbo.S_Proveedor AS PV 
			ON A.IdProveedor = PV.RFC 
			AND PV.Activo = 1  
	   LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES 
			ON  A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
			AND  A.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
	  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES 
			ON PSES.SAPPONumber = SES.PO_SAPNumer 
			AND  PSES.SAPSESNumber = SES.SESReferenceNumber
			AND  PSES.SESN = SES.SESNumber 
	  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO 
			ON  A.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
	  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL 
			ON  PO.Plant = PL.Planta 
	  LEFT JOIN Adinco.dbo.CO_Contratista AS CC 
			ON  PL.IdContratista = CC.IdContratista   
	   WHERE A.IdSubContratista = @SAPVENDOR  
	   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
				FROM dbo.MPY_MM_AceptacionCartaPCN A_PCN   
				WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido   
				ORDER BY A_PCN.CreadoEl DESC)   
		 OR AC.IdAceptacionCartaPCN IS NULL  
	   )   
	   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
	   AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA   
	   AND PSES.IdEstatus = 2   --> CTE    
	   AND (@Todos = 1 OR (A.Creado BETWEEN @FechaInicio AND @FechaFin))
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
  
   -- OBTENER ACEPTACIONES DE PROVEEDORES EXTRANJEROS 
   INSERT INTO #AceptacionesPedido 
   EXEC [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasCNExtranjeros] @Estatus,@IdProveedor
  
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