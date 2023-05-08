-- =============================================
-- Author:	DANIEL AC
-- Create date: 28/05/2018
-- Description: CONSULTAR PROCESO DE PROCURA PARA POSIBLE ELIMINACIÓN  DE UN PEDIDO
-- =============================================

CREATE
   PROCEDURE [dbo].[SP_MM_ConsultaValidacionEliminacion_Pedido] 

 @IDPEDIDO INT, 
 @IDPROVEEDOR INT,
 @IDCONTRATO INT

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	--DECLARE @IDACEPTACIONPEDIDO INT =256
 --   DECLARE @IDPROVEEDOR INT=420
		
	/*CREACIÓN DE TABLA QUE LLEVARA LA JERARQUIA DE LOS PROCESOS DE PROCURA PARA LOS PEDIDOS */
	/* DROP TABLE #PROCESO */
	CREATE TABLE #PROCESO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500),IDESTATUS INT, CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT)
		
	--SELECT * FROM #PROCESO
	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    0,
	CONCAT('Aceptación de servicio No.',AP.IdAceptacionPedido),
	'',
	0,
	'',
	'aceptacionpedido',
	'',
	AP.IdAceptacionPedido	
	FROM TA_Operacion AS O
	INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
	INNER JOIN MM_AceptacionPedido AS AP ON P.IdPedido = AP.IdPedido
	INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR
	LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO APROBADA
	 AND O.IdEstatusOperacion=2 --> APROBADA
	 AND O.IdProveedor = @IDPROVEEDOR 	 
	 AND O.NoVersion=P.Version	
	 AND P.IdPedido=	@IDPEDIDO
	 AND ISNULL(AP.IdEstatusEliminado,0) <> 1
	GROUP BY 
	P.IdPedido,
	PV.Razonsocial,
	PV.RegimenCapital,
	PG.IdPedido,	
	P.RecepcionServicio,
	HV.FechaVigencia,
	O.IdEstatusOperacion,
	AP.IdAceptacionPedido
	

	/*ACEPTACIONES DE CARTA CONTENIDO NACIONAL*/
	/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS Y CARTA DE CONTENIDO NACIONAL SI EL PROVEEDOR ES NACIONAL*/
	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    TEM_AP.ID,
	CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
	'',
	AC.IdEstatus,
	'',
	'aceptacioncn',
	'',	
	AC.IdAceptacionCartaPCN
	FROM MM_AceptacionPedido AS AP
	INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
	INNER JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
	INNER JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
	INNER JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	
	INNER JOIN #PROCESO AS TEM_AP ON TEM_AP.ID_PROCESO=AP.IdAceptacionPedido 
	LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	WHERE 
	AP.IdPedido = @IDPEDIDO    		
	GROUP BY 
	AC.IdAceptacionCartaPCN	,
	TD.TipoValidacion,
	AP.IdAceptacionPedido,
	AC.IdEstatus,
	TEM_AP.ID

	 /*RECEPCIÓN DE FACTURA DE PETROVENDOR*/

	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    TEM_CN.ID,
	CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
	'',
	O.IdEstatusOperacion,
	'',
	'aceptacionfactura',
	'',
	AF.IdAceptacionFactura
	FROM MM_AceptacionFactura AS AF
	INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura 	
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion			
	INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
	INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
	INNER JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
	INNER JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
	INNER JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	
	INNER JOIN #PROCESO AS TEM_CN ON TEM_CN.ID_PROCESO=ac.IdAceptacionCartaPCN
	LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	WHERE 	
	  TEM_CN.CLAVE_PROCESO='aceptacioncn'
	  AND P.IdPedido=@IDPEDIDO
	  AND TEM_CN.IdEstatus=2 --> CN APROBADA

	  	
	/*VALIDACIÓN DE FACTURAS CON FACTURAS DE ADINCO*/
	CREATE TABLE #VALIDACION_FACTURA(IdValidacion INT IDENTITY(1,1),IdAceptacionPedido INT,IdAceptacionFactura INT, IdFacturaPetronvendor INT, IdFacturaAdinco INT, TieneGastos INT, IdTieneTransferencias INT)

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
	FROM #PROCESO AS TEM
	INNER JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionFactura= TEM.ID_PROCESO
	INNER JOIN dbo.FI_Factura AS FP ON FP.IdFactura=AF.IdFactura
	LEFT JOIN Adinco.dbo.FI_Factura  AS FA ON FA.UUID = FP.UUID  COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE CLAVE_PROCESO='aceptacionfactura' 
	GROUP BY AF.IdAceptacionPedido,AF.IdAceptacionFactura, AF.IdFactura, FA.IdFactura
    
	/*VALIDACION DE GASTOS CONTRA FACTURAS DE ADINCO*/
	CREATE TABLE #FACTURAS_GASTOS(IdValidacion INT, Gastos INT)
	INSERT INTO  #FACTURAS_GASTOS(IdValidacion, Gastos)
	SELECT VF.IdValidacion, COUNT(R.IdRegistro)	
	FROM #VALIDACION_FACTURA AS VF
	INNER JOIN Adinco.dbo.CO_Registro R ON r.IdFactura= VF.IdFacturaAdinco
	WHERE VF.IdFacturaAdinco IS NOT NULL
	GROUP BY VF.IdValidacion

		/*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LOS GASTOS*/
		UPDATE VF
		SET VF.TieneGastos= FG.Gastos
		FROM #VALIDACION_FACTURA VF
		INNER JOIN #FACTURAS_GASTOS FG ON FG.IdValidacion = VF.IdValidacion

	/*VALIDACION DE TRANFERENCIAS CONTRA FACTURAS DE ADINCO*/
	CREATE TABLE #FACTURAS_TRANFERENCIAS(IdValidacion INT, Tranferencias INT)
	INSERT INTO  #FACTURAS_TRANFERENCIAS(IdValidacion, Tranferencias)
	SELECT VF.IdValidacion, COUNT(T.IdTransferFactura)	
	FROM #VALIDACION_FACTURA AS VF
	INNER JOIN Adinco.dbo.FI_TransferFactura T ON T.IdFactura= VF.IdFacturaAdinco
	WHERE VF.IdFacturaAdinco IS NOT NULL
	GROUP BY VF.IdValidacion
		
	    /*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LAS TRANSFERENCIAS*/
		UPDATE VF
		SET VF.IdTieneTransferencias= FT.Tranferencias
		FROM #VALIDACION_FACTURA VF
		INNER JOIN #FACTURAS_TRANFERENCIAS FT ON FT.IdValidacion = VF.IdValidacion

	/*VALIDACIÓN COMPROBANTES EXTRANJEROS*/

	 /*COMPROBANTE EXTRANJERO*/
	INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
	SELECT 	
    1,
	CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
	'',
	O.IdEstatusOperacion,
	'',
	'aprobacionextranjera',
	'',
	PC.IdPedimentoComprobante	
	FROM MM_AceptacionPedido AS AP
	INNER JOIN #PROCESO AS PAC ON PAC.ID_PROCESO=AP.IdAceptacionPedido
	INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	 
	LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
	INNER JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
    INNER JOIN dbo.TA_Operacion O 
			ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
	
	LEFT JOIN dbo.TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion	
	WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
	 AND ISNULL(PC.IdEstatusEliminado,0) <> 1
	 AND PAC.CLAVE_PROCESO='aceptacionpedido'
	 AND AP.IdPedido= @IDPEDIDO
	 GROUP BY 
	 PC.IdPedimentoComprobante,
	 O.IdEstatusOperacion,
	 AP.IdAceptacionPedido
	 
	 /*VALIDACION DE COMPROBANTES EXTRANJERO DE ADINCO*/
	  CREATE TABLE #VALIDACION_PEDIMENTO(IdValidacion INT IDENTITY(1,1),IdAceptacionPedido INT, IdPedimentoPetrovendor INT, IdPedimentoAdinco INT, TieneGastos INT, TieneTransferencias INT)
	  
		 INSERT INTO #VALIDACION_PEDIMENTO(IdAceptacionPedido,  IdPedimentoPetrovendor, IdPedimentoAdinco, TieneGastos, TieneTransferencias)
		 
		 SELECT  AP.IdAceptacionPedido, PP.IdPedimentoComprobante, PA.IdPedimentoComprobante, 0,0
		 FROM #PROCESO P
		 INNER JOIN dbo.FI_PedimentoComprobante PP ON PP.IdPedimentoComprobante=P.ID_PROCESO
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante  APP ON APP.IdPedimentoComprobante = PP.IdPedimentoComprobante
		 INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido=APP.IdAceptacionPedido
		 INNER JOIN Adinco.dbo.FI_PedimentoComprobante PA ON PA.IdPedimentoComprobantePetrovendor=PP.IdPedimentoComprobante
		 WHERE CLAVE_PROCESO='aprobacionextranjera'
		 GROUP BY AP.IdAceptacionPedido, PP.IdPedimentoComprobante, PA.IdPedimentoComprobante

		 /*VALIDACIÓN DE CANTIDAD DE GASTOS DE UN PEDIMENTO*/
		 CREATE TABLE #PEDIMENTO_GASTOS(IdValidacion INT, Gastos INT)
		 INSERT INTO  #PEDIMENTO_GASTOS(IdValidacion, Gastos)
		 SELECT VP.IdValidacion, COUNT(R.IdPedimentoComprobante) 
		 FROM #VALIDACION_PEDIMENTO VP
		 INNER JOIN Adinco.dbo.CO_Registro R ON VP.IdPedimentoAdinco=R.IdPedimentoComprobante
		 GROUP BY VP.IdValidacion

			UPDATE VP
			SET VP.TieneGastos= PG.Gastos
			FROM #VALIDACION_PEDIMENTO VP
			INNER JOIN #PEDIMENTO_GASTOS PG ON PG.IdValidacion = VP.IdValidacion

		 /*VALIDACIÓN DE CANTIDAD DE TRANFERENCIAS DE UN PEDIMENTO*/
		 CREATE TABLE #PEDIMENTO_TRANFERENCIAS(IdValidacion INT, Tranferencias INT)
		 INSERT INTO  #PEDIMENTO_TRANFERENCIAS(IdValidacion, Tranferencias)
		 SELECT VP.IdValidacion, COUNT(T.IdTransferFactura)
		 FROM #VALIDACION_PEDIMENTO VP
		 INNER JOIN Adinco.dbo.FI_TransferFactura T ON T.IdPedimentoComprobante=VP.IdPedimentoPetrovendor
		 GROUP BY VP.IdValidacion

		    UPDATE VP
			SET VP.TieneGastos= PT.Tranferencias
			FROM #VALIDACION_PEDIMENTO VP
			INNER JOIN #PEDIMENTO_TRANFERENCIAS PT ON PT.IdValidacion = VP.IdValidacion
	 


    ----SELECT * FROM #PROCESO
	SELECT IdValidacion, IdAceptacionPedido, IdAceptacionFactura, IdFacturaPetronvendor, IdFacturaAdinco, TieneGastos, IdTieneTransferencias, 'FACTURA' AS TIPO FROM #VALIDACION_FACTURA 
	UNION ALL
	SELECT IdValidacion, IdAceptacionPedido,0, IdPedimentoPetrovendor, IdPedimentoAdinco, TieneGastos, TieneTransferencias, 'COMPROBANTE' AS TIPO FROM #VALIDACION_PEDIMENTO

END;


