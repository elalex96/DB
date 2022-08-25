USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SIPAC_RC_CONT_26_M]    Script Date: 8/18/2022 3:50:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Yazmin Glez.
-- Create date: 01-11-17
-- Description: Reporte de CGI - MP Transferencia Electrónica. Plantilla RC_CONT_06_M
-- Modificado: 20180625
-- Modificado: Reyna Olvera
-- Description: Se modifico para que cuando no tenga archivo cargado en la transferencia, muestre una nota de archivo no cargado
-- Modificado: Manuel Cruz
-- Fecha Modificado: 2019-07-01
-- Description: Cambio para mostrar la transferencia con el complemento de pago
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
-- Modificado:       Manuel Cruz
-- Fecha Modificado: 2021-03-22
-- Description:      Se ajustó consulta de PE/PI para evitar la multiplicación de los montos por la cantidad de registros
-- =============================================
-- Modificado:       Manuel Cruz
-- Fecha Modificado: 2022-03-28
-- Description:      Se ajusta tipo de cambio RC_26_10 a 4 decimales
-- =============================================
-- Modificado:       Reyna Olvera
-- Fecha Modificado: 2022-08-18
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_26_M]
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0,
@Plantilla VARCHAR(150)  = ''
AS
     BEGIN
         SET NOCOUNT ON;
		 
/*Generar nombre de archivos*/
EXEC [SIPAC_RC_CONT_26_M_IdDocFormaPago]
    @Contrato,
    @Mes,
    @IdPresupuesto;

/*Omitir facturas en la hoja 26*/

IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL
    DROP TABLE #uuidNoReportar;
IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
    DROP TABLE #Facturas;
IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL
    DROP TABLE #MontosTotalTransferenciaPUE;
IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL
    DROP TABLE #MontosTotalTransferenciaPPD;
--
CREATE TABLE #uuidNoReportar (UUID VARCHAR(2000));
CREATE TABLE #Facturas
    (
        IdFactura       INT,
        UUID            VARCHAR(2000),
        TipoComprobante VARCHAR(50),
        MetodoPago      VARCHAR(50),
        IdMoneda        INT
    );
CREATE TABLE #MontosTotalTransferenciaPPD
    (
        IdFacturaCP  INT,
        UUIDCP       VARCHAR(2000),
        FormaPagoCP  VARCHAR(50),
        TipoCambioCP FLOAT,
        MonedaCP     VARCHAR(50),
        MontoPesos   FLOAT,
        MonedaPPD    INT,
        MontoDolares FLOAT,
        IdTransfer   INT
    );
CREATE TABLE #MontosTotalTransferenciaPUE
    (
        IdFacturaPUE   INT,
        UUIDPUE        VARCHAR(2000),
        FormaPagoPUE   VARCHAR(50),
        TipoCambio     FLOAT,
        MonedaTransfer VARCHAR(50),
        MontoPesos     FLOAT,
        MonedaFactura  INT,
        MontoFactura   FLOAT,
        MontoDolares   FLOAT,
        IdTransfer     INT
    );

IF (@Mes = '20190801')
    BEGIN
        INSERT INTO #uuidNoReportar
            (
                UUID
            )
        VALUES
            (
                '091A3242-EF0F-444A-A5C1-3D7D50247D3B'
            ),
            (
                '775E782A-9493-3D40-9B24-E1604A865A0F'
            ),
            (
                '78BB3869-8091-B049-98B4-1238E15E7BDA'
            ),
            (
                'A6344C73-4C5A-EA4A-B2F8-3378CDA24C17'
            );
    END;
IF (@Mes <> '20190901')
    BEGIN
        INSERT INTO #uuidNoReportar
            (
                UUID
            )
        VALUES
            (
                '9A159442-52BC-1E49-8190-D020953CE967'
            );
    END;
IF (@Mes <> '20200101')
    BEGIN
        INSERT INTO #uuidNoReportar
            (
                UUID
            )
        VALUES
            (
                '78CA2E37-22C0-408C-8E94-105C7388A704'
            ),
            (
                '30EFEC90-471E-434A-87CF-EFFEEE7C48C1'
            );
    END;
IF (@Mes = '20200501')
    BEGIN
        INSERT INTO #uuidNoReportar
            (
                UUID
            )
        VALUES
            (
                'D515F4A9-244C-422E-A2B1-11B234039715'
            ),
            (
                '1091E714-CC8E-46B8-8421-37470C285BAC'
            ),
            (
                '95AB6B55-C312-4CAF-9A9E-BD7E7A2124AB'
            ),
            (
                '10FDC8FB-DEBB-4BD5-8C10-6B51E61B5FE6'
            );
    END;
