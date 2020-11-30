-- =============================================
-- Author:		Daniel AC
-- Create date: 08/09/2020
-- Description: Se removio las tareas seriales que todavia no se deben mostrar al usuario actual, por que el aprobador anterior todavia no realiza la aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarSolicitudes_V2] 
	@idProveedor INT, 
	@IdContrato INT, 
	@IdUsuario INT,
	@Page INT,
	@Buscar NVARCHAR(200)
AS
BEGIN

	SET NOCOUNT ON;

	SET LANGUAGE Español

	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	DECLARE @PLANT NVARCHAR(10) = (SELECT TOP 1 CP.Planta
									FROM Adinco.dbo.CO_SAPContratista_Planta AS CP (NOLOCK)
									JOIN Adinco.dbo.CO_Contratista AS C (NOLOCK) ON CP.IdContratista= C.IdContratista 
									JOIN Petrovendor.dbo.S_Proveedor AS PR (NOLOCK) ON C.RFC COLLATE SQL_Latin1_General_CP1_CI_AS =  PR.RFC
									WHERE PR.IdProveedor = @IdProveedor);

	DECLARE @TAREASMURPHY TABLE(
		IdDocumento INT,
		IdTipoTarea INT,
		IdAsignador INT,
		FechaRegistro DATETIME
	)

	DECLARE @TAREAS TABLE(
		IdDocumento INT,
		IdOperacion INT
	);

	DECLARE @FlujoSerial TABLE
	( 
		IdOperacion INT ,
		NoSecuencia INT 
	);

	DECLARE @OperacionNoAprobadas TABLE
	( 
		IdOperacion INT 
	);

	IF @PLANT IS NOT NULL
	BEGIN
	    /*LISTA DE APROBACIONES ESPECIFICAS PARA MURPHY*/
		INSERT INTO @TAREASMURPHY
		SELECT
			PRS.IdPRESES AS IdDocumento,
			10,
			PRS.CreadoPor,
			PRS.CreadoEl
		FROM Adinco.dbo.CO_SAPPRESES AS PRS (NOLOCK)
			LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
				ON US.IdUsuario = PRS.CreadoPor
		WHERE PRS.IdEstatus = 1
			AND PRS.Plant = @PLANT
			AND (SELECT TOP 1 IdTipoUsuario FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario) IN (3,5,6)
			AND (
					CAST(PRS.IdPRESES AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR
					CAST(PRS.SAPPONumber AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(PRS.SAPSESNumber AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(PRS.SESN AS NVARCHAR(100)) LIKE '%' + @Buscar + '%'
				)
		GROUP BY PRS.IdPRESES,
                 PRS.CreadoEl,
				 PRS.CreadoPor
		UNION
		SELECT 
			AC.IdAceptacionCartaPCN,
			11,
			AC.CreadoPor,
			AC.CreadoEl
		FROM Adinco.dbo.CO_SAPPRESES AS PRS  (NOLOCK)
			LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
				ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PRS.SAPPONumber
				AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PRS.SAPSESNumber
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK)
				ON SES.PO_SAPNumer = PRS.SAPPONumber
				AND SES.SESReferenceNumber = PRS.SAPSESNumber
				AND SES.SESNumber = PRS.SESN
			LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC (NOLOCK)
				ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
				AND ISNULL(AC.IdEstatusEliminado,0) <> 1
			LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
				ON US.IdUsuario = AC.CreadoPor
		WHERE AC.IdAceptacionCartaPCN IS NOT NULL
			AND PRS.Plant = @PLANT
			AND AC.IdEstatus = 1
			AND PRS.IdEstatus = 2
			AND (
					CAST(PRS.IdPRESES AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR
					CAST(PRS.SAPPONumber AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(PRS.SAPSESNumber AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(PRS.SESN AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(AC.IdAceptacionPedido AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR
					SES.SESNumber LIKE '%' + @Buscar + '%'
				)
		GROUP BY AC.IdAceptacionCartaPCN,
				AC.CreadoPor,
				AC.CreadoEl
		UNION
		SELECT 
			AF.IdAceptacionPedido,
			12,
			F.CreadoPor,
			AF.CreadoEl
		FROM MPY_MM_AceptacionFactura AS AF  (NOLOCK)
	   LEFT JOIN TA_Estatus AS E (NOLOCK) ON E.IdEstatus = AF.IdEstatus    
	   LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido  
	   LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK) ON APD.IdAceptacionPedido = AP.IdAceptacionPedido  
	   LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV (NOLOCK) ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS  
	   LEFT JOIN S_Proveedor AS PR (NOLOCK) ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1   
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK) ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK) ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN  
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK) ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS  
		LEFT JOIN dbo.FI_Factura AS F (NOLOCK) ON F.IdFactura = AF.IdFactura 
		LEFT JOIN dbo.RelacionCartaCNPedido RC (NOLOCK) ON RC.IdAceptacionPedido = AP.IdAceptacionPedido 
		WHERE AF.IdEstatus = 1 
		AND PSES.Plant = @PLANT
		AND AF.IdAceptacionFactura IS NOT NULL
		AND AF.IdEstatusXML != 4  
		AND AF.IdEstatusXML != 4  
		AND (
					CAST(PSES.IdPRESES AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR
					CAST(PSES.SAPPONumber AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(PSES.SAPSESNumber AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(PSES.SESN AS NVARCHAR(100)) LIKE '%' + @Buscar + '%' OR
					CAST(AF.IdAceptacionPedido AS NVARCHAR(10)) LIKE '%' + @Buscar + '%' OR
					SES.SESNumber LIKE '%' + @Buscar + '%'
				)
		GROUP BY AF.IdAceptacionPedido,
				F.CreadoPor,
				AF.CreadoEl

		SET @AllRecords = (SELECT COUNT(1) FROM @TAREASMURPHY);

		SELECT
			*,
			@AllRecords AS Records,
			@RecordsByPage AS RecordByPage
		FROM 
		(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY PRS.CreadoEl ORDER BY PRS.CreadoEl  DESC) AS R,
			CASE	
				WHEN TM.IdTipoTarea = 10 THEN TM.IdDocumento
				WHEN TM.IdTipoTarea = 11 THEN AC.IdAceptacionPedido
				WHEN TM.IdTipoTarea = 12 THEN AF.IdAceptacionPedido
			END AS IdDocumento,
			TM.IdAsignador,
			US.Nombre AS Asignador,
			TM.FechaRegistro,
			CASE	
				WHEN TM.IdTipoTarea = 10 THEN 'PO N.' + PRS.SAPPONumber + ' - Reference N.' + PRS.SAPSESNumber + ISNULL(' - SES N.' + SES.SESNumber,'')
				WHEN TM.IdTipoTarea = 11 THEN 'National content letter of the PO N.' + CAST(APAC.IdPedido AS NVARCHAR(10)) +  + ' - Reference N.' + CAST(APAC.ReferenceNumber AS NVARCHAR(10)) + ISNULL(' - SES N.' + SES2.SESNumber,'') COLLATE SQL_Latin1_General_CP1_CI_AS
				WHEN TM.IdTipoTarea = 12 THEN 'Invoice of the N.' + CAST(APF.IdPedido AS NVARCHAR(10)) + ' - Reference N.' + CAST(APF.ReferenceNumber AS NVARCHAR(10)) + ISNULL(' - SES N.' + SES3.SESNumber,'') COLLATE SQL_Latin1_General_CP1_CI_AS
			END AS Descripcion,
			TM.IdTipoTarea AS IdTipoOperacion,
			'N/A' AS FechaFinalizacion,
			TM.IdDocumento AS IdOperacion,
			CASE	
				WHEN TM.IdTipoTarea = 10 THEN 'Proforma'
				WHEN TM.IdTipoTarea = 11 THEN 'Letter of NC'
				WHEN TM.IdTipoTarea = 12 THEN 'Invoice'
			END AS NombreOperacion,
			CASE	
				WHEN TM.IdTipoTarea = 10 THEN '/Murphy/MPY_RecepcionPreFacturaDetalle.aspx?'
				WHEN TM.IdTipoTarea = 11 THEN '/MurphyExcel/MPY_AprobacionCNDetalle.aspx?'
				WHEN TM.IdTipoTarea = 12 THEN '/MurphyExcel/MPY_RecepcionVentanillaDetalle.aspx?'
			END AS URL,
			CASE	
				WHEN TM.IdTipoTarea = 10 THEN 'PRESES=' + CAST(TM.IdDocumento AS NVARCHAR(10))
				WHEN TM.IdTipoTarea = 11 THEN 'aceptacion=' + CAST(TM.IdDocumento AS NVARCHAR(10))
				WHEN TM.IdTipoTarea = 12 THEN 'aceptacion=' + CAST(TM.IdDocumento AS NVARCHAR(10))
			END AS PARAMETROS,
			(ROW_NUMBER() OVER(ORDER BY PRS.CreadoEl DESC) - 1)/ @RecordsByPage AS _Page
		FROM @TAREASMURPHY AS TM
			LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PRS (NOLOCK)
				ON PRS.IdPRESES = TM.IdDocumento
				AND TM.IdTipoTarea = 10
			LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC (NOLOCK)
				ON AC.IdAceptacionCartaPCN = TM.IdDocumento
				AND TM.IdTipoTarea = 11
			LEFT JOIN dbo.MPY_MM_AceptacionPedido AS APAC (NOLOCK)
				ON APAC.IdAceptacionPedido = AC.IdAceptacionPedido	
			LEFT JOIN dbo.MPY_MM_AceptacionPedido AS APF (NOLOCK)
				ON APF.IdAceptacionPedido = TM.IdDocumento
				AND TM.IdTipoTarea = 12
			LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF (NOLOCK)
				ON AF.IdAceptacionPedido = APF.IdAceptacionPedido
			LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
				ON US.IdUsuario = TM.IdAsignador
			LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PRS2 (NOLOCK)
				ON PRS2.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = APAC.IdPedido
				AND PRS2.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = APAC.ReferenceNumber
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  (NOLOCK)
				ON SES.PO_SAPNumer = PRS.SAPPONumber AND 
					SES.SESReferenceNumber = PRS.SAPSESNumber AND 
					SES.SESNumber = PRS.SESN 
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES2  (NOLOCK)
				ON SES2.PO_SAPNumer = PRS2.SAPPONumber AND 
					SES2.SESReferenceNumber = PRS2.SAPSESNumber AND 
					SES2.SESNumber = PRS2.SESN 
			LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PRS3 (NOLOCK)
				ON PRS3.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = APF.IdPedido
				AND PRS3.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = APF.ReferenceNumber
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES3 (NOLOCK)
				ON SES3.PO_SAPNumer = PRS3.SAPPONumber AND 
					SES3.SESReferenceNumber = PRS3.SAPSESNumber AND 
					SES3.SESNumber = PRS3.SESN 
			GROUP BY PRS.CreadoEl,
                     TM.IdTipoTarea,
					 PRS.SAPPONumber,
					 TM.IdDocumento,
                     TM.IdAsignador,
                     US.Nombre,
                     TM.FechaRegistro,
                     TM.IdTipoTarea,
                     TM.IdDocumento,
					 PRS.SAPSESNumber,
					 APAC.IdPedido,
					 APAC.ReferenceNumber,
					 AC.IdAceptacionPedido,
					 AF.IdAceptacionPedido,
					 APF.IdPedido,
					 APF.ReferenceNumber,
					 PRS.SESN,
					 SES.SESNumber,
					 PRS.SAPSESNumber,
					 SES2.SESNumber,
					 SES3.SESNumber

		) AS R
		WHERE
			R._Page = (@Page - 1)
		ORDER BY R.FechaRegistro DESC

	END
	ELSE
    BEGIN
    /*LISTA DE TAREAS PENDIENTES DEFAULT PARA TODAS LAS OPERADORAS*/

	/*OBTENER LAS APROBACIONES SERIALES DONDE EL NUMERO DE SECUENCIA SEA MAYOR A CERO*/
	INSERT INTO @FlujoSerial
	( 
		IdOperacion, 
		NoSecuencia 
	)
	SELECT		
		O.IdOperacion, 
		t.NoSecuencia
	FROM dbo.TA_Operacion O (NOLOCK)	
	INNER JOIN dbo.TA_FlujoTarea FT (NOLOCK) ON 
		O.IdFlujoTarea=FT.IdFlujoTarea	 
		AND FT.IdTipoFlujo= 1 --> FLUJO DE APROBACIÓN SERIAL 
	INNER JOIN	dbo.TA_Tarea t (NOLOCK)
			ON  O.IdOperacion=t.IdOperacion 	
	WHERE O.IdTipoOperacion IN(2,9,14) --> APROBACIÓN DE SOLICITUD DE PEDIDO, DE PEDIDO, DE COMPRA DIRECTA 
		AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1  --> SEA DIFERENTE DE ELIMINADO
		AND t.IdAprobador = @IdUsuario
		AND t.NoSecuencia > 1 
	GROUP BY O.IdOperacion,t.NoSecuencia

   /*OBTENER LAS OPERACIONES DONDE EL USUARIO CON NOSECUENCIA ANTERIOR YA HA REALIZADO LA APROBACIÓN*/
   /*ESTO PARA PODER MOSTRAR LATAREA AL USUARIO ACTUAL SI YA ES SU TURNO DE APROBAR LA OPERACIÓN*/
	INSERT INTO @OperacionNoAprobadas
	( 
		IdOperacion 
	)
	SELECT 
		O.IdOperacion
	FROM dbo.TA_Operacion O (NOLOCK)
		INNER JOIN	@FlujoSerial f 
			ON  O.IdOperacion =f.IdOperacion 
		INNER JOIN	dbo.TA_Tarea T (NOLOCK)
			ON O.IdOperacion=T.IdOperacion 
			   AND T.NoSecuencia = ( f.NoSecuencia - 1 )
	WHERE O.IdTipoOperacion IN(2,9,14) --> APROBACIÓN DE SOLICITUD DE PEDIDO, DE PEDIDO, DE COMPRA DIRECTA 
		AND T.IdEstatus <> 2 --> ESTATUS APROBADO
	GROUP BY O.IdOperacion

	/*OBTENER LAS TAREAS DEL USUARIO ACTUAL (SOLICITUD DE PEDIDO)*/
	INSERT INTO @TAREAS
		
	SELECT		
		O.IdDocumento,
		O.IdOperacion
	FROM dbo.TA_Operacion O (NOLOCK)
		INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
			ON O.IdDocumento =SP.IdSolicitudPedido
			AND O.IdTipoOperacion=2 --> APROBACIÓN DE SOLICITUD DE PEDIDO	
			AND O.IdProveedor = @idProveedor			
		INNER JOIN	dbo.TA_Tarea tarea (NOLOCK)
			ON O.IdOperacion=tarea.IdOperacion 
		INNER JOIN	dbo.TA_Estatus TE (NOLOCK)
			ON  O.IdEstatusOperacion = TE.IdEstatus	
	WHERE tarea.IdEstatus = 1 --> ESTATUS EN APROBACIÓN			
		AND tarea.IdAprobador = @IdUsuario
		AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADA
		AND O.IdOperacion NOT IN ( SELECT IdOperacion FROM @OperacionNoAprobadas)
		AND (
				O.Descripcion LIKE '%' + @Buscar + '%' OR 
				O.IdDocumento LIKE '%' + @Buscar + '%'
			)
	GROUP BY O.IdDocumento,
		O.IdOperacion

	UNION ALL
	/*OBTENER LAS TAREAS DEL USUARIO ACTUAL (COMPRA DIRECTA )*/
	SELECT		
		O.IdDocumento,
		O.IdOperacion
	FROM dbo.TA_Operacion O (NOLOCK)
		LEFT JOIN	dbo.MM_Pedidos R
			ON O.IdDocumento=R.IdIdentificador 
			AND	R.IdProveedorCliente =@idProveedor 
		INNER JOIN	dbo.TA_TipoOperacion TTO (NOLOCK)
			ON O.IdTipoOperacion = TTO.IdTipoOperacion 
		INNER JOIN	dbo.TA_Tarea tarea (NOLOCK)
			ON O.IdOperacion =tarea.IdOperacion 
		INNER JOIN	dbo.TA_Estatus TE (NOLOCK)
			ON O.IdEstatusOperacion = TE.IdEstatus
	WHERE tarea.IdEstatus = 1 --> ESTATUS EN APROBACIÓN 
			AND O.IdProveedor = @idProveedor
			AND TTO.IdTipoOperacion = 14  --> APROBACIÓN DE COMPRA DIRECTA 
			AND tarea.IdAprobador = @IdUsuario
			AND O.IdOperacion NOT IN (SELECT IdOperacion FROM @OperacionNoAprobadas)
			AND (
				O.Descripcion LIKE '%' + @Buscar + '%' OR 
				O.IdDocumento LIKE '%' + @Buscar + '%'
			)
	GROUP BY O.IdDocumento,
		O.IdOperacion

	UNION ALL
	/*OBTENER LAS TAREAS DEL USUARIO ACTUAL (COMPRA DIRECTA )*/
	SELECT		
		O.IdDocumento,
		O.IdOperacion
	FROM dbo.TA_Operacion O (NOLOCK)
		INNER JOIN	dbo.TA_TipoOperacion TTO (NOLOCK)
			ON O.IdTipoOperacion=TTO.IdTipoOperacion 
		INNER JOIN	dbo.TA_Tarea tarea (NOLOCK)
			ON O.IdOperacion=tarea.IdOperacion 
		INNER JOIN	dbo.MM_Pedido P (NOLOCK)
			ON O.NoVersion = P.Version
			AND O.IdDocumento=P.IdSolicitudPedido
		INNER JOIN	dbo.TA_Estatus TE (NOLOCK)
			ON O.IdEstatusOperacion = TE.IdEstatus
	WHERE tarea.IdEstatus = 1
			AND O.IdProveedor = @idProveedor
			AND TTO.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
			AND O.NoVersion IS NOT NULL
			AND tarea.IdAprobador =@IdUsuario
			AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADA
			AND O.IdOperacion NOT IN ( SELECT IdOperacion FROM @OperacionNoAprobadas)
			AND (
				O.Descripcion LIKE '%' + @Buscar + '%' OR 
				O.IdDocumento LIKE '%' + @Buscar + '%'
			)
	GROUP BY O.IdDocumento,
			O.IdOperacion;

	SET @AllRecords = (SELECT COUNT(1) FROM @TAREAS);

	SELECT
		*,
		@AllRecords AS Records,
		@RecordsByPage AS RecordByPage
	FROM 
	(
	SELECT
		ROW_NUMBER() OVER(PARTITION BY OP.FechaRegistro ORDER BY OP.FechaRegistro DESC) AS R,
		CASE
			WHEN OP.IdTipoOperacion = 14 THEN PS.IdPedido
			ELSE OP.IdDocumento
		END AS IdDocumento,
		OP.IdAsignador,
		US.Nombre AS Asignador,
		CONVERT(VARCHAR,OP.FechaRegistro, 22) AS FechaRegistro ,
		OP.Descripcion,
		OP.IdTipoOperacion,
		TTO.NombreOperacion,
		CONVERT(VARCHAR,(DATEADD(DAY,TVC.DiaVencimiento, OP.FechaRegistro)),22) AS FechaFinalizacion ,
		OP.IdOperacion,
		CASE
			WHEN OP.IdTipoOperacion = 2 THEN '/01Proveedores/SP_DetalleSolicitudPedido.aspx?'
			WHEN OP.IdTipoOperacion = 9 THEN '/04Tareas/detalle_pedido.aspx?'
			WHEN OP.IdTipoOperacion = 14 THEN '/02Proveedores/DetalleCompraDirecta.aspx?'
		END AS URL,
		CASE
			WHEN OP.IdTipoOperacion = 2 THEN 'solped=|' + CAST(OP.IdDocumento AS NVARCHAR(10)) + ',&num_user=|' + CAST(@IdUsuario AS NVARCHAR(10)) + ',&origin=t&tp_user=|1'
			WHEN OP.IdTipoOperacion = 9 THEN 'num_ped=|' + CAST(OP.IdDocumento AS NVARCHAR(10)) + ',&num_user=|' + CAST(@IdUsuario AS NVARCHAR(10)) + ',&tp_user=|1' + ',&version=|' + CAST(OP.NoVersion AS NVARCHAR(10))
			WHEN OP.IdTipoOperacion = 14 THEN 'num_operacion=|' + CAST(OP.IdOperacion AS NVARCHAR(10)) + ',&compra=|' + CAST(OP.IdDocumento AS NVARCHAR(10)) + ',&creado=|' + CAST(OP.IdAsignador AS NVARCHAR(10)) + ',&num_user=|' + CAST(@IdUsuario AS NVARCHAR(10)) + ',&tp_user=|1,&origin=t'
		END AS PARAMETROS,
		(ROW_NUMBER() OVER(ORDER BY OP.FechaRegistro DESC) - 1)/ @RecordsByPage AS _Page
	FROM @TAREAS AS TAO
		INNER JOIN dbo.TA_Operacion AS OP (NOLOCK)
			ON OP.IdOperacion = TAO.IdOperacion
		LEFT JOIN dbo.TA_TipoOperacion AS TTO (NOLOCK)
			ON OP.IdTipoOperacion = TTO.IdTipoOperacion
		LEFT JOIN dbo.TA_Tarea AS TAR (NOLOCK)
			ON  TAO.IdOperacion= TAR.IdOperacion
		LEFT JOIN dbo.TA_Estatus AS TE (NOLOCK)
			ON OP.IdEstatusOperacion=TE.IdEstatus 
		LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
			ON OP.IdAsignador = US.IdUsuario 
		LEFT JOIN dbo.MM_Pedidos AS PS (NOLOCK)
			ON TAO.IdDocumento = PS.IdIdentificador 
			AND OP.IdProveedor= PS.IdProveedorCliente 
		LEFT JOIN dbo.TA_Vencimiento AS TVC (NOLOCK)
			ON OP.IdVigencia = TVC.IdVencimiento 
	GROUP BY OP.IdDocumento,
             OP.IdAsignador,
             US.Nombre,
			 OP.IdAsignador,
			 OP.FechaRegistro,
             OP.Descripcion,
             OP.IdTipoOperacion,
             OP.IdOperacion,
			 TTO.NombreOperacion,
			 TVC.DiaVencimiento,
			 OP.NoVersion,
			 PS.IdPedido
	) AS R
	WHERE
		R.R = 1 
		AND R._Page = (@Page - 1)
	ORDER BY R.FechaRegistro DESC

	END

END


