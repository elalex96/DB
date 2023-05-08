
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-09-04
-- Description:	
-- Modificado:	Manuel Cruz
-- Create date: 2019-09-10
-- Description:	Cambio para consumir complementos de pago de las facturas PPD y se cambio el tipo de cambio contra la fecha de pago
-- Modificado:	Manuel Cruz
-- Create date: 2019-11-19
-- Description:	Cambio para omitir en las consultas lo No Elegible
-- Modificado:	Manuel Cruz
-- Create date: 2021-09-21
-- Description:	Ajuste para contratos de carso (10047-CS04,10048-CS05), reporte para mostrar los gastos pagados en el mes del reporte sin considerar el complemento de pago
-- =============================================
CREATE PROCEDURE [dbo].[SP_CNH_FormatoPlanes_Inversion_2019_Yaz]
--exec[SP_CNH_FormatoPlanes_Inversion_2019] 10036,1,'2019-12-01',10058
--exec[SP_CNH_FormatoPlanes_Inversion_2019] 10036,1,'2019-12-01',10100
-- Add the parameters for the stored procedure here
@IdContrato          INT,
@IdUsuario           INT,
@Mes                 DATE,
@IdProgramaActividad INT,
@pIdPeriodo INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here

		 /*Eliminar tablas temporales*/

         IF OBJECT_ID('tempdb..#DATOS', 'U') IS NOT NULL
             DROP TABLE #DATOS;
         IF OBJECT_ID('tempdb..#PIVOT', 'U') IS NOT NULL
             DROP TABLE #PIVOT;
         IF OBJECT_ID('tempdb..#RESULTADO', 'U') IS NOT NULL
             DROP TABLE #RESULTADO;
         IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL
             DROP TABLE #uuidNoReportar;
         IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
             DROP TABLE #Facturas;
         IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL
             DROP TABLE #MontosTotalTransferenciaPPD;
         IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL
             DROP TABLE #MontosTotalTransferenciaPUE;
         IF OBJECT_ID('tempdb..#MontosConvertidosPedimentosCom', 'U') IS NOT NULL
             DROP TABLE #MontosConvertidosPedimentosCom;
         IF OBJECT_ID('tempdb..#CGIantes', 'U') IS NOT NULL
             DROP TABLE #CGIantes;
         IF OBJECT_ID('tempdb..#CGIdespues', 'U') IS NOT NULL
             DROP TABLE #CGIdespues;
         IF OBJECT_ID('tempdb..#CGICarso', 'U') IS NOT NULL
             DROP TABLE #CGICarso;

         CREATE TABLE #DATOS
         (IdTipoProgramaActividad INT, 
          IdActividadPetrolera    INT, 
          IdSubactividadPetrolera INT, 
          IdTareaPetrolera        INT, 
          IdServicio              INT, 
          IdGastoRubro            INT, 
          MontoRegistro           FLOAT, 
          MesPresentacion         DATE, 
          PCN                     FLOAT, 
          InicioPresup            DATE, 
          ANIO                    INT, 
          MES                     INT, 
          IdRegistro              INT, 
          MesPresentacionOrig     DATE
         );
		 --
         CREATE TABLE #PIVOT
         (ANIO                    INT, 
          MES                     INT, 
          MesPresentacion         DATE, 
          IdTipoProgramaActividad INT, 
          IdActividadPetrolera    INT, 
          IdSubactividadPetrolera INT, 
          IdTareaPetrolera        INT, 
          IdServicio              INT, 
          --PCN                     FLOAT, 
          InicioPresup            DATE, 
          MontoRegistro           FLOAT
         --MONac                   FLOAT, 
         --MOExt                   FLOAT, 
         --BiNac                   FLOAT, 
         --BiExt                   FLOAT, 
         --SerNac                  FLOAT, 
         --SerExt                  FLOAT, 
         --CapNac                  FLOAT, 
         --CapExt                  FLOAT, 
         --TransTec                FLOAT, 
         --InfraSoc                FLOAT
         );
		 --
         CREATE TABLE #RESULTADO
         (IdLinea                 INT IDENTITY(1, 1) PRIMARY KEY, 
          IdTipoProgramaActividad INT, 
          IdActividadPetrolera    INT, 
          IdSubactividadPetrolera INT, 
          IdTareaPetrolera        INT, 
          IdServicio              INT, 
          --Ano                     INT, 
          MONAC01                 FLOAT, 
          MONAC02                 FLOAT, 
          MONAC03                 FLOAT, 
          MONAC04                 FLOAT, 
          MONAC05                 FLOAT, 
          MONAC06                 FLOAT, 
          MONAC07                 FLOAT, 
          MONAC08                 FLOAT, 
          MONAC09                 FLOAT, 
          MONAC10                 FLOAT, 
          MONAC11                 FLOAT, 
          MONAC12                 FLOAT, 
          MONAC13                 FLOAT, 
          MONAC14                 FLOAT, 
          MONAC15                 FLOAT, 
          MONAC16                 FLOAT, 
          MONAC17                 FLOAT, 
          MONAC18                 FLOAT, 
          MONAC19                 FLOAT, 
          MONAC20                 FLOAT, 
          MONAC21                 FLOAT, 
          MONAC22                 FLOAT, 
          MONAC23                 FLOAT, 
          MONAC24                 FLOAT, 
          MONAC25                 FLOAT
         );
		 --
		 CREATE TABLE #uuidNoReportar
         (UUID VARCHAR(500)
		 );
		 --
         CREATE TABLE #Facturas
         (IdRegistro      INT, 
          UUID            NVARCHAR(500), 
          Idfactura       INT, 
          MontoRegistro   FLOAT, 
          TipoComprobante NVARCHAR(50), 
          RC2122          FLOAT, 
          MetodoPago      NVARCHAR(50), 
          Fecha           DATETIME, 
          IdMoneda        INT
         );
		 --
         CREATE TABLE #MontosTotalTransferenciaPPD
         (IdFacturaCP     INT, 
          UUIDCP          VARCHAR(500), 
          FormaPagoCP     VARCHAR(50), 
          MontoCP         FLOAT, 
          TipoCambioCP    FLOAT, 
          MonedaCP        VARCHAR(50), 
          MontoPesos      FLOAT, 
          MontoDolares    FLOAT, 
          TipoComprobante VARCHAR(50), 
          MontoRegistro   FLOAT, 
          IdRegistro      INT,
		  MesPagoCarso	  DATE
         );
		 --
         CREATE TABLE #MontosTotalTransferenciaPUE
         (IdRegistro      INT, 
          UUID            NVARCHAR(500), 
          Idfactura       INT, 
          MontoRegistro   FLOAT, 
          TipoComprobante NVARCHAR(50), 
          RC2122          FLOAT, 
          MetodoPago      NVARCHAR(50), 
          TCD             FLOAT, 
          FechaTCD        DATE, 
          IdMoneda        INT,
		  MesPagoCarso	  DATE
         );
		 --
         CREATE TABLE #MontosConvertidosPedimentosCom
         (IdRegistro             INT, 
          IdPedimentoComprobante INT, 
          MontoRegistro          FLOAT, 
          RC2122                 FLOAT, 
          TCD                    FLOAT,
		  MesPagoCarso	  DATE
         );
		 --
         CREATE TABLE #CGIantes
         ([RF_00]             VARCHAR(50), 
          [RI_00]             VARCHAR(100), 
          [RF01_01]           VARCHAR(100), 
          [RC21_00]           VARCHAR(50), 
          [RC21_01]           INT, 
          [RC21_02]           INT, 
          [RC21_03]           INT, 
          [RC21_04]           VARCHAR(50), 
          [RC21_05]           VARCHAR(100), 
          [RC21_06]           VARCHAR(100), 
          [RC21_07]           VARCHAR(100), 
          [RC21_08]           VARCHAR(50), 
          [RC21_09]           VARCHAR(50), 
          [RC21_10]           VARCHAR(50), 
          [RC21_11]           VARCHAR(50), 
          [RC21_12]           VARCHAR(50), 
          [RC21_13]           INT, 
          [RC21_14]           VARCHAR(100), 
          [RC21_15]           VARCHAR(100), 
          [RC21_16]           VARCHAR(100), 
          [RC21_17]           VARCHAR(100), 
          [RC21_18]           VARCHAR(300), 
          [RC21_19]           VARCHAR(50), 
          [RC21_20]           VARCHAR(MAX), 
          [RC21_21]           INT, 
          [RC21_22]           FLOAT, 
          [RC21_23]           FLOAT, 
          [RC21_24]           VARCHAR(50), 
          [RC21_25]           FLOAT, 
          [RC21_26]           INT, 
          IdServicio          INT, 
          IdProgramaActividad INT, 
          Inicio              DATE, 
          MesPresentacion     DATE
         );
		 --
         CREATE TABLE #CGIdespues
         ([RF_00]             VARCHAR(50), 
          [RI_00]             VARCHAR(100), 
          [RF01_01]           VARCHAR(100), 
          [RC21_00]           VARCHAR(50), 
          [RC21_01]           INT, 
          [RC21_02]           INT, 
          [RC21_03]           INT, 
          [RC21_04]           VARCHAR(50), 
          [RC21_05]           VARCHAR(100), 
          [RC21_06]           VARCHAR(100), 
          [RC21_07]           VARCHAR(100), 
          [RC21_08]           VARCHAR(50), 
          [RC21_09]           VARCHAR(50), 
          [RC21_10]           VARCHAR(50), 
          [RC21_11]           VARCHAR(50), 
          [RC21_12]           VARCHAR(50), 
          [RC21_13]           INT, 
          [RC21_14]           VARCHAR(100), 
          [RC21_15]           VARCHAR(100), 
          [RC21_16]           VARCHAR(100), 
          [RC21_17]           VARCHAR(100), 
          [RC21_18]           VARCHAR(300), 
          [RC21_19]           VARCHAR(50), 
          [RC21_20]           VARCHAR(MAX), 
          [RC21_21]           INT, 
          [RC21_22]           FLOAT, 
          [RC21_23]           FLOAT, 
          [RC21_24]           VARCHAR(50), 
          [RC21_25]           FLOAT, 
          [RC21_26]           INT, 
          IdServicio          INT, 
          IdProgramaActividad INT, 
          Inicio              DATE, 
          MesPresentacion     DATE
         );
		 --
         CREATE TABLE #CGICarso
         ([RF_00]             VARCHAR(50), 
          [RI_00]             VARCHAR(100), 
          [RF01_01]           VARCHAR(100), 
          [RC21_00]           VARCHAR(50), 
          [RC21_01]           INT, 
          [RC21_02]           INT, 
          [RC21_03]           INT, 
          [RC21_04]           VARCHAR(50), 
          [RC21_05]           VARCHAR(100), 
          [RC21_06]           VARCHAR(100), 
          [RC21_07]           VARCHAR(100), 
          [RC21_08]           VARCHAR(50), 
          [RC21_09]           VARCHAR(50), 
          [RC21_10]           VARCHAR(50), 
          [RC21_11]           VARCHAR(50), 
          [RC21_12]           VARCHAR(50), 
          [RC21_13]           INT, 
          [RC21_14]           VARCHAR(100), 
          [RC21_15]           VARCHAR(100), 
          [RC21_16]           VARCHAR(100), 
          [RC21_17]           VARCHAR(100), 
          [RC21_18]           VARCHAR(300), 
          [RC21_19]           VARCHAR(50), 
          [RC21_20]           VARCHAR(MAX), 
          [RC21_21]           INT, 
          [RC21_22]           FLOAT, 
          [RC21_23]           FLOAT, 
          [RC21_24]           VARCHAR(50), 
          [RC21_25]           FLOAT, 
          [RC21_26]           INT, 
          IdServicio          INT, 
          IdProgramaActividad INT, 
          Inicio              DATE, 
          MesPresentacion     DATE
         );

         /*Omitir facturas en la hoja 21*/

         IF(@Mes = '20190801')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('091A3242-EF0F-444A-A5C1-3D7D50247D3B'), ('775E782A-9493-3D40-9B24-E1604A865A0F'), ('78BB3869-8091-B049-98B4-1238E15E7BDA'), ('A6344C73-4C5A-EA4A-B2F8-3378CDA24C17');
             END;
         IF(@Mes <> '20190901')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('9A159442-52BC-1E49-8190-D020953CE967');
             END;
         IF(@Mes <> '20200101')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('78CA2E37-22C0-408C-8E94-105C7388A704'), ('30EFEC90-471E-434A-87CF-EFFEEE7C48C1');
             END;
         IF(@Mes = '20200501')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('D515F4A9-244C-422E-A2B1-11B234039715'), ('1091E714-CC8E-46B8-8421-37470C285BAC'), ('95AB6B55-C312-4CAF-9A9E-BD7E7A2124AB'), ('10FDC8FB-DEBB-4BD5-8C10-6B51E61B5FE6');
             END;

         /*TODAS LAS FACTURAS*/

         INSERT INTO #Facturas
         (IdRegistro, 
          UUID, 
          Idfactura, 
          MontoRegistro, 
          TipoComprobante, 
          RC2122, 
          MetodoPago, 
          Fecha, 
          IdMoneda
         )
                SELECT R.IdRegistro, 
                       ISNULL(F.UUID, 'NÚMERO NO REGISTRADO') AS UUID, 
                       F.IdFactura, 
                       R.MontoRegistro,
                       CASE
                           WHEN F.TipoComprobante LIKE '%ingreso%'
                                OR F.TipoComprobante LIKE 'I%'
                           THEN 'I'
                           WHEN(F.TipoComprobante) LIKE '%egreso%'
                               OR F.TipoComprobante LIKE 'E%'
                           THEN 'E'
                           WHEN(F.TipoComprobante) LIKE '%traslado%'
                               OR F.TipoComprobante LIKE 'T%'
                           THEN 'T'
                           WHEN(F.TipoComprobante) LIKE '%nómina%'
                               OR F.TipoComprobante LIKE 'N%'
                           THEN 'N'
                           WHEN(F.TipoComprobante) LIKE '%pago%'
                               OR F.TipoComprobante LIKE 'P%'
                           THEN 'P'
                           ELSE 'NA'
                       END AS TipoComprobante, 
                       SUM(CASE
                               WHEN ISNULL(R.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END) AS [RC21_22],
                       CASE
                           WHEN F.MetodoPago LIKE '%exhibi%'
                                OR F.MetodoPago LIKE '%PUE%'
                                OR F.FormaPago LIKE '%exhibi%'
                                OR F.FormaPago LIKE '%PUE%'
                           THEN 'PUE'
                           WHEN F.MetodoPago LIKE '%parcia%'
                                OR F.MetodoPago LIKE '%dife%'
                                OR F.MetodoPago LIKE '%PPD%'
                                OR F.FormaPago LIKE '%parcia%'
                                OR F.FormaPago LIKE '%dife%'
                                OR F.FormaPago LIKE '%PPD%'
                           THEN 'PPD'
                           WHEN F.TipoComprobante = 'P'
                           THEN 'PPD'
                       END AS MetodoPago, 
                       F.Fecha, 
                       F.IdMoneda
                FROM dbo.CO_Registro R WITH(NOLOCK)
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON R.IdFactura = F.IdFactura
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = F.IdContrato
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                            AND C.IdContrato = S.IdContrato
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = F.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                                           AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                                           AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                WHERE C.IdContrato = @IdContrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) <= @Mes
                      AND R.IdEstado = 10004
                      AND R.CvTipoDocFacturacion = 1
                      AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                      AND S.NombreServicio NOT LIKE '%No elegibles%'
                GROUP BY R.IdRegistro, 
                         ISNULL(F.UUID, 'NÚMERO NO REGISTRADO'), 
                         F.IdFactura, 
                         R.MontoRegistro,
                         CASE
                             WHEN F.TipoComprobante LIKE '%ingreso%'
                                  OR F.TipoComprobante LIKE 'I%'
                             THEN 'I'
                             WHEN(F.TipoComprobante) LIKE '%egreso%'
                                 OR F.TipoComprobante LIKE 'E%'
                             THEN 'E'
                             WHEN(F.TipoComprobante) LIKE '%traslado%'
                                 OR F.TipoComprobante LIKE 'T%'
                             THEN 'T'
                             WHEN(F.TipoComprobante) LIKE '%nómina%'
                                 OR F.TipoComprobante LIKE 'N%'
                             THEN 'N'
                             WHEN(F.TipoComprobante) LIKE '%pago%'
                                 OR F.TipoComprobante LIKE 'P%'
                             THEN 'P'
                             ELSE 'NA'
                         END,
                         CASE
                             WHEN F.MetodoPago LIKE '%exhibi%'
                                  OR F.MetodoPago LIKE '%PUE%'
                                  OR F.FormaPago LIKE '%exhibi%'
                                  OR F.FormaPago LIKE '%PUE%'
                             THEN 'PUE'
                             WHEN F.MetodoPago LIKE '%parcia%'
                                  OR F.MetodoPago LIKE '%dife%'
                                  OR F.MetodoPago LIKE '%PPD%'
                                  OR F.FormaPago LIKE '%parcia%'
                                  OR F.FormaPago LIKE '%dife%'
                                  OR F.FormaPago LIKE '%PPD%'
                             THEN 'PPD'
                             WHEN F.TipoComprobante = 'P'
                             THEN 'PPD'
                         END, 
                         F.Fecha, 
                         F.IdMoneda;