--
INSERT INTO #Facturas
    (
        IdFactura,
        UUID,
        TipoComprobante,
        MetodoPago,
        IdMoneda
    )
            SELECT
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                CASE
                    WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'
                         OR FI_Factura.TipoComprobante LIKE 'I%'
                        THEN 'I'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                         OR FI_Factura.TipoComprobante LIKE 'E%'
                        THEN 'E'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'
                         OR FI_Factura.TipoComprobante LIKE 'T%'
                        THEN 'T'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'
                         OR FI_Factura.TipoComprobante LIKE 'N%'
                        THEN 'N'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'
                         OR FI_Factura.TipoComprobante LIKE 'P%'
                        THEN 'P'
                    ELSE
                        'NA'
                END       AS TipoComprobante,
                CASE
                    WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                         OR FI_Factura.MetodoPago LIKE '%PUE%'
                         OR FI_Factura.FormaPago LIKE '%exhibi%'
                         OR FI_Factura.FormaPago LIKE '%PUE%'
                        THEN 'PUE'
                    WHEN FI_Factura.MetodoPago LIKE '%parcia%'
                         OR FI_Factura.MetodoPago LIKE '%dife%'
                         OR FI_Factura.MetodoPago LIKE '%PPD%'
                         OR FI_Factura.FormaPago LIKE '%parcia%'
                         OR FI_Factura.FormaPago LIKE '%dife%'
                         OR FI_Factura.FormaPago LIKE '%PPD%'
                        THEN 'PPD'
                    WHEN FI_Factura.TipoComprobante = 'P'
                        THEN 'PPD'
                END       AS MetodoPago,
                FI_Factura.IdMoneda
            FROM
                dbo.CO_Registro WITH (NOLOCK)
                JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON CO_Registro.IdFactura = FI_Factura.IdFactura
                           AND FI_Factura.IdContrato = @Contrato
                           AND CO_Registro.IdEstado = 10004
                           AND CO_Registro.CvTipoDocFacturacion = 1
                JOIN
                    dbo.CO_Contrato WITH (NOLOCK)
                        ON FI_Factura.IdContrato = CO_Contrato.IdContrato
                           AND CO_Contrato.IdContrato = @Contrato
                JOIN
                    dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                        ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                JOIN
                    dbo.CO_Servicio WITH (NOLOCK)
                        ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)
            WHERE
                CO_Contrato.IdContrato = @Contrato
                AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                AND CO_Registro.IdEstado = 10004
                AND CO_Registro.CvTipoDocFacturacion = 1
                AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
                AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                AND CO_LineaPresupuestoMes.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
            GROUP BY
                CASE
                    WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'
                         OR FI_Factura.TipoComprobante LIKE 'I%'
                        THEN 'I'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                         OR FI_Factura.TipoComprobante LIKE 'E%'
                        THEN 'E'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'
                         OR FI_Factura.TipoComprobante LIKE 'T%'
                        THEN 'T'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'
                         OR FI_Factura.TipoComprobante LIKE 'N%'
                        THEN 'N'
                    WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'
                         OR FI_Factura.TipoComprobante LIKE 'P%'
                        THEN 'P'
                    ELSE
                        'NA'
                END,
                CASE
                    WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                         OR FI_Factura.MetodoPago LIKE '%PUE%'
                         OR FI_Factura.FormaPago LIKE '%exhibi%'
                         OR FI_Factura.FormaPago LIKE '%PUE%'
                        THEN 'PUE'
                    WHEN FI_Factura.MetodoPago LIKE '%parcia%'
                         OR FI_Factura.MetodoPago LIKE '%dife%'
                         OR FI_Factura.MetodoPago LIKE '%PPD%'
                         OR FI_Factura.FormaPago LIKE '%parcia%'
                         OR FI_Factura.FormaPago LIKE '%dife%'
                         OR FI_Factura.FormaPago LIKE '%PPD%'
                        THEN 'PPD'
                    WHEN FI_Factura.TipoComprobante = 'P'
                        THEN 'PPD'
                END,
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                FI_Factura.IdMoneda;

