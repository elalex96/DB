-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-18
-- Description:	Consulta Aceptaciones de pedido de extranjeros proveedor de ventas para pedimento o comprobante
-- Author:		Daniel Cruz
-- Update date: 01-06-18
-- Description:	Se agrego condicion de solo mostrar comprobantes de pago que no estes con estatus de eliminación en 1
-- =============================================
-- Author:		Jose Roman
-- Update date: 07-02-2019
-- Description:	Se agrega validacion para los flujos de tipo serial
-- =============================================
-- =============================================
-- Author:		Abel Rivera
-- Update date: 26/11/19
-- Description:	Se agrego la columna para mostrar los comprobantes sin flujo de aprobacion asignado
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros_PROCURA]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Estatus INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
     BEGIN

	 --Validacion de flujo Serial
	 DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT
    );
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);

    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM dbo.TA_Operacion O
        LEFT JOIN dbo.FI_PedimentoComprobante pc ON pc.IdPedimentoComprobante = o.IdDocumento
        INNER JOIN dbo.TA_Tarea t
            ON t.IdOperacion = O.IdOperacion
    WHERE O.IdTipoOperacion = 16
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
          AND t.IdAprobador = @IdUsuario
          AND t.NoSecuencia > 1;

    INSERT INTO @OperacionNoAprobadas
    (
        IdOperacion
    )
    SELECT O.IdOperacion
    FROM dbo.TA_Operacion O
        INNER JOIN @FlujoSerial f
            ON f.IdOperacion = O.IdOperacion
        INNER JOIN dbo.TA_Tarea T
            ON T.IdOperacion = O.IdOperacion
               AND T.NoSecuencia = (f.NoSecuencia - 1)
    WHERE O.IdTipoOperacion = 16
          AND T.IdEstatus <> 2;
	
	IF @Estatus IN (1,2,3)
	BEGIN
		
		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado AS CreadoEl,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Proveedor,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
        TP.TipoPedido ,
		CASE WHEN PC.CvTipoDocFacturacion = 2 THEN 
			'Pedimento de importación'
			WHEN pc.CvTipoDocFacturacion = 3 THEN 
			'Comprobante Extranjero'
			END  AS TipoDocumentoFacturacion,
		O.IdOperacion,
	    P.IdSolicitudPedido,
		Contrato = c.NumeroContrato
		FROM		dbo.MM_AceptacionPedido AP 
		INNER JOIN	dbo.MM_Pedido P 
		ON			P.IdPedido = AP.IdPedido
		INNER JOIN	MM_Pedidos AS PG
		ON			P.IdPedido = PG.IdIdentificador
		AND			PG.IdProveedorCliente = P.IdProveedorCompras
		INNER JOIN	dbo.MM_TipoPedido AS TP
		ON			TP.IdTipoPedido = PG.IdTipoPedido
		INNER JOIN	dbo.S_Proveedor PR 
		ON			PR.IdProveedor= P.IdSubcontratista 
		INNER JOIN	dbo.FI_AceptacionPedido_PedimentoComprobante APC 
		ON			APC.IdAceptacionPedido=AP.IdAceptacionPedido
		INNER JOIN	dbo.FI_PedimentoComprobante PC 
		ON			PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
		INNER JOIN	dbo.TA_Operacion O 
		ON			O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		INNER JOIN	dbo.TA_Estatus AS E
		ON			E.IdEstatus = O.IdEstatusOperacion		
		inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	P.IdContrato	=	C.IdContrato 
		WHERE		ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		AND			P.IdProveedorCompras=@IdProveedor	
		AND			O.IdEstatusOperacion=@Estatus	 
		AND			ISNULL(PC.IdEstatusEliminado,0)<> 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1
		AND			O.IdOperacion NOT IN (
                                       SELECT IdOperacion FROM @OperacionNoAprobadas
                                   )
		 GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 AP.Creado,
                 AP.NombreUsuarioEntrega,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 PG.IdPedido,
                 TP.IdTipoPedido,
                 PC.IdPedimentoComprobante,
                 TP.TipoPedido,
				 O.IdEstatusOperacion,
				 E.Nombre,
				 PC.CvTipoDocFacturacion,
				 O.IdOperacion,
				 PC.IdEstatusEliminado,
				 P.IdSolicitudPedido,
				 c.IdContrato,
				 c.NumeroContrato
        ORDER BY AP.IdAceptacionPedido DESC;		 
		 
       END  

	IF @Estatus =4
	BEGIN
	  
		-- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL
		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado AS CreadoEl,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Proveedor,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
        TP.TipoPedido ,
		CASE WHEN PC.CvTipoDocFacturacion = 2 THEN 
			'Pedimento de importación'
			WHEN pc.CvTipoDocFacturacion = 3 THEN 
			'Comprobante Extranjero'
			END  AS TipoDocumentoFacturacion,
		O.IdOperacion,		 
		E.Nombre AS Estatus,
		 P.IdSolicitudPedido,
		 Contrato = c.NumeroContrato
		FROM
		 dbo.MM_AceptacionPedido AP 
		 INNER JOIN dbo.MM_Pedido P 
			ON P.IdPedido = AP.IdPedido
		 INNER JOIN MM_Pedidos AS PG
             ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN dbo.MM_TipoPedido AS TP
                ON TP.IdTipoPedido = PG.IdTipoPedido
		 INNER JOIN dbo.S_Proveedor PR 
				ON PR.IdProveedor= P.IdSubcontratista 
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
		 INNER JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
		 INNER JOIN dbo.TA_Operacion O 
			ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 LEFT JOIN dbo.TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion	
		inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	P.IdContrato	=	C.IdContrato 	 
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
		 AND ISNULL(PC.IdEstatusEliminado,0)<> 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1		
		 AND P.IdProveedorCompras=@IdProveedor			
		 AND O.IdOperacion NOT IN (
                                       SELECT IdOperacion FROM @OperacionNoAprobadas
                                   )
		AND ISNULL(O.IdFlujoTarea,0) <> 0		 
		 GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 AP.Creado,
                 AP.NombreUsuarioEntrega,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 PG.IdPedido,
                 TP.IdTipoPedido,
                 PC.IdPedimentoComprobante,
                 TP.TipoPedido,
				 O.IdEstatusOperacion,
				 E.Nombre,
				 PC.CvTipoDocFacturacion,
				 O.IdOperacion,
				 PC.IdEstatusEliminado,
				 P.IdSolicitudPedido,
				 c.IdContrato,
				 c.NumeroContrato
        ORDER BY AP.IdAceptacionPedido DESC;
		
       END  

	IF @Estatus = 5
	BEGIN
	  
		-- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL
		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado AS CreadoEl,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Proveedor,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
      TP.TipoPedido ,
		CASE WHEN PC.CvTipoDocFacturacion = 2 THEN 
			'Pedimento de importación'
			WHEN pc.CvTipoDocFacturacion = 3 THEN 
			'Comprobante Extranjero'
			END  AS TipoDocumentoFacturacion,
		O.IdOperacion,		 
		E.Nombre AS Estatus,
		 P.IdSolicitudPedido,
		Contrato = c.NumeroContrato
		FROM
		 dbo.MM_AceptacionPedido AP 
		 INNER JOIN dbo.MM_Pedido P 
			ON P.IdPedido = AP.IdPedido
		 INNER JOIN MM_Pedidos AS PG
             ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN dbo.MM_TipoPedido AS TP
                ON TP.IdTipoPedido = PG.IdTipoPedido
		 INNER JOIN dbo.S_Proveedor PR 
				ON PR.IdProveedor= P.IdSubcontratista 
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
		 INNER JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
		 INNER JOIN dbo.TA_Operacion O 
			ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 LEFT JOIN dbo.TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion		 
		 inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	P.IdContrato	=	C.IdContrato 
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
		 AND ISNULL(PC.IdEstatusEliminado,0)<> 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1		
		 AND P.IdProveedorCompras=@IdProveedor			
		 --AND O.IdOperacion NOT IN (
   --                                    SELECT IdOperacion FROM @OperacionNoAprobadas
   --                                )
		AND ISNULL(O.IdFlujoTarea,0) = 0
		AND O.IdEstatusOperacion = 9		 
		 GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 AP.Creado,
                 AP.NombreUsuarioEntrega,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 PG.IdPedido,
                 TP.IdTipoPedido,
                 PC.IdPedimentoComprobante,
                 TP.TipoPedido,
				 O.IdEstatusOperacion,
				 E.Nombre,
				 PC.CvTipoDocFacturacion,
				 O.IdOperacion,
				 PC.IdEstatusEliminado,
				 P.IdSolicitudPedido,
				 c.NumeroContrato,
				 c.IdContrato
        ORDER BY AP.IdAceptacionPedido DESC;

		
       END  

  END;