/*
Ajuste para Carso
Primero se queda la consulta general para los demas contratos
*/
IF(@IdContrato <> 10047 OR @IdContrato <> 10048)
BEGIN
         /*Facturas Con Tipo de Cambio de Transferencia*/
		 --PPD
         INSERT INTO #MontosTotalTransferenciaPPD
         (IdFacturaCP, 
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
                SELECT F.IdFactura AS IdFacturaCP, 
                       F.UUID AS UUIDCP, 
                       CP.FormaDePagoP AS FormaPagoCP, 
                       SUM(CPDR.ImpPagado) AS MontoCP, 
                       TCD.TipoCambio AS TipoCambioCP, 
                       CP.MonedaP AS MonedaCP, 
                       CAST(SUM(CPDR.ImpPagado) AS DECIMAL(15, 2)) AS MontoPesos, 
                       CAST(SUM(CASE
                                    WHEN TM.IdMoneda = 1
                                    THEN CPDR.ImpPagado / TCD.TipoCambio
                                    ELSE CPDR.ImpPagado
                                END) AS DECIMAL(15, 2)) AS MontoDolares, 
                       F.TipoComprobante, 
                       CAST(#Facturas.MontoRegistro / TCD.TipoCambio AS DECIMAL(15, 2)) AS MontoRegistro, 
                       #Facturas.IdRegistro
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                               AND F.IdContrato = FCPDR.IdContrato
                                                               AND F.IdContrato = T.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND TCD.IdMoneda = FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
                      AND TCD.IdMoneda = FCPDR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         CP.FormaDePagoP, 
                         TCD.TipoCambio, 
                         CP.MonedaP, 
                         F.TipoComprobante, 
                         CAST(#Facturas.MontoRegistro / TCD.TipoCambio AS DECIMAL(15, 2)), 
                         #Facturas.IdRegistro
                UNION
                SELECT F.IdFactura AS IdFacturaCP, 
                       F.UUID AS UUIDCP, 
                       CP.FormaDePagoP AS FormaPagoCP, 
                       SUM(CPDR.ImpPagado) AS MontoCP, 
                       1 AS TipoCambioCP, 
                       CP.MonedaP AS MonedaCP, 
                       CAST((SUM(CPDR.ImpPagado * TCD.TipoCambio)) AS DECIMAL(15, 2)) AS MontoPesos, 
                       CAST((SUM(CASE
                                     WHEN TM.IdMoneda = 2
                                     THEN CPDR.ImpPagado / TCD.TipoCambio
                                     ELSE CPDR.ImpPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                       F.TipoComprobante, 
                       CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro, 
                       #Facturas.IdRegistro
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                               AND F.IdContrato = FCPDR.IdContrato
                                                               AND F.IdContrato = T.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND TCD.IdMoneda <> FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
					  AND T.IdMoneda <> TM.IdMoneda
                      AND TM.IdMoneda = FCPDR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         CP.FormaDePagoP, 
                         CP.MonedaP, 
                         F.TipoComprobante, 
                         CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)), 
                         #Facturas.IdRegistro
				UNION
				--Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)
				--y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)
				SELECT F.IdFactura AS IdFacturaCP, 
						F.UUID AS UUIDCP, 
						CP.FormaDePagoP AS FormaPagoCP, 
						SUM(CPDR.ImpPagado) AS MontoCP, 
						1, --TCD.TipoCambio AS TipoCambioCP, 
						CP.MonedaP AS MonedaCP, 
						CAST((SUM(CASE 
										WHEN TM.IdMoneda = 2
											AND FCPDR.IdMoneda = 1 
										THEN CPDR.ImpPagado * 1 --TCD.TipoCambio
										END)) AS DECIMAL(15, 2)) AS MontoPesos, 
						CAST((SUM(CASE
										WHEN TM.IdMoneda = 2
											AND FCPDR.IdMoneda = 1
										THEN CPDR.ImpPagado / TCD.TipoCambio
										ELSE CPDR.ImpPagado
									END)) AS DECIMAL(15, 2)) AS MontoDolares, 
						F.TipoComprobante, 
						CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro, 
						#Facturas.IdRegistro
				FROM dbo.FI_Transfer T WITH(NOLOCK)
						JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
						JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
						JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
						JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
						JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
																AND F.IdContrato = FCPDR.IdContrato
																AND F.IdContrato = T.IdContrato
						JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
						JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
						LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda <> TM.IdMoneda
																			AND TCD.IdMoneda = FCPDR.IdMoneda
																			AND DAY(TCD.Fecha) = DAY(T.FechaPago)
																			AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
																			AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
				WHERE #Facturas.MetodoPago = 'PPD'
						AND TF.CvTipoDocFacturacion = 6
						AND T.IdMoneda = TM.IdMoneda
						AND TM.IdMoneda <> FCPDR.IdMoneda
				GROUP BY F.IdFactura, 
							F.UUID, 
							CP.FormaDePagoP, 
							--TCD.TipoCambio,
							CP.MonedaP, 
							F.TipoComprobante, 
							CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)), 
							#Facturas.IdRegistro;
         --PUE
         SELECT Con.UUID, 
                Con.Idfactura, 
                Con.TipoComprobante, 
                SUM(Con.MontoDolares) AS MontoDolares, 
                Con.MetodoPago, 
                MAX(Con.TipoCambio) AS TipoCambio, 
                MAX(Con.Fecha) AS Fecha, 
                Con.IdMoneda
         INTO #SumaDePagosDolares
         FROM
         (
             SELECT DISTINCT 
                    MCF.UUID, 
                    MCF.Idfactura, 
                    MCF.TipoComprobante,
                    CASE
                        WHEN ISNULL(TF.MontoPagado, 0) <> 0
                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END AS MontoDolares, 
                    MCF.MetodoPago, 
                    TCD.TipoCambio AS TipoCambio, 
                    TCD.Fecha, 
                    MCF.IdMoneda, 
                    T.IdMoneda AS MonedaTran, 
                    T.IdTransferencia
             FROM dbo.FI_Transfer T WITH(NOLOCK)
                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = MCF.IdMoneda
                                                                        AND TCD.IdMoneda = T.IdMoneda
                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
             WHERE MCF.MetodoPago = 'PUE'
                   AND TCD.IdMoneda = MCF.IdMoneda
             --
             UNION
             --
             SELECT DISTINCT 
                    MCF.UUID, 
                    MCF.Idfactura, 
                    MCF.TipoComprobante,
                    CASE
                        WHEN T.IdMoneda = 1
                             AND F.IdMoneda = 2
                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN T.IdMoneda = 2
                             AND F.IdMoneda = 1
                        THEN TF.MontoPagado
                    END AS MontoDolares, 
                    MCF.MetodoPago,
                    CASE
                        WHEN T.IdMoneda = 1
                             AND F.IdMoneda = 2
                        THEN 1
                        WHEN T.IdMoneda = 2
                             AND F.IdMoneda = 1
                        THEN TCD.TipoCambio
                    END AS TipoCambio, 
                    TCD.Fecha, 
                    MCF.IdMoneda, 
                    T.IdMoneda AS MonedaTran, 
                    T.IdTransferencia
             FROM dbo.FI_Transfer T WITH(NOLOCK)
                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura
                  JOIN dbo.FI_Factura F WITH(NOLOCK) ON MCF.Idfactura = F.IdFactura
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = T.IdMoneda
                                                                        AND TCD.IdMoneda <> F.IdMoneda
                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
             WHERE MCF.MetodoPago = 'PUE'
                   AND TCD.IdMoneda <> F.IdMoneda
         ) AS Con
         GROUP BY Con.UUID, 
                  Con.Idfactura, 
                  Con.TipoComprobante, 
                  Con.MetodoPago, 
                  Con.IdMoneda;
		 --
         INSERT INTO #MontosTotalTransferenciaPUE
         (IdRegistro, 
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
                       MCF.IdRegistro, 
                       MCF.UUID, 
                       MCF.Idfactura, 
                       MCF.MontoRegistro, 
                       MCF.TipoComprobante, 
                       SPD.MontoDolares, 
                       MCF.MetodoPago, 
                       SPD.TipoCambio, 
                       SPD.Fecha, 
                       MCF.IdMoneda
                --SELECT * 
                FROM #Facturas MCF
                     JOIN #SumaDePagosDolares SPD ON MCF.Idfactura = SPD.Idfactura
                WHERE MCF.MetodoPago = 'PUE';

         /*PEDIMENTO COMPROBANTE*/
         --Monto dolares Pedimentos y Comprobantes
         INSERT INTO #MontosConvertidosPedimentosCom
         (IdRegistro, 
          IdPedimentoComprobante, 
          MontoRegistro, 
          RC2122, 
          TCD
         )
                SELECT R.IdRegistro, 
                       P.IdPedimentoComprobante, 
                       R.MontoRegistro, 
                       SUM(CASE
                               WHEN ISNULL(R.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END) AS [RC21_22], 
                       TCDP.TipoCambio
                FROM dbo.CO_Registro R WITH(NOLOCK)
                     JOIN dbo.FI_PedimentoComprobante P WITH(NOLOCK) ON P.IdPedimentoComprobante = R.IdPedimentoComprobante
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = P.IdContrato
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdPedimentoComprobante = P.IdPedimentoComprobante
                     JOIN dbo.FI_Transfer T WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDP WITH(NOLOCK) ON TCDP.IdMoneda = P.IdMoneda
                                                                            AND DAY(TCDP.Fecha) = DAY(T.FechaPago)
                                                                            AND MONTH(TCDP.Fecha) = MONTH(T.FechaPago)
                                                                            AND YEAR(TCDP.Fecha) = YEAR(T.FechaPago)
                WHERE C.IdContrato = @IdContrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) <= @Mes
                      AND R.IdEstado = 10004
                      AND R.CvTipoDocFacturacion IN(2, 3)
                     AND ISNULL(CONVERT(INT, P.ProcesadoSIPAC), 0) = 0
                     AND S.NombreServicio NOT LIKE '%No elegibles%'
                GROUP BY R.IdRegistro, 
                         P.IdPedimentoComprobante, 
                         R.MontoRegistro, 
                         TCDP.TipoCambio;

         /*Consulta antes de Diciembre del 2019*/

         INSERT INTO #CGIantes
                SELECT [RF_00], 
                       [RI_00], 
                       [RF01_01], 
                       [RC21_00], 
                       [RC21_01], 
                       [RC21_02], 
                       ROW_NUMBER() OVER(ORDER BY [RC21_11] ASC) AS [RC21_03], 
                       [RC21_04], 
                       [RC21_05], 
                       [RC21_06], 
                       [RC21_07], 
                       [RC21_08], 
                       [RC21_09], 
                       [RC21_10], 
                       [RC21_11], 
                       [RC21_12], 
                       [RC21_13], 
                       [RC21_14], 
                       [RC21_15], 
                       [RC21_16], 
                       [RC21_17], 
                       [RC21_18], 
                       [RC21_19], 
                       [RC21_20], 
                       [RC21_21], 
                       [RC21_22], 
                       [RC21_23], 
                       [RC21_24], 
                       [RC21_25], 
                       [RC21_26], 
                       IdServicio, 
                       IdProgramaActividad, 
                       Inicio, 
                       MesPresentacion
                FROM
                (
                    SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                           LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                           C.NumeroContrato AS [RF01_01], 
                           SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                           MONTH(R.MesPresentacion) AS [RC21_01], 
                           YEAR(R.MesPresentacion) AS [RC21_02], 
                           NULL AS [RC21_03], 
                           SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                               ELSE 'NA'
                           END AS [RC21_05], 
                           'NA' AS [RC21_06], 
                           'NA' AS [RC21_07], 
                           TTF.TipoComprobante AS [RC21_08], 
                           TTF.MetodoPago AS [RC21_09], 
                           LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                           LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                           LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 1
                               ELSE 0
                           END AS [RC21_13],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                           END AS [RC21_14],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                           END AS [RC21_15],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(I.NombreInstalacion))
                           END AS [RC21_16], 
                           CC.Nivel3 AS [RC21_17], 
                           CC.Descripcion AS [RC21_18], 
                           R.Poliza AS [RC21_19], 
                           SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                           CASE
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                               THEN 1
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                               THEN 2
                               ELSE 2
                           END AS [RC21_21],
                           CASE
                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                    AND TTF.TipoComprobante IN('I', 'N', 'P')
                               THEN TTF.RC2122
                               ELSE 0
                           END AS [RC21_22],
                           CASE
                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                    AND TTF.TipoComprobante IN('E')
                               THEN TTF.RC2122
                               ELSE 0
                           END AS [RC21_23], 
                           TM.TipoMonedaCorto AS [RC21_24], 
                           TTF.TCD AS [RC21_25],
                           CASE
                               WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                               THEN 1
                               ELSE 2
                           END AS [RC21_26], 
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.FI_Transfer T WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                                                               AND F.IdContrato = T.IdContrato
                         JOIN dbo.CO_Registro R WITH(NOLOCK) ON F.IdFactura = R.IdFactura
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON P.IdAnioContractual = AC.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON T.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON LPM.IdServicio = S.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         JOIN #MontosTotalTransferenciaPUE TTF WITH(NOLOCK) ON TTF.Idfactura = R.IdFactura
                                                                               AND TTF.IdRegistro = R.IdRegistro
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND F.IdSubcontratista = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) < '2019-12-01'
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion = 1
                          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                          AND S.NombreServicio NOT LIKE '%No elegibles%'
                          AND TTF.MetodoPago = 'PUE'
                          AND P.IdProgramaActividad = @IdProgramaActividad
                    GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                             LTRIM(RTRIM(C.IDRegFiducidiario)), 
                             C.NumeroContrato, 
                             SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                             MONTH(R.MesPresentacion), 
                             YEAR(R.MesPresentacion), 
                             SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2),
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                                 ELSE 'NA'
                             END, 
                             LTRIM(RTRIM(APCNH.id_Actividad)), 
                             LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                             LTRIM(RTRIM(TP.id_Tarea)),
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 1
                                 ELSE 0
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(I.NombreInstalacion))
                             END,
                             CASE
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                 THEN 1
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                 THEN 2
                                 ELSE 2
                             END,
                             CASE
                                 WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                      AND TTF.TipoComprobante IN('I', 'N', 'P')
                                 THEN TTF.RC2122
                                 ELSE 0
                             END,
                             CASE
                                 WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                      AND TTF.TipoComprobante IN('E')
                                 THEN TTF.RC2122
                                 ELSE 0
                             END,
                             CASE
                                 WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                 THEN 1
                                 ELSE 2
                             END, 
                             TTF.TipoComprobante, 
                             TTF.MetodoPago, 
                             CC.Nivel3, 
                             CC.Descripcion, 
                             R.Poliza, 
                             SUBSTRING(R.Comentarios, 0, 299), 
                             TM.TipoMonedaCorto, 
                             TTF.TCD, 
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                    --
                    UNION
                    --
                    SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                           LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                           C.NumeroContrato AS [RF01_01], 
                           SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                           MONTH(R.MesPresentacion) AS [RC21_01], 
                           YEAR(R.MesPresentacion) AS [RC21_02], 
                           NULL AS [RC21_03], 
                           SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')
                               ELSE 'NA'
                           END AS [RC21_05], 
                           'NA' AS [RC21_06], 
                           'NA' AS [RC21_07], 
                           FCP.TipoComprobante AS [RC21_08], 
                           'PPD' AS [RC21_09], 
                           LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                           LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                           LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 1
                               ELSE 0
                           END AS [RC21_13],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                           END AS [RC21_14],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                           END AS [RC21_15],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(I.NombreInstalacion))
                           END AS [RC21_16], 
                           CC.Nivel3 AS [RC21_17], 
                           CC.Descripcion AS [RC21_18], 
                           R.Poliza AS [RC21_19], 
                           SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                           CASE
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                               THEN 1
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                               THEN 2
                               ELSE 2
                           END AS [RC21_21],
                           CASE
                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                    AND TTF.TipoComprobante IN('I', 'N', 'P')
                               THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                               ELSE 0
                           END AS [RC21_22],
                           CASE
                               WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                    AND TTF.TipoComprobante IN('E')
                               THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2))
                               ELSE 0
                           END AS [RC21_23], 
                           TM.TipoMonedaCorto AS [RC21_24], 
                           TTF.TipoCambioCP AS [RC21_25],
                           CASE
                               WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                               THEN 1
                               ELSE 2
                           END AS [RC21_26], 
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.CO_Registro R WITH(NOLOCK)
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = R.IdFactura
                         JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON F.UUID = CPDR.IdDocumento
                         JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                         JOIN #MontosTotalTransferenciaPPD TTF WITH(NOLOCK) ON CP.IdFactura = TTF.IdFacturaCP
                                                                               AND R.IdRegistro = TTF.IdRegistro
                         JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TTF.IdFacturaCP = FCP.IdFactura
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON F.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND F.IdSubcontratista = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) < '2019-12-01'
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion = 1
                          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                          AND S.NombreServicio NOT LIKE '%No elegibles%'
                          AND P.IdProgramaActividad = @IdProgramaActividad
                    GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                             LTRIM(RTRIM(C.IDRegFiducidiario)), 
                             C.NumeroContrato, 
                             SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                             MONTH(R.MesPresentacion), 
                             YEAR(R.MesPresentacion), 
                             SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2),
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')
                                 ELSE 'NA'
                             END, 
                             LTRIM(RTRIM(APCNH.id_Actividad)), 
                             LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                             LTRIM(RTRIM(TP.id_Tarea)),
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 1
                                 ELSE 0
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(I.NombreInstalacion))
                             END,
                             CASE
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                 THEN 1
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                 THEN 2
                                 ELSE 2
                             END,
                             CASE
                                 WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                      AND TTF.TipoComprobante IN('I', 'N', 'P')
                                 THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                                 ELSE 0
                             END,
                             CASE
                                 WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                      AND TTF.TipoComprobante IN('E')
                                 THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2))
                                 ELSE 0
                             END,
                             CASE
                                 WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                 THEN 1
                                 ELSE 2
                             END, 
                             FCP.TipoComprobante, 
                             CC.Nivel3, 
                             CC.Descripcion, 
                             R.Poliza, 
                             SUBSTRING(R.Comentarios, 0, 299), 
                             TM.TipoMonedaCorto, 
                             TTF.TipoCambioCP, 
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                    --
                    UNION
                    --
                    SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                           LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                           C.NumeroContrato AS [RF01_01], 
                           SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                           MONTH(R.MesPresentacion) AS [RC21_01], 
                           YEAR(R.MesPresentacion) AS [RC21_02], 
                           NULL AS [RC21_03], 
                           SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04], 
                           'NA' AS [RC21_05],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 3
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 2
                               THEN PC.NumeroPedimento
                           END AS [RC21_06],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 2
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 3
                               THEN PC.IdDocFacturacionSIPAC
                           END AS [RC21_07], 
                           'NA' AS [RC21_08], 
                           'PUE' AS [RC21_09], 
                           LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                           LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                           LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 1
                               ELSE 0
                           END AS [RC21_13],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                           END AS [RC21_14],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                           END AS [RC21_15],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(I.NombreInstalacion))
                           END AS [RC21_16], 
                           CC.Nivel3 AS [RC21_17], 
                           CC.Descripcion AS [RC21_18], 
                           R.Poliza AS [RC21_19], 
                           SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                           CASE
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                               THEN 1
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                               THEN 2
                               ELSE 2
                           END AS [RC21_21],
                           CASE
                               WHEN ISNULL(MP.MontoRegistro, 0) <> 0
                               THEN MP.RC2122
                               ELSE 0
                           END AS [RC21_22], 
                           0 AS [RC21_23], 
                           TM.TipoMonedaCorto AS [RC21_24], 
                           MP.TCD AS [RC21_25],
                           CASE
                               WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                               THEN 1
                               ELSE 2
                           END AS [RC21_26], 
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.FI_Transfer TR WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                         JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                                                             AND PC.IdContrato = TR.IdContrato
                         JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         JOIN #MontosConvertidosPedimentosCom MP WITH(NOLOCK) ON MP.IdRegistro = R.IdRegistro
                                                                                 AND MP.idPedimentoComprobante = R.IdPedimentoComprobante
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND PC.IdSubcontratistaExportador = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) < '2019-12-01'
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion IN(2, 3)
                         AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                         AND S.NombreServicio NOT LIKE '%No elegibles%'
                         AND P.IdProgramaActividad = @IdProgramaActividad
                    GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                             LTRIM(RTRIM(C.IDRegFiducidiario)), 
                             C.NumeroContrato, 
                             SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                             MONTH(R.MesPresentacion), 
                             YEAR(R.MesPresentacion), 
                             SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2),
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 3
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 2
                                 THEN PC.NumeroPedimento
                             END,
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 2
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 3
                                 THEN PC.IdDocFacturacionSIPAC
                             END, 
                             LTRIM(RTRIM(APCNH.id_Actividad)), 
                             LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                             LTRIM(RTRIM(TP.id_Tarea)),
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 1
                                 ELSE 0
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(I.NombreInstalacion))
                             END, 
                             CC.Nivel3, 
                             CC.Descripcion, 
                             R.Poliza, 
                             SUBSTRING(R.Comentarios, 0, 299),
                             CASE
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                 THEN 1
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                 THEN 2
                                 ELSE 2
                             END,
                             CASE
                                 WHEN ISNULL(MP.MontoRegistro, 0) <> 0
                                 THEN MP.RC2122
                                 ELSE 0
                             END, 
                             TM.TipoMonedaCorto, 
                             MP.TCD,
                             CASE
                                 WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                 THEN 1
                                 ELSE 2
                             END, 
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                ) AS Resultado;

         /*Base para hacer pivote*/

         INSERT INTO #DATOS
         (IdTipoProgramaActividad, 
          IdActividadPetrolera, 
          IdSubactividadPetrolera, 
          IdTareaPetrolera, 
          IdServicio, 
          MontoRegistro, 
          MesPresentacion, 
          InicioPresup, 
          ANIO, 
          MES, 
          MesPresentacionOrig
         )
                SELECT TPA.IdTipoProgramaActividad, 
                       AP.IdActividadPetrolera, 
                       SAP.IdSubactividadPetrolera, 
                       TP.IdTareaPetrolera, 
                       S.IdServicio, 
                       H21.RC21_22, 
                       H21.MesPresentacion, 
                       H21.Inicio, 
                       H21.RC21_01, 
                       H21.RC21_02, 
                       H21.MesPresentacion
                FROM #CGIantes H21 WITH(NOLOCK)
                     JOIN dbo.CO_ActividadPetroleraCNH AP WITH(NOLOCK) ON AP.id_Actividad = H21.RC21_10
                     JOIN dbo.CO_SubactividadPetrolera SAP WITH(NOLOCK) ON SAP.[id_Sub-actividad] = H21.RC21_11
                     JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON TP.id_Tarea = H21.RC21_12
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = H21.IdServicio
                     JOIN dbo.CO_ProgramaActividad PA WITH(NOLOCK) ON H21.IdProgramaActividad = PA.IdProgramaActividad
                     JOIN dbo.CO_TipoProgramaActividad TPA WITH(NOLOCK) ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                     JOIN dbo.CO_ActSubTareaPetroleraCNH ASTP WITH(NOLOCK) ON AP.IdActividadPetrolera = ASTP.IdActividadPetrolera
                                                                              AND SAP.IdSubactividadPetrolera = ASTP.IdSubactividadPetrolera
                                                                              AND TP.IdTareaPetrolera = ASTP.IdTareaPetrolera;

         /*HOJA 21 CGI para que den el mismo resultado a partir de Diciembre 2019*/

         INSERT INTO #CGIdespues
                SELECT [RF_00], 
                       [RI_00], 
                       [RF01_01], 
                       [RC21_00], 
                       [RC21_01], 
                       [RC21_02], 
                       ROW_NUMBER() OVER(ORDER BY [RC21_11] ASC) AS [RC21_03], 
                       [RC21_04], 
                       [RC21_05], 
                       [RC21_06], 
                       [RC21_07], 
                       [RC21_08], 
                       [RC21_09], 
                       [RC21_10], 
                       [RC21_11], 
                       [RC21_12], 
                       [RC21_13], 
                       [RC21_14], 
                       [RC21_15], 
                       [RC21_16], 
                       [RC21_17], 
                       [RC21_18], 
                       [RC21_19], 
                       [RC21_20], 
                       [RC21_21], 
                       [RC21_22], 
                       [RC21_23], 
                       [RC21_24], 
                       [RC21_25], 
                       [RC21_26], 
                       IdServicio, 
                       IdProgramaActividad, 
                       Inicio, 
                       MesPresentacion
                FROM
                (
                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                            C.NumeroContrato AS [RF01_01], 
                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                            MONTH(R.MesPresentacion) AS [RC21_01], 
                            YEAR(R.MesPresentacion) AS [RC21_02], 
                            NULL AS [RC21_03], 
                            SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                            CASE
                                WHEN R.CvTipoDocFacturacion = 1
                                THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                                ELSE 'NA'
                            END AS [RC21_05], 
                            'NA' AS [RC21_06], 
                            'NA' AS [RC21_07], 
                            TTF.TipoComprobante AS [RC21_08], 
                            TTF.MetodoPago AS [RC21_09], 
                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 1
                                ELSE 0
                            END AS [RC21_13],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                            END AS [RC21_14],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                            END AS [RC21_15],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(I.NombreInstalacion))
                            END AS [RC21_16], 
                            CC.Nivel3 AS [RC21_17], 
                            CC.Descripcion AS [RC21_18], 
                            R.Poliza AS [RC21_19], 
                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                            CASE
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                THEN 1
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                THEN 2
                                ELSE 2
                            END AS [RC21_21], 
                            SUM(CASE
                                    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                         AND TTF.TipoComprobante IN('I', 'N', 'P') --TTF.RC2122--
                                    THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))
                                    ELSE 0
                                END) AS [RC21_22], 
                            SUM(ABS(CASE
                                        WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                             AND TTF.TipoComprobante IN('E')
                                        THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))--TTF.RC2122
                                        ELSE 0
                                    END)) AS [RC21_23], 
                            TM.TipoMonedaCorto AS [RC21_24], 
                            TTF.TCD AS [RC21_25],
                            CASE
                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                THEN 1
                                ELSE 2
                            END AS [RC21_26],
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                     FROM dbo.CO_Registro R WITH(NOLOCK)
                          JOIN dbo.FI_Factura F WITH(NOLOCK) ON R.IdFactura = F.IdFactura
                          JOIN #MontosTotalTransferenciaPUE TTF ON TTF.Idfactura = R.IdFactura
                                                                   AND TTF.IdRegistro = R.IdRegistro
                          JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                          JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                          JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                          JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                          JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                          JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                          JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                          JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                          JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                          JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                 AND C.IdContrato = S.IdContrato
                          LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                          LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                          LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                          LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
                          LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                               AND F.IdSubcontratista = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) > '2019-11-01'
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion = 1
                          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                          AND S.NombreServicio NOT LIKE '%No elegibles%'
                          AND TTF.MetodoPago = 'PUE'
                          AND P.IdProgramaActividad = @IdProgramaActividad
                     GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                              LTRIM(RTRIM(C.IDRegFiducidiario)), 
                              C.NumeroContrato, 
                              SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                              MONTH(R.MesPresentacion), 
                              YEAR(R.MesPresentacion), 
                              SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2),
                              CASE
                                  WHEN R.CvTipoDocFacturacion = 1
                                  THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                                  ELSE 'NA'
                              END, 
                              LTRIM(RTRIM(APCNH.id_Actividad)), 
                              LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                              LTRIM(RTRIM(TP.id_Tarea)),
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 1
                                  ELSE 0
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(I.NombreInstalacion))
                              END,
                              CASE
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                  THEN 1
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                  THEN 2
                                  ELSE 2
                              END,
                              CASE
                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                  THEN 1
                                  ELSE 2
                              END, 
                              TTF.TipoComprobante, 
                              TTF.MetodoPago, 
                              CC.Nivel3, 
                              CC.Descripcion, 
                              R.Poliza, 
                              SUBSTRING(R.Comentarios, 0, 299), 
                              TM.TipoMonedaCorto, 
                              TTF.TCD,
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                    --
                    UNION
                    --
                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                            C.NumeroContrato AS [RF01_01], 
                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                            MONTH(R.MesPresentacion) AS [RC21_01], 
                            YEAR(R.MesPresentacion) AS [RC21_02], 
                            NULL AS [RC21_03], 
                            SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                            CASE
                                WHEN R.CvTipoDocFacturacion = 1
                                THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')
                                ELSE 'NA'
                            END AS [RC21_05], 
                            'NA' AS [RC21_06], 
                            'NA' AS [RC21_07], 
                            FCP.TipoComprobante AS [RC21_08], 
                            'PPD' AS [RC21_09], --TTF.MetodoPago
                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 1
                                ELSE 0
                            END AS [RC21_13],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                            END AS [RC21_14],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                            END AS [RC21_15],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(I.NombreInstalacion))
                            END AS [RC21_16], 
                            CC.Nivel3 AS [RC21_17], 
                            CC.Descripcion AS [RC21_18], 
                            R.Poliza AS [RC21_19], 
                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                            CASE
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                THEN 1
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                THEN 2
                                ELSE 2
                            END AS [RC21_21], 
                            SUM(CASE
                                    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                         AND TTF.TipoComprobante IN('I', 'N', 'P')
                                    THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                                    ELSE 0
                                END) AS [RC21_22], 
                            SUM(ABS(CASE
                                        WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                             AND TTF.TipoComprobante IN('E')
                                        THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2))
                                        ELSE 0
                                    END)) AS [RC21_23], 
                            CASE WHEN TTF.TipoCambioCP = 1
								 THEN 'USD'
								 ELSE 'MXN'
						    END AS [RC21_24], --TM.TipoMonedaCorto AS [RC21_24], 
                            TTF.TipoCambioCP AS [RC21_25],
                            CASE
                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                THEN 1
                                ELSE 2
                            END AS [RC21_26],
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.CO_Registro R WITH(NOLOCK)
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = R.IdFactura
                         JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON F.UUID = CPDR.IdDocumento
                         JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                         JOIN #MontosTotalTransferenciaPPD TTF WITH(NOLOCK) ON CP.IdFactura = TTF.IdFacturaCP
                                                                               AND R.IdRegistro = TTF.IdRegistro
                         JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TTF.IdFacturaCP = FCP.IdFactura
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON F.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND F.IdSubcontratista = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) > '2019-11-01'
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion = 1
                          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                          AND S.NombreServicio NOT LIKE '%No elegibles%'
                           AND FCP.UUID NOT IN
                     (
                         SELECT UUID
                         FROM #uuidNoReportar
                     )
                           AND FCP.UUID NOT IN
                     (
                         SELECT ControlF.UUID
                         FROM dbo.FI_ControlPPDComplementos ControlF
                         WHERE ControlF.IdContrato = @IdContrato
                     )
                          AND P.IdProgramaActividad = @IdProgramaActividad
                     GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                              LTRIM(RTRIM(C.IDRegFiducidiario)), 
                              C.NumeroContrato, 
                              SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                              MONTH(R.MesPresentacion), 
                              YEAR(R.MesPresentacion), 
                              SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2),
                              CASE
                                  WHEN R.CvTipoDocFacturacion = 1
                                  THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')
                                  ELSE 'NA'
                              END, 
                              LTRIM(RTRIM(APCNH.id_Actividad)), 
                              LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                              LTRIM(RTRIM(TP.id_Tarea)),
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 1
                                  ELSE 0
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(I.NombreInstalacion))
                              END,
                              CASE
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                  THEN 1
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                  THEN 2
                                  ELSE 2
                              END,
                              CASE
                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                  THEN 1
                                  ELSE 2
                              END, 
                              FCP.TipoComprobante,
                              --TTF.MetodoPago, 
                              CC.Nivel3, 
                              CC.Descripcion, 
                              R.Poliza, 
                              SUBSTRING(R.Comentarios, 0, 299), 
                              --TM.TipoMonedaCorto, 
                              CASE WHEN TTF.TipoCambioCP = 1
								   THEN 'USD'
								   ELSE 'MXN'
						      END,
                              TTF.TipoCambioCP,
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                    --
                    UNION
                    --
                    SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                           LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                           C.NumeroContrato AS [RF01_01], 
                           SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                           MONTH(R.MesPresentacion) AS [RC21_01], 
                           YEAR(R.MesPresentacion) AS [RC21_02], 
                           NULL AS [RC21_03], 
                           SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04], 
                           'NA' AS [RC21_05],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 3
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 2
                               THEN PC.NumeroPedimento
                           END AS [RC21_06],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 2
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 3
                               THEN PC.IdDocFacturacionSIPAC
                           END AS [RC21_07], 
                           'NA' AS [RC21_08], 
                           'PUE' AS [RC21_09], 
                           LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                           LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                           LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 1
                               ELSE 0
                           END AS [RC21_13],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                           END AS [RC21_14],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                           END AS [RC21_15],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(I.NombreInstalacion))
                           END AS [RC21_16], 
                           CC.Nivel3 AS [RC21_17], 
                           CC.Descripcion AS [RC21_18], 
                           R.Poliza AS [RC21_19], 
                           SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                           CASE
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                               THEN 1
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                               THEN 2
                               ELSE 2
                           END AS [RC21_21], 
                           SUM(CASE
                                   WHEN ISNULL(MP.MontoRegistro, 0) <> 0
                                   THEN MP.RC2122
                                   ELSE 0
                               END) AS [RC21_22], 
                           0 AS [RC21_23], 
                           TM.TipoMonedaCorto AS [RC21_24], 
                           MP.TCD AS [RC21_25],
                           CASE
                               WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                               THEN 1
                               ELSE 2
                           END AS [RC21_26], 
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.FI_Transfer TR WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                         JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                                                             AND PC.IdContrato = TR.IdContrato
                         JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         JOIN #MontosConvertidosPedimentosCom MP WITH(NOLOCK) ON MP.IdRegistro = R.IdRegistro
                                                                                 AND MP.idPedimentoComprobante = R.IdPedimentoComprobante
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND PC.IdSubcontratistaExportador = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) > '2019-11-01'
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion IN(2, 3)
                         AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                         AND S.NombreServicio NOT LIKE '%No elegibles%'
                         AND P.IdProgramaActividad = @IdProgramaActividad
                    GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                             LTRIM(RTRIM(C.IDRegFiducidiario)), 
                             C.NumeroContrato, 
                             SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                             MONTH(R.MesPresentacion), 
                             YEAR(R.MesPresentacion), 
                             SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2),
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 3
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 2
                                 THEN PC.NumeroPedimento
                             END,
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 2
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 3
                                 THEN PC.IdDocFacturacionSIPAC
                             END, 
                             LTRIM(RTRIM(APCNH.id_Actividad)), 
                             LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                             LTRIM(RTRIM(TP.id_Tarea)),
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 1
                                 ELSE 0
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(I.NombreInstalacion))
                             END, 
                             CC.Nivel3, 
                             CC.Descripcion, 
                             R.Poliza, 
                             SUBSTRING(R.Comentarios, 0, 299),
                             CASE
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                 THEN 1
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                 THEN 2
                                 ELSE 2
                             END,
                             TM.TipoMonedaCorto, 
                             MP.TCD,
                             CASE
                                 WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                 THEN 1
                                 ELSE 2
                             END, 
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                ) AS Resultado;

         /*Base para hacer pivote*/

         INSERT INTO #DATOS
         (IdTipoProgramaActividad, 
          IdActividadPetrolera, 
          IdSubactividadPetrolera, 
          IdTareaPetrolera, 
          IdServicio, 
          MontoRegistro, 
          MesPresentacion, 
          InicioPresup, 
          ANIO, 
          MES, 
          MesPresentacionOrig
         )
                SELECT TPA.IdTipoProgramaActividad, 
                       AP.IdActividadPetrolera, 
                       SAP.IdSubactividadPetrolera, 
                       TP.IdTareaPetrolera, 
                       S.IdServicio, 
                       H21.RC21_22, 
                       H21.MesPresentacion, 
                       H21.Inicio, 
                       H21.RC21_01, 
                       H21.RC21_02, 
                       H21.MesPresentacion
                FROM #CGIdespues H21 WITH(NOLOCK)
                     JOIN dbo.CO_ActividadPetroleraCNH AP WITH(NOLOCK) ON AP.id_Actividad = H21.RC21_10
                     JOIN dbo.CO_SubactividadPetrolera SAP WITH(NOLOCK) ON SAP.[id_Sub-actividad] = H21.RC21_11
                     JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON TP.id_Tarea = H21.RC21_12
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = H21.IdServicio
                     JOIN dbo.CO_ProgramaActividad PA WITH(NOLOCK) ON H21.IdProgramaActividad = PA.IdProgramaActividad
                     JOIN dbo.CO_TipoProgramaActividad TPA WITH(NOLOCK) ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                     JOIN dbo.CO_ActSubTareaPetroleraCNH ASTP WITH(NOLOCK) ON AP.IdActividadPetrolera = ASTP.IdActividadPetrolera
                                                                              AND SAP.IdSubactividadPetrolera = ASTP.IdSubactividadPetrolera
                                                                              AND TP.IdTareaPetrolera = ASTP.IdTareaPetrolera;
