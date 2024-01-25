IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CNH_FormatoPlanes_GastosInversionesAcumulado2023'
)
    DROP PROCEDURE USP_SEL_CNH_FormatoPlanes_GastosInversionesAcumulado2023
GO
CREATE PROCEDURE [dbo].[USP_SEL_CNH_FormatoPlanes_GastosInversionesAcumulado2023]
@IdContrato          INT,   
@IdUsuario           INT,   
@Mes                 DATE,   
@IdProgramaActividad INT 

AS  
     BEGIN  
         SET NOCOUNT ON; 
/*Calcular montos pagados*/
IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
    DROP TABLE #Facturas;

IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL
    DROP TABLE #MontosTotalTransferenciaPPD;

IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL
    DROP TABLE #MontosTotalTransferenciaPUE;

IF OBJECT_ID('tempdb..#MontosConvertidosPedimentosCom', 'U') IS NOT NULL
    DROP TABLE #MontosConvertidosPedimentosCom;

IF OBJECT_ID('tempdb..#SumaDePagosDolares', 'U') IS NOT NULL
    DROP TABLE #SumaDePagosDolares;

IF OBJECT_ID('tempdb..#SumaDePagosDolaresBase', 'U') IS NOT NULL
    DROP TABLE #SumaDePagosDolaresBase;

IF OBJECT_ID('tempdb..#ResultadoMontos', 'U') IS NOT NULL
    DROP TABLE #ResultadoMontos;

CREATE TABLE #ResultadoMontos
    (
        MontoUSD         FLOAT,
        CAPEX            BIT,
        OPEX             BIT,
        Actividad        Varchar(500),
		MontoNotaCreditoUSD DECIMAL(20, 4)
    );

CREATE TABLE #MontosTotalTransferenciaPUE
    (
        IdRegistro      INT,
        UUID            VARCHAR(2000),
        Idfactura       INT,
        MontoRegistro   FLOAT,
        TipoComprobante NVARCHAR(50),
        RC2122          FLOAT,
        MetodoPago      NVARCHAR(50),
        TCD             FLOAT,
        FechaTCD        DATE,
        IdMoneda        INT
    );

CREATE TABLE #Facturas
    (
        IdRegistro      INT,
        UUID            VARCHAR(2000),
        Idfactura       INT,
        MontoRegistro   FLOAT,
        TipoComprobante VARCHAR(50),
        RC2122          FLOAT,
        MetodoPago      VARCHAR(50),
        Fecha           DATETIME,
        IdMoneda        INT
    );

CREATE TABLE #MontosTotalTransferenciaPPD
    (
        IdFacturaCP     INT,
        UUIDCP          VARCHAR(2000),
        FormaPagoCP     VARCHAR(50),
        MontoCP         FLOAT,
        TipoCambioCP    FLOAT,
        MonedaCP        VARCHAR(50),
        MontoPesos      FLOAT,
        MontoDolares    FLOAT,
        TipoComprobante VARCHAR(50),
        MontoRegistro   FLOAT,
        IdRegistro      INT
    );

CREATE TABLE #MontosConvertidosPedimentosCom
    (
        IdRegistro             INT,
        IdPedimentoComprobante INT,
        MontoRegistro          FLOAT,
        RC2122                 FLOAT,
        TCD                    FLOAT
    );

CREATE TABLE #SumaDePagosDolares
    (
        UUID            VARCHAR(2000),
        Idfactura       INT,
        TipoComprobante VARCHAR(50),
        MontoDolares    FLOAT,
        MetodoPago      VARCHAR(50),
        TipoCambio      FLOAT,
        Fecha           DATE,
        IdMoneda        INT
    )

CREATE TABLE #SumaDePagosDolaresBase
    (
        UUID            VARCHAR(2000),
        Idfactura       INT,
        TipoComprobante VARCHAR(50),
        MontoDolares    FLOAT,
        MetodoPago      VARCHAR(50),
        TipoCambio      FLOAT,
        Fecha           DATE,
        IdMoneda        INT,
        MonedaTran      INT,
        IdTransferencia INT,
    )

DECLARE
    @IdPresupuesto     INT = 0,
    @MesFin            Date,
    @NombrePresupuesto VARCHAR(500),
    @IdTipoContrato    INT;
DECLARE
    @Aprobado                  INT = 10004,
    @TipoFactura               INT = 1,
    @PESO                      INT = 1,
    @DOLAR                     INT = 2,
    @TipoComplementoPago       INT = 6,
    @TipoPedimentoImportacion  INT = 2,
    @TipoComprobanteExtranjero INT = 3
DECLARE @MontoUSDInversion FLOAT = 0, @MontoUSDOperativo FLOAT = 0, @MontoUSDAbandono FLOAT = 0,
		@MontoUSDNotaCreditoCapex DECIMAL(20, 4), @MontoUSDNotaCreditoOpex DECIMAL(20 ,4),
		@MontoUSDNotaCredito DECIMAL(20, 4)

SELECT
    @IdPresupuesto     = IdPresupuesto,
    @NombrePresupuesto = Nombre
FROM
    CO_Presupuesto
WHERE
    IdProgramaActividad = @IdProgramaActividad;

SELECT
    @IdTipoContrato = IdTipoContrato
FROM
    CO_Contrato
WHERE
    IdContrato = @IdContrato;

