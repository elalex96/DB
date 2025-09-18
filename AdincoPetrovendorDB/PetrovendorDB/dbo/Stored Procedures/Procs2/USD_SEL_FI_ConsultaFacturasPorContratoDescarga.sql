USE PETROVENDOR
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USD_SEL_FI_ConsultaFacturasPorContratoDescarga'
)
    DROP PROCEDURE USD_SEL_FI_ConsultaFacturasPorContratoDescarga
GO
-- =============================================  
-- Author: Daniel AC 
-- Create date: 05-09-2025  
-- Description: Lista las facturas de un contrato  
-- =============================================  
CREATE PROCEDURE [dbo].[USD_SEL_FI_ConsultaFacturasPorContratoDescarga]
    @IdContrato INT,
    @IdUsuario INT,
    @FechaInicio DATETIME,
    @FechaFin DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PLANT	nvarchar(10);
	
	CREATE TABLE #Estatus(
		IdEstatus INT
	);

	CREATE TABLE #AceptacionesPedido 
	(
		IdAceptacionPedido	int				NULL,
		IdFactura			int				NULL,
		Pedido				varchar(150)	NULL,
		IdPedido			int				NULL,
		FechaRegistro		datetime		NULL,
		Proveedor			varchar(400)	NULL,
		Nombre				varchar(200)	NULL,
		RFC					nvarchar(100)	NULL,
		UUID				nvarchar(100)	NULL,
		FechaTimbrado		datetime		NULL,
		IdSolicitudPedido	nvarchar(100)	NULL,		
		IdOperacion			int,
		Contrato			varchar(100),
		OrigenAceptacion	varchar(100),
		RutaCarpeta			varchar(1000),
		RFC_RECEPTOR		varchar(1000)
	)	
	CREATE NONCLUSTERED INDEX ix_tempAceptacionesPedidoIdPedido  ON #AceptacionesPedido (IdPedido);
	CREATE NONCLUSTERED INDEX ix_tempAceptacionesPedidoIdSolicitudPedido  ON #AceptacionesPedido (IdSolicitudPedido);
	CREATE NONCLUSTERED INDEX ix_tempAceptacionesPedidoIdOperacion  ON #AceptacionesPedido (IdOperacion);
	
	CREATE TABLE #PLANT
	(			
		PLANT  VARCHAR(10)
	)
	CREATE NONCLUSTERED INDEX ix_tempProveedorPLANT  ON #PLANT (PLANT);

	IF @IdContrato IN (10053,10039) --> CTES PARA CONTRATOS DE MURPHY CUENCA SALINA Y EL DORADO
	BEGIN
	INSERT INTO #PLANT(PLANT)
	SELECT P.Planta
	FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
	JOIN Adinco.dbo.CO_SAPContratista_Planta AS P (NOLOCK)
		ON C.IdContratista = P.IdContratista
	WHERE C.IdContrato IN  (10053,10039);  --> CTES PARA CONTRATOS DE MURPHY CUENCA SALINA Y EL DORADO
	END 

	SET @PLANT = (SELECT TOP 1 PLANT FROM #PLANT);

	IF ISNULL(@PLANT,'') = ''
	BEGIN
	
		CREATE TABLE #FlujoSerial 
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
			IdProveedorCompras			INT,
			IdMoneda					INT,
			PedirCarta					BIT,
			RFC_RECEPTOR				varchar(1000)

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
				
		 CREATE TABLE #Contratos
		(	
			IdContrato			INT,
			NombreContrato	 	VARCHAR(300)

		)
		CREATE NONCLUSTERED INDEX ix_tempContratosIdContrato  ON #Contratos (IdContrato);
			   
	END;

	INSERT INTO #Estatus
	VALUES(2) --> CTE SOLO FACTURAS APROBADAS
	
	
	IF EXISTS (SELECT COUNT(1) FROM #PLANT)  
	BEGIN
	    -- FACTURAS DE MURPHY
		INSERT INTO #AceptacionesPedido     
			(IdAceptacionPedido,
			IdFactura,
			Pedido,
			IdPedido,
			FechaRegistro,
			Proveedor,
			Nombre,			
			RFC,
			UUID,
			FechaTimbrado,
			IdSolicitudPedido,
			IdOperacion,
			Contrato,
			OrigenAceptacion,
			RFC_RECEPTOR)
			SELECT 
				AF.IdAceptacionPedido,
				F.IdFactura,
			  CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS nvarchar(100)) COLLATE Modern_Spanish_CI_AS),
			  00,
			  AF.CreadoEl,
			  ISNULL(SV.VendorName, PR.RazonSocial) AS Proveedor,
			  E.Nombre,			  		  
			  ISNULL(SV.TaxID, '') AS RFC, 
		      ISNULL(F.UUID,'') AS UUID,
			  F.FechaTimbrado,
			  CONCAT('Reference Num:', AP.ReferenceNumber),
			  NULL,
			  Contrato = AC.NombreAreaContractual,
			  'MPY_MM_AceptacionPedido',
			  F.Receptor
			FROM #PLANT PL (NOLOCK)
			JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK)
				ON PL.PLANT = PO.Plant
			JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
				ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
			JOIN MPY_MM_AceptacionFactura AS AF (NOLOCK)
				ON AP.IdAceptacionPedido  = AF.IdAceptacionPedido
			JOIN TA_Estatus AS E (NOLOCK)
				ON AF.IdEstatus = E.IdEstatus
			JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
				ON AP.IdContrato = C.IdContrato
			JOIN Adinco..CO_AreaContractual AC
				ON C.IdAreaContractual = AC.IdAreaContractual
			JOIN dbo.FI_Factura AS F (NOLOCK)
					  ON AF.IdFactura=F.IdFactura 
					  AND CAST(F.FechaTimbrado AS date) BETWEEN CAST(@FechaInicio AS date) AND CAST(@FechaFin as date)
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
			AND ISNULL(AF.IdEstatusEliminado, 0) <> 1  -->CTE
			AND AF.IdEstatusXML != 4  -->CTE
			AND AF.IdEstatusXML != 4  -->CTE
			GROUP BY AF.IdAceptacionPedido,
					F.IdFactura,
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
					AC.NombreAreaContractual,	
					PO.SAPPONumber,
					F.Receptor
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
			IdProveedorCompras,
			IdMoneda,
			RFC_RECEPTOR
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
		PE.IdProveedorCompras,
		PE.IdMoneda,
		F.Receptor
		FROM MM_Pedido AS PE (NOLOCK)			
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
		  ON PE.IdContrato = @IdContrato
		  AND PE.IdPedido=AP.IdPedido	 
		  AND  ISNULL(AP.IdEliminado, 0) <> 1 -->CTE
		JOIN MM_AceptacionFactura AF (NOLOCK)	
			ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		JOIN FI_Factura F (NOLOCK)
			ON AF.IdFactura = F.IdFactura
			AND CAST(F.FechaTimbrado AS date) BETWEEN  CAST(@FechaInicio AS date) AND  CAST(@FechaFin AS date)
		JOIN dbo.TA_Operacion O (NOLOCK)
		  ON AF.IdAceptacionFactura  = O.IdDocumento
		  AND O.IdTipoOperacion = 10 --> CTE APROBACIÓN DE FACTURA
		  AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->QUE NO ESTE ELIMINADO
		  AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 -->CTE NO ESTE ELIMINADO
		JOIN dbo.RelacionCartaCNPedido RC (NOLOCK)
			ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 	 
		WHERE O.IdEstatusOperacion IN (SELECT IdEstatus FROM #Estatus)
		AND ISNULL(O.IdFlujoTarea, 0) <> 0
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
		PE.IdProveedorCompras,
		PE.IdMoneda,
		F.Receptor

		-- OBTENER CONTRATOS AGRUPADOS
		INSERT INTO #Contratos(IdContrato)
		SELECT IdContrato
		FROM #AceptacionesFactura  (NOLOCK)
		GROUP BY  IdContrato

		UPDATE CO
		SET CO.NombreContrato= AC.NombreAreaContractual
		FROM #Contratos CO
		JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
			ON CO.IdContrato=C.IdContrato 
		JOIN Adinco..CO_AreaContractual AC
			ON C.IdAreaContractual = AC.IdAreaContractual

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
		  IdFactura,
			Pedido,
			IdPedido,
			FechaRegistro,
			Proveedor,
			Nombre,		
			RFC,
			UUID,
			FechaTimbrado,
			IdSolicitudPedido,			
			IdOperacion,
			Contrato,
			OrigenAceptacion,
			RFC_RECEPTOR)
		  SELECT 
			AF.IdAceptacionPedido,
			FI.IdFactura,
			PG.IdPedido,
			AF.IdPedido,
			AF.FechaRegistro,
			CONCAT(PR.RazonSocial, ' ' ,ISNULL(Pr.RegimenCapital,'')) AS Proveedor,
			E.Nombre,
			ISNULL(PR.RFC, '') AS RFC, 
			ISNULL(FI.UUID,'') AS UUID,
			FI.FechaTimbrado AS FechaTimbrado,
			AF.IdSolicitudPedido,			
			AF.IdOperacion,
			Contrato =  C.NombreContrato,
			'MM_AceptacionPedido',
			AF.RFC_RECEPTOR
		   FROM #AceptacionesFactura AF	      
		  JOIN MM_Pedidos AS PG (NOLOCK)
			ON AF.IdPedido = PG.IdIdentificador
			AND AF.IdProveedorCompras = PG.IdProveedorCliente 
			AND PG.IdTipoPedido IN (2, 4, 6)-->CTES	MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
		   JOIN dbo.FI_Factura AS FI (NOLOCK)
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
				   FI.IdFactura,
				   E.IdEstatus,
				   FI.UUID, 
				   FI.Folio,
				   FI.Serie,
				   FI.FechaTimbrado,
				   c.IdContrato,
				   AF.RFC_RECEPTOR,
				   C.NombreContrato			 		   
		  ORDER BY AF.IdAceptacionPedido DESC;
		  			

	END

	IF @IdContrato IN  (10053,10039)   --> CTES PARA CONTRATOS DE MURPHY CUENCA SALINA Y EL DORADO
	BEGIN

		UPDATE #AceptacionesPedido
		SET RutaCarpeta = CONCAT(
		'FACTURASxRECEPTOR'
		,'/'
		,RFC_RECEPTOR
		,'/'
		,ISNULL(CAST(YEAR(FechaTimbrado) AS nvarchar(1000)),'SIN_ANIO')
		,'/'
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(RTRIM(LTRIM(Proveedor))), '/', ''), ':', ''), '*', ''), '"', ''), '<', ''), '>', ''), '|', ''), '\', ''))
		
		--- TABLA 1
		SELECT 
		Contrato = 'FACTURASxRECEPTOR'
	END
	ELSE 
	BEGIN 
		UPDATE #AceptacionesPedido
		SET RutaCarpeta = CONCAT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(RTRIM(LTRIM(Contrato))), '/', ''), ':', ''), '*', ''), '"', ''), '<', ''), '>', ''), '|', ''), '\', ''),'/',ISNULL(CAST(YEAR(FechaTimbrado) AS nvarchar(1000)),'SIN_ANIO'),'/',REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(RTRIM(LTRIM(Proveedor))), '/', ''), ':', ''), '*', ''), '"', ''), '<', ''), '>', ''), '|', ''), '\', ''))
		
		-- TABLA 1
		SELECT 
		Contrato = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(RTRIM(LTRIM(AC.NombreAreaContractual))), '/', ''), ':', ''), '*', ''), '"', ''), '<', ''), '>', ''), '|', ''), '\', '')  
		FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)		
		JOIN Adinco..CO_AreaContractual AC
			ON C.IdAreaContractual = AC.IdAreaContractual
		WHERE C.IdContrato = @IdContrato
	END 
	

	-- TABLA 2
	SELECT
    ROW_NUMBER() OVER (
    ORDER BY AP.FechaTimbrado DESC) AS IdRow,
    AP.IdAceptacionPedido, 
	AP.IdFactura,   
	UPPER(AP.UUID) AS UUID,
	AP.RutaCarpeta,
	AP.OrigenAceptacion,
    AP.RFC_RECEPTOR
	FROM #AceptacionesPedido AP  
	GROUP BY AP.IdAceptacionPedido,
		   AP.IdFactura,         
		   AP.UUID,
		   AP.RutaCarpeta,
		   AP.FechaTimbrado,
		   AP.OrigenAceptacion,
		   AP.RFC_RECEPTOR
  ORDER BY AP.FechaTimbrado DESC;


END;



