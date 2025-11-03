USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_PR_MM_ListaFacturasAprobacion') IS NOT NULL
BEGIN
DROP PROCEDURE SP_PR_MM_ListaFacturasAprobacion;
END
GO
--/****** Object:  StoredProcedure [dbo].[SP_PR_MM_ListaFacturasAprobacion]    Script Date: 26/06/2023 02:34:39 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-2023
-- Description:	Se muestra UUID Y FOLIO FACTURA CONSULTAS MURPHY
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03-05-2022
-- Description:	se corrige la consulta de murphy para consultar por contrato 
-- =============================================
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 25/10/2022
-- Description:	Se agrega el filtrado por fechas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/04/2023
-- Description:	se reestringe la consulta para evitar consultar todos los datos cuando se obtienen las fechas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/06/2023
-- Description:	optmizacion de consulta para murphy
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 26-06-2023
-- Description:	Se agrega columnas uuid, folio factura y fecha de timbrado
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29-09-2025
-- Description:	Se agrega filtro por aceptacion de factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ListaFacturasAprobacion] 
@IdProveedor int,
@Estatus int,
@IdContrato int = NULL,
@IdUsuario int = NULL,
@FechaRegistro datetime = NULL,
@FechaInicio datetime = NULL,
@FechaFin datetime = NULL
AS
BEGIN
  SET NOCOUNT ON;
	DECLARE @PLANT	nvarchar(10);

	SET @FechaFin = DATEADD(day, 1, @FechaFin);
	
	CREATE TABLE #Estatus(
		IdEstatus INT
	);

	CREATE TABLE #AceptacionesPedido 
	(
		IdAceptacionPedido	int				NULL,
		Pedido				varchar(150)	NULL,
		IdPedido			int				NULL,
		FechaRegistro		datetime		NULL,
		Proveedor			varchar(400)	NULL,
		Nombre				varchar(200)	NULL,
		TotalPedido			money			NULL,
		Moneda				nvarchar(100)	NULL,
		RFC					nvarchar(100)	NULL,
		FolioFactura		nvarchar(200)	NULL,
		UUID				nvarchar(100)	NULL,
		FechaTimbrado		datetime		NULL,
		IdSolicitudPedido	nvarchar(100)	NULL,
		span				nvarchar(100)	NULL,
		PedirCarta			bit,
		IdOperacion			int,
		Contrato			varchar(50),
		PO					varchar(300)
	)	
	CREATE NONCLUSTERED INDEX ix_tempAceptacionesPedidoIdPedido  ON #AceptacionesPedido (IdPedido);
	CREATE NONCLUSTERED INDEX ix_tempAceptacionesPedidoIdSolicitudPedido  ON #AceptacionesPedido (IdSolicitudPedido);
	CREATE NONCLUSTERED INDEX ix_tempAceptacionesPedidoIdOperacion  ON #AceptacionesPedido (IdOperacion);
	
	CREATE TABLE #PLANT
	(			
		PLANT  VARCHAR(10)
	)
	CREATE NONCLUSTERED INDEX ix_tempProveedorPLANT  ON #PLANT (PLANT);

	INSERT INTO #PLANT(PLANT)
	SELECT TOP 1
			P.Planta
	FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
	JOIN Adinco.dbo.CO_SAPContratista_Planta AS P (NOLOCK)
		ON C.IdContratista = P.IdContratista
	WHERE C.IdContrato = @IdContrato;

	SET @PLANT = (SELECT TOP 1 PLANT FROM #PLANT);

	IF ISNULL(@PLANT,'') = ''
	BEGIN
	
		create table #FlujoSerial 
		(
			IdOperacion int,
			NoSecuencia int
		)
		CREATE NONCLUSTERED INDEX ix_tempFlujoSerialIdOperacion  ON #FlujoSerial (IdOperacion);

		CREATE TABLE #OperacionNoAprobadas 
		(
			IdOperacion int
		)
		CREATE NONCLUSTERED INDEX ix_tempOperacionNoAprobadasIdOperacion ON #OperacionNoAprobadas (IdOperacion);

		CREATE TABLE #AceptacionesFactura
		(	
			IdAceptacionFactura			INT,
			IdPedido					INT,
			IdAceptacionPedido			INT,
			IdOperacion					INT,
			IdFactura					INT,
			IdContrato					INT,
			FechaRegistro               DATETIME,
			IdEstatus					INT,
			IdFlujoTarea				INT,
			IdSolicitudPedido			INT,
			IdSubcontratista			INT,
			IdMoneda					INT,
			PedirCarta					BIT

		)
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionFactura  ON #AceptacionesFactura (IdAceptacionFactura);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdPedido  ON #AceptacionesFactura (IdPedido);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionPedido  ON #AceptacionesFactura (IdAceptacionPedido);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdOperacion  ON #AceptacionesFactura (IdOperacion);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdFactura  ON #AceptacionesFactura (IdFactura);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdContrato  ON #AceptacionesFactura (IdContrato);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdEstatus  ON #AceptacionesFactura (IdEstatus);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdFlujoTarea  ON #AceptacionesFactura (IdFlujoTarea);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdSolicitudPedido  ON #AceptacionesFactura (IdSolicitudPedido);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdMoneda  ON #AceptacionesFactura (IdMoneda);
		CREATE NONCLUSTERED INDEX ix_tempAceptacionesFacturaIdAceptacionIdSubcontratista ON #AceptacionesFactura (IdSubcontratista);

		 CREATE TABLE #AceptacionTotales
		(	
			IdAceptacionPedido			INT,
			TotalPedido			MONEY	

		)
		CREATE NONCLUSTERED INDEX ix_tempAceptacionTotalesIdAceptacionPedido  ON #AceptacionTotales (IdAceptacionPedido);

		 CREATE TABLE #Contratos
		(	
			IdContrato			INT,
			NombreContrato	 	VARCHAR(300)

		)
		CREATE NONCLUSTERED INDEX ix_tempContratosIdContrato  ON #Contratos (IdContrato);

		 CREATE TABLE #Proveedor
		(	
			IdProveedor			INT	
		)
		CREATE NONCLUSTERED INDEX ix_tempProveedorIdProveedor  ON #Proveedor (IdProveedor);

		INSERT INTO #Proveedor(IdProveedor)
		SELECT @IdProveedor	

	END;

	IF @Estatus = 0
	BEGIN
		
		INSERT INTO #Estatus (IdEstatus) VALUES (1);--EN APROBACION
		INSERT INTO #Estatus (IdEstatus) VALUES (2);--APROBADA
		INSERT INTO #Estatus (IdEstatus) VALUES (3);--RECHAZADA
		INSERT INTO #Estatus (IdEstatus) VALUES (9);--ELIMINADA
	END
	ELSE
	BEGIN
		
		INSERT INTO #Estatus
		SELECT @Estatus

	END;

IF @FechaInicio IS NULL OR @FechaFin IS NULL
BEGIN

	IF @Estatus = 0 --CUANDO NO SE ENVIE FECHA SE MOSTRARAN 6 MESES ATRAS EN EL TAB DE TODOS
	BEGIN
		
		SET @FechaInicio = DATEADD(MM,-6,GETDATE());

		SET @FechaFin = GETDATE();

	END
	ELSE
	BEGIN 
		
		SET @FechaInicio = DATEADD(YY,-2,GETDATE());

		SET @FechaFin = GETDATE();

	END

	IF EXISTS (SELECT COUNT(1) FROM #PLANT)  
	BEGIN

		INSERT INTO #AceptacionesPedido     
			(IdAceptacionPedido,
			Pedido,
			IdPedido,
			FechaRegistro,
			Proveedor,
			Nombre,
			TotalPedido,
			Moneda,
			RFC,
			FolioFactura,
			UUID,
			FechaTimbrado,
			IdSolicitudPedido,
			span,
			PedirCarta,
			IdOperacion,
			Contrato,
			PO)
			SELECT 
			  AF.IdAceptacionPedido,
			  CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS nvarchar(100)) COLLATE Modern_Spanish_CI_AS),
			  00,
			  AF.CreadoEl,
			  ISNULL(SV.VendorName, PR.RazonSocial) AS Proveedor,
			  E.Nombre,
			  CASE
				WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
			  ELSE F.SubTotal
			  END AS TotalPedido,
			  APD.IdMoneda,
			  SV.TaxID AS RFC,			 
			  CONCAT(ISNULL(F.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(F.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(F.Folio,'')))) >0 THEN '-' END), ISNULL(F.Folio,'')) AS FolioFactura,
			  ISNULL(F.UUID,'') AS UUID,
			  F.FechaTimbrado AS FechaTimbrado,
			  CONCAT('Reference Num:', AP.ReferenceNumber),
			  CASE
				WHEN E.IdEstatus = 2 THEN 'label label-success'
				WHEN E.IdEstatus = 1 THEN 'label label-primary'
				WHEN E.IdEstatus = 3 THEN 'label label-danger'
				WHEN E.IdEstatus IS NULL THEN 'label label-default'
			  END,
			  RC.PedirCarta,
			  NULL,
			  Contrato = c.NumeroContrato,
			  PO.SAPPONumber as PO
			FROM #PLANT PL (NOLOCK)
			JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK)
				ON PL.PLANT = PO.Plant
			JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
				ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
				AND AP.IdContrato = @IdContrato
			JOIN MPY_MM_AceptacionFactura AS AF (NOLOCK)
				ON AP.IdAceptacionPedido  = AF.IdAceptacionPedido
			JOIN TA_Estatus AS E (NOLOCK)
				ON AF.IdEstatus = E.IdEstatus
			JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
					  ON AP.IdContrato = C.IdContrato 				  
			JOIN dbo.FI_Factura AS F (NOLOCK)
					  ON AF.IdFactura=F.IdFactura 
			JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK)
					  ON AP.IdAceptacionPedido= APD.IdAceptacionPedido
			LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN (NOLOCK)
				ON AP.IdAceptacionPedido=APCN.IdAceptacionPedido 
				AND APCN.IdEstatus = 2  -->CTE        
			JOIN Adinco.dbo.CO_SAPVendor AS SV (NOLOCK)
				ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
			LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
				ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
				AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS=PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS 
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK)
				ON PSES.SAPPONumber=SES.PO_SAPNumer 
				AND  PSES.SAPSESNumber=SES.SESReferenceNumber
				AND PSES.SESN=SES.SESNumber         
			LEFT JOIN dbo.RelacionCartaCNPedido AS RC (NOLOCK)
				ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
			LEFT JOIN S_Proveedor AS PR (NOLOCK)
				ON AP.IdSubContratista=PR.RFC
				AND PR.Activo = 1  -->CTE		
			WHERE AF.IdEstatus IN (SELECT IdEstatus FROM #Estatus)
			AND AF.CreadoEl >= @FechaInicio AND AF.CreadoEl <= @FechaFin
			AND ISNULL(AF.IdEstatusEliminado, 0) <> 1  -->CTE
			AND AF.IdEstatusXML != 4  -->CTE
			AND AF.IdEstatusXML != 4  -->CTE
			GROUP BY AF.IdAceptacionPedido,
					AP.IdPedido,
					PR.RazonSocial,
					PR.RegimenCapital,
					E.Nombre,
					PR.RFC,
					AP.IdSubContratista,
					AF.IdEstatusEliminado,
					AF.CreadoEl,
					SV.VendorName,
					APD.IdMoneda,
					SV.TaxID,
					E.IdEstatus,
					SES.SESNumber,
					AP.ReferenceNumber,
					PSES.IdPRESES,
					F.SubTotal,
					F.IdMoneda,
					F.FechaTimbrado,					
					F.Folio,
					F.Serie,
					F.UUID,
					RC.PedirCarta,
					c.IdContrato,
					c.NumeroContrato,
					PO.SAPPONumber
					ORDER BY AF.IdAceptacionPedido DESC;       
  
	END 

	IF ISNULL(@PLANT,'') = ''
	BEGIN

	   -- OBTENER TODAS LAS ACEPTACIONES DE FACTURA DE LA OPERADORA
		INSERT INTO #AceptacionesFactura
		(	
			IdAceptacionFactura,
			IdPedido,
			IdAceptacionPedido,
			IdOperacion,
			IdFactura,
			PedirCarta,
			IdContrato,
			FechaRegistro,
			IdEstatus,
			IdFlujoTarea,
			IdSolicitudPedido,
			IdSubcontratista,
			IdMoneda
		)

		SELECT
		AF.IdAceptacionFactura,
		PE.IdPedido,
		AF.IdAceptacionPedido,
		O.IdOperacion,
		AF.IdFactura,
		RC.PedirCarta,
		PE.IdContrato,
		O.FechaRegistro,
		O.IdEstatusOperacion,
		O.IdFlujoTarea,
		PE.IdSolicitudPedido,
		PE.IdSubcontratista,
		PE.IdMoneda	
		FROM #Proveedor PC  (NOLOCK)
		JOIN MM_Pedido AS PE (NOLOCK)
			ON PC.IdProveedor = PE.IdProveedorCompras
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
		  ON PE.IdPedido=AP.IdPedido	 
		  AND  ISNULL(AP.IdEliminado, 0) <> 1 -->CTE
		JOIN MM_AceptacionFactura AF (NOLOCK)	
			ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		JOIN dbo.TA_Operacion O (NOLOCK)
		  ON AF.IdAceptacionFactura  = O.IdDocumento
		  AND O.IdTipoOperacion = 10 --> CTE APROBACIÓN DE FACTURA
		  AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->QUE NO ESTE ELIMINADO
		  AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 -->CTE NO ESTE ELIMINADO
		JOIN dbo.RelacionCartaCNPedido RC (NOLOCK)
			ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 	 
		WHERE O.IdEstatusOperacion IN (SELECT IdEstatus FROM #Estatus)
		AND ISNULL(O.IdFlujoTarea, 0) <> 0
		AND AF.CreadoEl >= @FechaInicio AND AF.CreadoEl <= @FechaFin
		GROUP BY  
		AF.IdAceptacionFactura,
		O.IdOperacion,
		af.IdAceptacionPedido,
		PE.IdPedido,
		AF.IdFactura,
		RC.PedirCarta,
		PE.IdContrato,
		O.FechaRegistro,
		O.IdEstatusOperacion,
		O.IdFlujoTarea,
		PE.IdSolicitudPedido,
		PE.IdSubcontratista,
		PE.IdMoneda

		-- OBTENER CONTRATOS AGRUPADOS
		INSERT INTO #Contratos(IdContrato)
		SELECT IdContrato
		FROM #AceptacionesFactura  (NOLOCK)
		GROUP BY  IdContrato

		UPDATE CO
		SET CO.NombreContrato= C.NumeroContrato
		FROM #Contratos CO
		JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
			ON CO.IdContrato=C.IdContrato 

	  -- OBTENER CUALES SON SERIALES Y ESTA EL USUARIO ACTUAL
	  INSERT INTO #FlujoSerial 
	  (IdOperacion,
	  NoSecuencia)
		SELECT
		  AF.IdOperacion,
		  t.NoSecuencia
		FROM #AceptacionesFactura AF (NOLOCK)
		JOIN dbo.TA_FlujoTarea FT (NOLOCK)
		  ON AF.IdFlujoTarea=FT.IdFlujoTarea 
		   AND FT.IdTipoFlujo = 1 --->CTE SOLO DEBE APLICAR PARA LAS APROBACIONES SERIALES  
		JOIN dbo.TA_Tarea t (NOLOCK)
		  ON AF.IdOperacion=t.IdOperacion     
		WHERE t.IdAprobador = @IdUsuario
		AND t.NoSecuencia > 1--> CTE SEA UN NÚMERO DE SECUENCIA MAYOR A 1
		AND t.Activo = 1 --> CTE

		-- OBTENER LAS APROBACIONES DONDE ESTA EL USUARIO ACTUAL PERO LE FALTA QUE APRUEBA EL USUARIO ANTERIOR 
	   INSERT INTO #OperacionNoAprobadas (IdOperacion)
		SELECT
		  F.IdOperacion
		FROM #FlujoSerial F     
		JOIN dbo.TA_Tarea T (NOLOCK)
		  ON F.IdOperacion=T.IdOperacion 
		  AND (F.NoSecuencia - 1) = T.NoSecuencia
		WHERE T.Activo = 1 --> CTE
		AND T.IdEstatus <> 2;--> CTE DIFERENTE DE ESTATUS APROBADO

		-- ELIMINAR LAS ACEPTACIONES DE FACTURA QUE NO SE DEBEN MOSTRAR AL USUARIO ACTUAL
		DELETE AF
		FROM #AceptacionesFactura AF
		JOIN #OperacionNoAprobadas  A
		ON AF.IdOperacion = A.IdOperacion
	
		-- OBTENER DETALLE FINAL DE LAS ACEPTACIONES DE FACTURA 
		 INSERT INTO #AceptacionesPedido
		 (IdAceptacionPedido,
			Pedido,
			IdPedido,
			FechaRegistro,
			Proveedor,
			Nombre,
			TotalPedido,
			Moneda,
			RFC,
			FolioFactura,
			UUID,
			FechaTimbrado,
			IdSolicitudPedido,
			span,
			PedirCarta,
			IdOperacion,
			Contrato,
			PO)
		  SELECT 
			AF.IdAceptacionPedido,
			PG.IdPedido,
			AF.IdPedido,
			AF.FechaRegistro,
			CONCAT(PR.RazonSocial, ' ' ,ISNULL(Pr.RegimenCapital,'')) AS Proveedor,
			E.Nombre,
			0,
			TM.TipoMonedaCorto AS Moneda,
			ISNULL(PR.RFC, '') AS RFC, 			
			CONCAT(ISNULL(FI.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(FI.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(FI.Folio,'')))) >0 THEN '-' END), ISNULL(FI.Folio,'')) AS FolioFactura,
			ISNULL(FI.UUID,'') AS UUID,
			FI.FechaTimbrado AS FechaTimbrado,
			AF.IdSolicitudPedido,
			CASE
			  WHEN E.IdEstatus = 2 THEN 'label label-success'
			  WHEN E.IdEstatus = 1 THEN 'label label-primary'
			  WHEN E.IdEstatus = 3 THEN 'label label-danger'
			  WHEN E.IdEstatus IS NULL THEN 'label label-default'
			END,
			AF.PedirCarta,
			AF.IdOperacion,
			Contrato =  C.NombreContrato,
			'Sin PO relacionada' PO
		  FROM #AceptacionesFactura AF	      
		  JOIN MM_Pedidos AS PG (NOLOCK)
			ON AF.IdPedido = PG.IdIdentificador
			AND PG.IdProveedorCliente = @IdProveedor
			AND PG.IdTipoPedido IN (2, 4, 6)-->CTES	MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
		   JOIN dbo.FI_Factura AS fi (NOLOCK)
			ON AF.IdFactura=fi.IdFactura
		  JOIN S_Proveedor AS PR (NOLOCK)
			ON AF.IdSubcontratista=PR.IdProveedor  
		  JOIN dbo.PV_TipoMoneda AS TM (NOLOCK)
			ON AF.IdMoneda=TM.IdMoneda
		  JOIN TA_Estatus AS E (NOLOCK)
			ON AF.IdEstatus=E.IdEstatus
		  JOIN #Contratos AS C (NOLOCK)
			ON AF.IdContrato=C.IdContrato     	   	   
		  GROUP BY AF.IdAceptacionPedido,
				   AF.IdPedido,
				   AF.FechaRegistro,
				   AF.IdPedido,
				   AF.PedirCarta,
				   AF.IdOperacion,
				   PR.RazonSocial,
				   Pr.RegimenCapital,
				   E.Nombre,
				   PG.IdPedido,
				   TM.TipoMonedaCorto,
				   PR.RFC,             
				   AF.IdSolicitudPedido,
				   E.IdEstatus,
				   FI.UUID, 
				   FI.FechaTimbrado,
				   FI.Folio,
				   FI.Serie,
				   c.IdContrato,
				   C.NombreContrato			 					   
		  ORDER BY AF.IdAceptacionPedido DESC;

		  -- OBTENER TOTALES
		  INSERT INTO #AceptacionTotales(IdAceptacionPedido, TotalPedido)
		  SELECT AF.IdAceptacionPedido,
		  SUM(APD.Cantidad * PED.PrecioUnitario)
		  FROM #AceptacionesPedido AF
		  JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON AF.IdAceptacionPedido = APD.IdAceptacionPedido 
		  JOIN MM_PedidoDetalle AS PED (NOLOCK)
			ON AF.IdPedido=PED.IdPedido 
			AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
		   GROUP BY AF.IdAceptacionPedido

		-- ACTUALIZAR LOS MONTOS TOTALES 
		UPDATE AP 
		SET AP.TotalPedido=ATO.TotalPedido
		FROM #AceptacionesPedido AP
		JOIN #AceptacionTotales ATO
			ON AP.IdAceptacionPedido = ATO.IdAceptacionPedido

		-- ACTUALIZAR PO SI EXISTE
		UPDATE AP 
		SET AP.PO=RPO.PO
		FROM #AceptacionesPedido AP
		JOIN DEA_Relacion_PR_PO AS RPO	(NOLOCK)
			ON AP.IdPedido = RPO.IdPedido   	

	END

	SELECT
    ROW_NUMBER() OVER (
    ORDER BY FechaRegistro DESC) AS IdRow,
    IdAceptacionPedido,
    Pedido,
    IdPedido,
    FechaRegistro,
    Proveedor,
	Nombre,
    TotalPedido,
    Moneda,
    RFC,	
    IdSolicitudPedido,
    span,
    CASE
      WHEN ISNULL(PedirCarta, 0) = 1 THEN 'Si'
      ELSE 'No'
    END AS PedirCarta,
    IdOperacion,
    Contrato,
	PO,
	UUID,
	FechaTimbrado,
	FolioFactura
  FROM #AceptacionesPedido
  GROUP BY IdAceptacionPedido,
           Pedido,
           IdPedido,
           FechaRegistro,
           Proveedor,
           Nombre,
           TotalPedido,
           Moneda,
           RFC,
           IdSolicitudPedido,
           span,
           PedirCarta,
           IdOperacion,
           Contrato,
		   PO,
		   UUID,
		   FechaTimbrado,
		   FolioFactura
  ORDER BY FechaRegistro DESC;

END
ELSE
BEGIN
	
	IF EXISTS (SELECT COUNT(1) FROM #PLANT)  
	BEGIN

		INSERT INTO #AceptacionesPedido     
			(IdAceptacionPedido,
			Pedido,
			IdPedido,
			FechaRegistro,
			Proveedor,
			Nombre,
			TotalPedido,
			Moneda,
			RFC,
			FolioFactura,
			UUID,
			FechaTimbrado,
			IdSolicitudPedido,
			span,
			PedirCarta,
			IdOperacion,
			Contrato,
			PO)
			SELECT 
				AF.IdAceptacionPedido,
			  CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS nvarchar(100)) COLLATE Modern_Spanish_CI_AS),
			  00,
			  AF.CreadoEl,
			  ISNULL(SV.VendorName, PR.RazonSocial) AS Proveedor,
			  E.Nombre,
			  CASE
				WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
			  ELSE F.SubTotal
			  END AS TotalPedido,
			  APD.IdMoneda,			  
			  ISNULL(SV.TaxID, '') AS RFC, 
			  CONCAT(ISNULL(F.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(F.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(F.Folio,'')))) >0 THEN '-' END), ISNULL(F.Folio,'')) AS FolioFactura,
		      ISNULL(F.UUID,'') AS UUID,
			  F.FechaTimbrado,
			  CONCAT('Reference Num:', AP.ReferenceNumber),
			  CASE
				WHEN E.IdEstatus = 2 THEN 'label label-success'
				WHEN E.IdEstatus = 1 THEN 'label label-primary'
				WHEN E.IdEstatus = 3 THEN 'label label-danger'
				WHEN E.IdEstatus IS NULL THEN 'label label-default'
			  END,
			  RC.PedirCarta,
			  NULL,
			  Contrato = c.NumeroContrato,
			  PO.SAPPONumber as PO
			FROM #PLANT PL (NOLOCK)
			JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK)
				ON PL.PLANT = PO.Plant
			JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
				ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
				AND AP.IdContrato = @IdContrato
			JOIN MPY_MM_AceptacionFactura AS AF (NOLOCK)
				ON AP.IdAceptacionPedido  = AF.IdAceptacionPedido
			JOIN TA_Estatus AS E (NOLOCK)
				ON AF.IdEstatus = E.IdEstatus
			JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
					  ON AP.IdContrato = C.IdContrato 				  
			JOIN dbo.FI_Factura AS F (NOLOCK)
					  ON AF.IdFactura=F.IdFactura 
			JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK)
					  ON AP.IdAceptacionPedido= APD.IdAceptacionPedido
			LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN (NOLOCK)
				ON AP.IdAceptacionPedido=APCN.IdAceptacionPedido 
				AND APCN.IdEstatus = 2  -->CTE        
			JOIN Adinco.dbo.CO_SAPVendor AS SV (NOLOCK)
				ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
			LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
				ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
				AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS=PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS 
			LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK)
				ON PSES.SAPPONumber=SES.PO_SAPNumer 
				AND  PSES.SAPSESNumber=SES.SESReferenceNumber
				AND PSES.SESN=SES.SESNumber         
			LEFT JOIN dbo.RelacionCartaCNPedido AS RC (NOLOCK)
				ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
			LEFT JOIN S_Proveedor AS PR (NOLOCK)
				ON AP.IdSubContratista=PR.RFC
				AND PR.Activo = 1  -->CTE
			WHERE AF.IdEstatus IN (SELECT IdEstatus FROM #Estatus)
			AND AF.CreadoEl >= @FechaInicio AND AF.CreadoEl < @FechaFin
			AND ISNULL(AF.IdEstatusEliminado, 0) <> 1  -->CTE
			AND AF.IdEstatusXML != 4  -->CTE
			AND AF.IdEstatusXML != 4  -->CTE
			GROUP BY AF.IdAceptacionPedido,
					AP.IdPedido,
					PR.RazonSocial,
					PR.RegimenCapital,
					E.Nombre,
					PR.RFC,
					AP.IdSubContratista,
					AF.IdEstatusEliminado,
					AF.CreadoEl,
					SV.VendorName,
					APD.IdMoneda,
					SV.TaxID,
					E.IdEstatus,
					SES.SESNumber,
					AP.ReferenceNumber,
					PSES.IdPRESES,
					F.SubTotal,
					F.IdMoneda,
					F.FechaTimbrado,		
					F.Folio,
					F.Serie,
					F.UUID,
					RC.PedirCarta,
					c.IdContrato,
					c.NumeroContrato,
					PO.SAPPONumber
					ORDER BY AF.IdAceptacionPedido DESC;       
  
	END 

	IF ISNULL(@PLANT,'') = ''
	BEGIN

	   -- OBTENER TODAS LAS ACEPTACIONES DE FACTURA DE LA OPERADORA
		INSERT INTO #AceptacionesFactura
		(	
			IdAceptacionFactura,
			IdPedido,
			IdAceptacionPedido,
			IdOperacion,
			IdFactura,
			PedirCarta,
			IdContrato,
			FechaRegistro,
			IdEstatus,
			IdFlujoTarea,
			IdSolicitudPedido,
			IdSubcontratista,
			IdMoneda
		)

		SELECT
		AF.IdAceptacionFactura,
		PE.IdPedido,
		AF.IdAceptacionPedido,
		O.IdOperacion,
		AF.IdFactura,
		RC.PedirCarta,
		PE.IdContrato,
		O.FechaRegistro,
		O.IdEstatusOperacion,
		O.IdFlujoTarea,
		PE.IdSolicitudPedido,
		PE.IdSubcontratista,
		PE.IdMoneda	
		FROM #Proveedor PC  (NOLOCK)
		JOIN MM_Pedido AS PE (NOLOCK)
			ON PC.IdProveedor = PE.IdProveedorCompras
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
		  ON PE.IdPedido=AP.IdPedido	 
		  AND  ISNULL(AP.IdEliminado, 0) <> 1 -->CTE
		JOIN MM_AceptacionFactura AF (NOLOCK)	
			ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			
		JOIN dbo.TA_Operacion O (NOLOCK)
		  ON AF.IdAceptacionFactura  = O.IdDocumento
		  AND O.IdTipoOperacion = 10 --> CTE APROBACIÓN DE FACTURA
		  AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->QUE NO ESTE ELIMINADO
		  AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 -->CTE NO ESTE ELIMINADO
		JOIN dbo.RelacionCartaCNPedido RC (NOLOCK)
			ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 	 
		WHERE O.IdEstatusOperacion IN (SELECT IdEstatus FROM #Estatus)
		AND ISNULL(O.IdFlujoTarea, 0) <> 0
		AND AF.CreadoEl >= @FechaInicio AND AF.CreadoEl < @FechaFin
		GROUP BY  
		AF.IdAceptacionFactura,
		O.IdOperacion,
		af.IdAceptacionPedido,
		PE.IdPedido,
		AF.IdFactura,
		RC.PedirCarta,
		PE.IdContrato,
		O.FechaRegistro,
		O.IdEstatusOperacion,
		O.IdFlujoTarea,
		PE.IdSolicitudPedido,
		PE.IdSubcontratista,
		PE.IdMoneda

		-- OBTENER CONTRATOS AGRUPADOS
		INSERT INTO #Contratos(IdContrato)
		SELECT IdContrato
		FROM #AceptacionesFactura  (NOLOCK)
		GROUP BY  IdContrato

		UPDATE CO
		SET CO.NombreContrato= C.NumeroContrato
		FROM #Contratos CO
		JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
			ON CO.IdContrato=C.IdContrato 

	  -- OBTENER CUALES SON SERIALES Y ESTA EL USUARIO ACTUAL
	  INSERT INTO #FlujoSerial 
	  (IdOperacion,
	  NoSecuencia)
		SELECT
		  AF.IdOperacion,
		  t.NoSecuencia
		FROM #AceptacionesFactura AF (NOLOCK)
		JOIN dbo.TA_FlujoTarea FT (NOLOCK)
		  ON AF.IdFlujoTarea=FT.IdFlujoTarea 
		   AND FT.IdTipoFlujo = 1 --->CTE SOLO DEBE APLICAR PARA LAS APROBACIONES SERIALES  
		JOIN dbo.TA_Tarea t (NOLOCK)
		  ON AF.IdOperacion=t.IdOperacion     
		WHERE t.IdAprobador = @IdUsuario
		AND t.NoSecuencia > 1--> CTE SEA UN NÚMERO DE SECUENCIA MAYOR A 1
		AND t.Activo = 1 --> CTE

		-- OBTENER LAS APROBACIONES DONDE ESTA EL USUARIO ACTUAL PERO LE FALTA QUE APRUEBA EL USUARIO ANTERIOR 
	   INSERT INTO #OperacionNoAprobadas (IdOperacion)
		SELECT
		  F.IdOperacion
		FROM #FlujoSerial F     
		JOIN dbo.TA_Tarea T (NOLOCK)
		  ON F.IdOperacion=T.IdOperacion 
		  AND (F.NoSecuencia - 1) = T.NoSecuencia
		WHERE T.Activo = 1 --> CTE
		AND T.IdEstatus <> 2;--> CTE DIFERENTE DE ESTATUS APROBADO

		-- ELIMINAR LAS ACEPTACIONES DE FACTURA QUE NO SE DEBEN MOSTRAR AL USUARIO ACTUAL
		DELETE AF
		FROM #AceptacionesFactura AF
		JOIN #OperacionNoAprobadas  A
		ON AF.IdOperacion = A.IdOperacion
	
		-- OBTENER DETALLE FINAL DE LAS ACEPTACIONES DE FACTURA 
		 INSERT INTO #AceptacionesPedido
		 (IdAceptacionPedido,
			Pedido,
			IdPedido,
			FechaRegistro,
			Proveedor,
			Nombre,
			TotalPedido,
			Moneda,
			RFC,
			FolioFactura,
			UUID,
			FechaTimbrado,
			IdSolicitudPedido,
			span,
			PedirCarta,
			IdOperacion,
			Contrato,
			PO)
		  SELECT 
			AF.IdAceptacionPedido,
			PG.IdPedido,
			AF.IdPedido,
			AF.FechaRegistro,
			CONCAT(PR.RazonSocial, ' ' ,ISNULL(Pr.RegimenCapital,'')) AS Proveedor,
			E.Nombre,
			0,
			TM.TipoMonedaCorto AS Moneda,
			ISNULL(PR.RFC, '') AS RFC, 
			CONCAT(ISNULL(FI.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(FI.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(FI.Folio,'')))) >0 THEN '-' END), ISNULL(FI.Folio,'')) AS FolioFactura,
			ISNULL(FI.UUID,'') AS UUID,
			FI.FechaTimbrado AS FechaTimbrado,
			AF.IdSolicitudPedido,
			CASE
			  WHEN E.IdEstatus = 2 THEN 'label label-success'
			  WHEN E.IdEstatus = 1 THEN 'label label-primary'
			  WHEN E.IdEstatus = 3 THEN 'label label-danger'
			  WHEN E.IdEstatus IS NULL THEN 'label label-default'
			END,
			AF.PedirCarta,
			AF.IdOperacion,
			Contrato =  C.NombreContrato,
			'Sin PO relacionada' PO
		  FROM #AceptacionesFactura AF	      
		  JOIN MM_Pedidos AS PG (NOLOCK)
			ON AF.IdPedido = PG.IdIdentificador
			AND PG.IdProveedorCliente = @IdProveedor
			AND PG.IdTipoPedido IN (2, 4, 6)-->CTES	MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
		   JOIN dbo.FI_Factura AS fi (NOLOCK)
			ON AF.IdFactura=fi.IdFactura
		  JOIN S_Proveedor AS PR (NOLOCK)
			ON AF.IdSubcontratista=PR.IdProveedor  
		  JOIN dbo.PV_TipoMoneda AS TM (NOLOCK)
			ON AF.IdMoneda=TM.IdMoneda
		  JOIN TA_Estatus AS E (NOLOCK)
			ON AF.IdEstatus=E.IdEstatus
		  JOIN #Contratos AS C (NOLOCK)
			ON AF.IdContrato=C.IdContrato     	   	   
		  GROUP BY AF.IdAceptacionPedido,
				   AF.IdPedido,
				   AF.FechaRegistro,
				   AF.IdPedido,
				   AF.PedirCarta,
				   AF.IdOperacion,
				   PR.RazonSocial,
				   Pr.RegimenCapital,
				   E.Nombre,
				   PG.IdPedido,
				   TM.TipoMonedaCorto,
				   PR.RFC,             
				   AF.IdSolicitudPedido,
				   E.IdEstatus,
				   FI.UUID, 
				   FI.Folio,
				   FI.Serie,
				   FI.FechaTimbrado,
				   c.IdContrato,
				   C.NombreContrato			 					   
		  ORDER BY AF.IdAceptacionPedido DESC;

		  -- OBTENER TOTALES
		  INSERT INTO #AceptacionTotales(IdAceptacionPedido, TotalPedido)
		  SELECT AF.IdAceptacionPedido,
		  SUM(APD.Cantidad * PED.PrecioUnitario)
		  FROM #AceptacionesPedido AF
		  JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON AF.IdAceptacionPedido = APD.IdAceptacionPedido 
		  JOIN MM_PedidoDetalle AS PED (NOLOCK)
			ON AF.IdPedido=PED.IdPedido 
			AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
		   GROUP BY AF.IdAceptacionPedido

		-- ACTUALIZAR LOS MONTOS TOTALES 
		UPDATE AP 
		SET AP.TotalPedido=ATO.TotalPedido
		FROM #AceptacionesPedido AP
		JOIN #AceptacionTotales ATO
			ON AP.IdAceptacionPedido = ATO.IdAceptacionPedido

		-- ACTUALIZAR PO SI EXISTE
		UPDATE AP 
		SET AP.PO=RPO.PO
		FROM #AceptacionesPedido AP
		JOIN DEA_Relacion_PR_PO AS RPO	(NOLOCK)
			ON AP.IdPedido = RPO.IdPedido   	

	END

	SELECT
    ROW_NUMBER() OVER (
    ORDER BY FechaRegistro DESC) AS IdRow,
    IdAceptacionPedido,
    Pedido,
    IdPedido,
    FechaRegistro,
    Proveedor,
	Nombre,
    TotalPedido,
    Moneda,
    RFC,
    IdSolicitudPedido,
    span,
    CASE
      WHEN ISNULL(PedirCarta, 0) = 1 THEN 'Si'
      ELSE 'No'
    END AS PedirCarta,
    IdOperacion,
    Contrato,
	PO,
	UUID,
	FechaTimbrado,
	FolioFactura
  FROM #AceptacionesPedido
  GROUP BY IdAceptacionPedido,
           Pedido,
           IdPedido,
           FechaRegistro,
           Proveedor,
           Nombre,
           TotalPedido,
           Moneda,
           RFC,
           IdSolicitudPedido,
           span,
           PedirCarta,
           IdOperacion,
           Contrato,
		   PO,
		   UUID,
		   FechaTimbrado,
		   FolioFactura
  ORDER BY FechaRegistro DESC;
END
END;