SELECT
    @MesFin = CASE
                  WHEN MONTH(@Mes) = 1
                       OR MONTH(@Mes) = 2
                      THEN EOMONTH(DATEFROMPARTS(YEAR(@Mes), 2, 1))
                  WHEN MONTH(@Mes) = 3
                       OR MONTH(@Mes) = 4
                      THEN EOMONTH(DATEFROMPARTS(YEAR(@Mes), 4, 1))
                  WHEN MONTH(@Mes) = 5
                       OR MONTH(@Mes) = 6
                      THEN EOMONTH(DATEFROMPARTS(YEAR(@Mes), 6, 1))
                  WHEN MONTH(@Mes) = 7
                       OR MONTH(@Mes) = 8
                      THEN EOMONTH(DATEFROMPARTS(YEAR(@Mes), 8, 1))
                  WHEN MONTH(@Mes) = 9
                       OR MONTH(@Mes) = 10
                      THEN EOMONTH(DATEFROMPARTS(YEAR(@Mes), 10, 1))
                  WHEN MONTH(@Mes) = 11
                       OR MONTH(@Mes) = 12
                      THEN EOMONTH(DATEFROMPARTS(YEAR(@Mes), 12, 1))
              END;

INSERT INTO #Facturas
    (
        IdRegistro,
        UUID,
        Idfactura,
        MontoRegistro,
        TipoComprobante,
        RC2122,
        MetodoPago,
        Fecha,
        IdMoneda
    )
            SELECT
                CO_Registro.IdRegistro,
                ISNULL(FI_Factura.UUID, 'NÚMERO NO REGISTRADO') AS UUID,
                FI_Factura.IdFactura,
                CO_Registro.MontoRegistro,
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
                END                                             AS TipoComprobante,
                SUM(   CASE
                           WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                               THEN 0
                           WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND(
                                                  (ISNULL(CO_Registro.MontoRegistro, 0)
                                                   / CO_TipoCambioDiario.TipoCambio
                                                  ), 2
                                              ) AS DECIMAL(15, 2))
                           ELSE
                               0
                       END
                   )                                            AS [RC21_22],
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
                END                                             AS MetodoPago,
                FI_Factura.Fecha,
                FI_Factura.IdMoneda
            FROM
                CO_Servicio WITH (NOLOCK)
                INNER JOIN
                    dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                        ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                           AND CO_Servicio.IdContrato = @IdContrato
                           AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                           AND CO_LineaPresupuestoMes.IdPresupuesto = CASE
                                                                          WHEN @IdPresupuesto = 0
                                                                              THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                                          ELSE
                                                                              @IdPresupuesto
                                                                      END
                INNER JOIN
                    dbo.CO_Registro WITH (NOLOCK)
                        ON CO_Registro.IdEstado = @Aprobado
                           AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                           AND CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                           AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) <= @MesFin --= @Mes
                INNER JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON CO_Registro.IdFactura = FI_Factura.IdFactura
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)
            WHERE
                CO_Servicio.IdContrato = @IdContrato
                AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)	<= @MesFin --= @Mes
                AND CO_Registro.IdEstado = @Aprobado
                AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
                AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                AND CO_LineaPresupuestoMes.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
            GROUP BY
                CO_Registro.IdRegistro,
                ISNULL(FI_Factura.UUID, 'NÚMERO NO REGISTRADO'),
                FI_Factura.IdFactura,
                CO_Registro.MontoRegistro,
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
                FI_Factura.Fecha,
                FI_Factura.IdMoneda;

