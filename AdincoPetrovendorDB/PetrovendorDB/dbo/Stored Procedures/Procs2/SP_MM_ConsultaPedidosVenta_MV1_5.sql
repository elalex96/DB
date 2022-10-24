USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPedidosVenta_MV1_5]    Script Date: 20/10/2022 05:16:25 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Daniel AC  
-- Update date: 01/10/19  
-- Description: Se modificio columna de razón social  
-- ============================================  
-- Author:		Alexander Gomez
-- Create date: 19/04/2022
-- Description:	Se agrega a la consulta el dato del No.PO
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_ConsultaPedidosVenta_MV1_5]  
    -- Add the parameters for the stored procedure here  
    @IdProveedor INT,  
    @CONSULTA NVARCHAR(300),   
    @IdContrato INT,  
    @IdUsuario INT,  
    @FechaRegistro DATETIME  
  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
	CREATE TABLE #PEDIDOS (
		IdPedido INT,  
        FechaPedido DATETIME,  
        SubTotal MONEY,  
        Cliente VARCHAR(500),  
        Version FLOAT,  
        FechaVigencia DATETIME,  
        IdProveedorCompras INT,  
        IdPedidoGeneral INT,  
        Moneda NVARCHAR(50),  
        EstatusRecepcion NVARCHAR(200),  
        TipoPedido NVARCHAR(200),
        IdTipoPedido INT,
		NoPO NVARCHAR(100)
	);

  
    IF @CONSULTA = 'CONFIRMACION'  
    BEGIN  
		INSERT INTO #PEDIDOS (
			IdPedido,
			FechaPedido,
			SubTotal,
			Cliente,
			Version,
			FechaVigencia,
			IdProveedorCompras,
			IdPedidoGeneral,
			Moneda,
			TipoPedido,
			IdTipoPedido
		)
        SELECT P.IdPedido,  
               P.FechaEnvioPedido AS FechaPedido,  
               PD.Subtotal AS TotalPedido,  
               PV.RazonSocial  AS Cliente,  
               Version,  
               [FechaVigencia],  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
            INNER JOIN MM_PedidoDetalle AS PD  
                ON PD.IdPedido = P.IdPedido  
            INNER JOIN MM_PeticionOferta AS PO  
                ON PO.IdPeticionOferta = P.IdPeticionOferta  
            INNER JOIN S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            INNER JOIN TA_Operacion AS O  
                ON O.IdDocumento = P.IdSolicitudPedido  
                   AND P.Version = O.NoVersion  
            INNER JOIN TA_Prioridad AS PR  
                ON PR.IdPrioridad = O.IdPrioridad  
            INNER JOIN TA_Vencimiento AS V  
                ON V.IdVencimiento = O.IdVigencia  
            INNER JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = O.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON HV.IdPedido = P.IdPedido  
                   AND HV.IdPedido = PD.IdPedido  
            INNER JOIN MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador                     
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
                   AND PG.IdIdentificador = HV.IdPedido  
				   AND PG.IdTipoPedido in (2,4, 6)
            INNER JOIN PV_TipoMoneda AS TM  
                ON TM.IdMoneda = P.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
        WHERE P.RecepcionServicio IS NULL  
              AND P.IdSubcontratista = @IdProveedor  
              AND O.IdTipoOperacion = 9  
              AND O.IdEstatusOperacion = 2  
              AND (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) <= 0  
     AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
     AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 Version,  
                 P.RecepcionServicio,  
                 [FechaVigencia],  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido,
				 PD.Subtotal
        ORDER BY PG.IdPedido DESC;  
    END;  
     
    IF @CONSULTA = 'CONFIRMADOS'  
    BEGIN  
		
		INSERT INTO #PEDIDOS (
			IdPedido,
			FechaPedido,
			SubTotal,
			Cliente,
			Version,
			FechaVigencia,
			IdProveedorCompras,
			IdPedidoGeneral,
			Moneda,
			TipoPedido,
			IdTipoPedido
		)
        SELECT P.IdPedido,  
               P.FechaEnvioPedido AS FechaPedido,  
               PD.Subtotal AS TotalPedido,  
               RazonSocial  AS Cliente,  
               Version,  
               [FechaVigencia],  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
              TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
            INNER JOIN MM_PedidoDetalle AS PD  
                ON PD.IdPedido = P.IdPedido  
            INNER JOIN MM_PeticionOferta AS PO  
                ON PO.IdPeticionOferta = P.IdPeticionOferta  
            INNER JOIN S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            INNER JOIN TA_Operacion AS O  
                ON O.IdDocumento = P.IdSolicitudPedido  
                   AND P.Version = O.NoVersion  
            INNER JOIN TA_Prioridad AS PR  
                ON PR.IdPrioridad = O.IdPrioridad  
            INNER JOIN TA_Vencimiento AS V  
                ON V.IdVencimiento = O.IdVigencia  
            INNER JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = O.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON HV.IdPedido = P.IdPedido  
            INNER JOIN MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
				   AND PG.IdTipoPedido in (2,4, 6)
            INNER JOIN PV_TipoMoneda AS TM  
                ON TM.IdMoneda = P.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
        WHERE O.IdTipoOperacion = 9  
              AND P.IdSubcontratista = @IdProveedor  
              AND O.IdEstatusOperacion = 2  
              AND P.RecepcionServicio = 1  
     AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
     AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 Version,  
                 [FechaVigencia],  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido ,
				 PD.Subtotal
        ORDER BY PG.IdPedido DESC;  
    END;  
  
    IF @CONSULTA = 'VENCIDOS'  
    BEGIN  
		
		INSERT INTO #PEDIDOS (
			IdPedido,
			FechaPedido,
			SubTotal,
			Cliente,
			Version,
			FechaVigencia,
			IdProveedorCompras,
			IdPedidoGeneral,
			Moneda,
			TipoPedido,
			IdTipoPedido
		)
        SELECT P.IdPedido,  
               P.FechaEnvioPedido AS FechaPedido,  
               PD.Subtotal AS TotalPedido,  
               RazonSocial  AS Cliente,  
               Version,  
               [FechaVigencia],  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
            INNER JOIN MM_PedidoDetalle AS PD  
                ON PD.IdPedido = P.IdPedido  
            INNER JOIN MM_PeticionOferta AS PO  
                ON PO.IdPeticionOferta = P.IdPeticionOferta  
            INNER JOIN S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            INNER JOIN TA_Operacion AS O  
                ON O.IdDocumento = P.IdSolicitudPedido  
                   AND P.Version = O.NoVersion  
            INNER JOIN TA_Prioridad AS PR  
                ON PR.IdPrioridad = O.IdPrioridad  
            INNER JOIN TA_Vencimiento AS V  
                ON V.IdVencimiento = O.IdVigencia  
            INNER JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = O.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON HV.IdPedido = P.IdPedido  
            INNER JOIN MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras 
				   AND PG.IdTipoPedido in (2,4, 6) 
            INNER JOIN PV_TipoMoneda AS TM  
                ON TM.IdMoneda = P.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
        WHERE O.IdTipoOperacion = 9  
              AND P.IdSubcontratista = @IdProveedor  
              AND O.IdEstatusOperacion = 2  
              AND (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) >= 0  
              AND P.RecepcionServicio IS NULL  
     AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
     AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 Version,  
                 P.RecepcionServicio,  
                 [FechaVigencia],  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido  ,
				 PD.Subtotal
        ORDER BY PG.IdPedido DESC;  
    END;  
  
  
    IF @CONSULTA = 'RECHAZADOS'  
    BEGIN  
		
		INSERT INTO #PEDIDOS (
			IdPedido,
			FechaPedido,
			SubTotal,
			Cliente,
			Version,
			FechaVigencia,
			IdProveedorCompras,
			IdPedidoGeneral,
			Moneda,
			TipoPedido,
			IdTipoPedido
		)
        SELECT P.IdPedido,  
               P.FechaEnvioPedido AS FechaPedido,  
               PD.Subtotal AS TotalPedido,  
               RazonSocial  AS Cliente,  
               Version,  
               [FechaVigencia],  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
            INNER JOIN MM_PedidoDetalle AS PD  
                ON PD.IdPedido = P.IdPedido  
            INNER JOIN MM_PeticionOferta AS PO  
                ON PO.IdPeticionOferta = P.IdPeticionOferta  
            INNER JOIN S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            INNER JOIN TA_Operacion AS O  
                ON O.IdDocumento = P.IdSolicitudPedido  
                   AND P.Version = O.NoVersion  
            INNER JOIN TA_Prioridad AS PR  
                ON PR.IdPrioridad = O.IdPrioridad  
            INNER JOIN TA_Vencimiento AS V  
                ON V.IdVencimiento = O.IdVigencia  
            INNER JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = O.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON HV.IdPedido = P.IdPedido  
            INNER JOIN MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras  
				   AND PG.IdTipoPedido in (2,4, 6)
            INNER JOIN PV_TipoMoneda AS TM  
                ON TM.IdMoneda = P.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
        WHERE O.IdTipoOperacion = 9  
              AND P.IdSubcontratista = @IdProveedor  
              AND O.IdEstatusOperacion = 2  
              AND P.RecepcionServicio = 0  
     AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
     AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 Version,  
                 [FechaVigencia],  
                 P.IdProveedorCompras,  
            PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido  ,
				 PD.Subtotal
        ORDER BY PG.IdPedido DESC;  
    END;  
    ---#NOTA ---  
    --- IdTipoOperacion  = 9 Aprobación de Pedido  
    --- IdEstatusOperacion = 2 Pedido Aprobado  
    --- IdSubcontratista = Proveedor Vendedor   
 --- IdProveedorCompras = Operador  
    --- PG.IdTipoPedido = 2  =Pedido de Tipo Mercadeo  
  
 IF @CONSULTA = 'CERRADOS'  
    BEGIN  
		
		INSERT INTO #PEDIDOS (
			IdPedido,
			FechaPedido,
			SubTotal,
			Cliente,
			Version,
			FechaVigencia,
			IdProveedorCompras,
			IdPedidoGeneral,
			Moneda,
			EstatusRecepcion,
			TipoPedido,
			IdTipoPedido
		)
        SELECT P.IdPedido,  
               P.FechaEnvioPedido AS FechaPedido,  
               PD.Subtotal AS TotalPedido,  
               RazonSocial AS Cliente,  
               Version,  
               [FechaVigencia],  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               CASE  
                   WHEN P.RecepcionServicio = 1 THEN  
                       'Confirmada'  
                   WHEN P.RecepcionServicio = 0  THEN  
                       'Rechazada'  
                   WHEN (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) >= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'Vencida'  
                   WHEN (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) <= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'En confirmación'        
               END AS EstatusRecepcion,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
            INNER JOIN MM_PedidoDetalle AS PD  
                ON PD.IdPedido = P.IdPedido  
            INNER JOIN MM_PeticionOferta AS PO  
                ON PO.IdPeticionOferta = P.IdPeticionOferta  
            INNER JOIN S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            INNER JOIN TA_Operacion AS O  
                ON O.IdDocumento = P.IdSolicitudPedido  
                   AND P.Version = O.NoVersion  
            INNER JOIN TA_Prioridad AS PR  
                ON PR.IdPrioridad = O.IdPrioridad  
            INNER JOIN TA_Vencimiento AS V  
                ON V.IdVencimiento = O.IdVigencia  
            INNER JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = O.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON HV.IdPedido = P.IdPedido  
            INNER JOIN MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
				   AND PG.IdTipoPedido in (2,4, 6)  
            INNER JOIN PV_TipoMoneda AS TM  
                ON TM.IdMoneda = P.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido  
        WHERE O.IdTipoOperacion = 9  
              AND P.IdSubcontratista = @IdProveedor  
              AND O.IdEstatusOperacion = 2  
     AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADO  
     AND ISNULL(P.Cerrado, 0) = 1 --> PEDIDOS CERRADOS  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 Version,  
                 [FechaVigencia],  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 O.IdEstatusOperacion,  
                 P.RecepcionServicio,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido,  
     P.IdEstatusEliminado  ,
	 PD.Subtotal
        ORDER BY PG.IdPedido DESC;  
  
    END;  
  
    IF @CONSULTA = 'TODOS'  
    BEGIN  

		INSERT INTO #PEDIDOS (
			IdPedido,
			FechaPedido,
			SubTotal,
			Cliente,
			Version,
			FechaVigencia,
			IdProveedorCompras,
			IdPedidoGeneral,
			Moneda,
			EstatusRecepcion,
			TipoPedido,
			IdTipoPedido,
			NoPO
		)
        SELECT P.IdPedido,  
               P.FechaEnvioPedido AS FechaPedido,  
               PD.Subtotal AS TotalPedido,  
               RazonSocial AS Cliente,  
               Version,  
               [FechaVigencia],  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               CASE  
                   WHEN P.RecepcionServicio = 1 THEN  
                       'Confirmada'  
                   WHEN P.RecepcionServicio = 0  THEN  
                       'Rechazada'  
                   WHEN (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) >= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'Vencida'  
                   WHEN (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) <= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'En confirmación'        
               END AS EstatusRecepcion,  
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido ,
			   ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'N/A') AS NoPO
        FROM MM_Pedido AS P  
            INNER JOIN MM_PedidoDetalle AS PD  
                ON PD.IdPedido = P.IdPedido  
            INNER JOIN MM_PeticionOferta AS PO  
                ON PO.IdPeticionOferta = P.IdPeticionOferta  
            INNER JOIN S_Proveedor AS PV  
                ON PV.IdProveedor = P.IdProveedorCompras  
            INNER JOIN TA_Operacion AS O  
                ON O.IdDocumento = P.IdSolicitudPedido  
                   AND P.Version = O.NoVersion  
            INNER JOIN TA_Prioridad AS PR  
                ON PR.IdPrioridad = O.IdPrioridad  
            INNER JOIN TA_Vencimiento AS V  
                ON V.IdVencimiento = O.IdVigencia  
            INNER JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = O.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E  
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON HV.IdPedido = P.IdPedido  
            INNER JOIN MM_Pedidos AS PG  
                ON P.IdPedido = PG.IdIdentificador  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras 
				   AND PG.IdTipoPedido in (2,4, 6) 
            INNER JOIN PV_TipoMoneda AS TM  
                ON TM.IdMoneda = P.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  
                ON TP.IdTipoPedido = PG.IdTipoPedido
			LEFT JOIN WDEA_PurchasingDocumentsImportados AS WPI
				ON P.IdPedido = WPI.IdPedidoADINCO
			LEFT JOIN DEA_Relacion_PR_PO AS POW
				ON P.IdPedido = POW.IdPedido
			LEFT JOIN WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9  
              AND P.IdSubcontratista = @IdProveedor  
              AND O.IdEstatusOperacion = 2  
     AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADO  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 Version,  
                 [FechaVigencia],  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 O.IdEstatusOperacion,  
                 P.RecepcionServicio,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido,  
				 P.IdEstatusEliminado ,
				 WPI.PURCHASING_DOCUMENT,
				 POW.PO,
				 PDI.MECANISMO_CONTRATACION,
				 PD.Subtotal
        ORDER BY PG.IdPedido DESC;  
  
    END;  

	SELECT 
		IdPedido,
		FechaPedido,
		SUM(SubTotal) AS TotalPedido,
		Cliente,
		Version,
		FechaVigencia,
		IdProveedorCompras,
		IdPedidoGeneral,
		Moneda,
		EstatusRecepcion,
		TipoPedido,
		IdTipoPedido,
		NoPO
	FROM #PEDIDOS
	GROUP BY IdPedido,
		FechaPedido,
		Cliente,
		Version,
		FechaVigencia,
		IdProveedorCompras,
		IdPedidoGeneral,
		Moneda,
		TipoPedido,
		EstatusRecepcion,
		NoPO,
		IdTipoPedido;
  
END;  
  
