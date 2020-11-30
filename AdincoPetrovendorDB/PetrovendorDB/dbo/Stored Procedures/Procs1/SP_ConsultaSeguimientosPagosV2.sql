-- Author:		<Alexander Gomez>
-- Create date: <06-12-2018>
-- Description:	<Se consultan tambien los registros de murphy>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 13/12/2019
-- Description: Se agrego validación columna de AWSPDFId
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultaSeguimientosPagosV2] @IdProveedor   INT, 
                                                       @Pagado        BIT, 
                                                       @Facturas      NVARCHAR(MAX) = NULL, 
                                                       @IdContrato    INT           = NULL, 
                                                       @IdUsuario     INT           = NULL, 
                                                       @FechaRegistro DATETIME      = NULL
AS
    BEGIN
        DECLARE @PROVEDORRFC NVARCHAR(20)=
        (
            SELECT RFC
            FROM dbo.S_Proveedor
            WHERE IdProveedor = @IdProveedor
        );
        --DECLARE @Facturas NVARCHAR(max) ='19761,19745,' 
        DECLARE @FiltroFacturas NVARCHAR(MAX);
        SELECT @FiltroFacturas = COALESCE(STUFF(T.Col, LEN(T.Col) - CHARINDEX(',', REVERSE(T.Col)) + 1, 1, ''), T.Col)
        FROM(VALUES(@Facturas)) AS T(Col);
        SET @FiltroFacturas = LTRIM(RTRIM(@FiltroFacturas));
        --SELECT @FiltroFacturas

        CREATE TABLE #Facturas
        (IdFactura INT
        );
        IF LEN(@FiltroFacturas) > 0
            BEGIN
                INSERT INTO #Facturas(IdFactura)
                       SELECT Value
                       FROM dbo.Split(LEFT(@FiltroFacturas, (LEN(@FiltroFacturas))), ',');
        END;

        --SELECT * FROM #Facturas

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
        CREATE TABLE #SEGUIMIENTOPAGOS_PPD
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
        INSERT INTO #SEGUIMIENTOPAGOS
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
               FROM dbo.MM_AceptacionFactura AS AF
                    LEFT JOIN dbo.FI_Factura AS FP ON FP.IdFactura = AF.IdFactura
                    LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                    LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                    LEFT JOIN dbo.PV_TipoMoneda AS M ON M.IdMoneda = FP.IdMoneda
                    LEFT JOIN Adinco.dbo.FI_Factura AS FA ON FA.UUID COLLATE Modern_Spanish_CI_AS = FP.UUID COLLATE Modern_Spanish_CI_AS
                    LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC = FP.Receptor
                    LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRF ON TRF.IdFactura = FA.IdFactura
                    LEFT JOIN Adinco.dbo.FI_Transfer AS TR ON TR.IdTransferencia = TRF.IdTransfer
               WHERE AF.IdEstatusXML = 2 --XML APROBADO
                     AND AF.IdEstatusPDF = 2 --PDF APROBADO
                     AND P.IdSubcontratista = @IdProveedor --PROVEEDOR
                     AND FP.Activa = 1
                     AND ISNULL(FP.IsEliminado, 0) = 0
                     AND FA.IdFactura IS NOT NULL --FACTURA EN ADINCO
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
        INSERT INTO #SEGUIMIENTOPAGOS
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
               FROM Adinco.dbo.FI_Factura aFact
                    LEFT JOIN Petrovendor.dbo.FI_Factura pFact ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
                    LEFT JOIN dbo.MPY_MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
                    INNER JOIN dbo.MPY_MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
                    LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE ON TE.IdEstatus = acepFact.IdEstatus
                    LEFT JOIN Adinco.dbo.CO_Contratista AS CON ON CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = pFact.Receptor COLLATE SQL_Latin1_General_CP1_CI_AS
                    LEFT JOIN Adinco.dbo.PV_TipoMoneda M ON M.IdMoneda = aFact.IdMoneda
                    LEFT JOIN Adinco.dbo.FI_TransferFactura transFac ON transFac.IdFactura = aFact.IdFactura
                    LEFT JOIN Adinco.dbo.FI_Transfer transf ON transf.IdTransferencia = transFac.IdTransfer
               WHERE TE.IdEstatus = 2 --aprobadas
                     AND aFact.Activa = 1
                     AND pFact.Activa = 1
                     AND pFact.Emisor = @PROVEDORRFC
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
        INSERT INTO #SEGUIMIENTOPAGOS_PPD
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
               FROM dbo.MM_AceptacionFactura AS AF
                    LEFT JOIN dbo.FI_Factura AS FP ON FP.IdFactura = AF.IdFactura
                    LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                    LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                    LEFT JOIN dbo.PV_TipoMoneda AS M ON M.IdMoneda = FP.IdMoneda
                    LEFT JOIN Adinco.dbo.FI_Factura AS FA ON FA.UUID COLLATE Modern_Spanish_CI_AS = FP.UUID COLLATE Modern_Spanish_CI_AS
                    LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC = FP.Receptor
                    LEFT JOIN Adinco.dbo.FI_CPDocRelacionado dr ON DR.IdDocumento = FA.UUID
                    JOIN Adinco.dbo.FI_ComplementoDePago cp ON cp.IdComplementoDePago = dr.IdComplementoDePago
                    LEFT JOIN Adinco.dbo.FI_TransferFactura AS TRF ON TRF.IdFactura = CP.IdFactura
                    LEFT JOIN Adinco.dbo.FI_Transfer AS TR ON TR.IdTransferencia = TRF.IdTransfer
               WHERE AF.IdEstatusXML = 2 --XML APROBADO
                     AND AF.IdEstatusPDF = 2 --PDF APROBADO
                     AND P.IdSubcontratista = @IdProveedor --PROVEEDOR
                     AND FP.Activa = 1
                     AND ISNULL(FP.IsEliminado, 0) = 0
                     AND FA.IdFactura IS NOT NULL --FACTURA EN ADINCO
                     AND TR.AWSPDFId IS NOT NULL --> QUE SI TENGA UN ARCHIVO CARGADO EN FI_TRANSFER
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

        --ACTUALIZAR EL ESTATUS DE PAGADO SI TIENE UN ARCHIVO A LA TABLA DE PAGOS DE LA TABLA DE PAGOS CON COMPLEMENTO  
        UPDATE SP
          SET 
              SP.AWSPDFId = SPP.AWSPDFId, 
              SP.Proceso = SPP.Proceso, 
              SP.TieneArchivo = SPP.TieneArchivo
        FROM #SEGUIMIENTOPAGOS SP
             JOIN #SEGUIMIENTOPAGOS_PPD SPP ON SPP.UUID = SP.UUID
                                               AND SPP.IdFactura = SP.IdFactura;
        DECLARE @COUNT_FACTURAS INT;
        SET @COUNT_FACTURAS =
        (
            SELECT COUNT(IdFactura)
            FROM #Facturas
        );
        SELECT *
        FROM #SEGUIMIENTOPAGOS
        WHERE CASE
                  WHEN @COUNT_FACTURAS > 0
                       AND IdFacturaPet IN
        (
            SELECT IdFactura
            FROM #Facturas
        )
                  THEN 1
                  WHEN @COUNT_FACTURAS = 0
                       AND IdFacturaPet NOT IN
        (
            SELECT IdFactura
            FROM #Facturas
        )
                  THEN 1
                  ELSE 0
              END = 1
        ORDER BY Fecha DESC;
    END;
