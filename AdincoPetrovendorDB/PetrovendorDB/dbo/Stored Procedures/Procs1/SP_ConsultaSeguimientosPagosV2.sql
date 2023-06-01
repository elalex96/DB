USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultaSeguimientosPagosV2]    Script Date: 01/06/2023 01:45:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:		<Alexander Gomez>
-- Create date: <06-12-2018>
-- Description:	<Se consultan tambien los registros de murphy>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 13/12/2019
-- Description: Se agrego validación columna de AWSPDFId
-- =============================================
-- =============================================
-- Author:		Luis David
-- Create date: 10/05/2022
-- Description: Optimización de sp
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 01/06/2023
-- Description: Se modifica consulta para validar filtros de fechas 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultaSeguimientosPagosV2] @IdProveedor   INT, 
                                                       @Pagado        BIT, 
                                                       @Facturas      NVARCHAR(MAX) = NULL, 
                                                       @IdContrato    INT           = NULL, 
                                                       @IdUsuario     INT           = NULL, 
                                                       @FechaRegistro DATETIME      = NULL,
													   @Del DateTime=NULL,  
													   @Al DateTime=NULL
AS
    BEGIN
		DECLARE @COUNT_FACTURAS INT;
        DECLARE @FiltroFacturas NVARCHAR(MAX);
        DECLARE @PROVEDORRFC NVARCHAR(20)            

		DROP TABLE IF EXISTS #Facturas
        CREATE TABLE #Facturas
        (IdFactura INT
        );
		CREATE NONCLUSTERED INDEX ix_tempFacturas_IdFactura  ON #Facturas (IdFactura);

		DROP TABLE IF EXISTS #SEGUIMIENTOPAGOS
        CREATE TABLE #SEGUIMIENTOPAGOS
        (IdFactura          INT NULL, 
         IdFacturaPet       INT NULL, 
         IdSolicitudPedido  VARCHAR(20) NULL, 
         Receptor           NVARCHAR(200) NULL, 
         Fecha              DATETIME NULL, 
         Serie              NVARCHAR(MAX) NULL, 
         Folio              NVARCHAR(MAX) NULL, 
         Total              MONEY, 
         UUID               VARCHAR(500) NULL, 
         Moneda             VARCHAR(10) NULL, 
         Proceso            VARCHAR(100) NULL, 
         TieneArchivo       BIT NULL, 
         IdAceptacionPedido INT NULL, 
         ReceptorRFC        VARCHAR(500), 
         AWSPDFId           INT
        );
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_IdFactura  ON #SEGUIMIENTOPAGOS (IdFactura);
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_IdFacturaPet  ON #SEGUIMIENTOPAGOS (IdFacturaPet);
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_UUID  ON #SEGUIMIENTOPAGOS (UUID);
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_IdAceptacionPedido  ON #SEGUIMIENTOPAGOS (IdAceptacionPedido);

		DROP TABLE IF EXISTS #SEGUIMIENTOPAGOS_PPD
        CREATE TABLE #SEGUIMIENTOPAGOS_PPD
        (IdFactura          INT NULL, 
         IdFacturaPet       INT NULL,              
         UUID               VARCHAR(500) NULL, 
         Proceso            VARCHAR(100) NULL, 
         TieneArchivo       BIT NULL,         
         AWSPDFId           INT
        );
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_PPD_IdFactura  ON #SEGUIMIENTOPAGOS_PPD (IdFactura);
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_PPD_IdFacturaPet  ON #SEGUIMIENTOPAGOS_PPD (IdFacturaPet);
		CREATE NONCLUSTERED INDEX ix_tempSEGUIMIENTOPAGOS_PPD_UUID  ON #SEGUIMIENTOPAGOS_PPD (UUID);

		SET @PROVEDORRFC =
        (
            SELECT RFC
            FROM dbo.S_Proveedor (NOLOCK)
            WHERE IdProveedor = @IdProveedor
        ); 

		SELECT @FiltroFacturas = COALESCE(STUFF(T.Col, LEN(T.Col) - CHARINDEX(',', REVERSE(T.Col)) + 1, 1, ''), T.Col)
        FROM(VALUES(@Facturas)) AS T(Col);
        SET @FiltroFacturas = LTRIM(RTRIM(@FiltroFacturas));

        IF LEN(@FiltroFacturas) > 0
            BEGIN
                INSERT INTO #Facturas(IdFactura)
                       SELECT Value
                       FROM dbo.Split(LEFT(@FiltroFacturas, (LEN(@FiltroFacturas))), ',');
        END;


		SET @COUNT_FACTURAS =
        (
            SELECT COUNT(IdFactura)
            FROM #Facturas
        );       
		

        INSERT INTO #SEGUIMIENTOPAGOS(
		IdFactura, 
        IdFacturaPet, 
        IdSolicitudPedido, 
        Receptor, 
        Fecha, 
        Serie, 
        Folio, 
        Total, 
        UUID, 
        Moneda, 
        Proceso, 
        TieneArchivo, 
        IdAceptacionPedido, 
        ReceptorRFC, 
        AWSPDFId)
        SELECT DISTINCT 
                FA.IdFactura, 
                FP.IdFactura, 
                P.IdSolicitudPedido, 
                PR.RazonSocial, 
                FP.CreadoEn, 
                FP.Serie, 
                FP.Folio, 
                FP.MontoConIva AS Total, 
                FP.UUID, 
                M.TipoMonedaCorto, 
                Proceso = CASE
                            WHEN(TR.AWSPDFId IS NULL)
                            THEN 'No Pagado'
                            WHEN(TR.AWSPDFId IS NOT NULL)
                            THEN 'Pagado'
                        WHEN FA.IdFactura IS NULL
                            THEN 'En Proceso'
                        END, 
                TieneArchivo = CAST(CASE
                                        WHEN(TR.PDF IS NULL
                                            AND ISNULL(TR.AWSPDFId, 0) = 0)
                                        THEN 0
                                        ELSE 1
                                    END AS BIT), 
                AP.IdAceptacionPedido, 
                FP.Receptor, 
                TR.AWSPDFId
        FROM dbo.MM_AceptacionFactura AS AF (NOLOCK)
			JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
				ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
            JOIN dbo.MM_Pedido AS P (NOLOCK)
				ON AP.IdPedido = P.IdPedido
				AND P.IdSubcontratista = @IdProveedor --PROVEEDOR
            JOIN dbo.FI_Factura AS FP (NOLOCK)
				ON AF.IdFactura = FP.IdFactura
				AND CASE
					WHEN @COUNT_FACTURAS > 0  AND FP.IdFactura IN  (SELECT FTT.IdFactura FROM #Facturas FTT) THEN 
						1 
					WHEN @COUNT_FACTURAS = 0 AND CAST(FP.CreadoEn AS date) BETWEEN CAST(@Del AS date) AND CAST(@Al AS date) THEN 
						1
					ELSE 0
					END = 1            
            LEFT JOIN dbo.PV_TipoMoneda (NOLOCK) AS M 
				ON FP.IdMoneda = M.IdMoneda
            LEFT JOIN Adinco.dbo.FI_Factura AS FA (NOLOCK)
				ON FP.UUID COLLATE Modern_Spanish_CI_AS = FA.UUID COLLATE Modern_Spanish_CI_AS
            LEFT JOIN dbo.S_Proveedor (NOLOCK) AS PR 
				ON FP.Receptor = PR.RFC
            LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRF (NOLOCK)
				ON FA.IdFactura = TRF.IdFactura
            LEFT JOIN Adinco.dbo.FI_Transfer AS TR (NOLOCK)
				ON TRF.IdTransfer = TR.IdTransferencia
        WHERE AF.IdEstatusXML = 2 --XML APROBADO
                AND AF.IdEstatusPDF = 2 --PDF APROBADO                
                AND FP.Activa = 1
                AND ISNULL(FP.IsEliminado, 0) = 0					 	
        GROUP BY FA.IdFactura, 
                FP.IdFactura, 
                P.IdSolicitudPedido, 
                PR.RazonSocial, 
                FP.CreadoEn, 
                FP.Serie, 
                FP.Folio, 
                FP.MontoConIva, 
                FP.UUID, 
                M.TipoMonedaCorto, 
                AP.IdAceptacionPedido, 
                FP.Receptor, 
                TR.PDF, 
                TR.AWSPDFId, 
                TR.IdTransferencia;

        --> SEGUIMIENTO PAGOS DE MURPHY
        INSERT INTO #SEGUIMIENTOPAGOS(
		IdFactura, 
        IdFacturaPet, 
        IdSolicitudPedido, 
        Receptor, 
        Fecha, 
        Serie, 
        Folio, 
        Total, 
        UUID, 
        Moneda, 
        Proceso, 
        TieneArchivo, 
        IdAceptacionPedido, 
        ReceptorRFC, 
        AWSPDFId)
               SELECT aFact.IdFactura, 
                      pFact.IdFactura IdFacturaPet, 
                      'N/A', 
                      CON.RazonSocial AS Receptor, 
                      aFact.Fecha, 
                      aFact.Serie, 
                      aFact.Folio, 
                      aFact.MontoConIva AS Total, 
                      aFact.UUID, 
                      M.TipoMonedaCorto AS Moneda, 
                      Proceso = CASE
                                    WHEN transf.AWSPDFId IS NULL
                                    THEN 'No pagado'
                                    WHEN transf.AWSPDFId IS NOT NULL
                                    THEN 'Pagado'
                                    WHEN aFact.IdFactura IS NULL
                                    THEN 'En proceso'
                                END, 
                      TieneArchivo = CAST(CASE
                                              WHEN(transf.PDF IS NULL
                                                   AND transf.AWSPDFId IS NULL)
                                              THEN 0
                                              ELSE 1
                                          END AS BIT), 
                      acepFact.IdAceptacionPedido, 
                      aFact.Receptor, 
                      transf.AWSPDFId
               FROM dbo.MPY_MM_AceptacionFactura acepFact (NOLOCK)	
                    JOIN Petrovendor.dbo.FI_Factura pFact (NOLOCK)
						ON acepFact.IdFactura = pFact.IdFactura 						
						AND CASE
						 WHEN @COUNT_FACTURAS > 0  AND pFact.IdFactura IN  (SELECT FF.IdFactura FROM #Facturas FF) THEN 
							  1 
						 WHEN @COUNT_FACTURAS = 0 AND  CAST(pFact.Fecha AS date) BETWEEN CAST(@Del AS date) AND CAST(@Al AS date) THEN
							  1
						 ELSE 0
						 END = 1
					JOIN dbo.MPY_MM_AceptacionPedido acepPed (NOLOCK)
						ON acepFact.IdAceptacionPedido = acepPed.IdAceptacionPedido
					JOIN Petrovendor.dbo.TA_Estatus (NOLOCK) AS TE
						ON acepFact.IdEstatus = TE.IdEstatus 
						AND TE.IdEstatus = 2 --CTE aprobadas
					JOIN Adinco.dbo.CO_Contratista (NOLOCK) AS CON
						ON pFact.Receptor COLLATE SQL_Latin1_General_CP1_CI_AS = CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
						AND pFact.Emisor = @PROVEDORRFC 
                    LEFT JOIN Adinco.dbo.FI_Factura aFact (NOLOCK)
						ON  pFact.UUID COLLATE Modern_Spanish_CI_AS =  aFact.UUID COLLATE Modern_Spanish_CI_AS 
                    LEFT JOIN Adinco.dbo.PV_TipoMoneda (NOLOCK) AS M
						ON aFact.IdMoneda = M.IdMoneda
                    LEFT JOIN Adinco.dbo.FI_TransferFactura transFac (NOLOCK)
						ON aFact.IdFactura = transFac.IdFactura
                    LEFT JOIN Adinco.dbo.FI_Transfer transf  (NOLOCK)
						ON transFac.IdTransfer = transf.IdTransferencia
               WHERE aFact.Activa = 1
                     AND pFact.Activa = 1                    
                     AND pFact.IdFactura IS NOT NULL					 
               GROUP BY CASE
                            WHEN transf.IdTransferencia IS NULL
                            THEN 'No pagado'
                            WHEN transf.IdTransferencia IS NOT NULL
                            THEN 'Pagado'
                            WHEN aFact.IdFactura IS NULL
                            THEN 'En proceso'
                        END, 
                        CAST(CASE
                                 WHEN(transf.PDF IS NULL
                                      AND transf.AWSPDFId IS NULL)
                                 THEN 0
                                 ELSE 1
                             END AS BIT), 
                        aFact.IdFactura, 
                        pFact.IdFactura, 
                        CON.RazonSocial, 
                        aFact.Fecha, 
                        aFact.Serie, 
                        aFact.Folio, 
                        aFact.MontoConIva, 
                        aFact.UUID, 
                        M.TipoMonedaCorto, 
                        acepFact.IdAceptacionPedido, 
                        aFact.Receptor, 
                        transf.AWSPDFId, 
                        transf.IdTransferencia;

        ---OBTENER LAS FACTURA PAGADAS PERO CON UN COMPLEMENTO 
        INSERT INTO #SEGUIMIENTOPAGOS_PPD(
		IdFactura,
        IdFacturaPet,
		UUID,         
        Proceso, 
        TieneArchivo,
        AWSPDFId)
               SELECT DISTINCT 
                      FA.IdFactura, 
                      FP.IdFactura,     
                      FP.UUID, 
                      Proceso = CASE
                                    WHEN(TR.AWSPDFId IS NULL)
                                    THEN 'No Pagado'
                                    WHEN(TR.AWSPDFId IS NOT NULL)
                                    THEN 'Pagado'
                                    WHEN FA.IdFactura IS NULL
                                    THEN 'En Proceso'
                                END, 
                      TieneArchivo = CAST(CASE
                                              WHEN(TR.PDF IS NULL
                                                   AND ISNULL(TR.AWSPDFId, 0) = 0)
                                              THEN 0
                                              ELSE 1
                                          END AS BIT),                      
                      TR.AWSPDFId
               FROM dbo.MM_AceptacionFactura AS AF (NOLOCK)					
                    JOIN dbo.FI_Factura AS FP (NOLOCK)
						ON AF.IdFactura = FP.IdFactura
					JOIN #SEGUIMIENTOPAGOS SP
						ON FP.IdFactura  = SP.IdFacturaPet 
                    JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
						ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                    JOIN dbo.MM_Pedido AS P (NOLOCK)
						ON AP.IdPedido = P.IdPedido
						AND P.IdSubcontratista = @IdProveedor --PROVEEDOR
                    JOIN Adinco.dbo.FI_Factura AS FA (NOLOCK)
						ON SP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS =  FA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
                    LEFT JOIN Adinco.dbo.FI_CPDocRelacionado (NOLOCK) AS DR
						ON FA.UUID = DR.IdDocumento
                    LEFT JOIN Adinco.dbo.FI_ComplementoDePago CP (NOLOCK)
						ON DR.IdComplementoDePago = CP.IdComplementoDePago
                    LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRF (NOLOCK)
						ON CP.IdFactura = TRF.IdFactura
                    LEFT JOIN Adinco.dbo.FI_Transfer AS TR (NOLOCK)
						ON TRF.IdTransfer = TR.IdTransferencia
               WHERE AF.IdEstatusXML = 2 --XML APROBADO
                     AND AF.IdEstatusPDF = 2 --PDF APROBADO                     
                     AND FP.Activa = 1 -- CTE ACTIVO
                     AND ISNULL(FP.IsEliminado, 0) = 0 
               GROUP BY FA.IdFactura, 
                        FP.IdFactura,   
                        FP.CreadoEn,                         
                        FP.UUID, 
                        FP.Receptor, 
                        TR.PDF, 
                        TR.AWSPDFId, 
                        TR.IdTransferencia;

        --ACTUALIZAR EL ESTATUS DE PAGADO SI TIENE UN ARCHIVO A LA TABLA DE PAGOS DE LA TABLA DE PAGOS CON COMPLEMENTO  
        UPDATE SP
          SET 
              SP.AWSPDFId = SPP.AWSPDFId, 
              SP.Proceso = SPP.Proceso, 
              SP.TieneArchivo = SPP.TieneArchivo
        FROM #SEGUIMIENTOPAGOS SP
             JOIN #SEGUIMIENTOPAGOS_PPD SPP ON SP.UUID = SPP.UUID 
                                               AND SP.IdFactura = SPP.IdFactura;
        
        

        SELECT IdFactura, 
        IdFacturaPet, 
        IdSolicitudPedido, 
        Receptor, 
        Fecha, 
        Serie, 
        Folio, 
        Total, 
        UUID, 
        Moneda, 
        Proceso, 
        TieneArchivo, 
        IdAceptacionPedido, 
        ReceptorRFC, 
        AWSPDFId
        FROM #SEGUIMIENTOPAGOS	
        ORDER BY Fecha DESC;
    END;