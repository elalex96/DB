--USE [Petrovendor]
--GO
--IF EXISTS
--(
--    SELECT 1
--    FROM dbo.sysobjects
--    WHERE name = 'SP_MM_ConsultaValidacionEliminacion_AceptacionPedido'
--)
--    DROP PROCEDURE SP_MM_ConsultaValidacionEliminacion_AceptacionPedido;   
	
--GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaValidacionEliminacion_AceptacionPedido]    Script Date: 09/11/2024 11:26:35 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description: CONSULTAR PROCESO DE PROCURA PARA POSIBLE ELIMINACIÓN
-- =============================================
-- =============================================
-- Author:	DANIEL AC
-- Create date: 07/11/2024
-- Description: SE AGREGA CONSULTA PARA TOMAR EN CUENTA CUANDO UNA CARTA CN ES EXCLUIDA Y LA ACEPTACIÓN TIENE FACTURA
-- =============================================

CREATE  PROCEDURE [dbo].[SP_MM_ConsultaValidacionEliminacion_AceptacionPedido] 
 @IDACEPTACIONPEDIDO INT , 
 @IDPROVEEDOR INT,
 @IDCONTRATO INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	/*CREACIÓN DE TABLA QUE LLEVARA LA JERARQUIA DE LOS PROCESOS DE PROCURA*/
	CREATE TABLE #PROCESO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500),IDESTATUS INT, CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT)
	CREATE TABLE #VALIDACION_PEDIMENTO(IdValidacion INT IDENTITY(1,1),IdAceptacionPedido INT, IdPedimentoPetrovendor INT, IdPedimentoAdinco INT, TieneGastos INT, TieneTransferencias INT)
	CREATE TABLE #PEDIMENTO_GASTOS(IdValidacion INT, Gastos INT)
	CREATE TABLE #PEDIMENTO_TRANFERENCIAS(IdValidacion INT, Tranferencias INT)
	CREATE TABLE #VALIDACION_FACTURA(IdValidacion INT IDENTITY(1,1),IdAceptacionPedido INT,IdAceptacionFactura INT, IdFacturaPetronvendor INT, IdFacturaAdinco INT, TieneGastos INT, IdTieneTransferencias INT)
	CREATE TABLE #FACTURAS_GASTOS(IdValidacion INT, Gastos INT)
	CREATE TABLE #FACTURAS_TRANFERENCIAS(IdValidacion INT, Tranferencias INT)

	/*ACEPTACIONES DE CARTA CONTENIDO NACIONAL*/
	/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS Y CARTA DE CONTENIDO NACIONAL SI EL PROVEEDOR ES NACIONAL*/
	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    0,
	CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
	'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion,
	AC.IdEstatus,
	'',
	'aceptacioncn',
	'',	
	AC.IdAceptacionCartaPCN
	FROM MM_AceptacionPedido AS AP (NOLOCK)
	INNER JOIN MM_Pedido AS P (NOLOCK)
		ON  AP.IdPedido = P.IdPedido 	
	INNER JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
		ON AC.IdAceptacionPedido = AP.IdAceptacionPedido 	
	INNER JOIN S_Documento_S3 AS D (NOLOCK)
		ON AC.IdDocumento = D.IdDocumento 
	INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
		ON AC.IdEstatus = TD.IdTipoValidacionDoc 
	INNER JOIN S_Proveedor AS PV (NOLOCK)
		ON P.IdSubcontratista	 = PV.IdProveedor 
	INNER JOIN MM_Pedidos AS PG (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdProveedorCliente = @IDPROVEEDOR	
	LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
		ON PG.IdTipoPedido = TP.IdTipoPedido 
	WHERE 
	 AP.IdAceptacionPedido = @IDACEPTACIONPEDIDO    		
	GROUP BY 
	AC.IdAceptacionCartaPCN	,
	TD.TipoValidacion,
	AP.IdAceptacionPedido,
	AC.IdEstatus

	 /*RECEPCIÓN DE FACTURA DE PETROVENDOR CON CARTA*/

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
	FROM MM_AceptacionFactura AS AF(NOLOCK)
	INNER JOIN  TA_Operacion AS O (NOLOCK)
		ON  AF.IdAceptacionFactura 	 = O.IdDocumento 
		AND ISNULL(O.IdFlujoTarea, 0) <> 0
        AND O.IdTipoOperacion = 10 --> CTE APROBACIÓND DE FACTURA
	INNER JOIN TA_Estatus AS E (NOLOCK)
		ON O.IdEstatusOperacion	 = E.IdEstatus 		
	INNER JOIN MM_AceptacionPedido AS AP(NOLOCK)
		ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
	INNER JOIN MM_Pedido AS P (NOLOCK)
		ON AP.IdPedido =  P.IdPedido 	
	INNER JOIN MM_AceptacionCartaPCN AS AC(NOLOCK)
		ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
	INNER JOIN S_Documento_S3 AS D (NOLOCK)
		ON AC.IdDocumento = D.IdDocumento 
	INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
		ON AC.IdEstatus = TD.IdTipoValidacionDoc 
	INNER JOIN S_Proveedor AS PV(NOLOCK)
		ON  P.IdSubcontratista	 = PV.IdProveedor
	INNER JOIN MM_Pedidos AS PG (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdProveedorCliente = @IDPROVEEDOR	
	INNER JOIN #PROCESO AS TEM_CN (NOLOCK)
		ON AC.IdAceptacionCartaPCN = TEM_CN.ID_PROCESO
	LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
		ON  PG.IdTipoPedido = TP.IdTipoPedido 
	WHERE 	
	  TEM_CN.CLAVE_PROCESO='aceptacioncn'
	  AND AP.IdAceptacionPedido=@IDACEPTACIONPEDIDO
	  AND TEM_CN.IdEstatus=2 --> CN APROBADA

	 /*RECEPCIÓN DE FACTURA DE PETROVENDOR SIN CARTA*/

	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    0,
	CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
	'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
	O.IdEstatusOperacion,
	'',
	'aceptacionfactura',
	'',
	AF.IdAceptacionFactura
	FROM MM_AceptacionFactura AS AF(NOLOCK)
	INNER JOIN  TA_Operacion AS O (NOLOCK)
		ON  AF.IdAceptacionFactura 	 = O.IdDocumento 
		AND ISNULL(O.IdFlujoTarea, 0) <> 0
        AND O.IdTipoOperacion = 10 --> CTE APROBACIÓN DE FACTURA
	INNER JOIN TA_Estatus AS E (NOLOCK)
		ON O.IdEstatusOperacion	 = E.IdEstatus 		
	INNER JOIN MM_AceptacionPedido AS AP(NOLOCK)
		ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
	INNER JOIN MM_Pedido AS P (NOLOCK)
		ON AP.IdPedido =  P.IdPedido 	
	INNER JOIN RelacionCartaCNPedido RCN(NOLOCK)
		ON RCN.IdPedido = RCN.IdPedido
		AND RCN.IdAceptacionPedido = RCN.IdAceptacionPedido
		AND RCN.PedirCarta = 0
	INNER JOIN S_Proveedor AS PV(NOLOCK)
		ON  P.IdSubcontratista	 = PV.IdProveedor
	INNER JOIN MM_Pedidos AS PG (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdProveedorCliente = @IDPROVEEDOR	
	LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
		ON  PG.IdTipoPedido = TP.IdTipoPedido 
	WHERE AP.IdAceptacionPedido=@IDACEPTACIONPEDIDO

	 /*COMPROBANTE EXTRANJERO*/
	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    0,
	CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
	'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
	O.IdEstatusOperacion,
	'',
	'aprobacionextranjera',
	'',
	PC.IdPedimentoComprobante	
	FROM MM_AceptacionPedido AS AP(NOLOCK)
	INNER JOIN MM_Pedido AS P (NOLOCK)
		ON  AP.IdPedido	 = P.IdPedido 
	INNER JOIN S_Proveedor AS PV(NOLOCK)
		ON P.IdSubcontratista = PV.IdProveedor 	
	INNER JOIN MM_Pedidos AS PG (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdProveedorCliente = @IDPROVEEDOR
	INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
		ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
	INNER JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
		ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
    INNER JOIN dbo.TA_Operacion O (NOLOCK)
		ON PC.IdPedimentoComprobante  = O.IdDocumento
		AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
	LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus 	
	LEFT JOIN  MM_TipoPedido AS TP (NOLOCK)
		ON PG.IdTipoPedido = TP.IdTipoPedido 
	WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
	AND AP.IdAceptacionPedido= @IDACEPTACIONPEDIDO
	AND ISNULL(PC.IdEstatusEliminado,0) <> 1


	/*VALIDACION DE COMPROBANTES EXTRANJERO DE ADINCO*/
	  
	INSERT INTO #VALIDACION_PEDIMENTO(IdAceptacionPedido,  IdPedimentoPetrovendor, IdPedimentoAdinco, TieneGastos, TieneTransferencias)
		 
	SELECT  AP.IdAceptacionPedido, PP.IdPedimentoComprobante, PA.IdPedimentoComprobante, 0,0
	FROM #PROCESO P (NOLOCK)
	INNER JOIN dbo.FI_PedimentoComprobante PP  (NOLOCK)
	ON P.ID_PROCESO = PP.IdPedimentoComprobante
	INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante  APP  (NOLOCK)
	ON PP.IdPedimentoComprobante = APP.IdPedimentoComprobante 
	INNER JOIN dbo.MM_AceptacionPedido AP  (NOLOCK)
	ON APP.IdAceptacionPedido = AP.IdAceptacionPedido
	INNER JOIN Adinco.dbo.FI_PedimentoComprobante PA (NOLOCK)
	ON PP.IdPedimentoComprobante = PA.IdPedimentoComprobantePetrovendor
	WHERE CLAVE_PROCESO='aprobacionextranjera'
	GROUP BY AP.IdAceptacionPedido, PP.IdPedimentoComprobante, PA.IdPedimentoComprobante

	/*VALIDACIÓN DE CANTIDAD DE GASTOS DE UN PEDIMENTO*/
	INSERT INTO  #PEDIMENTO_GASTOS(IdValidacion, Gastos)
	SELECT VP.IdValidacion, COUNT(R.IdPedimentoComprobante) 
	FROM #VALIDACION_PEDIMENTO VP (NOLOCK)
	INNER JOIN Adinco.dbo.CO_Registro R  (NOLOCK)
	ON VP.IdPedimentoAdinco=R.IdPedimentoComprobante
	GROUP BY VP.IdValidacion

	UPDATE VP
	SET VP.TieneGastos= PG.Gastos
	FROM #VALIDACION_PEDIMENTO VP
	INNER JOIN #PEDIMENTO_GASTOS PG
	ON VP.IdValidacion = PG.IdValidacion 

	/*VALIDACIÓN DE CANTIDAD DE TRANFERENCIAS DE UN PEDIMENTO*/
	INSERT INTO  #PEDIMENTO_TRANFERENCIAS(IdValidacion, Tranferencias)
	SELECT VP.IdValidacion, COUNT(T.IdTransferFactura)
	FROM #VALIDACION_PEDIMENTO VP (NOLOCK)
	INNER JOIN Adinco.dbo.FI_TransferFactura T (NOLOCK) 
	ON VP.IdPedimentoPetrovendor = T.IdPedimentoComprobante
	GROUP BY VP.IdValidacion

	UPDATE VP
	SET VP.TieneGastos= PT.Tranferencias
	FROM #VALIDACION_PEDIMENTO VP(NOLOCK) 
	INNER JOIN #PEDIMENTO_TRANFERENCIAS PT (NOLOCK) 
		ON VP.IdValidacion = PT.IdValidacion 
	 
	/*VALIDACIÓN DE FACTURAS CON FACTURAS DE ADINCO*/
	INSERT INTO #VALIDACION_FACTURA
	(
		IdAceptacionPedido,
		IdAceptacionFactura,
		IdFacturaPetronvendor,
		IdFacturaAdinco,
		TieneGastos,
		IdTieneTransferencias
	)	
	SELECT  AF.IdAceptacionPedido,AF.IdAceptacionFactura, AF.IdFactura, FA.IdFactura,0,0
	FROM #PROCESO AS TEM(NOLOCK) 
	INNER JOIN dbo.MM_AceptacionFactura AS AF(NOLOCK) 
		ON AF.IdAceptacionFactura= TEM.ID_PROCESO
	INNER JOIN dbo.FI_Factura AS FP (NOLOCK) 
		ON FP.IdFactura=AF.IdFactura
	LEFT JOIN Adinco.dbo.FI_Factura  AS FA (NOLOCK) 
		ON FA.UUID = FP.UUID  COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE CLAVE_PROCESO='aceptacionfactura' 
	GROUP BY AF.IdAceptacionPedido,AF.IdAceptacionFactura, AF.IdFactura, FA.IdFactura
    
	/*VALIDACION DE GASTOS CONTRA FACTURAS DE ADINCO*/
	INSERT INTO  #FACTURAS_GASTOS(IdValidacion, Gastos)
	SELECT VF.IdValidacion, COUNT(R.IdRegistro)	
	FROM #VALIDACION_FACTURA AS VF(NOLOCK) 
	INNER JOIN Adinco.dbo.CO_Registro R (NOLOCK) 
		ON VF.IdFacturaAdinco = R.IdFactura
	WHERE VF.IdFacturaAdinco IS NOT NULL
	GROUP BY VF.IdValidacion

	/*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LOS GASTOS*/
	UPDATE VF
	SET VF.TieneGastos= FG.Gastos
	FROM #VALIDACION_FACTURA VF
	INNER JOIN #FACTURAS_GASTOS FG 
		ON VF.IdValidacion = FG.IdValidacion 

	/*VALIDACION DE TRANFERENCIAS CONTRA FACTURAS DE ADINCO*/
	INSERT INTO  #FACTURAS_TRANFERENCIAS(IdValidacion, Tranferencias)
	SELECT VF.IdValidacion, COUNT(T.IdTransferFactura)	
	FROM #VALIDACION_FACTURA AS VF(NOLOCK) 
	INNER JOIN Adinco.dbo.FI_TransferFactura T (NOLOCK) 
		ON VF.IdFacturaAdinco = T.IdFactura
	WHERE VF.IdFacturaAdinco IS NOT NULL
	GROUP BY VF.IdValidacion
		
	/*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LAS TRANSFERENCIAS*/
	UPDATE VF
	SET VF.IdTieneTransferencias= FT.Tranferencias
	FROM #VALIDACION_FACTURA VF
	INNER JOIN #FACTURAS_TRANFERENCIAS FT
		ON VF.IdValidacion= FT.IdValidacion 

	SELECT IdValidacion, IdAceptacionPedido, IdAceptacionFactura, IdFacturaPetronvendor, IdFacturaAdinco, TieneGastos, IdTieneTransferencias, 'FACTURA' AS TIPO FROM #VALIDACION_FACTURA 
	UNION ALL
	SELECT IdValidacion, IdAceptacionPedido,0, IdPedimentoPetrovendor, IdPedimentoAdinco, TieneGastos, TieneTransferencias, 'COMPROBANTE' AS TIPO FROM #VALIDACION_PEDIMENTO

END;