/*Facturas Con Tipo de Cambio de Transferencia*/
INSERT INTO #MontosTotalTransferenciaPPD
    (
        IdFacturaCP,
        UUIDCP,
        FormaPagoCP,
        MontoCP,
        TipoCambioCP,
        MonedaCP,
        MontoPesos,
        MontoDolares,
        TipoComprobante,
        MontoRegistro,
        IdRegistro
    )
            SELECT
                FI_Factura.IdFactura                                       AS IdFacturaCP,
                FI_Factura.UUID                                            AS UUIDCP,
                FI_ComplementoDePago.FormaDePagoP                          AS FormaPagoCP,
                SUM(FI_CPDocRelacionado.ImpPagado)                         AS MontoCP,
                ISNULL(CO_TipoCambioDiario.TipoCambio, 0)                  AS TipoCambioCP,
                FI_ComplementoDePago.MonedaP                               AS MonedaCP,
                CAST(SUM(FI_CPDocRelacionado.ImpPagado) AS DECIMAL(15, 2)) AS MontoPesos,
                CAST(SUM(   CASE
                                WHEN PV_TipoMoneda.IdMoneda = @DOLAR
                                    THEN FI_CPDocRelacionado.ImpPagado
                                WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                                    THEN 0
                                WHEN PV_TipoMoneda.IdMoneda = @PESO
                                    THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                WHEN PV_TipoMoneda.IdMoneda NOT IN (
                                                                       @PESO, @DOLAR
                                                                   )
                                    THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                            END
                        ) AS DECIMAL(15, 2))                               AS MontoDolares,
                FI_Factura.TipoComprobante,
                CAST(CASE
                         WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                             THEN 0
                         ELSE
                             #Facturas.MontoRegistro / CO_TipoCambioDiario.TipoCambio
                     END AS DECIMAL(15, 2))                                AS MontoRegistro,
                #Facturas.IdRegistro
            FROM
                #Facturas
                INNER JOIN
                    dbo.FI_Factura FCPDR WITH (NOLOCK)
                        ON #Facturas.IdFactura = FCPDR.IdFactura
                           AND #Facturas.MetodoPago = 'PPD'
                INNER JOIN
                    dbo.FI_CPDocRelacionado WITH (NOLOCK)
                        ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento
                INNER JOIN
                    dbo.FI_ComplementoDePago WITH (NOLOCK)
                        ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
                INNER JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura
                           AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago
                INNER JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                INNER JOIN
                    dbo.PV_TipoMoneda WITH (NOLOCK)
                        ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                INNER JOIN
                    dbo.FI_Transfer WITH (NOLOCK)
                        ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                           AND FI_Transfer.IdContrato = @IdContrato
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PPD'
                AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago
                AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda
            GROUP BY
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                FI_ComplementoDePago.FormaDePagoP,
                ISNULL(CO_TipoCambioDiario.TipoCambio, 0),
                FI_ComplementoDePago.MonedaP,
                FI_Factura.TipoComprobante,
                CAST(CASE
                         WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                             THEN 0
                         ELSE
                             #Facturas.MontoRegistro / CO_TipoCambioDiario.TipoCambio
                     END AS DECIMAL(15, 2)),
                #Facturas.IdRegistro
            UNION
            SELECT
                FI_Factura.IdFactura                                                                                     AS IdFacturaCP,
                FI_Factura.UUID                                                                                          AS UUIDCP,
                FI_ComplementoDePago.FormaDePagoP                                                                        AS FormaPagoCP,
                SUM(FI_CPDocRelacionado.ImpPagado)                                                                       AS MontoCP,
                1                                                                                                        AS TipoCambioCP,
                FI_ComplementoDePago.MonedaP                                                                             AS MonedaCP,
                CAST((SUM(FI_CPDocRelacionado.ImpPagado * ISNULL(CO_TipoCambioDiario.TipoCambio, 0))) AS DECIMAL(15, 2)) AS MontoPesos,
                CAST((SUM(   CASE
                                 WHEN PV_TipoMoneda.IdMoneda = @DOLAR
                                     THEN FI_CPDocRelacionado.ImpPagado
                                 WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                                     THEN 0
                                 WHEN PV_TipoMoneda.IdMoneda = @PESO
                                     THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                 WHEN PV_TipoMoneda.IdMoneda NOT IN (
                                                                        @PESO, @DOLAR
                                                                    )
                                     THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                             END
                         )
                     ) AS DECIMAL(15, 2))                                                                                AS MontoDolares,
                FI_Factura.TipoComprobante,
                CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2))                                                          AS MontoRegistro,
                #Facturas.IdRegistro
            FROM
                #Facturas
                INNER JOIN
                    dbo.FI_Factura FCPDR WITH (NOLOCK)
                        ON #Facturas.IdFactura = FCPDR.IdFactura
                           AND #Facturas.MetodoPago = 'PPD'
                INNER JOIN
                    dbo.FI_CPDocRelacionado WITH (NOLOCK)
                        ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento
                INNER JOIN
                    dbo.FI_ComplementoDePago WITH (NOLOCK)
                        ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
                INNER JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura
                           AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago
                INNER JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                INNER JOIN
                    dbo.PV_TipoMoneda WITH (NOLOCK)
                        ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                INNER JOIN
                    dbo.FI_Transfer WITH (NOLOCK)
                        ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                           AND FI_Transfer.IdContrato = @IdContrato
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda <> PV_TipoMoneda.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda <> FCPDR.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PPD'
                AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago
                AND FI_Transfer.IdMoneda <> PV_TipoMoneda.IdMoneda
                AND PV_TipoMoneda.IdMoneda = FCPDR.IdMoneda
            GROUP BY
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                FI_ComplementoDePago.FormaDePagoP,
                FI_ComplementoDePago.MonedaP,
                FI_Factura.TipoComprobante,
                CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),
                #Facturas.IdRegistro
            UNION

            --Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)     
            --y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)     
            SELECT
                FI_Factura.IdFactura                            AS IdFacturaCP,
                FI_Factura.UUID                                 AS UUIDCP,
                FI_ComplementoDePago.FormaDePagoP               AS FormaPagoCP,
                SUM(FI_CPDocRelacionado.ImpPagado)              AS MontoCP,
                1,
                FI_ComplementoDePago.MonedaP                    AS MonedaCP,
                CAST((SUM(   CASE
                                 WHEN PV_TipoMoneda.IdMoneda = @DOLAR
                                      AND FCPDR.IdMoneda = @PESO
                                     THEN FI_CPDocRelacionado.ImpPagado * 1
                             END
                         )
                     ) AS DECIMAL(15, 2))                       AS MontoPesos,
                CAST((SUM(   CASE
                                 WHEN FCPDR.IdMoneda = @DOLAR
                                     THEN FI_CPDocRelacionado.ImpPagado
                                 WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                                     THEN 0
                                 WHEN FCPDR.IdMoneda = @PESO
                                     THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                                 WHEN FCPDR.IdMoneda NOT IN (
                                                                @PESO, @DOLAR
                                                            )
                                     THEN FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                             END
                         )
                     ) AS DECIMAL(15, 2))                       AS MontoDolares,
                FI_Factura.TipoComprobante,
                CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,
                #Facturas.IdRegistro
            FROM
                #Facturas
                INNER JOIN
                    dbo.FI_Factura FCPDR WITH (NOLOCK)
                        ON #Facturas.IdFactura = FCPDR.IdFactura
                           AND #Facturas.MetodoPago = 'PPD'
                INNER JOIN
                    dbo.FI_CPDocRelacionado WITH (NOLOCK)
                        ON FCPDR.UUID = FI_CPDocRelacionado.IdDocumento
                INNER JOIN
                    dbo.FI_ComplementoDePago WITH (NOLOCK)
                        ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
                INNER JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura
                           AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago
                INNER JOIN
                    dbo.FI_Factura WITH (NOLOCK)
                        ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                INNER JOIN
                    dbo.PV_TipoMoneda WITH (NOLOCK)
                        ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
                INNER JOIN
                    dbo.FI_Transfer WITH (NOLOCK)
                        ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                           AND FI_Transfer.IdContrato = @IdContrato
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda <> PV_TipoMoneda.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda = FCPDR.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PPD'
                AND FI_TransferFactura.CvTipoDocFacturacion = @TipoComplementoPago
                AND FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
                AND PV_TipoMoneda.IdMoneda <> FCPDR.IdMoneda
            GROUP BY
                FI_Factura.IdFactura,
                FI_Factura.UUID,
                FI_ComplementoDePago.FormaDePagoP,
                FI_ComplementoDePago.MonedaP,
                FI_Factura.TipoComprobante,
                CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),
                #Facturas.IdRegistro