END
/*
Termina reporte general
Comienza ajuste para Carso
*/
IF(@IdContrato = 10047 OR @IdContrato = 10048)
BEGIN
         /*Facturas Con Tipo de Cambio de Transferencia*/
		 --PPD
         INSERT INTO #MontosTotalTransferenciaPPD
         (IdFacturaCP, 
          UUIDCP, 
          FormaPagoCP, 
          MontoCP, 
          TipoCambioCP, 
          MonedaCP, 
          MontoPesos, 
          MontoDolares, 
          TipoComprobante, 
          MontoRegistro, 
          IdRegistro,
		  MesPagoCarso
         )
                SELECT F.IdFactura AS IdFacturaCP, 
                       F.UUID AS UUIDCP, 
                       CP.FormaDePagoP AS FormaPagoCP, 
                       SUM(CPDR.ImpPagado) AS MontoCP, 
                       TCD.TipoCambio AS TipoCambioCP, 
                       CP.MonedaP AS MonedaCP, 
                       CAST(SUM(CPDR.ImpPagado) AS DECIMAL(15, 2)) AS MontoPesos, 
                       CAST(SUM(CASE
                                    WHEN TM.IdMoneda = 1
                                    THEN CPDR.ImpPagado / TCD.TipoCambio
                                    ELSE CPDR.ImpPagado
                                END) AS DECIMAL(15, 2)) AS MontoDolares, 
                       F.TipoComprobante, 
                       CAST(#Facturas.MontoRegistro / TCD.TipoCambio AS DECIMAL(15, 2)) AS MontoRegistro, 
                       #Facturas.IdRegistro,
					   T.FechaPago
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                               AND F.IdContrato = FCPDR.IdContrato
                                                               AND F.IdContrato = T.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND TCD.IdMoneda = FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
                      AND TCD.IdMoneda = FCPDR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         CP.FormaDePagoP, 
                         TCD.TipoCambio, 
                         CP.MonedaP, 
                         F.TipoComprobante, 
                         CAST(#Facturas.MontoRegistro / TCD.TipoCambio AS DECIMAL(15, 2)), 
                         #Facturas.IdRegistro,
						 T.FechaPago
                UNION
                SELECT F.IdFactura AS IdFacturaCP, 
                       F.UUID AS UUIDCP, 
                       CP.FormaDePagoP AS FormaPagoCP, 
                       SUM(CPDR.ImpPagado) AS MontoCP, 
                       1 AS TipoCambioCP, 
                       CP.MonedaP AS MonedaCP, 
                       CAST((SUM(CPDR.ImpPagado * TCD.TipoCambio)) AS DECIMAL(15, 2)) AS MontoPesos, 
                       CAST((SUM(CASE
                                     WHEN TM.IdMoneda = 2
                                     THEN CPDR.ImpPagado / TCD.TipoCambio
                                     ELSE CPDR.ImpPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                       F.TipoComprobante, 
                       CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro, 
                       #Facturas.IdRegistro,
					   T.FechaPago
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                               AND F.IdContrato = FCPDR.IdContrato
                                                               AND F.IdContrato = T.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND TCD.IdMoneda <> FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
					  AND T.IdMoneda <> TM.IdMoneda
                      AND TM.IdMoneda = FCPDR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         CP.FormaDePagoP, 
                         CP.MonedaP, 
                         F.TipoComprobante, 
                         CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)), 
                         #Facturas.IdRegistro,
						 T.FechaPago
				UNION
				--Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)
				--y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)
				SELECT F.IdFactura AS IdFacturaCP, 
						F.UUID AS UUIDCP, 
						CP.FormaDePagoP AS FormaPagoCP, 
						SUM(CPDR.ImpPagado) AS MontoCP, 
						1, --TCD.TipoCambio AS TipoCambioCP, 
						CP.MonedaP AS MonedaCP, 
						CAST((SUM(CASE 
										WHEN TM.IdMoneda = 2
											AND FCPDR.IdMoneda = 1 
										THEN CPDR.ImpPagado * 1 --TCD.TipoCambio
										END)) AS DECIMAL(15, 2)) AS MontoPesos, 
						CAST((SUM(CASE
										WHEN TM.IdMoneda = 2
											AND FCPDR.IdMoneda = 1
										THEN CPDR.ImpPagado / TCD.TipoCambio
										ELSE CPDR.ImpPagado
									END)) AS DECIMAL(15, 2)) AS MontoDolares, 
						F.TipoComprobante, 
						CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro, 
						#Facturas.IdRegistro,
						T.FechaPago
				FROM dbo.FI_Transfer T WITH(NOLOCK)
						JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
						JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
						JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura
						JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
						JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
																AND F.IdContrato = FCPDR.IdContrato
																AND F.IdContrato = T.IdContrato
						JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
						JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura
						LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda <> TM.IdMoneda
																			AND TCD.IdMoneda = FCPDR.IdMoneda
																			AND DAY(TCD.Fecha) = DAY(T.FechaPago)
																			AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
																			AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
				WHERE #Facturas.MetodoPago = 'PPD'
						AND TF.CvTipoDocFacturacion = 6
						AND T.IdMoneda = TM.IdMoneda
						AND TM.IdMoneda <> FCPDR.IdMoneda
				GROUP BY F.IdFactura, 
							F.UUID, 
							CP.FormaDePagoP, 
							--TCD.TipoCambio,
							CP.MonedaP, 
							F.TipoComprobante, 
							CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)), 
							#Facturas.IdRegistro,
							T.FechaPago
         --PUE normales y PPD directo sin complemento de pago
         SELECT Con.UUID, 
                Con.Idfactura, 
                Con.TipoComprobante, 
                SUM(Con.MontoDolares) AS MontoDolares, 
                Con.MetodoPago, 
                MAX(Con.TipoCambio) AS TipoCambio, 
                MAX(Con.Fecha) AS Fecha, 
                Con.IdMoneda,
				Con.FechaPago
         INTO #SumaDePagosDolaresCarso
         FROM
         (
             SELECT DISTINCT 
                    MCF.UUID, 
                    MCF.Idfactura, 
                    MCF.TipoComprobante,
                    CASE
                        WHEN ISNULL(TF.MontoPagado, 0) <> 0
                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END AS MontoDolares, 
                    MCF.MetodoPago, 
                    TCD.TipoCambio AS TipoCambio, 
                    TCD.Fecha, 
                    MCF.IdMoneda, 
                    T.IdMoneda AS MonedaTran, 
                    T.IdTransferencia,
					T.FechaPago
             FROM dbo.FI_Transfer T WITH(NOLOCK)
                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = MCF.IdMoneda
                                                                        AND TCD.IdMoneda = T.IdMoneda
                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
             WHERE MCF.MetodoPago IN ('PUE','PPD')
                   AND TCD.IdMoneda = MCF.IdMoneda
             --
             UNION
             --
             SELECT DISTINCT 
                    MCF.UUID, 
                    MCF.Idfactura, 
                    MCF.TipoComprobante,
                    CASE
                        WHEN T.IdMoneda = 1
                             AND F.IdMoneda = 2
                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        WHEN T.IdMoneda = 2
                             AND F.IdMoneda = 1
                        THEN TF.MontoPagado
                    END AS MontoDolares, 
                    MCF.MetodoPago,
                    CASE
                        WHEN T.IdMoneda = 1
                             AND F.IdMoneda = 2
                        THEN 1
                        WHEN T.IdMoneda = 2
                             AND F.IdMoneda = 1
                        THEN TCD.TipoCambio
                    END AS TipoCambio, 
                    TCD.Fecha, 
                    MCF.IdMoneda, 
                    T.IdMoneda AS MonedaTran, 
                    T.IdTransferencia,
					T.FechaPago
             FROM dbo.FI_Transfer T WITH(NOLOCK)
                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura
                  JOIN dbo.FI_Factura F WITH(NOLOCK) ON MCF.Idfactura = F.IdFactura
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = T.IdMoneda
                                                                        AND TCD.IdMoneda <> F.IdMoneda
                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
             WHERE MCF.MetodoPago IN ('PUE','PPD')
                   AND TCD.IdMoneda <> F.IdMoneda
         ) AS Con
         GROUP BY Con.UUID, 
                  Con.Idfactura, 
                  Con.TipoComprobante, 
                  Con.MetodoPago, 
                  Con.IdMoneda,
				  Con.FechaPago
		 --
         INSERT INTO #MontosTotalTransferenciaPUE
         (IdRegistro, 
          UUID, 
          Idfactura, 
          MontoRegistro, 
          TipoComprobante, 
          RC2122, 
          MetodoPago, 
          TCD, 
          FechaTCD, 
          IdMoneda,
		  MesPagoCarso
         )
                SELECT DISTINCT 
                       MCF.IdRegistro, 
                       MCF.UUID, 
                       MCF.Idfactura, 
                       MCF.MontoRegistro, 
                       MCF.TipoComprobante, 
                       SPD.MontoDolares, 
                       MCF.MetodoPago, 
                       SPD.TipoCambio, 
                       SPD.Fecha, 
                       MCF.IdMoneda,
					   SPD.FechaPago
                --SELECT * 
                FROM #Facturas MCF
                     JOIN #SumaDePagosDolaresCarso SPD ON MCF.Idfactura = SPD.Idfactura
                WHERE MCF.MetodoPago IN ('PUE','PPD');

         /*PEDIMENTO COMPROBANTE*/
         --Monto dolares Pedimentos y Comprobantes
         INSERT INTO #MontosConvertidosPedimentosCom
         (IdRegistro, 
          IdPedimentoComprobante, 
          MontoRegistro, 
          RC2122, 
          TCD,
		  MesPagoCarso
         )
                SELECT R.IdRegistro, 
                       P.IdPedimentoComprobante, 
                       R.MontoRegistro, 
                       SUM(CASE
                               WHEN ISNULL(R.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END) AS [RC21_22], 
                       TCDP.TipoCambio,
					   T.FechaPago
                FROM dbo.CO_Registro R WITH(NOLOCK)
                     JOIN dbo.FI_PedimentoComprobante P WITH(NOLOCK) ON P.IdPedimentoComprobante = R.IdPedimentoComprobante
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = P.IdContrato
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdPedimentoComprobante = P.IdPedimentoComprobante
                     JOIN dbo.FI_Transfer T WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDP WITH(NOLOCK) ON TCDP.IdMoneda = P.IdMoneda
                                                                            AND DAY(TCDP.Fecha) = DAY(T.FechaPago)
                                                                            AND MONTH(TCDP.Fecha) = MONTH(T.FechaPago)
                                                                            AND YEAR(TCDP.Fecha) = YEAR(T.FechaPago)
                WHERE C.IdContrato = @IdContrato
                      AND DATEFROMPARTS(YEAR(T.FechaPago), MONTH(T.FechaPago), 1) <= @Mes
                      AND R.IdEstado = 10004
                      AND R.CvTipoDocFacturacion IN(2, 3)
                     AND ISNULL(CONVERT(INT, P.ProcesadoSIPAC), 0) = 0
                     AND S.NombreServicio NOT LIKE '%No elegibles%'
                GROUP BY R.IdRegistro, 
                         P.IdPedimentoComprobante, 
                         R.MontoRegistro, 
                         TCDP.TipoCambio,
						 T.FechaPago
         
         /*HOJA 21 CGI para Carso mes de reporte igual a la fecha de pago*/

         INSERT INTO #CGICarso
                SELECT [RF_00], 
                       [RI_00], 
                       [RF01_01], 
                       [RC21_00], 
                       [RC21_01], 
                       [RC21_02], 
                       ROW_NUMBER() OVER(ORDER BY [RC21_11] ASC) AS [RC21_03], 
                       [RC21_04], 
                       [RC21_05], 
                       [RC21_06], 
                       [RC21_07], 
                       [RC21_08], 
                       [RC21_09], 
                       [RC21_10], 
                       [RC21_11], 
                       [RC21_12], 
                       [RC21_13], 
                       [RC21_14], 
                       [RC21_15], 
                       [RC21_16], 
                       [RC21_17], 
                       [RC21_18], 
                       [RC21_19], 
                       [RC21_20], 
                       [RC21_21], 
                       [RC21_22], 
                       [RC21_23], 
                       [RC21_24], 
                       [RC21_25], 
                       [RC21_26], 
                       IdServicio, 
                       IdProgramaActividad, 
                       Inicio, 
                       MesPresentacion
                FROM
                (
                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                            C.NumeroContrato AS [RF01_01], 
                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                            MONTH(R.MesPresentacion) AS [RC21_01], 
                            YEAR(R.MesPresentacion) AS [RC21_02], 
                            NULL AS [RC21_03], 
                            SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                            CASE
                                WHEN R.CvTipoDocFacturacion = 1
                                THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                                ELSE 'NA'
                            END AS [RC21_05], 
                            'NA' AS [RC21_06], 
                            'NA' AS [RC21_07], 
                            TTF.TipoComprobante AS [RC21_08], 
                            TTF.MetodoPago AS [RC21_09], 
                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 1
                                ELSE 0
                            END AS [RC21_13],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                            END AS [RC21_14],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                            END AS [RC21_15],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(I.NombreInstalacion))
                            END AS [RC21_16], 
                            CC.Nivel3 AS [RC21_17], 
                            CC.Descripcion AS [RC21_18], 
                            R.Poliza AS [RC21_19], 
                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                            CASE
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                THEN 1
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                THEN 2
                                ELSE 2
                            END AS [RC21_21], 
                            SUM(CASE
                                    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                         AND TTF.TipoComprobante IN('I', 'N', 'P')
                                    THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))
                                    ELSE 0
                                END) AS [RC21_22], 
                            SUM(ABS(CASE
                                        WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                             AND TTF.TipoComprobante IN('E')
                                        THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))--TTF.RC2122
                                        ELSE 0
                                    END)) AS [RC21_23], 
                            TM.TipoMonedaCorto AS [RC21_24], 
                            TTF.TCD AS [RC21_25],
                            CASE
                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                THEN 1
                                ELSE 2
                            END AS [RC21_26],
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                     FROM dbo.CO_Registro R WITH(NOLOCK)
                          JOIN dbo.FI_Factura F WITH(NOLOCK) ON R.IdFactura = F.IdFactura
                          JOIN #MontosTotalTransferenciaPUE TTF ON TTF.Idfactura = R.IdFactura
                                                                   AND TTF.IdRegistro = R.IdRegistro
                          JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                          JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                          JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                          JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                          JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                          JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                          JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                          JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                          JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                          JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                 AND C.IdContrato = S.IdContrato
                          LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                          LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                          LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                          LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
                          LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                               AND F.IdSubcontratista = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(TTF.MesPagoCarso), MONTH(TTF.MesPagoCarso), 1) <= @Mes
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion = 1
                          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                          AND S.NombreServicio NOT LIKE '%No elegibles%'
                          AND TTF.MetodoPago IN ('PUE','PPD')
                          AND P.IdProgramaActividad = @IdProgramaActividad
                     GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                              LTRIM(RTRIM(C.IDRegFiducidiario)), 
                              C.NumeroContrato, 
                              SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                              MONTH(R.MesPresentacion), 
                              YEAR(R.MesPresentacion), 
                              SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2),
                              CASE
                                  WHEN R.CvTipoDocFacturacion = 1
                                  THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                                  ELSE 'NA'
                              END, 
                              LTRIM(RTRIM(APCNH.id_Actividad)), 
                              LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                              LTRIM(RTRIM(TP.id_Tarea)),
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 1
                                  ELSE 0
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(I.NombreInstalacion))
                              END,
                              CASE
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                  THEN 1
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                  THEN 2
                                  ELSE 2
                              END,
                              CASE
                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                  THEN 1
                                  ELSE 2
                              END, 
                              TTF.TipoComprobante, 
                              TTF.MetodoPago, 
                              CC.Nivel3, 
                              CC.Descripcion, 
                              R.Poliza, 
                              SUBSTRING(R.Comentarios, 0, 299), 
                              TM.TipoMonedaCorto, 
                              TTF.TCD,
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                    --
                    UNION
                    --
                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                            C.NumeroContrato AS [RF01_01], 
                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                            MONTH(R.MesPresentacion) AS [RC21_01], 
                            YEAR(R.MesPresentacion) AS [RC21_02], 
                            NULL AS [RC21_03], 
                            SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                            CASE
                                WHEN R.CvTipoDocFacturacion = 1
                                THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')
                                ELSE 'NA'
                            END AS [RC21_05], 
                            'NA' AS [RC21_06], 
                            'NA' AS [RC21_07], 
                            FCP.TipoComprobante AS [RC21_08], 
                            'PPD' AS [RC21_09], --TTF.MetodoPago
                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 1
                                ELSE 0
                            END AS [RC21_13],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                            END AS [RC21_14],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                            END AS [RC21_15],
                            CASE
                                WHEN R.CostosAtribuiblesAdministracion = 1
                                THEN 'NA'
                                ELSE LTRIM(RTRIM(I.NombreInstalacion))
                            END AS [RC21_16], 
                            CC.Nivel3 AS [RC21_17], 
                            CC.Descripcion AS [RC21_18], 
                            R.Poliza AS [RC21_19], 
                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                            CASE
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                THEN 1
                                WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                THEN 2
                                ELSE 2
                            END AS [RC21_21], 
                            SUM(CASE
                                    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                         AND TTF.TipoComprobante IN('I', 'N', 'P')
                                    THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                                    ELSE 0
                                END) AS [RC21_22], 
                            SUM(ABS(CASE
                                        WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                             AND TTF.TipoComprobante IN('E')
                                        THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2))
                                        ELSE 0
                                    END)) AS [RC21_23], 
                            CASE WHEN TTF.TipoCambioCP = 1
								 THEN 'USD'
								 ELSE 'MXN'
						    END AS [RC21_24],
                            TTF.TipoCambioCP AS [RC21_25],
                            CASE
                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                THEN 1
                                ELSE 2
                            END AS [RC21_26],
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.CO_Registro R WITH(NOLOCK)
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = R.IdFactura
                         JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON F.UUID = CPDR.IdDocumento
                         JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                         JOIN #MontosTotalTransferenciaPPD TTF WITH(NOLOCK) ON CP.IdFactura = TTF.IdFacturaCP
                                                                               AND R.IdRegistro = TTF.IdRegistro
                         JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TTF.IdFacturaCP = FCP.IdFactura
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON F.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND F.IdSubcontratista = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(TTF.MesPagoCarso), MONTH(TTF.MesPagoCarso), 1) <= @Mes
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion = 1
                          AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                          AND S.NombreServicio NOT LIKE '%No elegibles%'
                           AND FCP.UUID NOT IN
                     (
                         SELECT UUID
                         FROM #uuidNoReportar
                     )
                           AND FCP.UUID NOT IN
                     (
                         SELECT ControlF.UUID
                         FROM dbo.FI_ControlPPDComplementos ControlF
                         WHERE ControlF.IdContrato = @IdContrato
                     )
                          AND P.IdProgramaActividad = @IdProgramaActividad
                     GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                              LTRIM(RTRIM(C.IDRegFiducidiario)), 
                              C.NumeroContrato, 
                              SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                              MONTH(R.MesPresentacion), 
                              YEAR(R.MesPresentacion), 
                              SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2),
                              CASE
                                  WHEN R.CvTipoDocFacturacion = 1
                                  THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO')
                                  ELSE 'NA'
                              END, 
                              LTRIM(RTRIM(APCNH.id_Actividad)), 
                              LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                              LTRIM(RTRIM(TP.id_Tarea)),
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 1
                                  ELSE 0
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                              END,
                              CASE
                                  WHEN R.CostosAtribuiblesAdministracion = 1
                                  THEN 'NA'
                                  ELSE LTRIM(RTRIM(I.NombreInstalacion))
                              END,
                              CASE
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                  THEN 1
                                  WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                  THEN 2
                                  ELSE 2
                              END,
                              CASE
                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                  THEN 1
                                  ELSE 2
                              END, 
                              FCP.TipoComprobante,
                              CC.Nivel3, 
                              CC.Descripcion, 
                              R.Poliza, 
                              SUBSTRING(R.Comentarios, 0, 299),
                              CASE WHEN TTF.TipoCambioCP = 1
								   THEN 'USD'
								   ELSE 'MXN'
						      END,
                              TTF.TipoCambioCP,
                              S.IdServicio, 
                              P.IdProgramaActividad, 
                              AC.Inicio, 
                              R.MesPresentacion
                    --
                    UNION
                    --
                    SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                           LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                           C.NumeroContrato AS [RF01_01], 
                           SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                           MONTH(R.MesPresentacion) AS [RC21_01], 
                           YEAR(R.MesPresentacion) AS [RC21_02], 
                           NULL AS [RC21_03], 
                           SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04], 
                           'NA' AS [RC21_05],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 3
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 2
                               THEN PC.NumeroPedimento
                           END AS [RC21_06],
                           CASE
                               WHEN R.CvTipoDocFacturacion = 1
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 2
                               THEN 'NA'
                               WHEN R.CvTipoDocFacturacion = 3
                               THEN PC.IdDocFacturacionSIPAC
                           END AS [RC21_07], 
                           'NA' AS [RC21_08], 
                           'PUE' AS [RC21_09], 
                           LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                           LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                           LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 1
                               ELSE 0
                           END AS [RC21_13],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                           END AS [RC21_14],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                           END AS [RC21_15],
                           CASE
                               WHEN R.CostosAtribuiblesAdministracion = 1
                               THEN 'NA'
                               ELSE LTRIM(RTRIM(I.NombreInstalacion))
                           END AS [RC21_16], 
                           CC.Nivel3 AS [RC21_17], 
                           CC.Descripcion AS [RC21_18], 
                           R.Poliza AS [RC21_19], 
                           SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20],
                           CASE
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                               THEN 1
                               WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                               THEN 2
                               ELSE 2
                           END AS [RC21_21], 
                           SUM(CASE
                                   WHEN ISNULL(MP.MontoRegistro, 0) <> 0
                                   THEN MP.RC2122
                                   ELSE 0
                               END) AS [RC21_22], 
                           0 AS [RC21_23], 
                           TM.TipoMonedaCorto AS [RC21_24], 
                           MP.TCD AS [RC21_25],
                           CASE
                               WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                               THEN 1
                               ELSE 2
                           END AS [RC21_26], 
                           S.IdServicio, 
                           P.IdProgramaActividad, 
                           AC.Inicio, 
                           R.MesPresentacion
                    FROM dbo.FI_Transfer TR WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                         JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                                                             AND PC.IdContrato = TR.IdContrato
                         JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                         JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                         JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                         JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                         JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                         JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                         JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                         JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                         JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                         JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion
                         JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                                                                AND C.IdContrato = S.IdContrato
                         JOIN #MontosConvertidosPedimentosCom MP WITH(NOLOCK) ON MP.IdRegistro = R.IdRegistro
                                                                                 AND MP.idPedimentoComprobante = R.IdPedimentoComprobante
                         LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo
                         LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento
                         LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                         LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda
                         LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista
                                                                              AND PC.IdSubcontratistaExportador = RE.IdRelacionada
                    WHERE C.IdContrato = @IdContrato
                          AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) <= @Mes
                          AND R.IdEstado = 10004
                          AND R.CvTipoDocFacturacion IN(2, 3)
                         AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                         AND S.NombreServicio NOT LIKE '%No elegibles%'
                         AND P.IdProgramaActividad = @IdProgramaActividad
                    GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                             LTRIM(RTRIM(C.IDRegFiducidiario)), 
                             C.NumeroContrato, 
                             SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                             MONTH(R.MesPresentacion), 
                             YEAR(R.MesPresentacion), 
                             SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2),
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 3
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 2
                                 THEN PC.NumeroPedimento
                             END,
                             CASE
                                 WHEN R.CvTipoDocFacturacion = 1
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 2
                                 THEN 'NA'
                                 WHEN R.CvTipoDocFacturacion = 3
                                 THEN PC.IdDocFacturacionSIPAC
                             END, 
                             LTRIM(RTRIM(APCNH.id_Actividad)), 
                             LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                             LTRIM(RTRIM(TP.id_Tarea)),
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 1
                                 ELSE 0
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                             END,
                             CASE
                                 WHEN R.CostosAtribuiblesAdministracion = 1
                                 THEN 'NA'
                                 ELSE LTRIM(RTRIM(I.NombreInstalacion))
                             END, 
                             CC.Nivel3, 
                             CC.Descripcion, 
                             R.Poliza, 
                             SUBSTRING(R.Comentarios, 0, 299),
                             CASE
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                                 THEN 1
                                 WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                                 THEN 2
                                 ELSE 2
                             END,
                             TM.TipoMonedaCorto, 
                             MP.TCD,
                             CASE
                                 WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                                 THEN 1
                                 ELSE 2
                             END, 
                             S.IdServicio, 
                             P.IdProgramaActividad, 
                             AC.Inicio, 
                             R.MesPresentacion
                ) AS Resultado;

         /*Base para hacer pivote*/

         INSERT INTO #DATOS
         (IdTipoProgramaActividad, 
          IdActividadPetrolera, 
          IdSubactividadPetrolera, 
          IdTareaPetrolera, 
          IdServicio, 
          MontoRegistro, 
          MesPresentacion, 
          InicioPresup, 
          ANIO, 
          MES, 
          MesPresentacionOrig
         )
                SELECT TPA.IdTipoProgramaActividad, 
                       AP.IdActividadPetrolera, 
                       SAP.IdSubactividadPetrolera, 
                       TP.IdTareaPetrolera, 
                       S.IdServicio, 
                       H21.RC21_22, 
                       H21.MesPresentacion, 
                       H21.Inicio, 
                       H21.RC21_01, 
                       H21.RC21_02, 
                       H21.MesPresentacion
                FROM #CGICarso H21 WITH(NOLOCK)
                     JOIN dbo.CO_ActividadPetroleraCNH AP WITH(NOLOCK) ON AP.id_Actividad = H21.RC21_10
                     JOIN dbo.CO_SubactividadPetrolera SAP WITH(NOLOCK) ON SAP.[id_Sub-actividad] = H21.RC21_11
                     JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON TP.id_Tarea = H21.RC21_12
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = H21.IdServicio
                     JOIN dbo.CO_ProgramaActividad PA WITH(NOLOCK) ON H21.IdProgramaActividad = PA.IdProgramaActividad
                     JOIN dbo.CO_TipoProgramaActividad TPA WITH(NOLOCK) ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                     JOIN dbo.CO_ActSubTareaPetroleraCNH ASTP WITH(NOLOCK) ON AP.IdActividadPetrolera = ASTP.IdActividadPetrolera
                                                                              AND SAP.IdSubactividadPetrolera = ASTP.IdSubactividadPetrolera
                                                                              AND TP.IdTareaPetrolera = ASTP.IdTareaPetrolera;