/*PPD*/
--
INSERT INTO #MontosTotalTransferenciaPPD
    (
        IdFacturaCP,
        UUIDCP,
        FormaPagoCP,
        TipoCambioCP,
        MonedaCP,
        MontoPesos,
        MonedaPPD,
        MontoDolares,
        IdTransfer
    )
            SELECT
                Result.IdFacturaCP,
                Result.UUIDCP,
                Result.FormaPagoCP,
                Result.TipoCambioCP,
                Result.MonedaCP,
                SUM(Result.MontoCP)      AS MontoCP,
                Result.MonedaPPD,
                SUM(Result.MontoDolares) AS MontoDolares,
                Result.IdTransferencia
            FROM
                (
                    SELECT
                        FI_Factura.IdFactura               AS IdFacturaCP,
                        FI_Factura.UUID                    AS UUIDCP,
                        FI_ComplementoDePago.FormaDePagoP  AS FormaPagoCP,
                        CO_TipoCambioDiario.TipoCambio     AS TipoCambioCP,
                        PV_TipoMoneda.IdMoneda             AS MonedaCP,
                        SUM(FI_CPDocRelacionado.ImpPagado) AS MontoCP,
                        FCPDR.IdMoneda                     AS MonedaPPD,
                        CAST((SUM(   CASE
                                         WHEN PV_TipoMoneda.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 1
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                         WHEN PV_TipoMoneda.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 2
                                             THEN FI_CPDocRelacionado.ImpPagado
                                     END
                                 )
                             ) AS DECIMAL(15, 2))          AS MontoDolares,
                        FI_Transfer.IdTransferencia
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                                   AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        JOIN
                            dbo.FI_ComplementoDePago WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
                        JOIN
                            dbo.FI_Factura WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura FCPDR WITH (NOLOCK)
                                ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
                                   AND FI_Factura.IdContrato = FCPDR.IdContrato
                        JOIN
                            #Facturas
                                ON #Facturas.IdFactura = FCPDR.IdFactura
                                   AND #Facturas.MetodoPago = 'PPD'
                        JOIN
                            dbo.PV_TipoMoneda WITH (NOLOCK)
                                ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                        LEFT JOIN
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)
                                ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
                    WHERE
                        #Facturas.MetodoPago = 'PPD'
                        AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        AND FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
                        AND PV_TipoMoneda.IdMoneda = FCPDR.IdMoneda
                    GROUP BY
                        FI_Factura.IdFactura,
                        FI_Factura.UUID,
                        FI_ComplementoDePago.FormaDePagoP,
                        CO_TipoCambioDiario.TipoCambio,
                        PV_TipoMoneda.IdMoneda,
                        FCPDR.IdMoneda,
                        FI_Transfer.IdTransferencia
                    UNION
                    SELECT
                        FI_Factura.IdFactura               AS IdFacturaCP,
                        FI_Factura.UUID                    AS UUIDCP,
                        FI_ComplementoDePago.FormaDePagoP  AS FormaPagoCP,
                        CO_TipoCambioDiario.TipoCambio     AS TipoCambioCP,
                        PV_TipoMoneda.IdMoneda             AS MonedaCP,
                        SUM(FI_CPDocRelacionado.ImpPagado) AS MontoCP,
                        FCPDR.IdMoneda                     AS MonedaPPD,
                        CAST((SUM(   CASE
                                         WHEN PV_TipoMoneda.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 1
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                         WHEN PV_TipoMoneda.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 2
                                             THEN FI_CPDocRelacionado.ImpPagado
                                     END
                                 )
                             ) AS DECIMAL(15, 2))          AS MontoDolares,
                        FI_Transfer.IdTransferencia
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                                   AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        JOIN
                            dbo.FI_ComplementoDePago WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
                        JOIN
                            dbo.FI_Factura WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura FCPDR WITH (NOLOCK)
                                ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
                                   AND FI_Factura.IdContrato = FCPDR.IdContrato
                        JOIN
                            #Facturas
                                ON #Facturas.IdFactura = FCPDR.IdFactura
                                   AND #Facturas.MetodoPago = 'PPD'
                        JOIN
                            dbo.PV_TipoMoneda WITH (NOLOCK)
                                ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                        LEFT JOIN
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)
                                ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
                    WHERE
                        #Facturas.MetodoPago = 'PPD'
                        AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        AND FI_Transfer.IdMoneda <> PV_TipoMoneda.IdMoneda
                        AND PV_TipoMoneda.IdMoneda = FCPDR.IdMoneda
                    GROUP BY
                        FI_Factura.IdFactura,
                        FI_Factura.UUID,
                        FI_ComplementoDePago.FormaDePagoP,
                        CO_TipoCambioDiario.TipoCambio,
                        PV_TipoMoneda.IdMoneda,
                        FCPDR.IdMoneda,
                        FI_Transfer.IdTransferencia
                    UNION
                    SELECT
                        FI_Factura.IdFactura              AS IdFacturaCP,
                        FI_Factura.UUID                   AS UUIDCP,
                        FI_ComplementoDePago.FormaDePagoP AS FormaPagoCP,
                        CO_TipoCambioDiario.TipoCambio    AS TipoCambioCP,
                        PV_TipoMoneda.IdMoneda            AS MonedaCP,
                        CAST((SUM(   CASE
                                         WHEN PV_TipoMoneda.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 2
                                             THEN FI_CPDocRelacionado.ImpPagado * CO_TipoCambioDiario.TipoCambio
                                         WHEN PV_TipoMoneda.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 1
                                             THEN FI_CPDocRelacionado.ImpPagado
                                     END
                                 )
                             ) AS DECIMAL(15, 2))         AS MontoCP,
                        CASE
                            WHEN PV_TipoMoneda.IdMoneda = 1
                                 AND FCPDR.IdMoneda = 2
                                THEN 1
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FCPDR.IdMoneda = 1
                                THEN 2
                        END                               AS MonedaPPD,
                        CAST((SUM(   CASE
                                         WHEN PV_TipoMoneda.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 2
                                             THEN FI_CPDocRelacionado.ImpPagado
                                         WHEN PV_TipoMoneda.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 1
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                     END
                                 )
                             ) AS DECIMAL(15, 2))         AS MontoDolares,
                        FI_Transfer.IdTransferencia
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                                   AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        JOIN
                            dbo.FI_ComplementoDePago WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
                        JOIN
                            dbo.FI_Factura WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)
                                ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura FCPDR WITH (NOLOCK)
                                ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
                                   AND FI_Factura.IdContrato = FCPDR.IdContrato
                        JOIN
                            #Facturas
                                ON #Facturas.IdFactura = FCPDR.IdFactura
                                   AND #Facturas.MetodoPago = 'PPD'
                        JOIN
                            dbo.PV_TipoMoneda WITH (NOLOCK)
                                ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                        LEFT JOIN
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)
                                ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
                                   AND CO_TipoCambioDiario.IdMoneda <> FCPDR.IdMoneda
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
                    WHERE
                        #Facturas.MetodoPago = 'PPD'
                        AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        AND FI_Transfer.IdMoneda <> PV_TipoMoneda.IdMoneda
                        AND PV_TipoMoneda.IdMoneda <> FCPDR.IdMoneda
                    GROUP BY
                        FI_Factura.IdFactura,
                        FI_Factura.UUID,
                        FI_ComplementoDePago.FormaDePagoP,
                        CO_TipoCambioDiario.TipoCambio,
                        PV_TipoMoneda.IdMoneda,
                        CASE
                            WHEN PV_TipoMoneda.IdMoneda = 1
                                 AND FCPDR.IdMoneda = 2
                                THEN 1
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FCPDR.IdMoneda = 1
                                THEN 2
                        END,
                        FI_Transfer.IdTransferencia
                    UNION
                    --Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)
                    --y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)
                    SELECT
                        FI_Factura.IdFactura      AS IdFacturaCP,
                        FI_Factura.UUID           AS UUIDCP,
                        CP.FormaDePagoP           AS FormaPagoCP,
                        CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FCPDR.IdMoneda = 1
                                THEN 1
                            WHEN PV_TipoMoneda.IdMoneda = 1
                                 AND FCPDR.IdMoneda = 2
                                THEN TCDD.TipoCambio
                        END,
                        PV_TipoMoneda.IdMoneda    AS MonedaCP,
                        CAST((SUM(   CASE
                                         WHEN PV_TipoMoneda.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 1
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                         WHEN PV_TipoMoneda.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 2
                                             THEN FI_CPDocRelacionado.ImpPagado * TCDD.TipoCambio
                                     END
                                 )
                             ) AS DECIMAL(15, 2)) AS MontoCP,
                        CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FCPDR.IdMoneda = 1
                                THEN FCPDR.IdMoneda
                            WHEN PV_TipoMoneda.IdMoneda = 1
                                 AND FCPDR.IdMoneda = 2
                                THEN FCPDR.IdMoneda
                        END                       AS MonedaPPD,
                        CAST((SUM(   CASE
                                         WHEN PV_TipoMoneda.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 1
                                             THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                         WHEN PV_TipoMoneda.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 2
                                             THEN FI_CPDocRelacionado.ImpPagado
                                     END
                                 )
                             ) AS DECIMAL(15, 2)) AS MontoDolares,
                        FI_Transfer.IdTransferencia
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                                   AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        JOIN
                            dbo.FI_ComplementoDePago CP WITH (NOLOCK)
                                ON FI_TransferFactura.IdFactura = CP.IdFactura
                        JOIN
                            dbo.FI_Factura WITH (NOLOCK)
                                ON CP.IdFactura = FI_Factura.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado WITH (NOLOCK)
                                ON CP.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
                        JOIN
                            dbo.FI_Factura           FCPDR WITH (NOLOCK)
                                ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
                                   AND FI_Factura.IdContrato = FCPDR.IdContrato
                        JOIN
                            #Facturas
                                ON #Facturas.IdFactura = FCPDR.IdFactura
                                   And #Facturas.MetodoPago = 'PPD'
                        JOIN
                            dbo.PV_TipoMoneda WITH (NOLOCK)
                                ON CP.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                        LEFT JOIN
                            dbo.CO_TipoCambioDiario WITH (NOLOCK)
                                ON CO_TipoCambioDiario.IdMoneda <> PV_TipoMoneda.IdMoneda
                                   AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda
                                   AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                                   AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                                   AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
                        LEFT JOIN
                            dbo.CO_TipoCambioDiario  TCDD WITH (NOLOCK)
                                ON TCDD.IdMoneda <> FCPDR.IdMoneda
                                   AND TCDD.IdMoneda NOT IN (
                                                                10000, 10003, 10004
                                                            )
                                   AND DAY(TCDD.Fecha) = DAY(FI_Transfer.FechaPago)
                                   AND MONTH(TCDD.Fecha) = MONTH(FI_Transfer.FechaPago)
                                   AND YEAR(TCDD.Fecha) = YEAR(FI_Transfer.FechaPago)
                    WHERE
                        #Facturas.MetodoPago = 'PPD'
                        AND FI_TransferFactura.CvTipoDocFacturacion = 6
                        AND FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
                        AND PV_TipoMoneda.IdMoneda <> FCPDR.IdMoneda
                    GROUP BY
                        FI_Factura.IdFactura,
                        FI_Factura.UUID,
                        CP.FormaDePagoP,
                        CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FCPDR.IdMoneda = 1
                                THEN 1
                            WHEN PV_TipoMoneda.IdMoneda = 1
                                 AND FCPDR.IdMoneda = 2
                                THEN TCDD.TipoCambio
                        END,
                        PV_TipoMoneda.IdMoneda,
                        CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FCPDR.IdMoneda = 1
                                THEN FCPDR.IdMoneda
                            WHEN PV_TipoMoneda.IdMoneda = 1
                                 AND FCPDR.IdMoneda = 2
                                THEN FCPDR.IdMoneda
                        END,
                        FI_Transfer.IdTransferencia
                ) AS Result
            GROUP BY
                Result.IdFacturaCP,
                Result.UUIDCP,
                Result.FormaPagoCP,
                Result.TipoCambioCP,
                Result.MonedaCP,
                Result.MonedaPPD,
                Result.IdTransferencia;