/**/
INSERT INTO #SumaDePagosDolaresBase
    (
        UUID,
        Idfactura,
        TipoComprobante,
        MontoDolares,
        MetodoPago,
        TipoCambio,
        Fecha,
        IdMoneda,
        MonedaTran,
        IdTransferencia
    )
            SELECT DISTINCT
                #Facturas.UUID,
                #Facturas.Idfactura,
                #Facturas.TipoComprobante,
                CASE
                    WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                        THEN 0
                    WHEN ISNULL(FI_TransferFactura.MontoPagado, 0) <> 0
                        THEN CAST(ROUND((ISNULL(FI_TransferFactura.MontoPagado, 0) / CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE
                        0
                END                                       AS MontoDolares,
                #Facturas.MetodoPago,
                ISNULL(CO_TipoCambioDiario.TipoCambio, 0) AS TipoCambio,
                CO_TipoCambioDiario.Fecha,
                #Facturas.IdMoneda,
                FI_Transfer.IdMoneda                      AS MonedaTran,
                FI_Transfer.IdTransferencia
            FROM
                dbo.FI_Transfer WITH (NOLOCK)
                JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
                           AND FI_Transfer.IdContrato = @IdContrato
                JOIN
                    #Facturas
                        ON FI_TransferFactura.IdFactura = #Facturas.Idfactura
                           AND #Facturas.MetodoPago = 'PUE'
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = #Facturas.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PUE'
                AND CO_TipoCambioDiario.IdMoneda = #Facturas.IdMoneda;

INSERT INTO #SumaDePagosDolaresBase
    (
        UUID,
        Idfactura,
        TipoComprobante,
        MontoDolares,
        MetodoPago,
        TipoCambio,
        Fecha,
        IdMoneda,
        MonedaTran,
        IdTransferencia
    )
            --     
            SELECT DISTINCT
                #Facturas.UUID,
                #Facturas.Idfactura,
                #Facturas.TipoComprobante,
                CASE
                    WHEN FI_Transfer.IdMoneda = @DOLAR
                         AND #Facturas.IdMoneda = @PESO
                        THEN FI_TransferFactura.MontoPagado
                    WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                        THEN 0
                    WHEN FI_Transfer.IdMoneda = @PESO
                         AND #Facturas.IdMoneda = @DOLAR
                        THEN CAST(ROUND((ISNULL(FI_TransferFactura.MontoPagado, 0) / CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(15, 2))
                END                  AS MontoDolares,
                #Facturas.MetodoPago,
                CASE
                    WHEN FI_Transfer.IdMoneda = @PESO
                         AND #Facturas.IdMoneda = @DOLAR
                        THEN 1
                    WHEN FI_Transfer.IdMoneda = @DOLAR
                         AND #Facturas.IdMoneda = @PESO
                        THEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0)
                END                  AS TipoCambio,
                CO_TipoCambioDiario.Fecha,
                #Facturas.IdMoneda,
                FI_Transfer.IdMoneda AS MonedaTran,
                FI_Transfer.IdTransferencia
            FROM
                #Facturas
                INNER JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_TransferFactura.IdFactura = #Facturas.Idfactura
                           AND #Facturas.MetodoPago = 'PUE'
                INNER JOIN
                    dbo.FI_Transfer WITH (NOLOCK)
                        ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                           AND FI_Transfer.IdContrato = @IdContrato
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
                           AND CO_TipoCambioDiario.IdMoneda <> #Facturas.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                #Facturas.MetodoPago = 'PUE'
                AND CO_TipoCambioDiario.IdMoneda <> #Facturas.IdMoneda;

INSERT INTO #SumaDePagosDolares
    (
        UUID,
        Idfactura,
        TipoComprobante,
        MontoDolares,
        MetodoPago,
        TipoCambio,
        Fecha,
        IdMoneda
    )
            SELECT
                UUID,
                Idfactura,
                TipoComprobante,
                SUM(MontoDolares) AS MontoDolares,
                MetodoPago,
                MAX(TipoCambio)   AS TipoCambio,
                MAX(Fecha)        AS Fecha,
                IdMoneda
            FROM
                #SumaDePagosDolaresBase
            GROUP BY
                UUID,
                Idfactura,
                TipoComprobante,
                MetodoPago,
                IdMoneda;
--     
INSERT INTO #MontosTotalTransferenciaPUE
    (
        IdRegistro,
        UUID,
        Idfactura,
        MontoRegistro,
        TipoComprobante,
        RC2122,
        MetodoPago,
        TCD,
        FechaTCD,
        IdMoneda
    )
            SELECT DISTINCT
                #Facturas.IdRegistro,
                #Facturas.UUID,
                #Facturas.Idfactura,
                #Facturas.MontoRegistro,
                #Facturas.TipoComprobante,
                #SumaDePagosDolares.MontoDolares,
                #Facturas.MetodoPago,
                #SumaDePagosDolares.TipoCambio,
                #SumaDePagosDolares.Fecha,
                #Facturas.IdMoneda
            FROM
                #Facturas
                JOIN
                    #SumaDePagosDolares
                        ON #Facturas.Idfactura = #SumaDePagosDolares.Idfactura
            WHERE
                #Facturas.MetodoPago = 'PUE';

/*PEDIMENTO COMPROBANTE*/
--     
INSERT INTO #MontosConvertidosPedimentosCom
    (
        IdRegistro,
        IdPedimentoComprobante,
        MontoRegistro,
        RC2122,
        TCD
    )
            SELECT
                CO_Registro.IdRegistro,
                FI_PedimentoComprobante.IdPedimentoComprobante,
                CO_Registro.MontoRegistro,
                SUM(   CASE
                           WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0
                               THEN 0
                           WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND(
                                                  (ISNULL(CO_Registro.MontoRegistro, 0)
                                                   / CO_TipoCambioDiario.TipoCambio
                                                  ), 2
                                              ) AS DECIMAL(15, 2))
                           ELSE
                               0
                       END
                   )                   AS [RC21_22],
                ISNULL(CO_TipoCambioDiario.TipoCambio, 0)
            FROM
                dbo.CO_Registro WITH (NOLOCK)
                JOIN
                    dbo.FI_PedimentoComprobante WITH (NOLOCK)
                        ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
                           AND CO_Registro.IdEstado = @Aprobado
                           AND CO_Registro.CvTipoDocFacturacion IN (
                                                                       @TipoPedimentoImportacion,
                                                                       @TipoComprobanteExtranjero
                                                                   )
                           AND FI_PedimentoComprobante.IdContrato = @IdContrato
                           AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                JOIN
                    dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                        ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                           AND CO_LineaPresupuestoMes.IdPresupuesto = CASE
                                                                          WHEN @IdPresupuesto = 0
                                                                              THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                                          ELSE
                                                                              @IdPresupuesto
                                                                      END
                JOIN
                    dbo.CO_Servicio WITH (NOLOCK)
                        ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                           AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                JOIN
                    dbo.FI_TransferFactura WITH (NOLOCK)
                        ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
                JOIN
                    dbo.FI_Transfer WITH (NOLOCK)
                        ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                LEFT JOIN
                    dbo.CO_TipoCambioDiario WITH (NOLOCK)
                        ON CO_TipoCambioDiario.IdMoneda = FI_PedimentoComprobante.IdMoneda
                           AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
                           AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
                           AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
            WHERE
                FI_PedimentoComprobante.IdContrato = @IdContrato
                AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                AND CO_Registro.IdEstado = @Aprobado
                AND CO_Registro.CvTipoDocFacturacion IN (
                                                            @TipoPedimentoImportacion, @TipoComprobanteExtranjero
                                                        )
                AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0
                AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                AND CO_LineaPresupuestoMes.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
            GROUP BY
                CO_Registro.IdRegistro,
                FI_PedimentoComprobante.IdPedimentoComprobante,
                CO_Registro.MontoRegistro,
                ISNULL(CO_TipoCambioDiario.TipoCambio, 0);

/*RESULTADOS FINALES*/
INSERT INTO #ResultadoMontos
    (
        MontoUSD,
        CAPEX,
        OPEX,
        Actividad,
		MontoNotaCreditoUSD
    )
            SELECT
                SUM(   CASE
                           WHEN ISNULL(TTF.TCD, 0) = 0
                               THEN 0
                           WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                AND ISNULL(F.MontoConIva, 0) <> 0
                                AND TTF.TipoComprobante IN (
                                                               'I', 'N', 'P'
                                                           )
                               THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))
                           ELSE
                               0
                       END
                   ) AS [RC21_22],
                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 0
                                     THEN -- 0 es Capex, por eso se coloca el 1 en el then ya que esta columna hace referencia a capex
											1
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser null ambos debe ser el valor hacia Opex
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser ambos valores 1 ambos debe ser el valor hacia Opex
                            ELSE
                                CO_CatalogoCuentaSH.Inversion
                        END
                END, -- CAPEX

                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 1
                                     THEN -- 1 es opex, 
									1 -- se coloca 1 por que es columna opex
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 1
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 1 -- Se coloca en 1 por que es la columna de opex, y al ser ambos valores 1  debe ser el valor hacia Opex
                            ELSE
                                CO_CatalogoCuentaSH.Operacion
                        END
                END, -- OPEX 
                CASE
                    WHEN @IdTipoContrato = 1
                        THEN CO_TipoServicio.NombreTipoServicio
                    ELSE
                        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                END,
				SUM(ABS(   CASE  
											   WHEN ISNULL(TTF.TCD, 0) = 0  
                                                  THEN 0  
                                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0  
                                                    AND TTF.TipoComprobante IN (  
                                                                                   'E'  
                                                                               )  
                                                   THEN CAST((TTF.MontoRegistro / TTF.TCD)  
                                                             * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))  
                                               ELSE  
                                                   0  
                                           END  
                                       )  
                                   ) AS [RC21_23] -- Nota de credito
            FROM
                dbo.CO_Registro WITH (NOLOCK)
                JOIN
                    dbo.FI_Factura               F WITH (NOLOCK)
                        ON CO_Registro.IdFactura = F.IdFactura
                           AND CO_Registro.IdEstado = @Aprobado
                           AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                           AND CO_Registro.IdEstado = @Aprobado
                           AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                JOIN
                    #MontosTotalTransferenciaPUE TTF
                        ON TTF.Idfactura = CO_Registro.IdFactura
                           AND TTF.IdRegistro = CO_Registro.IdRegistro
                           AND TTF.MetodoPago = 'PUE'
                JOIN
                    dbo.CO_LineaPresupuestoMes   LPM WITH (NOLOCK)
                        ON CO_Registro.IdPrograma = LPM.IdLineaPresupuestoMes
                JOIN
                    dbo.CO_Presupuesto           P WITH (NOLOCK)
                        ON LPM.IdPresupuesto = P.IdPresupuesto
                           AND P.IdPresupuesto = CASE
                                                     WHEN @IdPresupuesto = 0
                                                         THEN LPM.IdPresupuesto
                                                     ELSE
                                                         @IdPresupuesto
                                                 END
                JOIN
                    dbo.CO_AnioContractual       AC WITH (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                           AND AC.IdContrato = @IdContrato
                JOIN
                    dbo.CO_Servicio              S WITH (NOLOCK)
                        ON LPM.IdServicio = S.IdServicio
                           AND S.NombreServicio NOT LIKE '%No elegibles%'
                JOIN
                    dbo.CO_CatalogoCuentaSH WITH (NOLOCK)
                        ON CO_Registro.IdCatalogoCuentasSH = CO_CatalogoCuentaSH.IdCatalogoCuentasSH
                LEFT JOIN
                    dbo.CO_ActividadPetroleraCNH (NOLOCK)
                        ON LPM.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                LEFT JOIN
                    CO_TipoServicio (NOLOCK)
                        ON LPM.IdTipoServicio = CO_TipoServicio.IdTipoServicio
            WHERE
                DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                AND CO_Registro.IdEstado = @Aprobado
                AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                AND S.NombreServicio NOT LIKE '%No elegibles%'
                AND TTF.MetodoPago = 'PUE'
                AND P.IdPresupuesto = CASE
                                          WHEN @IdPresupuesto = 0
                                              THEN LPM.IdPresupuesto
                                          ELSE
                                              @IdPresupuesto
                                      END
            GROUP BY
                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 0
                                     THEN -- 0 es Capex, por eso se coloca el 1 en el then ya que es la columna de capex
									 1
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser null ambos debe ser el valor hacia Opex
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 0
                            ELSE
                                CO_CatalogoCuentaSH.Inversion
                        END
                END, -- CAPEX

                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 1
                                     THEN -- 1 es opex, 
                1 -- 0 es Opex, por eso se coloca el 1 en el then
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 1
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 1
                            ELSE
                                CO_CatalogoCuentaSH.Operacion
                        END
                END, -- OPEX , 
                CASE
                    WHEN @IdTipoContrato = 1
                        THEN CO_TipoServicio.NombreTipoServicio
                    ELSE
                        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                END
            --     

            UNION

            --     
            SELECT
                SUM(   CASE
                           WHEN ISNULL(TTF.TipoCambioCP, 0) = 0
                               THEN 0
                           WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                AND TTF.TipoComprobante IN (
                                                               'I', 'N', 'P'
                                                           )
                               THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                           ELSE
                               0
                       END
                   ) AS [RC21_22],
                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 0
                                     THEN -- 0 es Capex, por eso se coloca el 1 en el then
                1
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser null ambos debe ser el valor hacia Opex
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 0
                            ELSE
                                CO_CatalogoCuentaSH.Inversion
                        END
                END, -- CAPEX

                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 1
                                     THEN -- 1 es opex, 
                1 -- 0 es Opex, por eso se coloca el 1 en el then
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 1
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 1
                            ELSE
                                CO_CatalogoCuentaSH.Operacion
                        END
                END, -- OPEX , 
                CASE
                    WHEN @IdTipoContrato = 1
                        THEN CO_TipoServicio.NombreTipoServicio
                    ELSE
                        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                END,
				SUM(ABS(   CASE  
                                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0  
                                                    AND TTF.TipoComprobante IN (  
                                                                                   'E'  
                                                                               )  
                                                   THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2))  
                                               ELSE  
                                                   0  
                                           END  
                                       )  
                                   ) AS [RC21_23] --Nota de credito
            FROM
                dbo.CO_Registro WITH (NOLOCK)
                JOIN
                    dbo.FI_Factura               F WITH (NOLOCK)
                        ON CO_Registro.IdFactura = F.IdFactura
                           AND CO_Registro.IdEstado = @Aprobado
                           AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                           AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                           AND CO_Registro.IdEstado = @Aprobado
                           AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                JOIN
                    dbo.FI_CPDocRelacionado      CPDR WITH (NOLOCK)
                        ON F.UUID = CPDR.IdDocumento
                JOIN
                    dbo.FI_ComplementoDePago     CP WITH (NOLOCK)
                        ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                JOIN
                    #MontosTotalTransferenciaPPD TTF
                        ON CP.IdFactura = TTF.IdFacturaCP
                           AND CO_Registro.IdRegistro = TTF.IdRegistro
                JOIN
                    dbo.FI_Factura               FCP WITH (NOLOCK)
                        ON TTF.IdFacturaCP = FCP.IdFactura
                JOIN
                    dbo.CO_LineaPresupuestoMes   LPM WITH (NOLOCK)
                        ON CO_Registro.IdPrograma = LPM.IdLineaPresupuestoMes
                JOIN
                    dbo.CO_Presupuesto           P WITH (NOLOCK)
                        ON LPM.IdPresupuesto = P.IdPresupuesto
                           AND P.IdPresupuesto = CASE
                                                     WHEN @IdPresupuesto = 0
                                                         THEN LPM.IdPresupuesto
                                                     ELSE
                                                         @IdPresupuesto
                                                 END
                JOIN
                    dbo.CO_AnioContractual       AC WITH (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                           AND AC.IdContrato = @IdContrato
                JOIN
                    dbo.CO_Servicio              S WITH (NOLOCK)
                        ON LPM.IdServicio = S.IdServicio
                           AND S.NombreServicio NOT LIKE '%No elegibles%'
                JOIN
                    dbo.CO_CatalogoCuentaSH WITH (NOLOCK)
                        ON CO_Registro.IdCatalogoCuentasSH = CO_CatalogoCuentaSH.IdCatalogoCuentasSH
                LEFT JOIN
                    dbo.CO_ActividadPetroleraCNH (NOLOCK)
                        ON LPM.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                LEFT JOIN
                    CO_TipoServicio (NOLOCK)
                        ON LPM.IdTipoServicio = CO_TipoServicio.IdTipoServicio
				LEFT JOIN
					FI_ControlPPDComplementos ControlF(NOLOCK)
					ON  FCP.UUID	=     ControlF.UUID
            WHERE
                AC.IdContrato = @IdContrato
                AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                AND CO_Registro.IdEstado = @Aprobado
                AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
                AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                AND S.NombreServicio NOT LIKE '%No elegibles%'
				AND ControlF.IdControlPPDC IS NULL
                AND P.IdPresupuesto = CASE
                                          WHEN @IdPresupuesto = 0
                                              THEN LPM.IdPresupuesto
                                          ELSE
                                              @IdPresupuesto
                                      END
            GROUP BY
                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 0
                                     THEN -- 0 es Capex, por eso se coloca el 1 en el then
                1
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser null ambos debe ser el valor hacia Opex
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 0
                            ELSE
                                CO_CatalogoCuentaSH.Inversion
                        END
                END, -- CAPEX

                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 1
                                     THEN -- 1 es opex, 
                1 -- 0 es Opex, por eso se coloca el 1 en el then
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 1
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 1
                            ELSE
                                CO_CatalogoCuentaSH.Operacion
                        END
                END, -- OPEX , 
                CASE
                    WHEN @IdTipoContrato = 1
                        THEN CO_TipoServicio.NombreTipoServicio
                    ELSE
                        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                END
            --     

            UNION

            --     
            SELECT
                SUM(   CASE
                           WHEN ISNULL(MP.MontoRegistro, 0) <> 0
                               THEN MP.RC2122
                           ELSE
                               0
                       END
                   ) AS [RC21_22],
                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 0
                                     THEN -- 0 es Capex, por eso se coloca el 1 en el then
										1
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser null ambos debe ser el valor hacia Opex
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 0
                            ELSE
                                CO_CatalogoCuentaSH.Inversion
                        END
                END, -- CAPEX

                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 1
                                     THEN -- 1 es opex, 
										 1 -- 0 es Opex, por eso se coloca el 1 en el then
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 1
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 1
                            ELSE
                                CO_CatalogoCuentaSH.Operacion
                        END
                END, -- OPEX , 
                CASE
                    WHEN @IdTipoContrato = 1
                        THEN CO_TipoServicio.NombreTipoServicio
                    ELSE
                        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                END,
				0 AS [RC21_23] --Nota de credito
            FROM
                dbo.FI_Transfer                     TR WITH (NOLOCK)
                JOIN
                    dbo.FI_TransferFactura          TF WITH (NOLOCK)
                        ON TR.IdTransferencia = TF.IdTransfer
                JOIN
                    dbo.FI_PedimentoComprobante     PC WITH (NOLOCK)
                        ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                           AND PC.IdContrato = TR.IdContrato
                JOIN
                    dbo.CO_Registro WITH (NOLOCK)
                        ON CO_Registro.IdPedimentoComprobante = PC.IdPedimentoComprobante
                           AND CO_Registro.IdEstado = @Aprobado
                           AND CO_Registro.CvTipoDocFacturacion IN (
                                                                       @TipoPedimentoImportacion,
                                                                       @TipoComprobanteExtranjero
                                                                   )
                           AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                JOIN
                    dbo.CO_LineaPresupuestoMes      LPM WITH (NOLOCK)
                        ON CO_Registro.IdPrograma = LPM.IdLineaPresupuestoMes
                JOIN
                    dbo.CO_Presupuesto              P WITH (NOLOCK)
                        ON P.IdPresupuesto = LPM.IdPresupuesto
                           AND P.IdPresupuesto = CASE
                                                     WHEN @IdPresupuesto = 0
                                                         THEN LPM.IdPresupuesto
                                                     ELSE
                                                         @IdPresupuesto
                                                 END
                JOIN
                    dbo.CO_AnioContractual          AC WITH (NOLOCK)
                        ON AC.IdAnioContractual = P.IdAnioContractual
                           AND AC.IdContrato = @IdContrato
                JOIN
                    dbo.CO_Servicio                 S WITH (NOLOCK)
                        ON S.IdServicio = LPM.IdServicio
                           AND S.NombreServicio NOT LIKE '%No elegibles%'
                JOIN
                    #MontosConvertidosPedimentosCom MP
                        ON MP.IdRegistro = CO_Registro.IdRegistro
                           AND MP.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
                JOIN
                    dbo.CO_CatalogoCuentaSH WITH (NOLOCK)
                        ON CO_Registro.IdCatalogoCuentasSH = CO_CatalogoCuentaSH.IdCatalogoCuentasSH
                LEFT JOIN
                    dbo.CO_ActividadPetroleraCNH (NOLOCK)
                        ON LPM.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                LEFT JOIN
                    CO_TipoServicio (NOLOCK)
                        ON LPM.IdTipoServicio = CO_TipoServicio.IdTipoServicio
            WHERE
                AC.IdContrato = @IdContrato
                AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)<= @MesFin --= @Mes
                AND CO_Registro.IdEstado = @Aprobado
                AND CO_Registro.CvTipoDocFacturacion IN (
                                                            @TipoPedimentoImportacion, @TipoComprobanteExtranjero
                                                        )
                AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                AND S.NombreServicio NOT LIKE '%No elegibles%'
                AND ISNULL(PC.EsnotaCredito, 0) <> 1
                AND P.IdPresupuesto = CASE
                                          WHEN @IdPresupuesto = 0
                                              THEN LPM.IdPresupuesto
                                          ELSE
                                              @IdPresupuesto
                                      END
            GROUP BY
                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 0
                                     THEN -- 0 es Capex, por eso se coloca el 1 en el then
										1
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 0 -- Se coloca en 0 por que es la columna de capex, y al ser null ambos debe ser el valor hacia Opex
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 0
                            ELSE
                                CO_CatalogoCuentaSH.Inversion
                        END
                END, -- CAPEX

                CASE
                    WHEN CO_Registro.CapexOpexEdicion IS NOT NULL
                        THEN CASE
                                 WHEN CO_Registro.CapexOpexEdicion = 1
                                     THEN -- 1 es opex, 
                1 -- 0 es Opex, por eso se coloca el 1 en el then
                                 ELSE
                                     0
                             END
                    ELSE
                        CASE
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 0
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 0
                                THEN 1
                            WHEN ISNULL(CO_CatalogoCuentaSH.Inversion, 0) = 1
                                 AND ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1
                                THEN 1
                            ELSE
                                CO_CatalogoCuentaSH.Operacion
                        END
                END, -- OPEX , 
                CASE
                    WHEN @IdTipoContrato = 1
                        THEN CO_TipoServicio.NombreTipoServicio
                    ELSE
                        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                END

