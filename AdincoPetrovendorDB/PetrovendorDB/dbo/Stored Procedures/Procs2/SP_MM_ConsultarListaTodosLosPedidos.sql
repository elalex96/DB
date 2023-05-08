-- =============================================
-- Author:		Daniel AC
-- Create date: 23-04-2018
-- Description:	Consultar lista de todos los Pedidos por filtro
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarListaTodosLosPedidos]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @Filtro NVARCHAR(MAX),
    @F_IdProveedorPedido INT,
    @F_IdUsuarioCompras INT,
    @F_IdUsuarioRequitor INT,
    @F_TipoPedido NVARCHAR(350),
    @F_FechaInicio DATE,
    @F_FechaFin DATE,
    @ValidacionFecha BIT,
    @F_TipoMoneda INT,
    @F_MontoInicio MONEY,
    @F_MontoFin MONEY,
	@F_MostrarEliminados  BIT = 0 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
   
   
	DECLARE @FECHA_INICIO_NEW DATETIME=@F_FechaInicio
    DECLARE @FECHA_FIN_NEW DATETIME=@F_FechaFin

	---#Busca todos los pedidos sin requerimientos 
    IF @Filtro = 'TODOS'
    BEGIN

		SELECT * FROM (
        --#MERCADEO
		 	
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(RazonSocial,'') + ' ' + ISNULL(RegimenCapital,'') AS Proveedor,
               --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepción' END AS RecepcionServicio,
               E.Nombre,
               P.Version,
               P.RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               TP.TipoPedido AS TIPO,
               O.IdOperacion AS IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   CASE WHEN ISNULL(P.IdEstatusEliminado,0)<> 1 THEN 
			   'ACTIVO' 
			   ELSE 
			   'ELIMINADO' 
			   END  AS Activo
        FROM MM_Pedido AS P
            LEFT JOIN MM_PedidoDetalle AS PD
                ON PD.IdPedido = P.IdPedido
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            LEFT JOIN S_Proveedor AS PV
                ON PV.IdProveedor = P.IdSubcontratista
            LEFT JOIN TA_Operacion AS O
                ON O.IdDocumento = P.IdSolicitudPedido
            LEFT JOIN TA_Prioridad AS PR
                ON PR.IdPrioridad = O.IdPrioridad
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            LEFT JOIN TA_TipoOperacion AS TTO
                ON TTO.IdTipoOperacion = O.IdTipoOperacion
            LEFT JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_HorasVigenciaPedido AS HV
                ON P.IdPedido = HV.IdPedido
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = P.IdMoneda
			LEFT JOIN MM_Pedidos AS PG 
				ON P.IdPedido = PG.IdIdentificador 
				--AND PG.IdTipoPedido = 2 
				AND PG.IdProveedorCliente = @IdProveedor
			LEFT JOIN MM_TipoPedido AS TP 
			ON TP.IdTipoPedido=PG.IdTipoPedido
        WHERE O.IdTipoOperacion = 9
              AND O.IdProveedor = @IdProveedor
             AND P.Version = O.NoVersion
			 AND (CASE 
			 WHEN ISNULL(P.IdEstatusEliminado,0) = @F_MostrarEliminados THEN 
				1
			 WHEN @F_MostrarEliminados = 1  THEN 
				1
			 ELSE 
				0
			 END  = 1)	 
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.CreadoEl,
                 RazonSocial,
                 RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 O.IdOperacion,
				 PG.IdPedido,
				 TP.TipoPedido,
				 P.IdEstatusEliminado

       
        UNION ALL
        --#COMPRA DIRECTA
        SELECT coRegistro.IdRegistro AS IdPedido,
               coRegistro.IdFactura AS IdSolicitudPedido,
               TAO.FechaRegistro AS FechaEnvioPedido,
               fiFact.SubTotal AS TotalPedido,
               ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
               TE.Nombre,
               NULL AS Version,
               NULL AS RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               'Compra directa' AS TIPO,
               TAO.IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   'ACTIVO' AS Activo
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable
            LEFT JOIN dbo.CO_LineaPresupuestoMes linea
                ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = fiFact.IdMoneda
            LEFT JOIN dbo.S_Proveedor AS P
                ON P.RFC = fiFact.Emisor
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador =fiFact.IdFactura
				 AND PG.IdTipoPedido=1 AND PG.IdProveedorCliente=@IdProveedor
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.IdProveedor = @IdProveedor

	 UNION

	 /*TODOS LOS COMPROBANTES EXTRANJEROS*/

		SELECT PC.IdPedimentoComprobante AS IdPedido,
               NULL AS IdSolicitudPedido,
               TAO.FechaRegistro AS FechaEnvioPedido,
               SUM(PCD.ImporteTotal) AS TotalPedido,
               ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
               TE.Nombre,
               NULL AS Version,
               NULL AS RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               'Comprobante extranjero' AS TIPO,
               TAO.IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   'ACTIVO' AS Activo
        FROM dbo.FI_PedimentoComprobante AS PC
			INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD 
				ON PCD.IdPedimentoComprobante=PC.IdPedimentoComprobante            
            INNER JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = PC.IdPedimentoComprobante
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion  
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = PC.IdMoneda
            LEFT JOIN dbo.S_Proveedor AS P
                ON P.IdProveedor = PC.IdSubcontratistaExportador
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador =PC.IdPedimentoComprobante
				 AND PG.IdTipoPedido= 7 AND PG.IdProveedorCliente=@IdProveedor
        WHERE TAO.IdTipoOperacion = 16
              AND TAO.IdProveedor = @IdProveedor
		GROUP BY 
		PC.IdPedimentoComprobante,        
        TAO.FechaRegistro,       
        P.RazonSocial,
		P.RegimenCapital,
        TE.Nombre,     
        TM.TipoMonedaCorto,     
        TAO.IdOperacion,
		PG.IdPedido

		) Pedidos ORDER BY FechaEnvioPedido DESC

		


    END;

    --- IdTipoOperacion = 7--> Pedido
    --- IdTipoOperacion = 14-> Orden de compra
	---#Busca solo pedidos de un tipo con lo requeirmientos solicitados 
    IF @Filtro = 'FILTRO'
    BEGIN

        IF @F_TipoPedido = 'Mercadeo'
        BEGIN
		
		       SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(RazonSocial,'') + ' ' + ISNULL(RegimenCapital,'') AS Proveedor,
               --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepción' END AS RecepcionServicio,
               E.Nombre,
               P.Version,
               P.RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               TP.TipoPedido AS TIPO,
               O.IdOperacion AS IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   CASE WHEN ISNULL(P.IdEstatusEliminado,0)<> 1 THEN 
			   'ACTIVO' 
			   ELSE 
			   'ELIMINADO' 
			   END  AS Activo
        FROM MM_Pedido AS P
            LEFT JOIN MM_PedidoDetalle AS PD
                ON PD.IdPedido = P.IdPedido
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            LEFT JOIN S_Proveedor AS PV
                ON PV.IdProveedor = P.IdSubcontratista
            LEFT JOIN TA_Operacion AS O
                ON O.IdDocumento = P.IdSolicitudPedido
            LEFT JOIN TA_Prioridad AS PR
                ON PR.IdPrioridad = O.IdPrioridad
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            LEFT JOIN TA_TipoOperacion AS TTO
                ON TTO.IdTipoOperacion = O.IdTipoOperacion
            LEFT JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_HorasVigenciaPedido AS HV
                ON P.IdPedido = HV.IdPedido
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = P.IdMoneda
			LEFT JOIN MM_Pedidos AS PG 
				ON P.IdPedido = PG.IdIdentificador 			
				AND PG.IdProveedorCliente = @IdProveedor
			LEFT JOIN MM_TipoPedido AS TP 
			ON TP.IdTipoPedido=PG.IdTipoPedido
			LEFT JOIN dbo.MM_SolicitudPedido AS SP
				ON	SP.IdSolicitudPedido=P.IdSolicitudPedido
        WHERE O.IdTipoOperacion = 9            
             AND P.Version = O.NoVersion
			 AND PG.IdTipoPedido=2  ---> MERCADEO
			 AND O.IdProveedor = @IdProveedor 
			 AND 
			 CASE WHEN  P.IdSubcontratista = @F_IdProveedorPedido 
			 THEN 1
			  WHEN @F_IdProveedorPedido = 0 AND P.IdSubcontratista IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1
			 AND CASE WHEN  P.CreadoPor = @F_IdUsuarioCompras
			 THEN 1
			 WHEN @F_IdUsuarioCompras = 0 AND P.CreadoPor IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1
			 AND CASE WHEN  SP.IdUsuarioSolicitante = @F_IdUsuarioRequitor
			  THEN 1
			 WHEN @F_IdUsuarioRequitor = 0 AND SP.IdUsuarioSolicitante IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1
			 AND CASE WHEN  P.CreadoEl BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
			 THEN 1
			  WHEN @ValidacionFecha= 0 AND  P.CreadoEl  IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1	
			 AND CASE WHEN TM.IdMoneda = @F_TipoMoneda
			 THEN 1
			  WHEN @F_TipoMoneda = 0 AND TM.IdMoneda IS NOT NULL  THEN 1
			   ELSE 0
			  END  = 1	
			  AND (CASE 
			 WHEN ISNULL(P.IdEstatusEliminado,0) = @F_MostrarEliminados THEN 
				1
			 WHEN @F_MostrarEliminados = 1  THEN 
				1
			 ELSE 
				0
			 END  = 1)
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.CreadoEl,
                 RazonSocial,
                 RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 O.IdOperacion,
				 PG.IdPedido,
				 TP.TipoPedido,
				 P.IdEstatusEliminado
	   
	   HAVING (CASE WHEN SUM(PD.Subtotal) BETWEEN @F_MontoInicio AND @F_MontoFin 
			 THEN 1
			  WHEN @F_MontoFin = 0 AND SUM(PD.Subtotal) IS NOT NULL  THEN 1
			   ELSE 0
			  END  = 1	)
	  ORDER BY IdPedidoGeneral DESC

        END;

        IF @F_TipoPedido = 'Compra directa'
        BEGIN
			
		SELECT coRegistro.IdRegistro AS IdPedido,
               coRegistro.IdFactura AS IdSolicitudPedido,
               TAO.FechaRegistro AS FechaEnvioPedido,
               fiFact.SubTotal AS TotalPedido,
               ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
               TE.Nombre,
               NULL AS Version,
               NULL AS RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               'Compra directa' AS TIPO,
               TAO.IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   'ACTIVO' AS Activo
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable
            LEFT JOIN dbo.CO_LineaPresupuestoMes linea
                ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = fiFact.IdMoneda
            LEFT JOIN dbo.S_Proveedor AS P
                ON P.RFC = fiFact.Emisor
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador =fiFact.IdFactura
				 AND PG.IdTipoPedido=1 AND PG.IdProveedorCliente=@IdProveedor
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.IdProveedor = @IdProveedor
			  AND 
			 CASE WHEN  P.IdProveedor = @F_IdProveedorPedido 
			 THEN 1
			  WHEN @F_IdProveedorPedido = 0 AND P.IdProveedor IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1
			  AND 
			 CASE WHEN  TAO.IdAsignador = @F_IdUsuarioCompras 
			 THEN 1
			  WHEN @F_IdUsuarioCompras = 0 AND TAO.IdAsignador IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1	
			    AND 
			 CASE WHEN  TAO.IdAsignador = @F_IdUsuarioRequitor 
			 THEN 1
			  WHEN @F_IdUsuarioRequitor = 0 AND TAO.IdAsignador IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1	
			    AND 
			 CASE WHEN  TM.IdMoneda  = @F_TipoMoneda 
			 THEN 1
			  WHEN @F_TipoMoneda = 0 AND TM.IdMoneda IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1	  
           AND CASE WHEN coRegistro.FecMovto BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
			 THEN 1
			  WHEN @ValidacionFecha= 0  AND  coRegistro.FecMovto   IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1	
		    AND CASE WHEN fiFact.SubTotal BETWEEN  @F_MontoInicio AND @F_MontoFin
			 THEN 1
			  WHEN @F_MontoFin = 0 AND  fiFact.SubTotal    IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1	
			 ORDER BY coRegistro.IdFactura DESC

        END;

        --IF @F_TipoPedido = 'Licitación'
        --BEGIN

        --    /*TODAVIA NO SE IMPLEMENTA ESTA TIPO DE COMPRA*/

        --END;

		IF @F_TipoPedido = 'Adjudicación directa'
        BEGIN	
			
		       SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(RazonSocial,'') + ' ' + ISNULL(RegimenCapital,'') AS Proveedor,
               E.Nombre,
               P.Version,
               P.RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               TP.TipoPedido AS TIPO,
               O.IdOperacion AS IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   CASE WHEN ISNULL(P.IdEstatusEliminado,0)<> 1 THEN 
			   'ACTIVO' 
			   ELSE 
			   'ELIMINADO' 
			   END  AS Activo
				FROM MM_Pedido AS P
					LEFT JOIN MM_PedidoDetalle AS PD
						ON PD.IdPedido = P.IdPedido
					LEFT JOIN MM_PeticionOferta AS PO
						ON PO.IdPeticionOferta = P.IdPeticionOferta
					LEFT JOIN S_Proveedor AS PV
						ON PV.IdProveedor = P.IdSubcontratista
					LEFT JOIN TA_Operacion AS O
						ON O.IdDocumento = P.IdSolicitudPedido
					LEFT JOIN TA_Prioridad AS PR
						ON PR.IdPrioridad = O.IdPrioridad
					LEFT JOIN TA_Vencimiento AS V
						ON V.IdVencimiento = O.IdVigencia
					LEFT JOIN TA_TipoOperacion AS TTO
						ON TTO.IdTipoOperacion = O.IdTipoOperacion
					LEFT JOIN TA_Estatus AS E
						ON E.IdEstatus = O.IdEstatusOperacion
					LEFT JOIN MM_HorasVigenciaPedido AS HV
						ON P.IdPedido = HV.IdPedido
					LEFT JOIN PV_TipoMoneda AS TM
						ON TM.IdMoneda = P.IdMoneda
					LEFT JOIN MM_Pedidos AS PG 
						ON P.IdPedido = PG.IdIdentificador 			
						AND PG.IdProveedorCliente = @IdProveedor
					LEFT JOIN MM_TipoPedido AS TP 
					ON TP.IdTipoPedido=PG.IdTipoPedido
					LEFT JOIN dbo.MM_SolicitudPedido AS SP
						ON	SP.IdSolicitudPedido=P.IdSolicitudPedido
				WHERE O.IdTipoOperacion = 9            
					 AND P.Version = O.NoVersion
					 AND PG.IdTipoPedido=4  ---> ADJUDICACIÓN DIRECTA
					 AND O.IdProveedor = @IdProveedor 
					 AND 
					 CASE WHEN  P.IdSubcontratista = @F_IdProveedorPedido 
					 THEN 1
					  WHEN @F_IdProveedorPedido = 0 AND P.IdSubcontratista IS NOT NULL  THEN 1
						ELSE 0
					  END  = 1
					 AND CASE WHEN  P.CreadoPor = @F_IdUsuarioCompras
					 THEN 1
					 WHEN @F_IdUsuarioCompras = 0 AND P.CreadoPor IS NOT NULL  THEN 1
						ELSE 0
					 END  = 1
					 AND CASE WHEN  SP.IdUsuarioSolicitante = @F_IdUsuarioRequitor
					  THEN 1
					 WHEN @F_IdUsuarioRequitor = 0 AND SP.IdUsuarioSolicitante IS NOT NULL  THEN 1
						ELSE 0
					 END  = 1
					 AND CASE WHEN  P.CreadoEl BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
					 THEN 1
					  WHEN @ValidacionFecha= 0 AND  P.CreadoEl  IS NOT NULL  THEN 1
						ELSE 0
					 END  = 1	
					 AND CASE WHEN TM.IdMoneda = @F_TipoMoneda
					 THEN 1
					  WHEN @F_TipoMoneda = 0 AND TM.IdMoneda IS NOT NULL  THEN 1
					   ELSE 0
					  END  = 1	
					  AND (CASE 
					 WHEN ISNULL(P.IdEstatusEliminado,0) = @F_MostrarEliminados THEN 
						1
					 WHEN @F_MostrarEliminados = 1  THEN 
						1
					 ELSE 
						0
					 END  = 1)
				GROUP BY P.IdPedido,
						 P.IdSolicitudPedido,
						 P.CreadoEl,
						 RazonSocial,
						 RegimenCapital,
						 P.RecepcionServicio,
						 E.Nombre,
						 P.Version,
						 TM.TipoMonedaCorto,
						 O.IdOperacion,
						 PG.IdPedido,
						 TP.TipoPedido,						
						 P.IdEstatusEliminado
			   HAVING (CASE WHEN SUM(PD.Subtotal) BETWEEN @F_MontoInicio AND @F_MontoFin 
					 THEN 1
					  WHEN @F_MontoFin = 0 AND SUM(PD.Subtotal) IS NOT NULL  THEN 1
					   ELSE 0
					  END  = 1	)
			  ORDER BY IdPedidoGeneral DESC

        END;
		 IF @F_TipoPedido = 'Comprobante extranjero'
			BEGIN
				SELECT PC.IdPedimentoComprobante AS IdPedido,
				   NULL AS IdSolicitudPedido,
				   TAO.FechaRegistro AS FechaEnvioPedido,
				   SUM(PCD.ImporteTotal) AS TotalPedido,
				   ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
				   TE.Nombre,
				   NULL AS Version,
				   NULL AS RecepcionServicio,
				   TM.TipoMonedaCorto AS TipoMoneda,
				   'Comprobante extranjero' AS TIPO,
				   TAO.IdOperacion,
				   PG.IdPedido AS IdPedidoGeneral,
				   'ACTIVO' AS Activo
			FROM dbo.FI_PedimentoComprobante AS PC
				INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD 
					ON PCD.IdPedimentoComprobante=PC.IdPedimentoComprobante            
				INNER JOIN TA_Operacion AS TAO
					ON TAO.IdDocumento = PC.IdPedimentoComprobante
				LEFT JOIN TA_Estatus AS TE
					ON TE.IdEstatus = TAO.IdEstatusOperacion  
				LEFT JOIN PV_TipoMoneda AS TM
					ON TM.IdMoneda = PC.IdMoneda
				LEFT JOIN dbo.S_Proveedor AS P
					ON P.IdProveedor = PC.IdSubcontratistaExportador
				LEFT JOIN dbo.MM_Pedidos PG
					ON PG.IdIdentificador =PC.IdPedimentoComprobante
					 AND PG.IdTipoPedido= 7 AND PG.IdProveedorCliente=@IdProveedor
			WHERE TAO.IdTipoOperacion = 16
				  AND TAO.IdProveedor = @IdProveedor
				 AND CASE WHEN  PC.IdSubcontratistaExportador = @F_IdProveedorPedido THEN 1
					WHEN @F_IdProveedorPedido = 0 AND PC.IdSubcontratistaExportador IS NOT NULL  THEN 1
					ELSE 0
				  END  = 1
				 AND CASE WHEN  PC.CreadoPor = @F_IdUsuarioRequitor THEN 1
					WHEN @F_IdUsuarioRequitor = 0 AND PC.CreadoPor IS NOT NULL  THEN 1
					ELSE 0
				  END  = 1
				AND CASE WHEN  PC.CreadoPor = @F_IdUsuarioCompras THEN 1
					WHEN @F_IdUsuarioCompras = 0 AND PC.CreadoPor IS NOT NULL  THEN 1
					ELSE 0
				  END  = 1
				AND CASE WHEN  PC.CreadoEn BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
					 THEN 1
					  WHEN @ValidacionFecha= 0 AND  PC.CreadoEn  IS NOT NULL  THEN 1
						ELSE 0
					 END  = 1	
				 AND CASE WHEN PC.IdMoneda = @F_TipoMoneda
				 THEN 1
				  WHEN @F_TipoMoneda = 0 AND PC.IdMoneda IS NOT NULL  THEN 1
				   ELSE 0
				  END  = 1
			GROUP BY 
			PC.IdPedimentoComprobante,        
			TAO.FechaRegistro,       
			P.RazonSocial,
			P.RegimenCapital,
			TE.Nombre,     
			TM.TipoMonedaCorto,     
			TAO.IdOperacion,
			PG.IdPedido
			HAVING (CASE WHEN SUM(PCD.ImporteTotal) BETWEEN @F_MontoInicio AND @F_MontoFin 
			 THEN 1
			  WHEN @F_MontoFin = 0 AND SUM(PCD.ImporteTotal) IS NOT NULL  THEN 1
			   ELSE 0
			  END  = 1	)
		 ORDER BY IdPedidoGeneral DESC 
			
		END 
    END;


	--#Busca todos los pedidos con los requerimientos solicitados 
    IF @Filtro = 'TODO_FILTRO'
    BEGIN
		
		/*FILTRAR TODOS LOS TIPOS DE PEDIDO DEACUERDO AL PARAMETRO SELECCIONADO*/
		SELECT * FROM (
		       /*PEDIDOS DE MERCADEO Y ADJUDICACIÓN DIRECTA*/
			
		       SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(RazonSocial,'') + ' ' + ISNULL(RegimenCapital,'') AS Proveedor,
               --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepción' END AS RecepcionServicio,
               E.Nombre,
               P.Version,
               P.RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               TP.TipoPedido AS TIPO,
               O.IdOperacion AS IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   CASE WHEN ISNULL(P.IdEstatusEliminado,0)<> 1 THEN 
				'ACTIVO' 
			   ELSE 
			    'ELIMINADO' 
			   END  AS Activo
        FROM MM_Pedido AS P
            LEFT JOIN MM_PedidoDetalle AS PD
                ON PD.IdPedido = P.IdPedido
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            LEFT JOIN S_Proveedor AS PV
                ON PV.IdProveedor = P.IdSubcontratista
            LEFT JOIN TA_Operacion AS O
                ON O.IdDocumento = P.IdSolicitudPedido
            LEFT JOIN TA_Prioridad AS PR
                ON PR.IdPrioridad = O.IdPrioridad
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            LEFT JOIN TA_TipoOperacion AS TTO
                ON TTO.IdTipoOperacion = O.IdTipoOperacion
            LEFT JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_HorasVigenciaPedido AS HV
                ON P.IdPedido = HV.IdPedido
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = P.IdMoneda
			LEFT JOIN MM_Pedidos AS PG 
				ON P.IdPedido = PG.IdIdentificador 			
				AND PG.IdProveedorCliente = @IdProveedor
			LEFT JOIN MM_TipoPedido AS TP 
			ON TP.IdTipoPedido=PG.IdTipoPedido
			LEFT JOIN dbo.MM_SolicitudPedido AS SP
				ON	SP.IdSolicitudPedido=P.IdSolicitudPedido
        WHERE O.IdTipoOperacion = 9            
             AND P.Version = O.NoVersion
			 AND (PG.IdTipoPedido=2 OR PG.IdTipoPedido=4 )---> MERCADEO OR ADJUDICACION DIRECTA
			 AND O.IdProveedor = @IdProveedor 
			 AND 
			 CASE WHEN  P.IdSubcontratista = @F_IdProveedorPedido 
			 THEN 1
			  WHEN @F_IdProveedorPedido = 0 AND P.IdSubcontratista IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1
			 AND CASE WHEN  P.CreadoPor = @F_IdUsuarioCompras
			 THEN 1
			 WHEN @F_IdUsuarioCompras = 0 AND P.CreadoPor IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1
			 AND CASE WHEN  SP.IdUsuarioSolicitante = @F_IdUsuarioRequitor
			  THEN 1
			 WHEN @F_IdUsuarioRequitor = 0 AND SP.IdUsuarioSolicitante IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1
			 AND CASE WHEN  P.CreadoEl BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
			 THEN 1
			  WHEN @ValidacionFecha= 0 AND  P.CreadoEl  IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1	
			 AND CASE WHEN TM.IdMoneda = @F_TipoMoneda
			 THEN 1
			  WHEN @F_TipoMoneda = 0 AND TM.IdMoneda IS NOT NULL  THEN 1
			   ELSE 0
			  END  = 1	
			AND (CASE 
			WHEN ISNULL(P.IdEstatusEliminado,0) = @F_MostrarEliminados THEN 
				1
			WHEN @F_MostrarEliminados = 1  THEN 
				1
			ELSE 
				0
			END  = 1)
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.CreadoEl,
                 RazonSocial,
                 RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 O.IdOperacion,
				 PG.IdPedido,
				 TP.TipoPedido,
				 P.IdEstatusEliminado	   
	   HAVING (CASE WHEN SUM(PD.Subtotal) BETWEEN @F_MontoInicio AND @F_MontoFin 
			 THEN 1
			  WHEN @F_MontoFin = 0 AND SUM(PD.Subtotal) IS NOT NULL  THEN 1
			   ELSE 0
			  END  = 1	)

			 UNION ALL 

			SELECT PC.IdPedimentoComprobante AS IdPedido,
				   NULL AS IdSolicitudPedido,
				   TAO.FechaRegistro AS FechaEnvioPedido,
				   SUM(PCD.ImporteTotal) AS TotalPedido,
				   ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
				   TE.Nombre,
				   NULL AS Version,
				   NULL AS RecepcionServicio,
				   TM.TipoMonedaCorto AS TipoMoneda,
				   'Comprobante extranjero' AS TIPO,
				   TAO.IdOperacion,
				   PG.IdPedido AS IdPedidoGeneral,
				   'ACTIVO' AS Activo
			FROM dbo.FI_PedimentoComprobante AS PC
				INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD 
					ON PCD.IdPedimentoComprobante=PC.IdPedimentoComprobante            
				INNER JOIN TA_Operacion AS TAO
					ON TAO.IdDocumento = PC.IdPedimentoComprobante
				LEFT JOIN TA_Estatus AS TE
					ON TE.IdEstatus = TAO.IdEstatusOperacion  
				LEFT JOIN PV_TipoMoneda AS TM
					ON TM.IdMoneda = PC.IdMoneda
				LEFT JOIN dbo.S_Proveedor AS P
					ON P.IdProveedor = PC.IdSubcontratistaExportador
				LEFT JOIN dbo.MM_Pedidos PG
					ON PG.IdIdentificador =PC.IdPedimentoComprobante
					 AND PG.IdTipoPedido= 7 AND PG.IdProveedorCliente=@IdProveedor
			WHERE TAO.IdTipoOperacion = 16
				  AND TAO.IdProveedor = @IdProveedor
				 AND CASE WHEN  PC.IdSubcontratistaExportador = @F_IdProveedorPedido THEN 1
					WHEN @F_IdProveedorPedido = 0 AND PC.IdSubcontratistaExportador IS NOT NULL  THEN 1
					ELSE 0
				  END  = 1
				 AND CASE WHEN  PC.CreadoPor = @F_IdUsuarioRequitor THEN 1
					WHEN @F_IdUsuarioRequitor = 0 AND PC.CreadoPor IS NOT NULL  THEN 1
					ELSE 0
				  END  = 1
				AND CASE WHEN  PC.CreadoPor = @F_IdUsuarioCompras THEN 1
					WHEN @F_IdUsuarioCompras = 0 AND PC.CreadoPor IS NOT NULL  THEN 1
					ELSE 0
				  END  = 1
				AND CASE WHEN  PC.CreadoEn BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
					 THEN 1
					  WHEN @ValidacionFecha= 0 AND  PC.CreadoEn  IS NOT NULL  THEN 1
						ELSE 0
					 END  = 1	
				 AND CASE WHEN PC.IdMoneda = @F_TipoMoneda
				 THEN 1
				  WHEN @F_TipoMoneda = 0 AND PC.IdMoneda IS NOT NULL  THEN 1
				   ELSE 0
				  END  = 1
			GROUP BY 
			PC.IdPedimentoComprobante,        
			TAO.FechaRegistro,       
			P.RazonSocial,
			P.RegimenCapital,
			TE.Nombre,     
			TM.TipoMonedaCorto,     
			TAO.IdOperacion,
			PG.IdPedido
			HAVING (CASE WHEN SUM(PCD.ImporteTotal) BETWEEN @F_MontoInicio AND @F_MontoFin 
			 THEN 1
			  WHEN @F_MontoFin = 0 AND SUM(PCD.ImporteTotal) IS NOT NULL  THEN 1
			   ELSE 0
			  END  = 1	)
		
		UNION ALL

				SELECT coRegistro.IdRegistro AS IdPedido,
               coRegistro.IdFactura AS IdSolicitudPedido,
               TAO.FechaRegistro AS FechaEnvioPedido,
               fiFact.SubTotal AS TotalPedido,
               ISNULL(P.RazonSocial,'') + ' ' + ISNULL(P.RegimenCapital,'') AS Proveedor,
               TE.Nombre,
               NULL AS Version,
               NULL AS RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               'Compra directa' AS TIPO,
               TAO.IdOperacion,
			   PG.IdPedido AS IdPedidoGeneral,
			   'ACTIVO' AS Activo
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable
            LEFT JOIN dbo.CO_LineaPresupuestoMes linea
                ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
            LEFT JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = fiFact.IdMoneda
            LEFT JOIN dbo.S_Proveedor AS P
                ON P.RFC = fiFact.Emisor
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador =fiFact.IdFactura
				 AND PG.IdTipoPedido=1 AND PG.IdProveedorCliente=@IdProveedor
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.IdProveedor = @IdProveedor
			  AND 
			 CASE WHEN  P.IdProveedor = @F_IdProveedorPedido 
			 THEN 1
			  WHEN @F_IdProveedorPedido = 0 AND P.IdProveedor IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1
			  AND 
			 CASE WHEN  TAO.IdAsignador = @F_IdUsuarioCompras 
			 THEN 1
			  WHEN @F_IdUsuarioCompras = 0 AND TAO.IdAsignador IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1	
			    AND 
			 CASE WHEN  TAO.IdAsignador = @F_IdUsuarioRequitor 
			 THEN 1
			  WHEN @F_IdUsuarioRequitor = 0 AND TAO.IdAsignador IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1	
			    AND 
			 CASE WHEN  TM.IdMoneda  = @F_TipoMoneda 
			 THEN 1
			  WHEN @F_TipoMoneda = 0 AND TM.IdMoneda IS NOT NULL  THEN 1
				ELSE 0
			  END  = 1	  
           AND CASE WHEN coRegistro.FecMovto BETWEEN  @FECHA_INICIO_NEW AND DATEADD(HOUR,24,@FECHA_FIN_NEW)
			 THEN 1
			  WHEN @ValidacionFecha= 0  AND  coRegistro.FecMovto   IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1	
		    AND CASE WHEN fiFact.SubTotal BETWEEN  @F_MontoInicio AND @F_MontoFin
			 THEN 1
			  WHEN @F_MontoFin = 0 AND  fiFact.SubTotal    IS NOT NULL  THEN 1
				ELSE 0
			 END  = 1	
			 

	 ) Pedidos ORDER BY FechaEnvioPedido DESC

    END;
END;