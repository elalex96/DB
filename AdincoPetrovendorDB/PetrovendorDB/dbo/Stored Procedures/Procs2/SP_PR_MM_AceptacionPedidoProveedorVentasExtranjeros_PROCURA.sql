USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros_PROCURA'
)
    DROP PROCEDURE SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros_PROCURA;
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros_PROCURA]    Script Date: 06/11/2023 06:36:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros_PROCURA]    Script Date: 19/12/2023 10:44:51 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-18
-- Description:	Consulta Aceptaciones de pedido de extranjeros proveedor de ventas para pedimento o comprobante
-- Author:		Daniel Cruz
-- Update date: 01-06-18- / 19-12-2023
-- Description:	Se agrego condicion de solo mostrar comprobantes de pago que no estes con estatus de eliminación en 1/ Se agrega filtro para que descarte solo las aprobaciones seriales a los aprobadores que aun no les toca realizar aprobación
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
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
AS
     BEGIN


	 --Validacion de flujo Serial
	 DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT
    );
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);

	 CREATE TABLE #AceptacionesPedidoExtranjeros(  
	 IdAceptacionPedido INT NULL,  
	 IdPedido INT NULL,  
	 CreadoEl DATETIME NULL,  
	 NombreUsuarioEntrega VARCHAR(max) NULL,  
	 Proveedor VARCHAR(max) NULL,  
	 IdPedidoGeneral INT NULL,  
	 IdTipoPedido INT NULL,
	 IdPedimentoComprobante INT NULL,  
	 TipoPedido VARCHAR(max) NULL,
	 TipoDocumentoFacturacion VARCHAR(max) NULL,  
	 IdOperacion INT NULL,
	 Estatus VARCHAR(200) NULL,  
	 IdSolicitudPedido INT NULL,
	 Contrato VARCHAR(max) NULL 
	);  

	-- SOLO FILTRAR LAS APROBACIONES DE COMPROBANTE EXTRANJERO QUE SON SERIALES 
    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM dbo.TA_Operacion O (NOLOCK)
        JOIN dbo.FI_PedimentoComprobante pc (NOLOCK)
			ON o.IdDocumento = pc.IdPedimentoComprobante 
		JOIN TA_FlujoTarea FT (NOLOCK) 
			ON O.IdFlujoTarea = FT.IdFlujoTarea
		JOIN TA_TipoFlujoTarea	OFT (NOLOCK)
			ON FT.IdTipoFlujo = OFT.IdTipoFlujoTarea
        JOIN dbo.TA_Tarea t (NOLOCK)
            ON O.IdOperacion = t.IdOperacion 
    WHERE O.IdTipoOperacion = 16 --> CTE COMPROBANTE EXTRANJERO
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
		  AND OFT.Nombre ='Serial'
          AND t.IdAprobador = @IdUsuario
          AND t.NoSecuencia > 1; --> SOLO INCLUIR A SI EL USUARIO NO ES EL PRIMER APROBADOR

    INSERT INTO @OperacionNoAprobadas
    (
        IdOperacion
    )
    SELECT O.IdOperacion
    FROM dbo.TA_Operacion O (NOLOCK)
        INNER JOIN @FlujoSerial f
            ON O.IdOperacion = f.IdOperacion 
        INNER JOIN dbo.TA_Tarea T (NOLOCK)
            ON O.IdOperacion = T.IdOperacion
               AND (f.NoSecuencia - 1) = T.NoSecuencia 
    WHERE O.IdTipoOperacion = 16 --> CTE COMPROBANTE EXTRANJERO
          AND T.IdEstatus <> 2; --> CTE DONDE NO ESTE COMO APROBADO
	
	IF @Estatus IN (1,2,3)
	BEGIN
		
		INSERT INTO #AceptacionesPedidoExtranjeros(  
		 IdAceptacionPedido,  
		 IdPedido,  
		 CreadoEl,  
		 NombreUsuarioEntrega,  
		 Proveedor,  
		 IdPedidoGeneral,  
		 IdTipoPedido,
		 IdPedimentoComprobante,  
		 TipoPedido,
		 TipoDocumentoFacturacion,  
		 IdOperacion,		 
		 IdSolicitudPedido,
		 Contrato 
		)
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
		FROM		dbo.MM_AceptacionPedido AP (NOLOCK) 
		INNER JOIN	dbo.MM_Pedido P (NOLOCK) 
		ON			AP.IdPedido = P.IdPedido
		INNER JOIN	MM_Pedidos AS PG (NOLOCK)
		ON			P.IdPedido = PG.IdIdentificador
		AND			P.IdProveedorCompras = PG.IdProveedorCliente
		INNER JOIN	dbo.MM_TipoPedido AS TP (NOLOCK)
		ON			PG.IdTipoPedido = TP.IdTipoPedido
		INNER JOIN	dbo.S_Proveedor PR (NOLOCK) 
		ON			P.IdSubcontratista  = PR.IdProveedor
		INNER JOIN	dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK) 
		ON			AP.IdAceptacionPedido = APC.IdAceptacionPedido
		INNER JOIN	dbo.FI_PedimentoComprobante PC (NOLOCK) 
		ON			APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		INNER JOIN	dbo.TA_Operacion O  (NOLOCK)
		ON			PC.IdPedimentoComprobante  = O.IdDocumento
					AND O.IdTipoOperacion=16 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
		INNER JOIN	dbo.TA_Estatus AS E (NOLOCK)
		ON			 O.IdEstatusOperacion	 = E.IdEstatus 
		INNER JOIN	Adinco.dbo.CO_Contrato	AS	C (NOLOCK) 	
		ON			P.IdContrato	=	C.IdContrato 
		WHERE		ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> CTE NACIONALIDAD EXTRANJERA		
		AND			P.IdProveedorCompras=@IdProveedor	
		AND			O.IdEstatusOperacion=@Estatus	 
		AND			ISNULL(PC.IdEstatusEliminado,0)<> 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1
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
		 
		 -- ELIMINAR LAS OPERACIONES QUE AUN NO ESTAN APROBADAS Y QUE NO SE DEBEN MOSTRAR AL APROBADOR DE UNA APROB SERIAL
		 DELETE AFE
		 FROM #AceptacionesPedidoExtranjeros AFE
		 JOIN @OperacionNoAprobadas ONA 
			ON AFE.IdOperacion = ONA.IdOperacion		

       END  

	IF @Estatus =4
	BEGIN
	  
		-- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL
		INSERT INTO #AceptacionesPedidoExtranjeros(  
		 IdAceptacionPedido,  
		 IdPedido,  
		 CreadoEl,  
		 NombreUsuarioEntrega,  
		 Proveedor,  
		 IdPedidoGeneral,  
		 IdTipoPedido,
		 IdPedimentoComprobante,  
		 TipoPedido,
		 TipoDocumentoFacturacion,  
		 IdOperacion,	
		 Estatus,
		 IdSolicitudPedido,
		 Contrato 
		)
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
		 dbo.MM_AceptacionPedido AP  (NOLOCK)
		 INNER JOIN dbo.MM_Pedido P  (NOLOCK)
			ON AP.IdPedido = P.IdPedido 
		 INNER JOIN MM_Pedidos AS PG (NOLOCK)
             ON P.IdPedido = PG.IdIdentificador
                   AND P.IdProveedorCompras = PG.IdProveedorCliente 
		 INNER JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido 
		 INNER JOIN dbo.S_Proveedor PR  (NOLOCK)
				ON P.IdSubcontratista  = PR.IdProveedor
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC  (NOLOCK)
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 INNER JOIN dbo.FI_PedimentoComprobante PC  (NOLOCK)
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		 INNER JOIN dbo.TA_Operacion O  (NOLOCK)
			ON PC.IdPedimentoComprobante  = O.IdDocumento
			AND O.IdTipoOperacion=16 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO		 
		INNER JOIN	Adinco.dbo.CO_Contrato	AS	C  (NOLOCK)	
			ON	P.IdContrato	=	C.IdContrato 	 
		LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
             ON O.IdEstatusOperacion = E.IdEstatus 	
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> CTE NACIONALIDAD EXTRANJERA
		 AND ISNULL(PC.IdEstatusEliminado,0)<> 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1		
		 AND P.IdProveedorCompras=@IdProveedor			
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

		 -- ELIMINAR LAS OPERACIONES QUE AUN NO ESTAN APROBADAS Y QUE NO SE DEBEN MOSTRAR AL APROBADOR DE UNA APROB SERIAL
		 DELETE AFE
		 FROM #AceptacionesPedidoExtranjeros AFE
		 JOIN @OperacionNoAprobadas ONA 
			ON AFE.IdOperacion = ONA.IdOperacion	
    END  

	IF @Estatus = 5
	BEGIN
	  
		-- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL
		INSERT INTO #AceptacionesPedidoExtranjeros(  
		 IdAceptacionPedido,  
		 IdPedido,  
		 CreadoEl,  
		 NombreUsuarioEntrega,  
		 Proveedor,  
		 IdPedidoGeneral,  
		 IdTipoPedido,
		 IdPedimentoComprobante,  
		 TipoPedido,
		 TipoDocumentoFacturacion,  
		 IdOperacion,	
		 Estatus,
		 IdSolicitudPedido,
		 Contrato 
		)
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
		FROM dbo.MM_AceptacionPedido AP  (NOLOCK)
		 INNER JOIN dbo.MM_Pedido P  (NOLOCK)
			ON AP.IdPedido = P.IdPedido
		 INNER JOIN MM_Pedidos AS PG (NOLOCK)
             ON P.IdPedido = PG.IdIdentificador
                   AND  P.IdProveedorCompras = PG.IdProveedorCliente
		 INNER JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido
		 INNER JOIN dbo.S_Proveedor PR  (NOLOCK)
				ON P.IdSubcontratista  = PR.IdProveedor
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC  (NOLOCK)
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 INNER JOIN dbo.FI_PedimentoComprobante PC  (NOLOCK)
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		 INNER JOIN dbo.TA_Operacion O  (NOLOCK)
			ON PC.IdPedimentoComprobante  = O.IdDocumento
			AND O.IdTipoOperacion=16 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
		 INNER JOIN	Adinco.dbo.CO_Contrato	AS	C 	 (NOLOCK)
			ON	P.IdContrato	=	C.IdContrato 
		 LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus 	 
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> CTE NACIONALIDAD EXTRANJERA
		 AND ISNULL(PC.IdEstatusEliminado,0)<> 1 --> CTE NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1		
		 AND P.IdProveedorCompras=@IdProveedor		
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
	   
	   SELECT 	   
		IdAceptacionPedido,  
		IdPedido,  
		CreadoEl,  
		NombreUsuarioEntrega,  
		Proveedor,  
		IdPedidoGeneral,  
		IdTipoPedido,
		IdPedimentoComprobante,  
		TipoPedido,
		TipoDocumentoFacturacion,  
		IdOperacion,	
		Estatus,
		IdSolicitudPedido,
		Contrato 
		FROM #AceptacionesPedidoExtranjeros
  END;

