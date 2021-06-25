USE Petrovendor
GO
--Modifier: Luis David
-- Modifier date: 24-06-2021
-- Description: Valida que el pedido sea de dea para saber si va a bloquear o no
DROP PROCEDURE IF EXISTS AP_ValidaAceptacionPedidoDEA
go
CREATE PROCEDURE AP_ValidaAceptacionPedidoDEA 
@IdAceptacionPedido int,
@IdProveedor int 
AS
BEGIN
	drop table if exists #AceptacionesPedido
	declare @nombreProveedor varchar(500);
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
        UUID NVARCHAR(MAX),
		Contrato NVARCHAR(300),
		IdSolicitudPedido VARCHAR(300) NULL,
		IdProveedor int
    );  
  
  
 
  
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
               F.UUID,
			   CONCAT(CO.NumeroContrato,' - ', A.NombreAreaContractual),
			   CONVERT(VARCHAR, SP.IdSolicitudPedido),
			   p.IdProveedorCompras
        FROM dbo.MM_Pedido P  (NOLOCK)
            INNER JOIN dbo.MM_Pedidos AS PG  (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
				   AND P.IdSubcontratista = @IdProveedor 
            INNER JOIN dbo.MM_AceptacionPedido AS AP  (NOLOCK)
                ON AP.IdPedido = P.IdPedido  
            LEFT JOIN dbo.MM_AceptacionCartaPCN AS APC  (NOLOCK)
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND (APC.IdAceptacionCartaPCN IS NOT NULL) --Si no se solicita una CN, se muestra una aceptacion de servicio     
                   AND ISNULL(APC.IdEstatusEliminado, 0) <> 1 --> Que no esten eliminadas     
			INNER JOIN dbo.S_Proveedor AS PV  (NOLOCK)
                ON PV.IdProveedor = P.IdProveedorCompras  
            LEFT JOIN dbo.MM_AceptacionFactura AS AF  (NOLOCK)
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> Que no esten eliminadas     
            LEFT JOIN dbo.TA_Operacion AS O  (NOLOCK)
                ON O.IdDocumento = AF.IdAceptacionFactura  
                   AND P.IdSubcontratista = O.IdProveedor  
            LEFT JOIN dbo.TA_Estatus AS E  (NOLOCK)
                ON E.IdEstatus = O.IdEstatusOperacion  
            LEFT JOIN dbo.FI_Factura F  (NOLOCK)
                ON F.IdFactura = AF.IdFactura  
            INNER JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
                ON TP.IdTipoPedido = PG.IdTipoPedido  
            LEFT JOIN dbo.RelacionCartaCNPedido rel  (NOLOCK)
                ON rel.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND rel.IdPedido = P.IdPedido  
                   AND rel.PedirCarta = 0  
			INNER JOIN mm_solicitudpedido as SP
				ON P.IdSolicitudPedido = SP.IdSolicitudPedido
			INNER JOIN Adinco..CO_Contrato as CO
				ON SP.IdContrato = CO.IdContrato
			INNER JOIN Adinco..CO_AreaContractual A
				ON CO.IdAreaContractual = A.IdAreaContractual
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
                 F.UUID,
				 CO.NumeroContrato,
				 A.NombreAreaContractual,
				 SP.IdSolicitudPedido,
				 p.IdProveedorCompras
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
               F.UUID  ,
			   CONCAT(C.NumeroContrato,' - ', A.NombreAreaContractual),
			   PSES.SAPPONumber,
			   0
        FROM dbo.MPY_MM_AceptacionPedido AS AP  (NOLOCK)
            LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APC  (NOLOCK)
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF  (NOLOCK)
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido  
            LEFT JOIN dbo.S_TipoValidacionDoc AS TVDF  (NOLOCK)
                ON TVDF.IdTipoValidacionDoc = AF.IdEstatusXML  
            LEFT JOIN dbo.FI_Factura F  (NOLOCK)
                ON F.IdFactura = AF.IdFactura  
            LEFT JOIN dbo.S_Proveedor AS PV  (NOLOCK)
                ON PV.RFC = AP.IdProveedor  
                   AND PV.Activo = 1  
            LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES	(NOLOCK)  
                ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
                   AND PSES.IdEstatus = 2 --solo aprobadas  
            LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  (NOLOCK)
                ON SES.PO_SAPNumer = PSES.SAPPONumber  
                   AND SES.SESReferenceNumber = PSES.SAPSESNumber  
                   AND SES.SESNumber = PSES.SESN  
            LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  (NOLOCK)
             ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
			LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL  (NOLOCK)
                ON PL.Planta = PO.Plant  
            LEFT JOIN Adinco.dbo.CO_Contratista AS CO  (NOLOCK)
                ON CO.IdContratista = PL.IdContratista  
			JOIN Adinco..Co_Contrato as C
				ON AP.IdContrato = C.IdContrato
			INNER JOIN Adinco..CO_AreaContractual A
				ON C.IdAreaContractual = A.IdAreaContractual
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
                 F.UUID ,
				 C.NumeroContrato,
				 A.NombreAreaContractual,
				 PSES.SAPPONumber
        ORDER BY AP.IdAceptacionPedido DESC;  

    set @nombreProveedor = (SELECT  p.RazonSocial
    FROM #AceptacionesPedido ap
	join S_Proveedor p
	on ap.IdProveedor = p.IdProveedor
	WHERE IdAceptacionPedido = @IdAceptacionPedido)

	IF @nombreProveedor LIKE '%Wintershall Dea Mexico S. de R.L. de C.V.%'  
	BEGIN
		SELECT 1 AS ISDEA
	END
	ELSE
	BEGIN
		SELECT 0 AS ISDEA
	END
END
-- AP_ValidaAceptacionPedidoDEA 10424,2837