/*PUE*/
--
INSERT INTO #MontosTotalTransferenciaPUE
    (
        IdFacturaPUE,
        UUIDPUE,
        FormaPagoPUE,
        TipoCambio,
        MonedaTransfer,
        MontoPesos,
        MonedaFactura,
        MontoFactura,
        MontoDolares,
        IdTransfer
    )
            SELECT
                FI_Factura.IdFactura           AS IdFacturaPUE,
                FI_Factura.UUID                AS UUIDPUE,
                PV_MetodoPago.C_FormaPago      AS MetodoPago,
                CO_TipoCambioDiario.TipoCambio AS TipoCambioTransfer,
                FI_Transfer.IdMoneda           AS MonedaTransfer,
                CAST((SUM(   CASE
                                 WHEN FI_Transfer.IdMoneda = 2
                                      AND FI_Factura.IdMoneda = 2
                                     THEN FI_TransferFactura.MontoPagado * CO_TipoCambioDiario.TipoCambio
                                 WHEN FI_Transfer.IdMoneda = 1
                                      AND FI_Factura.IdMoneda = 1
                                     THEN FI_TransferFactura.MontoPagado
                             END
                         )
                     ) AS DECIMAL(15, 2))      AS MontoPesos,
                FI_Factura.IdMoneda            AS MonedaPUE,
                FI_Factura.MontoConIva,
                CAST((SUM(   CASE
                                 WHEN FI_Transfer.IdMoneda = 1
                                      AND FI_Factura.IdMoneda = 1
                                     THEN FI_TransferFactura.MontoPagado / CO_TipoCambioDiario.TipoCambio
                                 WHEN FI_Transfer.IdMoneda = 2
                                      AND FI_Factura.IdMoneda = 2
                                     THEN FI_TransferFactura.MontoPagado
                             END
                         )
                     ) AS DECIMAL(15, 2))      AS MontoDolares,
                FI_Transfer.IdTransferencia
            FROM
                dbo.FI_Transfer WITH (NOLOCK)
                JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                           AND FI_TransferFactura.CvTipoDocFacturacion = 1
                JOIN
                    dbo.PV_MetodoPago WITH (NOLOCK)
                        ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
                JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
                           AND FI_Factura.IdContrato = FI_Transfer.IdContrato
                JOIN
                    #Facturas
                        ON #Facturas.IdFactura = FI_Factura.IdFactura
                           AND #Facturas.MetodoPago = 'PUE'
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
                LEFT JOIN
                    dbo.CO_TipoCambioDiario TCDT WITH (NOLOCK)
                        ON TCDT.IdMoneda <> FI_Transfer.IdMoneda
                           AND TCDT.IdMoneda <> FI_Factura.IdMoneda
                           AND TCDT.IdMoneda NOT IN (
                                                        10000, 10003, 10004
                                                    )
                           AND DAY(TCDT.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(TCDT.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(TCDT.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PUE'
                AND FI_TransferFactura.CvTipoDocFacturacion = 1
                AND FI_Factura.IdMoneda = FI_Transfer.IdMoneda
            GROUP BY
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                PV_MetodoPago.C_FormaPago,
                CO_TipoCambioDiario.TipoCambio,
                FI_Transfer.IdMoneda,
                FI_Factura.IdMoneda,
                FI_Factura.MontoConIva,
                FI_Transfer.IdTransferencia
            UNION
            SELECT
                FI_Factura.IdFactura           AS IdFacturaPUE,
                FI_Factura.UUID                AS UUIDPUE,
                PV_MetodoPago.C_FormaPago      AS MetodoPago,
                CO_TipoCambioDiario.TipoCambio AS TipoCambioTransfer,
                FI_Transfer.IdMoneda           AS MonedaTransfer,
                CAST((SUM(   CASE
                                 WHEN FI_Transfer.IdMoneda = 2
                                      AND FI_Factura.IdMoneda = 1
                                     THEN FI_TransferFactura.MontoPagado * CO_TipoCambioDiario.TipoCambio
                                 WHEN FI_Transfer.IdMoneda = 1
                                      AND FI_Factura.IdMoneda = 2
                                     THEN FI_TransferFactura.MontoPagado
                             END
                         )
                     ) AS DECIMAL(15, 2))      AS MontoPesos,
                FI_Factura.IdMoneda            AS MonedaPUE,
                FI_Factura.MontoConIva,
                CAST((SUM(   CASE
                                 WHEN FI_Transfer.IdMoneda = 1
                                      AND FI_Factura.IdMoneda = 2
                                     THEN FI_TransferFactura.MontoPagado / CO_TipoCambioDiario.TipoCambio
                                 WHEN FI_Transfer.IdMoneda = 2
                                      AND FI_Factura.IdMoneda = 1
                                     THEN FI_TransferFactura.MontoPagado
                             END
                         )
                     ) AS DECIMAL(15, 2))      AS MontoDolares,
                FI_Transfer.IdTransferencia
            FROM
                dbo.FI_Transfer WITH (NOLOCK)
                JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                           AND FI_TransferFactura.CvTipoDocFacturacion = 1
                JOIN
                    dbo.PV_MetodoPago WITH (NOLOCK)
                        ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
                JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
                           AND FI_Factura.IdContrato = FI_Transfer.IdContrato
                JOIN
                    #Facturas
                        ON #Facturas.IdFactura = FI_Factura.IdFactura
                           AND #Facturas.MetodoPago = 'PUE'
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda <> FI_Factura.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
                LEFT JOIN
                    dbo.CO_TipoCambioDiario TCDT WITH (NOLOCK)
                        ON TCDT.IdMoneda <> FI_Transfer.IdMoneda
                           AND TCDT.IdMoneda = FI_Factura.IdMoneda
                           AND TCDT.IdMoneda NOT IN (
                                                        10000, 10003, 10004
                                                    )
                           AND DAY(TCDT.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(TCDT.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(TCDT.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PUE'
                AND FI_TransferFactura.CvTipoDocFacturacion = 1
                AND FI_Factura.IdMoneda <> FI_Transfer.IdMoneda
            GROUP BY
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                PV_MetodoPago.C_FormaPago,
                CO_TipoCambioDiario.TipoCambio,
                FI_Transfer.IdMoneda,
                FI_Factura.IdMoneda,
                FI_Factura.MontoConIva,
                FI_Transfer.IdTransferencia;

/*SELECT FINAL*/

SELECT
    LTRIM(RTRIM(CO_Contratista.IDSIPAC))                           AS [RF_00],
    CO_Contrato.IDRegFiducidiario                                  AS [RI_00],
    MONTH(CO_Registro.MesPresentacion)                             AS [RC26_00],
    YEAR(CO_Registro.MesPresentacion)                              AS [RC26_01],
    MTT.FormaPagoPUE                                               AS [RC26_02],
    CASE
        WHEN CO_Registro.CvTipoDocFacturacion = 1
            THEN ISNULL(FI_Factura.UUID, 'NA')
    END                                                            AS [RC26_03],
    FI_Transfer.FechaPago                                          AS [RC26_04],
    CASE
        WHEN FI_Transfer.AWSPDFId IS NULL
            THEN 'NOTA:Falta ingresar archivo PDF'
        ELSE
            FI_Transfer.NombreExtencionArchivo
    END                                                            AS [RC26_05],
    FI_Transfer.HashSHA256                                         AS [RC26_06],
    CAST(MTT.MontoPesos AS DECIMAL(15, 2))                         AS [RC26_07],
    PV_TipoMoneda.TipoMonedaCorto                                  AS [RC26_08],
    CAST(MTT.MontoDolares AS DECIMAL(15, 2))                       AS [RC26_09],
    CAST(MTT.TipoCambio AS DECIMAL(15, 4))                         AS [RC26_10],
    LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RazonSocial, 0, 119))) AS [RC26_11],
    2                                                              AS [RC26_12]
FROM
    dbo.FI_Transfer WITH (NOLOCK)
    JOIN
        dbo.FI_TransferFactura WITH (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
    JOIN
        #MontosTotalTransferenciaPUE MTT
            ON FI_TransferFactura.IdFactura = MTT.IdFacturaPUE
               AND MTT.IdTransfer = FI_TransferFactura.IdTransfer
    JOIN
        dbo.FI_Factura WITH (NOLOCK)
            ON MTT.IdFacturaPUE = FI_Factura.IdFactura
               AND FI_Factura.IdContrato = FI_Transfer.IdContrato
    JOIN
        dbo.CO_Registro WITH (NOLOCK)
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
               AND CO_Registro.IdEstado = 10004
    JOIN
        dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
    JOIN
        dbo.CO_Presupuesto WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
    JOIN
        dbo.CO_AnioContractual WITH (NOLOCK)
            ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
    JOIN
        dbo.CO_Contrato WITH (NOLOCK)
            ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
               AND CO_Contrato.IdContrato = @Contrato
    JOIN
        dbo.CO_Contratista WITH (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
    JOIN
        dbo.CO_Servicio WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
               AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
    JOIN
        dbo.PV_Subcontratista WITH (NOLOCK)
            ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
    JOIN
        dbo.PV_TipoMoneda WITH (NOLOCK)
            ON MTT.MonedaTransfer = PV_TipoMoneda.IdMoneda
WHERE
    CO_Contrato.IdContrato = @Contrato
    AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
    AND CO_Registro.IdEstado = 10004
    AND ISNULL(CONVERT(INT, FI_Transfer.ProcesadoSIPAC), 0) = 0
    AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
    AND CO_Presupuesto.IdPresupuesto = CASE
                                           WHEN @IdPresupuesto = 0
                                               THEN CO_LineaPresupuestoMes.IdPresupuesto
                                           ELSE
                                               @IdPresupuesto
                                       END
GROUP BY
    LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
    MONTH(CO_Registro.MesPresentacion),
    YEAR(CO_Registro.MesPresentacion),
    CASE
        WHEN CO_Registro.CvTipoDocFacturacion = 1
            THEN ISNULL(FI_Factura.UUID, 'NA')
    END,
    CASE
        WHEN FI_Transfer.AWSPDFId IS NULL
            THEN 'NOTA:Falta ingresar archivo PDF'
        ELSE
            FI_Transfer.NombreExtencionArchivo
    END,
    CAST(MTT.MontoPesos AS DECIMAL(15, 2)),
    CAST(MTT.MontoDolares AS DECIMAL(15, 2)),
    LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RazonSocial, 0, 119))),
    CO_Contrato.IDRegFiducidiario,
    MTT.FormaPagoPUE,
    FI_Transfer.FechaPago,
    FI_Transfer.HashSHA256,
    PV_TipoMoneda.TipoMonedaCorto,
    CAST(MTT.TipoCambio AS DECIMAL(15, 4))
--
UNION
--
SELECT
    LTRIM(RTRIM(CO_Contratista.IDSIPAC))                           AS [RF_00],
    CO_Contrato.IDRegFiducidiario                                  AS [RI_00],
    MONTH(CO_Registro.MesPresentacion)                             AS [RC26_00],
    YEAR(CO_Registro.MesPresentacion)                              AS [RC26_01],
    MTT.FormaPagoCP                                                AS [RC26_02],
    ISNULL(MTT.UUIDCP, 'NA')                                       AS [RC26_03],
    FI_Transfer.FechaPago                                          AS [RC26_04],
    CASE
        WHEN FI_Transfer.AWSPDFId IS NULL
            THEN 'NOTA:Falta ingresar archivo PDF'
        ELSE
            FI_Transfer.NombreExtencionArchivo
    END                                                            AS [RC26_05],
    FI_Transfer.HashSHA256                                         AS [RC26_06],
    CAST(MTT.MontoPesos AS DECIMAL(15, 2))                         AS [RC26_07],
    PV_TipoMoneda.TipoMonedaCorto                                  AS [RC26_08],
    CAST(MTT.MontoDolares AS DECIMAL(15, 2))                       AS [RC26_09],
    CAST(MTT.TipoCambioCP AS DECIMAL(15, 4))                       AS [RC26_10],
    LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RazonSocial, 0, 119))) AS [RC26_11],
    2                                                              AS [RC26_12]
