--USE [Petrovendor]
--GO
--IF EXISTS
--(
--    SELECT 1
--    FROM dbo.sysobjects
--    WHERE name = 'SP_MM_HistorialEliminacion_Procura'
--)
--    DROP PROCEDURE SP_MM_HistorialEliminacion_Procura;   
	
--GO
/****** Object:  StoredProcedure [dbo].[SP_MM_HistorialEliminacion_Procura]    Script Date: 06/11/2024 05:46:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description: ELIMINACIÓN DE PEDIDO HISTORIAL DE PROCURA
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 05/07/2022
-- Description: correccion al eliminar factura
-- =============================================
-- =============================================
-- Author:	DANIEL AC
-- Create date: 07/11/2024
-- Description: SE AGREGA CONSULTA PARA TOMAR EN CUENTA CUANDO UNA CARTA CN ES EXCLUIDA Y LA ACEPTACIÓN TIENE FACTURA Y CUANDO SE RESTAURA UNA SP
-- =============================================

CREATE  PROCEDURE [dbo].[SP_MM_HistorialEliminacion_Procura]  

 @IDPROVEEDOR INT,
 @IDCONTRATO INT,
 @IDUSUARIO INT,
 @ACCION NVARCHAR(MAX) = NULL,
 @IDELIMINADO INT =NULL

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
   SET NOCOUNT ON;
   CREATE TABLE #PROCESO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500),IDESTATUS INT, CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT, ID_PROCESO_PUBLICO INT )
   DECLARE @HistorialActivo BIT = 1
   DECLARE @TIPO_ELIMINACION NVARCHAR(50) 
   DECLARE @ID_PROCESO INT 

	IF (@ACCION = 'HISTORIAL_ELIMINADOS' OR @ACCION = 'HISTORIAL_RECUPERADOS')
	BEGIN 
	 
		IF @ACCION = 'HISTORIAL_RECUPERADOS'
			SET @HistorialActivo = 0

		SELECT 
		RE.IdEliminacion,
		RE.FechaRegistro AS FechaEliminacion,
		te.DetalleEliminacion,
		CASE WHEN TE.TipoEliminacion = 'P' THEN 
			PG.IdPedido /*CUANDO SEA UN PEDIO SE DEBE MOSTRAR EL ID PEDIDO GENERAL */
		ELSE 
			RE.IdProceso 
		END AS NoProceso,
		RE.ComentarioExterno,
		RE.ComentarioInterno,
		U.Nombre AS Usuario,
		RE.FechaRecuperacion, 
		UR.Nombre AS UsuarioRecuperador,
		RE.ComentarioRecuperacion,
		RE.Activo
		FROM AD_RegistroEliminacion RE (NOLOCK)
		INNER  JOIN AD_TipoEliminacion TE (NOLOCK)
			ON  RE.TipoEliminacion = TE.TipoEliminacion
		LEFT JOIN S_Usuario U (NOLOCK)
			ON RE.IdUsuario = U.IdUsuario
		LEFT JOIN MM_Pedidos PG (NOLOCK)
			ON RE.IdProceso = PG.IdIdentificador 
			AND PG.IdProveedorCliente = @IDPROVEEDOR
			AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS DE MERCADEO, DIRECTA 
		LEFT JOIN S_Usuario UR (NOLOCK)
			ON  RE.RecuperadoPor = UR.IdUsuario 
		WHERE 
		RE.IdProveedor=@IDPROVEEDOR 
		AND RE.Activo  = @HistorialActivo --> SIRVE PARA MOSTRAR EN HISTORIAL DE ELIMINACION / HISTORIAL DE ELIMINADOS 
		ORDER BY RE.FechaRegistro DESC 
	END 

	IF @ACCION = 'HISTORIAL_DETALLE'
	BEGIN
				 
		SELECT @ID_PROCESO=IdProceso,
		@TIPO_ELIMINACION=TipoEliminacion
		FROM  AD_RegistroEliminacion (NOLOCK)
		WHERE IdEliminacion = @IDELIMINADO 
		AND Activo = 1

		/*HISTORIAL DE ELIMINACIÓN DE UNA ACEPTACIÓN DE PEDIDO*/
		IF @TIPO_ELIMINACION='AP' AND @ID_PROCESO IS NOT NULL
		BEGIN 
						 
			/*RECUPERAR ACEPTACIONES DE PEDIDO ELIMINADOS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT
			0,
			CONCAT('Aceptación de pedido No.',AP.IdAceptacionPedido),
			'',
			0,
			'',
			'aceptacionpedido',
			'',
			AP.IdAceptacionPedido
			FROM dbo.MM_AceptacionPedido AP (NOLOCK)
			WHERE IdAceptacionPedido=@ID_PROCESO 
			AND AP.IdEliminado= @IDELIMINADO


			/*RECUPERAR CARTA DE CONTENIDO NACIONAL ELIMINADAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
			CASE WHEN AC.IdEstatus IS NULL THEN 
				'<i class="fa fa-tag text-warning"></i> Solicitada al proveedor'
				ELSE 
				'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion
			END,
			AC.IdEstatus,
			'',
			'aceptacioncn',
			'',	
			AC.IdAceptacionCartaPCN
			FROM MM_AceptacionPedido AS AP (NOLOCK)
			INNER JOIN MM_Pedido AS P  (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			LEFT JOIN MM_AceptacionCartaPCN AS AC  (NOLOCK)
				ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			LEFT JOIN S_Documento_S3 AS D  (NOLOCK)
				ON AC.IdDocumento = D.IdDocumento 
			LEFT JOIN S_TipoValidacionDoc AS TD  (NOLOCK)
				ON AC.IdEstatus = TD.IdTipoValidacionDoc
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
				ON P.IdSubcontratista = PV.IdProveedor 
			INNER JOIN MM_Pedidos AS PG  (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO PAP  (NOLOCK)
				ON AP.IdAceptacionPedido = PAP.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE 
			 AC.IdEliminado = @IDELIMINADO  
			 AND PAP.CLAVE_PROCESO='aceptacionpedido'			
			GROUP BY 
			AC.IdAceptacionCartaPCN	,
			TD.TipoValidacion,
			AP.IdAceptacionPedido,
			AC.IdEstatus,
			PAP.ID
			
			/*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS CON CARTA*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			TEM_CN.ID,
			CONCAT('Recepción de factura No.',AF.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			O.IdEstatusOperacion,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura
			FROM MM_AceptacionFactura AS AF (NOLOCK)
			INNER JOIN  TA_Operacion AS O (NOLOCK)
				ON AF.IdAceptacionFactura = O.IdDocumento
				AND O.IdTipoOperacion = 10	
			INNER JOIN TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus 			
			INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON   AP.IdPedido = P.IdPedido 
			INNER JOIN MM_AceptacionCartaPCN AS AC(NOLOCK)
				ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D (NOLOCK)
				ON AC.IdDocumento =  D.IdDocumento 
			INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
				ON AC.IdEstatus = TD.IdTipoValidacionDoc 
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON  P.IdSubcontratista	 = PV.IdProveedor 
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdProveedorCliente = @IDPROVEEDOR	
			LEFT JOIN #PROCESO AS TEM_CN (NOLOCK)
				ON AC.IdAceptacionCartaPCN = TEM_CN.ID_PROCESO
			LEFT JOIN #PROCESO AS TEM_AP (NOLOCK)
				ON AF.IdAceptacionPedido = TEM_AP.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE AF.IdEliminado=@IDELIMINADO
			GROUP BY AP.IdAceptacionPedido,
			E.Nombre,
			O.IdEstatusOperacion,
			AF.IdAceptacionFactura,
			AF.IdAceptacionPedido,
			TEM_CN.ID;


			/*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS SIN CARTA*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Recepción de factura No.',AF.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre+' con exclusión de carta CN',
			O.IdEstatusOperacion,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura
			FROM MM_AceptacionFactura AS AF (NOLOCK)
			INNER JOIN  TA_Operacion AS O (NOLOCK)
				ON AF.IdAceptacionFactura = O.IdDocumento
				AND O.IdTipoOperacion = 10	
			INNER JOIN TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus 			
			INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON   AP.IdPedido = P.IdPedido 
			INNER JOIN RelacionCartaCNPedido RCN (NOLOCK)
				ON AP.IdAceptacionPedido = RCN.IdAceptacionPedido
				AND AP.IdPedido =  RCN.IdPedido
				AND RCN.PedirCarta = 0
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON  P.IdSubcontratista	 = PV.IdProveedor 
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdProveedorCliente = @IDPROVEEDOR				
			LEFT JOIN #PROCESO AS TEM_AP (NOLOCK)
				ON AF.IdAceptacionPedido = TEM_AP.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE AF.IdEliminado=@IDELIMINADO
			GROUP BY AP.IdAceptacionPedido,
			E.Nombre,
			O.IdEstatusOperacion,
			AF.IdAceptacionFactura,
			AF.IdAceptacionPedido,
			TEM_AP.ID;

		  /*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS */

		 INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
			CASE WHEN O.IdOperacion IS NULL THEN 
				'<i class="fa fa-tag text-warning"></i> Solicitado al proveedor'
				ELSE
				'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre
				END,
			O.IdEstatusOperacion,
			'',
			'aprobacionextranjera',
			'',
			PC.IdPedimentoComprobante	
			FROM MM_AceptacionPedido AS AP (NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON  AP.IdPedido = P.IdPedido	
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON P.IdSubcontratista = PV.IdProveedor 	
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdProveedorCliente = @IDPROVEEDOR	 
			INNER JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
				ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
			INNER JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
				ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
			INNER JOIN dbo.TA_Operacion O (NOLOCK)
				ON PC.IdPedimentoComprobante  = O.IdDocumento
				AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			INNER JOIN #PROCESO PAP (NOLOCK)
				ON AP.IdAceptacionPedido = PAP.ID_PROCESO
			INNER JOIN dbo.TA_Estatus AS E (NOLOCK)
				ON  O.IdEstatusOperacion = E.IdEstatus	
				AND PC.IdEliminado=@IDELIMINADO
				AND PAP.CLAVE_PROCESO='aceptacionpedido'

			SELECT ID,
			ID_PADRE, 
			PROCESO,
			ESTATUS,
			IDESTATUS, 
			CLASS, 
			CLAVE_PROCESO, 
			ACCION_EJECUTAR,
			ID_PROCESO, 
			ID_PROCESO_PUBLICO  
			FROM #PROCESO 

		END 

		IF @TIPO_ELIMINACION='P' AND @ID_PROCESO IS NOT NULL
		BEGIN 
			
			/*RECUPERAR ACEPTACIONES DE PEDIDO ELIMINADOAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT
			0,
			CONCAT('Pedido No.',PG.IdPedido),
			CONCAT('<i class="fa fa-info-circle text-warning" title="Este pedido pertenece a la siguiente aprobación"></i>',' Aprobación de pedido No. Operación ',O.IdOperacion,' <i class="fa fa-tag text-warning"></i> ',E.Nombre),
			0,
			'',
			'pedido',
			'',
			P.IdPedido
			FROM dbo.MM_Pedido P (NOLOCK)
			INNER JOIN dbo.MM_Pedidos PG  (NOLOCK)
				ON P.IdPedido  = PG.IdIdentificador 
			INNER JOIN dbo.TA_Operacion O  (NOLOCK)
				ON P.IdSolicitudPedido = O.IdDocumento
				AND P.Version =  O.NoVersion
				AND O.IdTipoOperacion = 9 --> CTE APROBACIÓN DE PEDIDO
			INNER JOIN dbo.TA_Estatus E  (NOLOCK)
				ON O.IdEstatusOperacion  = E.IdEstatus				
			WHERE 
			P.IdPedido=@ID_PROCESO   
			AND P.IdEliminado= @IDELIMINADO 
			AND PG.IdProveedorCliente=@IDPROVEEDOR

			/*RECUPERAR CONFIRMACIONES DE SERVICIO*/

				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			    SELECT 	
				TEM_PED.ID,
				'Confirmación de pedido',
				CASE 
				WHEN P.RecepcionServicio = 1 THEN '<i class="fa fa-tag text-warning"></i> Aceptada' 
				WHEN P.RecepcionServicio  = 0 THEN '<i class="fa fa-tag text-warning"></i> Rechazada' 
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
						'<i class="fa fa-tag text-warning"></i> Vencida'  
				ELSE 	  
						'<i class="fa fa-tag text-warning"></i> En confirmación' 
				END AS RecepcionServicio,
				'',
				'confirmacionpedido',
				'', 
				P.IdPedido,
				PG.IdPedido	
				FROM TA_Operacion AS O (NOLOCK)
				INNER JOIN MM_Pedido AS P  (NOLOCK)
					ON O.IdDocumento = P.IdSolicitudPedido
				INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
					ON P.IdPedido = HV.IdPedido
				INNER JOIN S_Proveedor AS PV  (NOLOCK)
					ON P.IdSubcontratista	= PV.IdProveedor 	
				INNER JOIN TA_Estatus AS E (NOLOCK)
					ON O.IdEstatusOperacion= E.IdEstatus 
				LEFT JOIN PV_TipoMoneda AS TM  (NOLOCK)
					ON P.IdMoneda = TM.IdMoneda
				INNER JOIN MM_Pedidos AS PG  (NOLOCK)
					ON P.IdPedido = PG.IdIdentificador 
					AND PG.IdProveedorCliente = @IDPROVEEDOR				
				INNER JOIN #PROCESO AS TEM_PED (NOLOCK)
					ON P.IdPedido = TEM_PED.ID_PROCESO
				LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
					ON PG.IdTipoPedido = TP.IdTipoPedido
				WHERE O.IdTipoOperacion = 9  --> APROBACIÓN DE PEDIDO
				 AND O.IdEstatusOperacion=2 --> APROBADA
				 AND O.IdProveedor = @IDPROVEEDOR 				  
				 AND O.NoVersion=P.Version							
				 AND TEM_PED.CLAVE_PROCESO='pedido'		
				 AND P.IdEliminado=@IDELIMINADO		 
				GROUP BY 
				P.IdPedido,
				PV.Razonsocial,
				PV.RegimenCapital,
				PG.IdPedido,				
				TEM_PED.ID,
				P.RecepcionServicio,
				HV.FechaVigencia,
				O.IdEstatusOperacion 

			
			/*RECUPERAR ACEPTACIONES DE PEDIDO ELIMINADOAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT
			P.ID,
			CONCAT('Aceptación de Servicio No.',AP.IdAceptacionPedido),
			'',
			0,
			'',
			'aceptacionpedido',
			'',
			AP.IdAceptacionPedido
			FROM dbo.MM_AceptacionPedido AP (NOLOCK)
			INNER JOIN #PROCESO P  (NOLOCK)
				ON P.ID_PROCESO=AP.IdPedido
			INNER JOIN #PROCESO PC  (NOLOCK)
				ON AP.IdPedido = PC.ID_PROCESO
			WHERE AP.IdEliminado= @IDELIMINADO
			AND P.CLAVE_PROCESO='pedido'
			AND PC.CLAVE_PROCESO='confirmacionpedido'



			/*RECUPERAR CARTA DE CONTENIDO NACIONAL ELIMINADAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion,
			AC.IdEstatus,
			'',
			'aceptacioncn',
			'',	
			AC.IdAceptacionCartaPCN
			FROM MM_AceptacionPedido AS AP(NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON AP.IdPedido =  P.IdPedido	
			INNER JOIN MM_AceptacionCartaPCN AS AC(NOLOCK)
				ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D(NOLOCK)
				ON  AC.IdDocumento = D.IdDocumento 
			INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
				ON  AC.IdEstatus = TD.IdTipoValidacionDoc
			INNER JOIN S_Proveedor AS PV(NOLOCK)
				ON P.IdSubcontratista = PV.IdProveedor 
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador
				AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO PAP (NOLOCK)
				ON AP.IdAceptacionPedido = PAP.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE 
			 AC.IdEliminado = @IDELIMINADO  
			GROUP BY 
			AC.IdAceptacionCartaPCN	,
			TD.TipoValidacion,
			AP.IdAceptacionPedido,
			AC.IdEstatus,
			PAP.ID


			/*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS CON CARTA */

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			TEM_CN.ID,
			CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			O.IdEstatusOperacion,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura
			FROM MM_AceptacionFactura AS AF (NOLOCK)
			INNER JOIN  TA_Operacion AS O (NOLOCK)
				ON  AF.IdAceptacionFactura = O.IdDocumento  
				AND O.IdTipoOperacion = 10 	
			INNER JOIN TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion= E.IdEstatus 			
			INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			INNER JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
				ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D (NOLOCK)
				ON  AC.IdDocumento = D.IdDocumento
			INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
				ON  AC.IdEstatus = TD.IdTipoValidacionDoc
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
				ON  P.IdSubcontratista= PV.IdProveedor	
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO AS TEM_CN  (NOLOCK)
				ON AC.IdAceptacionCartaPCN = TEM_CN.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE 	
		  TEM_CN.CLAVE_PROCESO='aceptacioncn'
		  AND AF.IdEliminado=@IDELIMINADO
		  AND TEM_CN.IdEstatus=2 --> CN APROBADA

		  /*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS SIN CARTA */

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre+' con exclusión de carta CN',
			O.IdEstatusOperacion,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura
			FROM MM_AceptacionFactura AS AF (NOLOCK)
			INNER JOIN  TA_Operacion AS O (NOLOCK)
				ON AF.IdAceptacionFactura  = O.IdDocumento 
				AND O.IdTipoOperacion = 10 	
			INNER JOIN TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion= E.IdEstatus 			
			INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			INNER JOIN RelacionCartaCNPedido RCN (NOLOCK)
				ON AP.IdPedido = RCN.IdPedido
				AND AP.IdAceptacionPedido = RCN.IdAceptacionPedido
				AND RCN.PedirCarta = 0
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
				ON  P.IdSubcontratista= PV.IdProveedor	
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO AS TEM_AP (NOLOCK)
				ON AP.IdAceptacionPedido = TEM_AP.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE 	
		  TEM_AP.CLAVE_PROCESO='aceptacionpedido'
		  AND AF.IdEliminado=@IDELIMINADO

		  /*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS  */

		 INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			O.IdEstatusOperacion,
			'',
			'aprobacionextranjera',
			'',
			PC.IdPedimentoComprobante	
			FROM MM_AceptacionPedido AS AP(NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON AP.IdPedido =  P.IdPedido 	
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON P.IdSubcontratista = PV.IdProveedor 
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador
				AND PG.IdProveedorCliente = @IDPROVEEDOR	 
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON  PG.IdTipoPedido = TP.IdTipoPedido
			INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
				ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
			INNER JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
				ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
			INNER JOIN dbo.TA_Operacion O (NOLOCK)
				ON PC.IdPedimentoComprobante  = O.IdDocumento
				AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			INNER JOIN #PROCESO PAP (NOLOCK)
				ON AP.IdAceptacionPedido = PAP.ID_PROCESO
			LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
				ON  O.IdEstatusOperacion = E.IdEstatus 				
			WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
			AND PC.IdEliminado=@IDELIMINADO
			AND PAP.CLAVE_PROCESO='aceptacionpedido'

			SELECT 
			ID,
			ID_PADRE, 
			PROCESO,
			ESTATUS,
			IDESTATUS, 
			CLASS, 
			CLAVE_PROCESO, 
			ACCION_EJECUTAR,
			ID_PROCESO, 
			ID_PROCESO_PUBLICO  
			FROM #PROCESO 

		END 

		IF @TIPO_ELIMINACION='SP' AND @ID_PROCESO IS NOT NULL
		BEGIN 
			
			/*RECUPERAR SOLICITUD DE PEDIDO CON EL IDELIMINADO*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
			SELECT 
			0,
			CONCAT('Solicitud de pedido No.', IdSolicitudPedido),
			'',
			'',
			'solicitudpedido',
			'', 
			IdSolicitudPedido,
			IdSolicitudPedido 
			FROM dbo.MM_SolicitudPedido   (NOLOCK)
			WHERE IdSolicitudPedido=@ID_PROCESO
			AND ISNULL(IdEstatusEliminado,0) = 1
	
			/*BUSQUEDA DE APROBACIÓN DE SOLICITUD DE PEDIDO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)	
			SELECT 1,
			CONCAT('Aprobación de solicitud de pedido No. Operación ',O.IdOperacion),
			CONCAT('<i class="fa fa-tag text-warning"></i> ',E.Nombre),
			'',
			'aprobacionsp',
			'',
			O.IdOperacion,
			O.IdDocumento  
			FROM dbo.MM_SolicitudPedido AS SP (NOLOCK)
			INNER JOIN dbo.TA_Operacion AS O  (NOLOCK)
				ON SP.IdSolicitudPedido = O.IdDocumento
			INNER JOIN dbo.TA_Estatus AS E  (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus
			WHERE SP.IdSolicitudPedido=@ID_PROCESO  
				AND O.IdEliminado=@IDELIMINADO 
				AND O.IdTipoOperacion=2 -->APROBACIÓN DE SOLICITUD DE PEDIDO
			AND ISNULL(SP.IdEstatusEliminado,0)=1

			/*BUSQUEDA DE SOLICITUD DE OFERTA*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
			SELECT 2,
			CONCAT('Solicitud de oferta No.',SP.IdSolicitudPedido),
			CASE WHEN SP.PeticionEnviada = 1 THEN 
				'<i class="fa fa-tag text-warning"></i> Enviada a cotización'
			ELSE 
				'<i class="fa fa-tag text-warning"></i> Sin enviar a cotización'
			END AS Estatus,
			'',
			'solicitudoferta',
			'', 
			SP.IdSolicitudPedido,
			SP.IdSolicitudPedido
			FROM dbo.MM_SolicitudPedido AS SP (NOLOCK)
			INNER JOIN dbo.TA_Operacion AS O (NOLOCK)
				ON  SP.IdSolicitudPedido = O.IdDocumento
			WHERE IdSolicitudPedido=@ID_PROCESO 
			AND O.IdTipoOperacion=2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
			AND O.IdEstatusOperacion=2 --> APROBADA
			AND ISNULL(SP.IdEstatusEliminado,0)=1

			/*BUSQUEDA DE OFERTA*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
			SELECT 3,CONCAT('Oferta No.',SP.IdSolicitudPedido),
			(CASE WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0) THEN
				'<i class="fa fa-tag text-warning"></i> Fecha límite de cotización finalizada'
			ELSE
				'<i class="fa fa-tag text-warning"></i> En cotización'
			END) AS ESTATUS
			,'', 'oferta','', SP.IdSolicitudPedido,SP.IdSolicitudPedido
			FROM dbo.MM_SolicitudPedido AS SP (NOLOCK)
			INNER JOIN dbo.TA_Operacion AS O (NOLOCK)
				ON SP.IdSolicitudPedido = O.IdDocumento 
			WHERE SP.IdSolicitudPedido=@ID_PROCESO 
			AND O.IdTipoOperacion=6 -->ENVIO PROCESO DE COTIZACIÓN
			AND ISNULL(SP.IdEstatusEliminado,0)=1


			/*BUSQUEDA DE APROBACIONES DE PEDIDO*/
			/*CONTAR CANTIDAD DE APROBACIONES DE PEDIDO*/
			DECLARE @CANTIDAD_APROBACIONES INT = 0 
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 4, CONCAT('Aprobación de pedido No. Operación ', o.IdOperacion),CONCAT('<i class="fa fa-tag text-warning"></i> ',E.Nombre),'','aprobacionpedido','', o.IdOperacion 
			FROM dbo.MM_SolicitudPedido AS SP (NOLOCK)
			INNER JOIN dbo.TA_Operacion AS O (NOLOCK)
				ON SP.IdSolicitudPedido = O.IdDocumento 
			INNER JOIN dbo.TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus
			WHERE SP.IdSolicitudPedido=@ID_PROCESO
			AND O.IdTipoOperacion=9 --> APROBACIÓN DE PEDIDO
			ORDER BY O.IdOperacion ASC
								
			/*CONSULTA DE PEDIDO DE LAS APROBACIONES CORRESPONDIENTES*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM.ID,
			CONCAT('Pedido ', PG.IdPedido),
			'<span class="text-black">' +(PV.Razonsocial + ' '+ISNULL(PV.RegimenCapital,''))+'</span>',
			'',
			'pedido',
			'', 
			P.IdPedido,
			PG.IdPedido
			FROM TA_Operacion AS O (NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON  P.IdSubcontratista = PV.IdProveedor 	
			INNER JOIN TA_Estatus AS E (NOLOCK)
				ON  O.IdEstatusOperacion = E.IdEstatus
			LEFT  JOIN PV_TipoMoneda AS TM (NOLOCK)
				ON  P.IdMoneda = TM.IdMoneda
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO
			INNER JOIN #PROCESO AS TEM (NOLOCK)
				ON O.IdOperacion  = TEM.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
			 AND O.IdProveedor = @IdProveedor 
			 AND P.IdSolicitudPedido = @ID_PROCESO  
			 AND O.NoVersion=P.Version
			 AND O.IdOperacion=TEM.ID_PROCESO
			 AND TEM.CLAVE_PROCESO='aprobacionpedido'
			 AND ISNULL(P.IdEstatusEliminado,0)=1
			GROUP BY 
			P.IdPedido,
			PV.Razonsocial,
			PV.RegimenCapital,
			PG.IdPedido,
			TEM.ID

			/*CONFIRMACIÓN DE SERVICIO*/
			/*CONSULTA DE PEDIDO DE APROBADAS Y CON ACEPTACIÓN DE SERVICIO CORRESPONDIENTES AL PEDIDO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
		   SELECT 	
			TEM_PED.ID,
			'Confirmación de pedido',
			CASE 
			WHEN P.RecepcionServicio = 1 THEN '<i class="fa fa-tag text-warning"></i> Aceptada' 
			WHEN P.RecepcionServicio  = 0 THEN '<i class="fa fa-tag text-warning"></i> Rechazada' 
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					'<i class="fa fa-tag text-warning"></i> Vencida'  
			ELSE 	  
					'<i class="fa fa-tag text-warning"></i> En confirmación' 
			END AS RecepcionServicio,
			'',
			'confirmacionpedido',
			'', 
			P.IdPedido,
			PG.IdPedido	
			FROM TA_Operacion AS O (NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK) 
				ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
				ON P.IdPedido = HV.IdPedido
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON  P.IdSubcontratista	 = PV.IdProveedor
			INNER JOIN TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus 
			LEFT JOIN PV_TipoMoneda AS TM (NOLOCK)
				ON P.IdMoneda = TM.IdMoneda 
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO
			INNER JOIN #PROCESO AS TEM (NOLOCK)
				ON O.IdOperacion  = TEM.ID_PROCESO
			INNER JOIN #PROCESO AS TEM_PED (NOLOCK)
				ON P.IdPedido = TEM_PED.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE O.IdTipoOperacion = 9  --> APROBACIÓN DE PEDIDO
			 AND O.IdEstatusOperacion=2 --> APROBADA
			 AND O.IdProveedor = @IdProveedor 
			 AND P.IdSolicitudPedido = @ID_PROCESO  
			 AND O.NoVersion=P.Version
			 AND O.IdOperacion=TEM.ID_PROCESO
			 AND TEM.CLAVE_PROCESO='aprobacionpedido'
			 AND TEM_PED.CLAVE_PROCESO='pedido'
			 AND ISNULL(P.IdEstatusEliminado,0) = 1
			GROUP BY 
			P.IdPedido,
			PV.Razonsocial,
			PV.RegimenCapital,
			PG.IdPedido,
			TEM.ID,
			TEM_PED.ID,
			P.RecepcionServicio,
			HV.FechaVigencia,
			O.IdEstatusOperacion 
	  
			/*ACEPTACIONES DE PEDIDO*/ 
			/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
	 
			SELECT 	
			TEM_CS.ID,
			CONCAT('Aceptación de servicio No.',AP.IdAceptacionPedido),
			'',
			'',
			'aceptacionpedido',
			'',
			AP.IdAceptacionPedido,
			AP.IdAceptacionPedido	
			FROM TA_Operacion AS O  (NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN MM_AceptacionPedido AS AP  (NOLOCK)
				ON P.IdPedido = AP.IdPedido
			INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
				ON P.IdPedido = HV.IdPedido
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
				ON P.IdSubcontratista = PV.IdProveedor 		
			INNER JOIN TA_Estatus AS E  (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus  
			INNER JOIN PV_TipoMoneda AS TM  (NOLOCK)
				ON P.IdMoneda = TM.IdMoneda 
			INNER JOIN MM_Pedidos AS PG  (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO
 			INNER JOIN #PROCESO AS TEM  (NOLOCK)
				ON O.IdOperacion  = TEM.ID_PROCESO
			INNER JOIN #PROCESO AS TEM_PED  (NOLOCK)
				ON P.IdPedido = TEM_PED.ID_PROCESO 
			INNER JOIN #PROCESO AS TEM_CS  (NOLOCK)
				ON P.IdPedido = TEM_CS.ID_PROCESO 
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido  
			WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO APROBADA
			 AND O.IdEstatusOperacion=2 --> APROBADA
			 AND O.IdProveedor = @IdProveedor 
			 AND P.IdSolicitudPedido = @ID_PROCESO  
			 AND O.NoVersion=P.Version
			 AND O.IdOperacion=TEM.ID_PROCESO
			 AND TEM.CLAVE_PROCESO='aprobacionpedido'
			 AND TEM_PED.CLAVE_PROCESO='pedido'
			 AND TEM_CS.CLAVE_PROCESO='confirmacionpedido'
			 AND ISNULL(AP.IdEstatusEliminado,0) = 1
			GROUP BY 
			P.IdPedido,
			PV.Razonsocial,
			PV.RegimenCapital,
			PG.IdPedido,
			TEM.ID,
			TEM_PED.ID,
			P.RecepcionServicio,
			HV.FechaVigencia,
			O.IdEstatusOperacion,
			AP.IdAceptacionPedido,
			TEM_CS.ID	

			/*ACEPTACIONES DE CARTA CONTENIDO NACIONAL*/
			/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS Y CARTA DE CONTENIDO NACIONAL SI EL PROVEEDOR ES NACIONAL*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
			CASE WHEN AC.IdEstatus IS NULL THEN 
			'<i class="fa fa-tag text-warning"></i> Solicitada al proveedor'
			ELSE 
			'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion
			END,
			'',
			'aceptacioncn',
			'',
			AC.IdAceptacionCartaPCN,
			AP.IdAceptacionPedido	
			FROM MM_AceptacionPedido AS AP (NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			LEFT JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
				ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			LEFT JOIN S_Documento_S3 AS D (NOLOCK)
				ON AC.IdDocumento = D.IdDocumento
			LEFT JOIN S_TipoValidacionDoc AS TD (NOLOCK)
				ON AC.IdEstatus = TD.IdTipoValidacionDoc
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON P.IdSubcontratista	 = PV.IdProveedor  
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO 
			INNER JOIN #PROCESO AS TEM_AP (NOLOCK)
				ON AP.IdAceptacionPedido = TEM_AP.ID_PROCESO 
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			WHERE 
			 P.IdSolicitudPedido = @ID_PROCESO  	
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
			 AND ISNULL(AC.IdEstatusEliminado,0)=1
			GROUP BY 
			AC.IdAceptacionCartaPCN	,
			TD.TipoValidacion,
			AP.IdAceptacionPedido,
			AC.IdEstatus,
			TEM_AP.ID

		    /*RECEPCIÓN DE FACTURA CON CARTA*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_CN.ID,
			CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura,
			AP.IdAceptacionPedido
			FROM MM_AceptacionFactura AS AF  (NOLOCK)
			INNER JOIN  TA_Operacion AS O  (NOLOCK)
				ON  AF.IdAceptacionFactura = O.IdDocumento 
				AND O.IdTipoOperacion = 10 	--> CTE APROBACIÓN DE FACTURA
			INNER JOIN TA_Estatus AS E  (NOLOCK)
				ON  O.IdEstatusOperacion = E.IdEstatus 			
			INNER JOIN MM_AceptacionPedido AS AP  (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P  (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			INNER JOIN MM_AceptacionCartaPCN AS AC  (NOLOCK)
				ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D  (NOLOCK)
				ON AC.IdDocumento = D.IdDocumento
			INNER JOIN S_TipoValidacionDoc AS TD  (NOLOCK)
				ON AC.IdEstatus =TD.IdTipoValidacionDoc 
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
				ON  P.IdSubcontratista	 = PV.IdProveedor
			INNER JOIN MM_Pedidos AS PG  (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO
			INNER JOIN #PROCESO AS TEM_AP  (NOLOCK)
				ON AP.IdAceptacionPedido = TEM_AP.ID_PROCESO 
			INNER JOIN #PROCESO AS TEM_CN  (NOLOCK)
				ON AC.IdAceptacionCartaPCN = TEM_CN.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido
			WHERE 
			 P.IdSolicitudPedido = @ID_PROCESO  	
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
			 AND TEM_CN.CLAVE_PROCESO='aceptacioncn'
			 AND AC.IdEstatus=2 --> QUE LA APROBACIÓN DE CARTA CONTENIDO NACIONAL ESTE APROBADA

			  /*RECEPCIÓN DE FACTURA SIN CARTA*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre+' con exclusión de carta CN',
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura,
			AP.IdAceptacionPedido
			FROM MM_AceptacionFactura AS AF  (NOLOCK)
			INNER JOIN  TA_Operacion AS O  (NOLOCK)
				ON  AF.IdAceptacionFactura = O.IdDocumento 
				AND O.IdTipoOperacion = 10 	--> CTE APROBACIÓN DE FACTURA
			INNER JOIN TA_Estatus AS E  (NOLOCK)
				ON  O.IdEstatusOperacion = E.IdEstatus 			
			INNER JOIN MM_AceptacionPedido AS AP  (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P  (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			INNER JOIN RelacionCartaCNPedido RCN (NOLOCK)
				ON AP.IdPedido = RCN.IdPedido
				AND AP.IdAceptacionPedido = RCN.IdAceptacionPedido
				AND RCN.PedirCarta = 0
			INNER JOIN S_Proveedor AS PV  (NOLOCK)
				ON  P.IdSubcontratista	 = PV.IdProveedor
			INNER JOIN MM_Pedidos AS PG  (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO
			INNER JOIN #PROCESO AS TEM_AP  (NOLOCK)
				ON AP.IdAceptacionPedido = TEM_AP.ID_PROCESO 			
			LEFT JOIN  MM_TipoPedido AS TP  (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido
			WHERE 
			 P.IdSolicitudPedido = @ID_PROCESO  	
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'

			/*COMPROBANTE EXTRANJERO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
			CASE WHEN O.IdOperacion IS NULL THEN 
			'<i class="fa fa-tag text-warning"></i> Solicitado al proveedor'
			ELSE
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre
			END,
			'',
			'aprobacionextranjera',
			'',
			PC.IdPedimentoComprobante,
			AP.IdAceptacionPedido	
			FROM MM_AceptacionPedido AS AP(NOLOCK)
			INNER JOIN MM_Pedido AS P (NOLOCK)
				ON  AP.IdPedido = P.IdPedido 	
			INNER JOIN S_Proveedor AS PV (NOLOCK)
				ON P.IdSubcontratista = PV.IdProveedor 
			INNER JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras = PG.IdProveedorCliente 
				AND PG.IdTipoPedido IN (2,4,6) --> CTES PEDIDOS MERCADERO, ADJU DIRECTA Y ORDEN DE TRABAJO
			INNER JOIN #PROCESO AS TEM_AP (NOLOCK)
				ON AP.IdAceptacionPedido  = TEM_AP.ID_PROCESO
			LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido 
			LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
				ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
			LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
				ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante			 
			LEFT JOIN dbo.TA_Operacion O (NOLOCK)
				ON PC.IdPedimentoComprobante = O.IdDocumento 
				AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus 	
			WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
			 AND P.IdSolicitudPedido=	@ID_PROCESO		 
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
			 AND ISNULL(PC.IdEstatusEliminado,0) = 1

			SELECT ID,
			ID_PADRE, 
			PROCESO,
			ESTATUS,
			IDESTATUS, 
			CLASS, 
			CLAVE_PROCESO, 
			ACCION_EJECUTAR,
			ID_PROCESO, 
			ID_PROCESO_PUBLICO  
			FROM #PROCESO
	    END	
	END 

	/*BUSCAR TOLAS LAS SOLICITUDES DE PEDIDO CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'SOLICITUD_PEDIDO'  
	BEGIN 
			
		SELECT 
		SP.IdSolicitudPedido, 
		SP.MotivoUrgencia,
		TSP.TipoSolicitudPedido, 
		SP.FechaAlta,			
		TE.Nombre,
		CC.CentroCosto,
		U.Nombre AS NombreUsuario,
		SP.MotivoUrgencia,
		AC.NombreAreaContractual AS AreaContractual,
		SP.IdEliminado,
		RH.FechaRegistro AS FechaEliminacion				 
		FROM MM_SolicitudPedido AS SP (NOLOCK)
		INNER JOIN MM_TipoSolicitudPedido AS TSP(NOLOCK)
			ON SP.IdTipoSolicitudPedido  = TSP.IdTipoSolicitudPedido 
		INNER JOIN TA_Operacion AS TAO(NOLOCK)
			ON  SP.IdSolicitudPedido  =  TAO.IdDocumento
		INNER JOIN TA_Estatus AS TE(NOLOCK)
			ON TAO.IdEstatusOperacion = TE.IdEstatus  
		LEFT JOIN CC_CentroCosto AS CC(NOLOCK)
			ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U(NOLOCK)
			ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C(NOLOCK)
			ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC(NOLOCK)
			ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.AD_RegistroEliminacion RH(NOLOCK)
			ON SP.IdEliminado = RH.IdEliminacion 
		WHERE			
		TAO.IdTipoOperacion=2  --> APROBACIÓN DE SOLICITUD DE PEDIDO
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)=1--> TIPO DE ESTATUS ELIMINADO		
		AND SP.IdProveedor = @IDPROVEEDOR 	
		ORDER BY SP.FechaAlta DESC

	END 

	/*BUSCAR TOLAS LAS SOLICITUDES DE OFERTA CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'SOLICITUD_OFERTA'  
	BEGIN 
		SELECT  SP.IdSolicitudPedido,
					SP.MotivoUrgencia,
					TSP.TipoSolicitudPedido,
					PSP.Prioridad,
					SP.FechaAlta,
					(CASE SP.UnaSolaEntregaRequerida
						 WHEN 1
						 THEN CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103)
						 WHEN 0
						 THEN CONCAT(CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103), ' -- ', CONVERT(NVARCHAR, SP.FechaEntregaFinRequerida, 103))
					 END) AS FechaEntrega,
					  U.Nombre,
					  CASE 
					  WHEN SP.PeticionEnviada = 1 THEN 
						'Enviada'
					  ELSE 
						'Pendiente de enviar'
					  END AS EstatusOferta,
					  ISNULL(SP.IdTipoProceso,0) AS IdTipoProceso,
					  ISNULL(TP.TipoPedido, 'Sin clasificación') AS NombreTipo,
					  SP.IdEliminado,
					  RE.FechaRegistro
			 FROM MM_SolicitudPedido AS SP (NOLOCK)
				  INNER JOIN MM_TipoSolicitudPedido AS TSP  (NOLOCK)
					ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
				  INNER JOIN MM_PrioridadSolicitudPedido AS PSP  (NOLOCK)
					ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido 
				  INNER JOIN TA_Operacion AS OT  (NOLOCK)
					ON SP.IdSolicitudPedido = OT.IdDocumento 
				  INNER JOIN S_Usuario AS U  (NOLOCK)
					ON OT.IdAsignador = U.IdUsuario 
				  LEFT JOIN dbo.MM_TipoPedido TP  (NOLOCK)
					ON SP.IdTipoProceso = TP.IdTipoPedido 	
				  LEFT JOIN dbo.AD_RegistroEliminacion RE  (NOLOCK)
					ON SP.IdEliminado = RE.IdEliminacion	
			 WHERE 
				   OT.IdEstatusOperacion = 2
				   AND OT.IdTipoOperacion= 2 
				   AND SP.Activo = 1  
				   AND ISNULL(SP.Visible,1)=1	
				   AND ISNULL(SP.IdEstatusEliminado,0)= 1 -->CON ESTATUS ELIMINADO		  
				   AND SP.IdProveedor = @IdProveedor
			 GROUP BY SP.IdSolicitudPedido,
					SP.MotivoUrgencia,
					TSP.TipoSolicitudPedido,
					PSP.Prioridad,
					SP.FechaAlta,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					U.Nombre,
					SP.PeticionEnviada,
					SP.IdTipoProceso,
					TP.TipoPedido,
					SP.IdEstatusEliminado,
					SP.IdEliminado,
					RE.FechaRegistro
			 ORDER BY SP.IdSolicitudPedido DESC 

	END 

	/*BUSCAR TOLAS LAS OFERTAS CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'OFERTA'  
	BEGIN 

		 SELECT SP.IdSolicitudPedido,
               TSP.TipoSolicitudPedido,
               O.Descripcion,
               O.FechaRegistro,
               O.FechaFinalizacion AS FechaFinOferta,
               CAST(SUM(   CASE
                               WHEN PO.NoCotizar = 1 THEN
                                   1
                               ELSE
                                   CASE
                                       WHEN PO.Cotizado = 1 THEN
                                           1
                                       ELSE
                                           0
                                   END
                           END
                       ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS Nombre,
               CASE                  
				   WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0) THEN
                       'FINALIZADA'				  
                   ELSE
                       'EN COTIZACIÓN'
               END AS EstatusCotizacion,
			   O.IdEliminado,
			   RE.FechaRegistro,
			   TP.TipoPedido,
			   TP.IdTipoPedido
        FROM MM_SolicitudPedido AS SP
            INNER JOIN MM_TipoSolicitudPedido AS TSP (NOLOCK)
                ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON  SP.IdSolicitudPedido  = O.IdDocumento                  
            LEFT JOIN TA_Vencimiento AS V (NOLOCK)
                ON  O.IdVigencia = V.IdVencimiento
            LEFT JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus 
            LEFT JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON SP.IdSolicitudPedido= PO.IdSolicitudPedido 
			LEFT JOIN dbo.AD_RegistroEliminacion RE  (NOLOCK)
				ON O.IdEliminado = RE.IdEliminacion
			LEFT JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
				ON SP.IdTipoProceso = TP.IdTipoPedido
        WHERE O.FechaFinalizacion IS NOT NULL               
			  AND SP.IdProveedor = @IDPROVEEDOR 
			  AND ISNULL(O.IdEstatusEliminado,0)=1   
			  AND O.IdTipoOperacion =6          
        GROUP BY SP.IdSolicitudPedido,
                 TSP.TipoSolicitudPedido,
                 O.Descripcion,
                 O.FechaRegistro,
                 O.FechaFinalizacion,
				 O.IdEstatusEliminado,
				 O.IdEliminado,
			     RE.FechaRegistro,
				 TP.TipoPedido,
				 TP.IdTipoPedido
        ORDER BY SP.IdSolicitudPedido DESC

 
	END 

	/*BUSCAR TOLAS LOS PEDIDOS CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'PEDIDO'  
	BEGIN 
		SELECT P.IdPedido,
			P.IdSolicitudPedido,
			P.CreadoEl AS CreadoEl, 
			P.FechaEnvioPedido AS FechaEnvioPedido,
			SUM(PD.Subtotal) AS TotalPedido,
			ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			CASE 
			WHEN P.RecepcionServicio = 1 THEN 'Confirmación Aceptada' 
			WHEN P.RecepcionServicio  = 0 THEN 'Confirmación Rechazada' 
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					'Confirmación Vencida '  
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  <= 0 AND O.IdEstatusOperacion = 2 THEN	
					'En Confirmación'  
			ELSE 	  
					'Confirmación No Iniciada ' 
			END AS RecepcionServicio,
			E.Nombre,			 
			CAST(P.Version as NVARCHAR(200)) AS Version ,
			TM.TipoMonedaCorto AS TipoMoneda,
			PG.IdPedido AS IdPedidoGeneral,
			TP.TipoPedido,
			TP.IdTipoPedido,
			P.IdEliminado,
			RE.FechaRegistro
		FROM MM_Pedido AS P (NOLOCK)
		INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
			ON P.IdPedido = PD.IdPedido 
		INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
			ON P.IdPeticionOferta = PO.IdPeticionOFerta
		INNER JOIN S_Proveedor AS PV (NOLOCK)
			ON P.IdSubcontratista = PV.IdProveedor 
		INNER JOIN TA_Operacion AS O (NOLOCK)
			ON  P.IdSolicitudPedido = O.IdDocumento
		INNER JOIN TA_Prioridad AS PR (NOLOCK)
			ON O.IdPrioridad = PR.IdPrioridad 
		INNER JOIN TA_Vencimiento AS V (NOLOCK)
			ON O.IdVigencia = V.IdVencimiento 
		INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
			ON O.IdTipoOperacion = TTO.IdTipoOperacion
		INNER JOIN TA_Estatus AS E (NOLOCK)
			ON O.IdEstatusOperacion = E.IdEstatus 
		INNER JOIN MM_HorasVigenciaPedido AS HV(NOLOCK)
			ON P.IdPedido = HV.IdPedido
		LEFT JOIN PV_TipoMoneda AS TM(NOLOCK)
			ON P.IdMoneda = TM.IdMoneda 		
		INNER JOIN MM_Pedidos AS PG (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = @IDPROVEEDOR
		LEFT  JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
			ON  PG.IdTipoPedido = TP.IdTipoPedido
		LEFT JOIN dbo.AD_RegistroEliminacion RE (NOLOCK)
			ON P.IdEliminado = RE.IdEliminacion
		WHERE O.IdTipoOperacion = 9 
		AND O.IdProveedor = @IDPROVEEDOR					 
		AND P.Version=O.NoVersion
		AND ISNULL(P.IdEstatusEliminado,0)=1
		GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, O.IdEstatusOperacion,P.CreadoEl,PG.IdPedido,TP.TipoPedido,TP.IdTipoPedido,P.IdEstatusEliminado, P.IdEliminado,RE.FechaRegistro
		ORDER BY PG.IdPedido DESC
	END 


	/*BUSCAR TOLAS LAS ACEPTACIONES PEDIDO CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'ACEPTACION_PEDIDO'  
	BEGIN 
		
         SELECT 
                AP.IdAceptacionPedido,
                AP.IdPedido,				
				AP.Comentario,
                AP.Creado,
				CONCAT(LE.[Calle],' ',LE.[NoExterior],' ',LE.[NoInterior],' ',LE.[Colonia],' ',LE.[Municipio],' ',LE.[Estado], ' ', PAIS.Pais) AS LugarEntrega,
               	TD.TipoDomicilio ,
				CONCAT(P.RazonSocial,' ', P.RegimenCapital) As Proveedor,
				PG.IdPedido AS IdPedidoGeneral,
				TP.TipoPedido,
				MP.IdSolicitudPedido,
				AP.IdEliminado,
				RE.FechaRegistro
         FROM MM_AceptacionPedido AS AP  (NOLOCK)
		 INNER JOIN MM_Pedido AS MP  (NOLOCK)
			ON AP.IdPedido = MP.IdPedido 
		 INNER JOIN DG_Domicilio AS LE  (NOLOCK)
			ON  AP.IdDomicilioEntrega = LE.IdDomicilio
		 INNER JOIN DG_TipoDomicilio AS  TD  (NOLOCK)
			ON  LE.IdTipoDomicilio=  TD.IdTipoDomicilio
		 INNER JOIN PV_PaisRepublica AS PAIS  (NOLOCK)
			ON LE.IdPais = PAIS.id 
		 INNER JOIN S_Proveedor AS P (NOLOCK)
			ON MP.IdSubcontratista = P.IdProveedor 
		 INNER JOIN MM_Pedidos AS PG (NOLOCK)
			ON MP.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = @IdProveedor
		 LEFT  JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido 
		 LEFT JOIN dbo.AD_RegistroEliminacion RE  (NOLOCK)
			ON AP.IdEliminado = RE.IdEliminacion
         WHERE AP.IdProveedor = @IdProveedor	
		 AND ISNULL(AP.IdEstatusEliminado,0) = 1 --> MOSTRAR ACEPTACIONES ELIMINADAS	 
		 ORDER BY IdAceptacionPedido DESC
	END 

	/*BUSCAR TOLAS LAS CARTA CN CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'CARTA_CONTENIDO'  
	BEGIN 
		
		SELECT AC.IdAceptacionCartaPCN, Ac.IdAceptacionPedido, AP.IdPedido, AC.IdDocumento, Ac.CreadoEl,
		CONCAT(PR.RazonSocial ,' ', ISNULL(PR.RegimenCapital,'')) AS Proveedor,
		TD.TipoValidacion,
		PG.IdPedido AS IdPedidoGeneral,
		TP.TipoPedido,
		P.IdSolicitudPedido,
		AC.IdEliminado,
		RE.FechaRegistro
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC (NOLOCK)
		INNER JOIN [dbo].[S_Documento_S3] AS D (NOLOCK)
			ON AC.IdDocumento = D.IdDocumento 
		INNER JOIN [dbo].[MM_AceptacionPedido] AS AP(NOLOCK)
			ON  AC.IdAceptacionPedido = AP.IdAceptacionPedido
		INNER JOIN [dbo].[MM_Pedido] AS P (NOLOCK)
			ON AP.IdPedido = P.IdPedido
		INNER JOIN [dbo].[S_Proveedor] AS PR(NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
		INNER JOIN [dbo].[S_TipoValidacionDoc] AS TD(NOLOCK)
			ON AC.IdEstatus = TD.IdTipoValidacionDoc
		INNER JOIN [dbo].[MM_Pedidos] AS PG (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador
			AND PG.IdProveedorCliente = @IdProveedor
	    LEFT  JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
			ON  PG.IdTipoPedido = TP.IdTipoPedido
		LEFT JOIN dbo.AD_RegistroEliminacion RE (NOLOCK)
			ON AC.IdEliminado = RE.IdEliminacion
		WHERE  P.IdProveedorCompras = @IdProveedor
		AND ISNULL(AC.IdEstatusEliminado,0) = 1  --> QUE ESTEN ELIMINADOS
		ORDER BY  Ac.IdAceptacionPedido desc

	END 

	/*BUSCAR TOLAS APROBACION_FACTURA CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'APROBACION_FACTURA'  
	BEGIN 
		SELECT AF.IdAceptacionPedido,
		Pe.IdPedido,
		O.FechaRegistro, 
		PR.RazonSocial+' '+ISNULL(Pr.RegimenCapital,'') As Proveedor, 
		E.Nombre,
		PG.IdPedido AS IdPedidoGeneral, 
		TP.TipoPedido, 
		SUM((APD.Cantidad+APD.Excedente) * PED.PrecioUnitario) AS TotalPedido,
		TM.TipoMonedaCorto AS Moneda, 
		PR.RFC,
		PE.IdSolicitudPedido,
		AF.IdEliminado,
		RE.FechaRegistro
		FROM MM_AceptacionFactura AS AF (NOLOCK)
		INNER JOIN  TA_Operacion AS O  (NOLOCK)
			ON AF.IdAceptacionFactura = O.IdDocumento 
			AND O.IdTipoOperacion = 10 	
		INNER JOIN TA_Estatus AS E  (NOLOCK)
			ON  O.IdEstatusOperacion = E.IdEstatus 
		INNER JOIN MM_AceptacionPedido AS AP  (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
		INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK) 
			ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		INNER JOIN MM_Pedido AS PE (NOLOCK)
			ON AP.IdPedido = PE.IdPedido
		INNER JOIN MM_PedidoDetalle AS PED (NOLOCK)
			ON PE.IdPedido = PED.IdPedido 
			AND APD.IdPedidoDetalle=PED.IdPedidoDetalle 		 
		INNER JOIN MM_Pedidos AS PG  (NOLOCK)
			ON PE.IdPedido = PG.IdIdentificador  
			AND PG.IdProveedorCliente = @IDPROVEEDOR
		INNER JOIN S_Proveedor AS PR (NOLOCK)
			ON PE.IdSubcontratista = PR.IdProveedor 
		INNER JOIN dbo.PV_TipoMoneda AS TM  (NOLOCK)
			ON PE.IdMoneda = TM.IdMoneda
		LEFT  JOIN dbo.MM_TipoPedido AS TP (NOLOCK) 
			ON PG.IdTipoPedido = TP.IdTipoPedido 
		LEFT JOIN dbo.AD_RegistroEliminacion RE (NOLOCK)
			ON AF.IdEliminado = RE.IdEliminacion
		WHERE
		 O.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
		 AND PE.IdProveedorCompras= @IDPROVEEDOR 
		 AND ISNULL(AF.IdEstatusEliminado,0)=1
	    GROUP BY 
		AF.IdAceptacionPedido,
		Pe.IdPedido, 
		O.FechaRegistro, 
		PR.RazonSocial,
		Pr.RegimenCapital, 
		E.Nombre,
		PG.IdPedido, 
		TP.TipoPedido,
		TM.TipoMonedaCorto, 
		PR.RFC,AF.IdEstatusEliminado,
		PE.IdSolicitudPedido,
		AF.IdEliminado,
		RE.FechaRegistro
		ORDER BY AF.IdAceptacionPedido DESC	
	END 

	IF @ACCION = 'APROBACION_PEDIMENTO'  
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
		E.Nombre AS Estatus,
		P.IdSolicitudPedido,
		PC.IdEliminado,
		RE.FechaRegistro
		FROM dbo.MM_AceptacionPedido AP (NOLOCK)
		 INNER JOIN dbo.MM_Pedido P (NOLOCK)
			ON  AP.IdPedido= P.IdPedido
		 INNER JOIN MM_Pedidos AS PG(NOLOCK)
             ON P.IdPedido = PG.IdIdentificador
              AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN dbo.MM_TipoPedido AS TP(NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido 
		 INNER JOIN dbo.S_Proveedor PR (NOLOCK)
				ON P.IdSubcontratista = PR.IdProveedor 
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 INNER JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		 INNER JOIN dbo.TA_Operacion O (NOLOCK)
			ON PC.IdPedimentoComprobante  = O.IdDocumento
			AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 LEFT JOIN dbo.TA_Estatus AS E(NOLOCK)
            ON O.IdEstatusOperacion= E.IdEstatus	
		 LEFT JOIN dbo.AD_RegistroEliminacion RE (NOLOCK)
			ON PC.IdEliminado = RE.IdEliminacion 
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
		 AND ISNULL(PC.IdEstatusEliminado,0)= 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1		
		 AND P.IdProveedorCompras=@IdProveedor					 
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
				 PC.IdEliminado,
				 RE.FechaRegistro
				ORDER BY AP.IdAceptacionPedido DESC;
	END 

	IF @ACCION = 'APROBACION_PEDIDO'  
	BEGIN 
		SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,
		   E.Nombre,
           P.Version,
           getdate() AS  FechaVigencia
		FROM TA_Operacion AS O(NOLOCK)
			LEFT JOIN MM_Pedido AS P(NOLOCK)
				ON  O.IdDocumento = P.IdSolicitudPedido 
			LEFT JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido        
			LEFT JOIN TA_Estatus AS E(NOLOCK)
				ON O.IdEstatusOperacion = E.IdEstatus 
			LEFT JOIN TA_Tarea AS T(NOLOCK)
				ON  O.IdOperacion = T.IdOperacion 	
			LEFT JOIN dbo.S_Usuario U (NOLOCK)
				ON T.IdAprobador = U.IdUsuario
			LEFT JOIN dbo.S_UsuarioProveedor UP(NOLOCK)
				ON U.IdUsuario = UP.IdUsuario
			AND UP.IdProveedor = O.IdProveedor 
		WHERE     
			  O.IdProveedor=@IdProveedor
			  AND O.IdTipoOperacion = 9
			  AND P.Version = O.NoVersion
			  AND ISNULL(O.IdEstatusEliminado,0) =1  -->APROBACIÓN NO ESTE ELIMINADO
		GROUP BY O.IdOperacion,
				 O.IdDocumento,
				 O.FechaRegistro,
				 O.Descripcion,
				 E.Nombre,
				 O.IdTipoOperacion,
				 P.Version,
				 O.IdEstatusEliminado          
		ORDER BY O.FechaRegistro DESC
	END 
	IF @ACCION='APROBACION_SOLICITUDPEDIDO'
	BEGIN 
		    SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,           
		   E.Nombre AS Nombre
			FROM TA_Operacion AS O (NOLOCK)
			INNER JOIN TA_TipoOperacion AS OT(NOLOCK)
			ON O.IdTipoOperacion = OT.IdTipoOperacion 
			INNER JOIN TA_Estatus AS E(NOLOCK)
			ON O.IdEstatusOperacion = E.IdEstatus 
			INNER JOIN TA_TareaOperacion AS TTO(NOLOCK)
			ON O.IdOperacion = TTO.IdOperacion 
			INNER JOIN TA_Tarea AS T(NOLOCK)
			ON  TTO.IdTarea = T.IdTarea 
			WHERE 
			O.IdTipoOperacion = 2
			AND O.IdProveedor = @IdProveedor
			AND ISNULL(O.IdEstatusEliminado, 0) = 1  --> MOSTRAR NO ELIMINADAS 
			GROUP BY O.IdOperacion,
			O.IdDocumento,
			O.FechaRegistro,
			O.Descripcion,
			E.Nombre,
			O.IdEstatusEliminado
			ORDER BY O.FechaRegistro DESC;

	END 

	IF @ACCION = 'HISTORIAL_DETALLE_RECUPERADO'
	BEGIN
		SELECT 
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		ID_ELIMINADO
		FROM APP_BitacoraRestauracionProcesosDetalle BRPD (NOLOCK)
		WHERE ID_ELIMINADO = @IDELIMINADO
	END 
END 