END
/*
Termina ajuste para Carso
*/
         /*Calcular primer mes para vaciar los datos en la plantilla*/

         DECLARE @diferenciames INT= 0;
         SELECT @diferenciames = 1 - MONTH(InicioPresup)
         FROM #DATOS;
         --
         UPDATE #DATOS
           SET 
               MesPresentacion = DATEADD(month, @diferenciames, MesPresentacion);
         --
         UPDATE #DATOS
           SET 
               anio = YEAR(MesPresentacion), 
               mes = MONTH(MesPresentacion);
         --
         UPDATE #DATOS
           SET 
               MES = CASE
                         WHEN DATEDIFF(MM, InicioPresup, MesPresentacionOrig) >= 12
                         THEN MES + 12
                         ELSE MES
                     END;

         /*PIVOT OMITIDO*/

         IF(@IdContrato = 10036
            AND @IdProgramaActividad = 10100)
             BEGIN
                 INSERT INTO #PIVOT
                        SELECT anio, 
                               Mes, 
                               MesPresentacion, 
                               IdTipoProgramaActividad, 
                               IdActividadPetrolera, 
                               IdSubactividadPetrolera, 
                               IdTareaPetrolera, 
                               IdServicio, 
                               InicioPresup, 
                               MontoRegistro
                        FROM #DATOS
                        WHERE MesPresentacion >= '2019-01-01';
             END;
             ELSE
             BEGIN
                 INSERT INTO #PIVOT
                 SELECT anio, 
                        Mes, 
                        MesPresentacion, 
                        IdTipoProgramaActividad, 
                        IdActividadPetrolera, 
                        IdSubactividadPetrolera, 
                        IdTareaPetrolera, 
                        IdServicio, 
                        InicioPresup, 
                        MontoRegistro
                 FROM #DATOS;
             END;

         /*PRIMER PIVOT MESES EN COLUMNAS*/

         INSERT INTO #RESULTADO
                SELECT IdTipoProgramaActividad, 
                       IdActividadPetrolera, 
                       IdSubactividadPetrolera, 
                       IdTareaPetrolera, 
                       IdServicio, 
                       SUM(ISNULL([1], 0)), 
                       SUM(ISNULL([2], 0)), 
                       SUM(ISNULL([3], 0)), 
                       SUM(ISNULL([4], 0)), 
                       SUM(ISNULL([5], 0)), 
                       SUM(ISNULL([6], 0)), 
                       SUM(ISNULL([7], 0)), 
                       SUM(ISNULL([8], 0)), 
                       SUM(ISNULL([9], 0)), 
                       SUM(ISNULL([10], 0)), 
                       SUM(ISNULL([11], 0)), 
                       SUM(ISNULL([12], 0)), 
                       SUM(ISNULL([13], 0)), 
                       SUM(ISNULL([14], 0)), 
                       SUM(ISNULL([15], 0)), 
                       SUM(ISNULL([16], 0)), 
                       SUM(ISNULL([17], 0)), 
                       SUM(ISNULL([18], 0)), 
                       SUM(ISNULL([19], 0)), 
                       SUM(ISNULL([20], 0)), 
                       SUM(ISNULL([21], 0)), 
                       SUM(ISNULL([22], 0)), 
                       SUM(ISNULL([23], 0)), 
                       SUM(ISNULL([24], 0)), 
                       SUM(ISNULL([25], 0))
                FROM
                (
                    SELECT IdTipoProgramaActividad, 
                           IdActividadPetrolera, 
                           IdSubactividadPetrolera, 
                           IdTareaPetrolera, 
                           IdServicio, 
                           InicioPresup, 
                           Mes, 
                           ANIO, 
                           ISNULL(MontoRegistro, 0) AS MontoRegistro
                    FROM #PIVOT
                ) AS SourceTable PIVOT(SUM(MontoRegistro) FOR MES IN([1], 
                                                                     [2], 
                                                                     [3], 
                                                                     [4], 
                                                                     [5], 
                                                                     [6], 
                                                                     [7], 
                                                                     [8], 
                                                                     [9], 
                                                                     [10], 
                                                                     [11], 
                                                                     [12], 
                                                                     [13], 
                                                                     [14], 
                                                                     [15], 
                                                                     [16], 
                                                                     [17], 
                                                                     [18], 
                                                                     [19], 
                                                                     [20], 
                                                                     [21], 
                                                                     [22], 
                                                                     [23], 
                                                                     [24], 
                                                                     [25])) AS PV1
                GROUP BY IdTipoProgramaActividad, 
                         IdActividadPetrolera, 
                         IdSubactividadPetrolera, 
                         IdTareaPetrolera, 
                         IdServicio;

         /*SUMA DEL TOTAL ACUMULADO*/

         SELECT UPPER(dbo.RemoverAcentos(TPA.TipoPrograma)) AS TipoPrograma, 
                UPPER(dbo.RemoverAcentos(LTRIM(AP.id_Actividad)+' '+LTRIM(AP.DescripcionActividadPetrolera))) AS DescripcionActividadPetrolera, 
                UPPER(dbo.RemoverAcentos(LTRIM(SAP.[id_Sub-actividad])+' '+LTRIM(SAP.SubactividadPetrolera))) AS SubactividadPetrolera, 
                UPPER(dbo.RemoverAcentos(LTRIM(TP.id_Tarea)+' '+LTRIM(TP.TareaPetrolera))) AS TareaPetrolera, 
                UPPER(dbo.RemoverAcentos(S.NombreServicio)) AS NombreServicio, 
                R.MONAC01, 
                R.MONAC02, 
                R.MONAC03, 
                R.MONAC04, 
                R.MONAC05, 
                R.MONAC06, 
                R.MONAC07, 
                R.MONAC08, 
                R.MONAC09, 
                R.MONAC10, 
                R.MONAC11, 
                R.MONAC12, 
                R.MONAC13, 
                R.MONAC14, 
                R.MONAC15, 
                R.MONAC16, 
                R.MONAC17, 
                R.MONAC18, 
                R.MONAC19, 
                R.MONAC20, 
                R.MONAC21, 
                R.MONAC22, 
                R.MONAC23, 
                R.MONAC24, 
                R.MONAC25, 
                FORMAT((R.MONAC01 + R.MONAC02 + R.MONAC03 + R.MONAC04 + R.MONAC05 + R.MONAC06 + R.MONAC07 + R.MONAC08 + R.MONAC09 + R.MONAC10 + R.MONAC11 + R.MONAC12 + R.MONAC13 + R.MONAC14 + R.MONAC15 + R.MONAC16 + R.MONAC17 + R.MONAC18 + R.MONAC19 + R.MONAC20 + R.MONAC21 + R.MONAC22 + R.MONAC23 + R.MONAC24 + R.MONAC25), '#,#0.0000') AS Total, 
                TPA.IdTipoProgramaActividad, 
                AP.IdActividadPetrolera, 
                SAP.IdSubactividadPetrolera, 
                TP.IdTareaPetrolera, 
                S.IdServicio
             INTO #tmpResultFinal
         FROM #RESULTADO R WITH(NOLOCK)
              JOIN dbo.CO_ActividadPetroleraCNH AP WITH(NOLOCK) ON AP.IdActividadPetrolera = R.IdActividadPetrolera
              JOIN dbo.CO_SubactividadPetrolera SAP WITH(NOLOCK) ON SAP.IdSubactividadPetrolera = R.IdSubactividadPetrolera
              JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON TP.IdTareaPetrolera = R.IdTareaPetrolera
              JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = R.IdServicio
              JOIN dbo.CO_TipoProgramaActividad TPA WITH(NOLOCK) ON TPA.IdTipoProgramaActividad = R.IdTipoProgramaActividad
              JOIN dbo.CO_ActSubTareaPetroleraCNH ASTP WITH(NOLOCK) ON AP.IdActividadPetrolera = ASTP.IdActividadPetrolera
                                                                       AND SAP.IdSubactividadPetrolera = ASTP.IdSubactividadPetrolera
                                                                       AND TP.IdTareaPetrolera = ASTP.IdTareaPetrolera
         ORDER BY TipoPrograma, 
                  DescripcionActividadPetrolera, 
                  SubactividadPetrolera, 
                  TareaPetrolera;

         /*RESULTADO QUE SE VACIA EN LA PLANTILLA EXCEL*/

         SELECT TipoPrograma, 
                DescripcionActividadPetrolera, 
                SubactividadPetrolera, 
                TareaPetrolera, 
                NombreServicio, 
                TOT01 = FORMAT(MONAC01, '#,#0.0000'), 
                TOT02 = FORMAT(MONAC02, '#,#0.0000'), 
                TOT03 = FORMAT(MONAC03, '#,#0.0000'), 
                TOT04 = FORMAT(MONAC04, '#,#0.0000'), 
                TOT05 = FORMAT(MONAC05, '#,#0.0000'), 
                TOT06 = FORMAT(MONAC06, '#,#0.0000'), 
                TOT07 = FORMAT(MONAC07, '#,#0.0000'), 
                TOT08 = FORMAT(MONAC08, '#,#0.0000'), 
                TOT09 = FORMAT(MONAC09, '#,#0.0000'), 
                TOT10 = FORMAT(MONAC10, '#,#0.0000'), 
                TOT11 = FORMAT(MONAC11, '#,#0.0000'), 
                TOT12 = FORMAT(MONAC12, '#,#0.0000'), 
                TOT13 = FORMAT(MONAC13, '#,#0.0000'), 
                TOT14 = FORMAT(MONAC14, '#,#0.0000'), 
                TOT15 = FORMAT(MONAC15, '#,#0.0000'), 
                TOT16 = FORMAT(MONAC16, '#,#0.0000'), 
                TOT17 = FORMAT(MONAC17, '#,#0.0000'), 
                TOT18 = FORMAT(MONAC18, '#,#0.0000'), 
                TOT19 = FORMAT(MONAC19, '#,#0.0000'), 
                TOT20 = FORMAT(MONAC20, '#,#0.0000'), 
                TOT21 = FORMAT(MONAC21, '#,#0.0000'), 
                TOT22 = FORMAT(MONAC22, '#,#0.0000'), 
                TOT23 = FORMAT(MONAC23, '#,#0.0000'), 
                TOT24 = FORMAT(MONAC24, '#,#0.0000'), 
                TOT25 = FORMAT(MONAC25, '#,#0.0000'), 
                Total, 
                IdTipoProgramaActividad, 
                IdActividadPetrolera, 
                IdSubactividadPetrolera, 
                IdTareaPetrolera, 
                IdServicio
         FROM #tmpResultFinal
         ORDER BY TipoPrograma, 
                  DescripcionActividadPetrolera, 
                  SubactividadPetrolera, 
                  TareaPetrolera;

		-- RETORNA LOS MESES EN FORMA DE LISTA DESDE LA FECHA INICIO HASTA LA FECHA FIN
	SET Language 'Spanish';
	declare @start DATE = getdate()
	declare @end DATE = getdate()

	SELECT @start =  isnull(Inicio, getdate()), @end = isnull(dateadd(month, 25 , inicio), getdate()) FROM CO_PeriodoContrato WHERE IdPeriodo = @pIdPeriodo
		
	;with months (date)
	AS
	(
	SELECT @start
	UNION ALL
	SELECT DATEADD(month, 1, date)
	from months
	where DATEADD(month, 1, date) < @end
	)
	select     CONCAT(DATENAME(mm, date), '-' , DATEPART(yy, date)) as Meses
	from months
END;