USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultaPedidosVenta_MV1_5'
)
    DROP PROCEDURE SP_MM_ConsultaPedidosVenta_MV1_5; 
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPedidosVenta_MV1_5]    Script Date: 02/08/2023 01:24:40 p. m. ******/
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
-- Author:		Alexander Gomez
-- Create date: 01/06/2023
-- Description:	correccion en la suma de los totales de los pedidos, reacomodo de joins y nolocks
-- =============================================
-- Author:		Daniel
-- Create date: 02/08/2023
-- Description:	Correccion en la suma de los totales de los pedidos, reacomodo de joins y nolocks
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosVenta_MV1_5]  
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
               SUM(PD.Subtotal) AS TotalPedido,  
               PV.RazonSocial  AS Cliente,  
               P.Version,  
               HV.FechaVigencia,  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
			INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido  = O.IdDocumento 
				   AND P.IdSubcontratista = @IdProveedor  
				   AND O.IdTipoOperacion = 9  --> CTE APROBACIÓN DE PEDIDO
				   AND O.IdEstatusOperacion = 2  --> CTE PEDIDO APROBADO
                   AND P.Version = O.NoVersion
				   AND P.RecepcionServicio IS NULL --> CTE QUE NO ESTE RECEPCIONADO
				   AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
				   AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS  
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido = PD.IdPedido             
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdProveedorCompras  = PV.IdProveedor               
            INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
                ON P.IdPedido = HV.IdPedido 
                   AND PD.IdPedido = HV.IdPedido 
				   AND  (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0  
            INNER JOIN MM_Pedidos AS PG  (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador                     
                   AND P.IdProveedorCompras = PG.IdProveedorCliente  
                   AND HV.IdPedido = PG.IdIdentificador  
				   AND PG.IdTipoPedido in (2,4, 6)
            INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido  = TP.IdTipoPedido
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital, 
                 P.Version,  
                 P.RecepcionServicio,  
                 HV.FechaVigencia,  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido
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
               SUM(PD.Subtotal) AS TotalPedido,  
               PV.RazonSocial  AS Cliente,  
               P.Version,  
               HV.FechaVigencia,  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
              TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
			INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento 
				   AND P.IdSubcontratista = @IdProveedor
                   AND P.RecepcionServicio = 1  --> CTE QUE ESTE RECEPCIONADO				   
				   AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
				   AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS 
				   AND O.IdTipoOperacion = 9  --> CTE APROBACION DE PEDIDO
				   AND O.IdEstatusOperacion = 2  --> CTE PEDIDO APROBADO
				   AND O.NoVersion = P.Version  				    
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido = PD.IdPedido             
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdProveedorCompras = PV.IdProveedor
            INNER JOIN TA_Estatus AS E  (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus  
            INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
                ON P.IdPedido = HV.IdPedido  
            INNER JOIN MM_Pedidos AS PG  (NOLOCK)
                ON PG.IdIdentificador = P.IdPedido  
                   AND P.IdProveedorCompras  = PG.IdProveedorCliente 
				   AND PG.IdTipoPedido in (2,4, 6)
            INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido  
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 P.Version,  
                 HV.FechaVigencia,  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido
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
               SUM(PD.Subtotal) AS TotalPedido,  
               PV.RazonSocial  AS Cliente,  
               P.Version,  
               HV.FechaVigencia,  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
			INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
				   AND P.IdSubcontratista =  @IdProveedor                    
				   AND P.RecepcionServicio IS NULL  -->CTE QUE AUN NO ESTE RECEPCIONDO
				   AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
				   AND ISNULL(P.Cerrado, 0) = 0 -->CTE PEDIDOS NO CERRADOS  
				   AND O.IdTipoOperacion = 9  --> CTE APROBACIÓN DE PEDIDO				  
				   AND O.IdEstatusOperacion = 2 --> CTE PEDIDO APROBADO	
				   AND P.Version = O.NoVersion 
            INNER JOIN MM_PedidoDetalle AS PD  (NOLOCK)
                ON P.IdPedido = PD.IdPedido             
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdProveedorCompras  = PV.IdProveedor             
            INNER JOIN TA_Estatus AS E  (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus  
            INNER JOIN MM_HorasVigenciaPedido AS HV  
                ON P.IdPedido = HV.IdPedido  
				AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 
            INNER JOIN MM_Pedidos AS PG  (NOLOCK)
                ON PG.IdIdentificador  = P.IdPedido 
                   AND P.IdProveedorCompras  = PG.IdProveedorCliente
				   AND PG.IdTipoPedido in (2,4, 6) 
            INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK) 
                ON PG.IdTipoPedido = TP.IdTipoPedido 
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 P.Version,  
                 P.RecepcionServicio,  
                 HV.FechaVigencia,  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido  
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
               SUM(PD.Subtotal) AS TotalPedido,  
               PV.RazonSocial  AS Cliente,  
               P.Version,  
               HV.FechaVigencia,  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  
			INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento  
				  AND P.IdSubcontratista = @IdProveedor
				  AND P.RecepcionServicio = 0  --> CTE QUE NO ESTE RECPECIONADO
				  AND ISNULL(P.IdEstatusEliminado,0)<>1  --> NO MOSTRAR PEDIDOS ELIMINADOS   
				  AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS                   
				  AND O.IdEstatusOperacion = 2 --> CTE PEDIDO APROBADO
				  AND O.IdTipoOperacion = 9  --> CTE APROBACIÓN DE PEDIDO
				  AND P.Version = O.NoVersion
            INNER JOIN MM_PedidoDetalle AS PD  (NOLOCK)
                ON P.IdPedido = PD.IdPedido            
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdProveedorCompras = PV.IdProveedor
            INNER JOIN TA_Estatus AS E  (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus  
            INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
                ON P.IdPedido = HV.IdPedido  
            INNER JOIN MM_Pedidos AS PG  (NOLOCK)
                ON PG.IdIdentificador = P.IdPedido  
                   AND P.IdProveedorCompras = PG.IdProveedorCliente  
				   AND PG.IdTipoPedido in (2,4, 6)
            INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido 
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 P.Version,  
                 HV.FechaVigencia,  
                 P.IdProveedorCompras,  
				 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido  
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
               SUM(PD.Subtotal) AS TotalPedido,  
               PV.RazonSocial AS Cliente,  
               P.Version,  
               HV.FechaVigencia,  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               CASE  
                   WHEN P.RecepcionServicio = 1 THEN  
                       'Confirmada'  
                   WHEN P.RecepcionServicio = 0  THEN  
                       'Rechazada'  
                   WHEN (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'Vencida'  
                   WHEN (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'En confirmación'        
               END AS EstatusRecepcion,  
               TP.TipoPedido,  
               TP.IdTipoPedido  
        FROM MM_Pedido AS P  (NOLOCK)
			INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
				   AND P.IdSubcontratista = @IdProveedor 
				   AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADO  
				   AND ISNULL(P.Cerrado, 0) = 1 --> PEDIDOS CERRADOS                    
				   AND O.IdTipoOperacion = 9  --> CTE APROBACIÓN DE PEDIDO
                   AND O.IdEstatusOperacion = 2 --> PEDIDO APROBADO
				   AND P.Version = O.NoVersion  
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK) 
                ON P.IdPedido = PD.IdPedido  
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdProveedorCompras = PV.IdProveedor   
            INNER JOIN TA_Estatus AS E  (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus  
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK) 
                ON P.IdPedido = HV.IdPedido  
            INNER JOIN MM_Pedidos AS PG  (NOLOCK)
                ON PG.IdIdentificador = P.IdPedido  
                   AND P.IdProveedorCompras = PG.IdProveedorCliente
				   AND PG.IdTipoPedido in (2,4, 6)  
            INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK) 
                ON PG.IdTipoPedido = TP.IdTipoPedido           
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
                P.IdEstatusEliminado  
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
               SUM(PD.Subtotal) AS TotalPedido,  
               PV.RazonSocial AS Cliente,  
               P.Version,  
               HV.FechaVigencia,  
               P.IdProveedorCompras,  
               PG.IdPedido AS IdPedidoGeneral,  
               TM.TipoMonedaCorto AS Moneda,  
               CASE  
                   WHEN P.RecepcionServicio = 1 THEN  
                       'Confirmada'  
                   WHEN P.RecepcionServicio = 0  THEN  
                       'Rechazada'  
                   WHEN (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'Vencida'  
                   WHEN (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0   
                        AND P.RecepcionServicio IS NULL THEN  
                       'En confirmación'        
               END AS EstatusRecepcion,  
               TP.TipoPedido,
               TP.IdTipoPedido,			
			   'N/A' AS NoPO
        FROM MM_Pedido AS P              
			INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento  
				   AND P.IdSubcontratista = @IdProveedor		
				   AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADO
                   AND P.Version = O.NoVersion  
				   AND O.IdTipoOperacion = 9   --> CTE APROBACIÓN DE PEDIDO
				   AND O.IdEstatusOperacion = 2 --> CTE PEDIDO APROBADO				   
			INNER JOIN MM_PedidoDetalle AS PD  (NOLOCK)
                ON P.IdPedido = PD.IdPedido
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdProveedorCompras = PV.IdProveedor 
            INNER JOIN TA_Estatus AS E  (NOLOCK)
                ON E.IdEstatus = O.IdEstatusOperacion  
            INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
                ON P.IdPedido = HV.IdPedido  
            INNER JOIN MM_Pedidos AS PG  (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador  
                   AND P.IdProveedorCompras = PG.IdProveedorCliente 
				   AND PG.IdTipoPedido in (2,4, 6) 
            INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda  
            LEFT JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido         
        GROUP BY P.IdPedido,  
                 P.IdSolicitudPedido,  
                 P.FechaEnvioPedido,  
                 RazonSocial,  
                 RegimenCapital,  
                 E.Nombre,  
                 P.Version,  
                 HV.FechaVigencia,  
                 P.IdProveedorCompras,  
                 PG.IdPedido,  
                 TM.TipoMonedaCorto,  
                 O.IdEstatusOperacion,  
                 P.RecepcionServicio,  
                 TP.TipoPedido,  
                 TP.IdTipoPedido,  
				 P.IdEstatusEliminado
        ORDER BY PG.IdPedido DESC;  
		 
		/*ACTUALIZAR INFORMACIÓN DEA*/
		UPDATE P 
		SET P.TipoPedido = CASE WHEN ISNULL(WPI.MECANISMO_CONTRATACION,'')='L' THEN 
						   'Licitación'
						   ELSE
						    P.TipoPedido
					       END,
		P.NoPO = ISNULL(WPI.PURCHASING_DOCUMENT,'N/A') 
		FROM #PEDIDOS P 
		JOIN WDEA_PurchasingDocumentsImportados AS WPI(NOLOCK)	     
		 ON P.IdPedido = WPI.IdPedidoADINCO 

		/*REEMPLAZAR LOS N/A DEL PRIMER UPDATE*/
		UPDATE  P
		SET P.NoPO = CASE WHEN ISNULL(NoPO,'')='N/A' THEN 
						ISNULL(POW.PO,'N/A') 
					 ELSE 
					    P.NoPO
				     END
		FROM #PEDIDOS P 
		JOIN DEA_Relacion_PR_PO AS POW (NOLOCK)
			ON P.IdPedido = POW.IdPedido
  
    END;  

	SELECT 
		IdPedido,
		FechaPedido,
		SubTotal AS TotalPedido,
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
		IdTipoPedido,
		SubTotal;
  
END;  