FROM
    dbo.FI_Transfer WITH (NOLOCK)
    JOIN
        dbo.FI_TransferFactura WITH (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
    JOIN
        #MontosTotalTransferenciaPPD MTT
            ON FI_TransferFactura.IdFactura = MTT.IdFacturaCP
               AND MTT.IdTransfer = FI_TransferFactura.IdTransfer
    JOIN
        dbo.FI_ComplementoDePago WITH (NOLOCK)
            ON MTT.IdFacturaCP = FI_ComplementoDePago.IdFactura
    JOIN
        dbo.FI_CPDocRelacionado WITH (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
    JOIN
        dbo.FI_Factura               FCP WITH (NOLOCK)
            ON FI_TransferFactura.IdFactura = FCP.IdFactura
               AND FI_Transfer.IdContrato = FCP.IdContrato
    JOIN
        dbo.FI_Factura               FCPDR WITH (NOLOCK)
            ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
    JOIN
        dbo.CO_Registro WITH (NOLOCK)
            ON FCPDR.IdFactura = CO_Registro.IdFactura
               AND CO_Registro.IdEstado = 10004
    JOIN
        dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
    JOIN
        dbo.CO_Presupuesto WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
    JOIN
        dbo.CO_AnioContractual WITH (NOLOCK)
            ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
    JOIN
        dbo.CO_Contrato WITH (NOLOCK)
            ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
               AND CO_Contrato.IdContrato = @Contrato
    JOIN
        dbo.CO_Contratista WITH (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
    JOIN
        dbo.CO_Servicio WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
               AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
    JOIN
        dbo.PV_Subcontratista WITH (NOLOCK)
            ON FCPDR.IdSubcontratista = PV_Subcontratista.IdSubcontratista
    JOIN
        dbo.PV_TipoMoneda WITH (NOLOCK)
            ON MTT.MonedaCP = PV_TipoMoneda.IdMoneda
WHERE
    CO_Contrato.IdContrato = @Contrato
    AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
    AND CO_Registro.IdEstado = 10004
    AND ISNULL(CONVERT(INT, FI_Transfer.ProcesadoSIPAC), 0) = 0
    AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
    AND FCP.UUID NOT IN (
                            SELECT
                                RPT.UUID
                            FROM
                                #uuidNoReportar RPT
                        )
    AND FCP.UUID NOT IN (
                            SELECT
                                ControlF.UUID
                            FROM
                                dbo.FI_ControlPPDComplementos ControlF
                            WHERE
                                ControlF.IdContrato = @Contrato
                        )
    AND CO_Presupuesto.IdPresupuesto = CASE
                                           WHEN @IdPresupuesto = 0
                                               THEN CO_LineaPresupuestoMes.IdPresupuesto
                                           ELSE
                                               @IdPresupuesto
                                       END
GROUP BY
    LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
    MONTH(CO_Registro.MesPresentacion),
    YEAR(CO_Registro.MesPresentacion),
    ISNULL(MTT.UUIDCP, 'NA'),
    CASE
        WHEN FI_Transfer.AWSPDFId IS NULL
            THEN 'NOTA:Falta ingresar archivo PDF'
        ELSE
            FI_Transfer.NombreExtencionArchivo
    END,
    CAST(MTT.MontoPesos AS DECIMAL(15, 2)),
    CAST(MTT.MontoDolares AS DECIMAL(15, 2)),
    LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RazonSocial, 0, 119))),
    CO_Contrato.IDRegFiducidiario,
    MTT.FormaPagoCP,
    FI_Transfer.FechaPago,
    FI_Transfer.HashSHA256,
    PV_TipoMoneda.TipoMonedaCorto,
    CAST(MTT.TipoCambioCP AS DECIMAL(15, 4))