SELECT
    @MontoUSDInversion =ISNULL(SUM(ISNULL(MontoUSD,0)),0),--as MontoUSDInversion
	@MontoUSDNotaCreditoCapex = ISNULL(SUM(ISNULL(MontoNotaCreditoUSD,0)),0)
FROM
    #ResultadoMontos WHERE CAPEX = 1;

SELECT
     @MontoUSDOperativo= ISNULL(SUM(ISNULL(MontoUSD,0)),0), --as MontoUSDOperativo
	 @MontoUSDNotaCreditoOpex = ISNULL(SUM(ISNULL(MontoNotaCreditoUSD,0)),0)
FROM
    #ResultadoMontos WHERE OPEX = 1;

IF((SELECT PATINDEX('%Desarrollo%',@NombrePresupuesto) ) >0)
BEGIN
	SELECT
     @MontoUSDAbandono = ISNULL(SUM(ISNULL(MontoUSD,0)),0), --as MontoUSDAbandono
	 @MontoUSDNotaCredito = ISNULL(SUM(ISNULL(MontoNotaCreditoUSD,0)),0)
FROM
    #ResultadoMontos WHERE Actividad = 'Abandono';
END


SELECT (@MontoUSDInversion - @MontoUSDNotaCreditoCapex) as MontoUSDInversion, (@MontoUSDOperativo - @MontoUSDNotaCreditoOpex) as MontoUSDOperativo, (@MontoUSDAbandono - @MontoUSDNotaCredito) as MontoUSDAbandono

END