--
UNION
--
SELECT
    LTRIM(RTRIM(CO_Contratista.IDSIPAC))                                                        AS [RF_00],
    CO_Contrato.IDRegFiducidiario                                                               AS [RI_00],
    MONTH(CO_Registro.MesPresentacion)                                                          AS [RC26_00],
    YEAR(CO_Registro.MesPresentacion)                                                           AS [RC26_01],
    PV_MetodoPago.C_FormaPago                                                                   AS [RC26_02],
    CASE
        WHEN CO_Registro.CvTipoDocFacturacion = 2
            THEN ISNULL(FI_PedimentoComprobante.NumeroPedimento, 'NA')
        WHEN CO_Registro.CvTipoDocFacturacion = 3
            THEN ISNULL(FI_PedimentoComprobante.IdDocFacturacionSIPAC, 'NA')
    END                                                                                         AS [RC26_04],
    FI_Transfer.FechaPago                                                                       AS [RC26_04],
    CASE
        WHEN FI_Transfer.AWSPDFId IS NULL
            THEN 'NOTA:Falta ingresar archivo PDF'
        ELSE
            FI_Transfer.NombreExtencionArchivo
    END                                                                                         AS [RC26_05],
    FI_Transfer.HashSHA256                                                                      AS [RC26_06],
    CAST(SUM(FI_TransferFactura.MontoPagado) / COUNT(CO_Registro.IdRegistro) AS DECIMAL(15, 2)) AS [RC26_07],
    PV_TipoMoneda.TipoMonedaCorto                                                               AS [RC26_08],
    CAST((SUM(   CASE
                     WHEN ISNULL(FI_TransferFactura.MontoPagado, 0) <> 0
                         THEN CAST((ISNULL(FI_TransferFactura.MontoPagado, 0) / CO_TipoCambioDiario.TipoCambio) AS DECIMAL(15, 2))
                     ELSE
                         0
                 END
             )
         ) / COUNT(CO_Registro.IdRegistro) AS DECIMAL(15, 2))                                   AS [RC26_09],
    CAST(CO_TipoCambioDiario.TipoCambio AS DECIMAL(15, 4))                                      AS [RC26_10],
    LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RazonSocial, 0, 119)))                              AS [RC26_11],
    2                                                                                           AS [RC26_12]
FROM
    dbo.FI_Transfer WITH (NOLOCK)
    JOIN
        dbo.FI_TransferFactura WITH (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
    JOIN
        dbo.FI_PedimentoComprobante WITH (NOLOCK)
            ON FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
               AND FI_Transfer.IdContrato = FI_PedimentoComprobante.IdContrato
    JOIN
        dbo.CO_Registro WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
               AND CO_Registro.IdEstado = 10004
    JOIN
        dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
    JOIN
        dbo.CO_Presupuesto WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
    JOIN
        dbo.CO_AnioContractual WITH (NOLOCK)
            ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
    JOIN
        dbo.CO_Contrato WITH (NOLOCK)
            ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
               AND CO_Contrato.IdContrato = @Contrato
    JOIN
        dbo.CO_Contratista WITH (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
    JOIN
        dbo.CO_Servicio WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
               AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
    JOIN
        dbo.PV_Subcontratista WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
    JOIN
        dbo.PV_TipoMoneda WITH (NOLOCK)
            ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
    LEFT JOIN
        dbo.CO_TipoCambioDiario WITH (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
    LEFT JOIN
        dbo.PV_MetodoPago WITH (NOLOCK)
            ON PV_MetodoPago.idMetodoPago = FI_Transfer.IdMetodoPago
WHERE
    CO_Contrato.IdContrato = @Contrato
    AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
    AND CO_Registro.IdEstado = 10004
    AND ISNULL(CONVERT(INT, FI_Transfer.ProcesadoSIPAC), 0) = 0
    AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
    AND ISNULL(FI_PedimentoComprobante.EsnotaCredito, 0) <> 1
    AND CO_Presupuesto.IdPresupuesto = CASE
                                           WHEN @IdPresupuesto = 0
                                               THEN CO_LineaPresupuestoMes.IdPresupuesto
                                           ELSE
                                               @IdPresupuesto
                                       END
GROUP BY
    LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
    MONTH(CO_Registro.MesPresentacion),
    YEAR(CO_Registro.MesPresentacion),
    CASE
        WHEN CO_Registro.CvTipoDocFacturacion = 2
            THEN ISNULL(FI_PedimentoComprobante.NumeroPedimento, 'NA')
        WHEN CO_Registro.CvTipoDocFacturacion = 3
            THEN ISNULL(FI_PedimentoComprobante.IdDocFacturacionSIPAC, 'NA')
    END,
    CASE
        WHEN FI_Transfer.AWSPDFId IS NULL
            THEN 'NOTA:Falta ingresar archivo PDF'
        ELSE
            FI_Transfer.NombreExtencionArchivo
    END,
    LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RazonSocial, 0, 119))),
    CO_Contrato.IDRegFiducidiario,
    PV_MetodoPago.C_FormaPago,
    FI_Transfer.FechaPago,
    FI_Transfer.HashSHA256,
    PV_TipoMoneda.TipoMonedaCorto,
    CAST(CO_TipoCambioDiario.TipoCambio AS DECIMAL(15, 4));
     END;