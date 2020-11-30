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
-- =============================================
CREATE PROCEDURE [dbo].[SP_CNH_FormatoPlanes_Inversion_2019_MC]
--exec[SP_CNH_FormatoPlanes_Inversion_2019] 0,1,'2019-07-01',10058
--exec[SP_CNH_FormatoPlanes_Inversion_2019] 0,1,'2019-10-01',10100
--exec[SP_CNH_FormatoPlanes_Inversion_2019] 0,1,'2018-08-01',10008
-- Add the parameters for the stored procedure here
@IdContrato          INT, 
@IdUsuario           INT, 
@Mes                 DATE, 
@IdProgramaActividad INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here

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

         /**/

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
          MonoRegistro            FLOAT
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

         /**/

         CREATE TABLE #RESULTADO
         (IdLinea                 INT IDENTITY(1, 1) PRIMARY KEY, 
          IdTipoProgramaActividad INT, 
          IdActividadPetrolera    INT, 
          IdSubactividadPetrolera INT, 
          IdTareaPetrolera        INT, 
          IdServicio              INT, 
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
          MONAC20                 FLOAT--, 
         --MONAC21                 FLOAT, 
         --MONAC22                 FLOAT, 
         --MONAC23                 FLOAT, 
         --MONAC24                 FLOAT, 
         --MONAC25                 FLOAT
         --MOEXT01                 FLOAT, 
         --MOEXT02                 FLOAT, 
         --MOEXT03                 FLOAT, 
         --MOEXT04                 FLOAT, 
         --MOEXT05                 FLOAT, 
         --MOEXT06                 FLOAT, 
         --MOEXT07                 FLOAT, 
         --MOEXT08                 FLOAT, 
         --MOEXT09                 FLOAT, 
         --MOEXT10                 FLOAT, 
         --MOEXT11                 FLOAT, 
         --MOEXT12                 FLOAT, 
         --MOEXT13                 FLOAT, 
         --MOEXT14                 FLOAT, 
         --MOEXT15                 FLOAT, 
         --MOEXT16                 FLOAT, 
         --MOEXT17                 FLOAT, 
         --MOEXT18                 FLOAT, 
         --MOEXT19                 FLOAT, 
         --MOEXT20                 FLOAT, 
         --BINAC01                 FLOAT, 
         --BINAC02                 FLOAT, 
         --BINAC03                 FLOAT, 
         --BINAC04                 FLOAT, 
         --BINAC05                 FLOAT, 
         --BINAC06                 FLOAT, 
         --BINAC07                 FLOAT, 
         --BINAC08                 FLOAT, 
         --BINAC09                 FLOAT, 
         --BINAC10                 FLOAT, 
         --BINAC11                 FLOAT, 
         --BINAC12                 FLOAT, 
         --BINAC13                 FLOAT, 
         --BINAC14                 FLOAT, 
         --BINAC15                 FLOAT, 
         --BINAC16                 FLOAT, 
         --BINAC17                 FLOAT, 
         --BINAC18                 FLOAT, 
         --BINAC19                 FLOAT, 
         --BINAC20                 FLOAT, 
         --BIEXT01                 FLOAT, 
         --BIEXT02                 FLOAT, 
         --BIEXT03                 FLOAT, 
         --BIEXT04                 FLOAT, 
         --BIEXT05                 FLOAT, 
         --BIEXT06                 FLOAT, 
         --BIEXT07                 FLOAT, 
         --BIEXT08                 FLOAT, 
         --BIEXT09                 FLOAT, 
         --BIEXT10                 FLOAT, 
         --BIEXT11                 FLOAT, 
         --BIEXT12                 FLOAT, 
         --BIEXT13                 FLOAT, 
         --BIEXT14                 FLOAT, 
         --BIEXT15                 FLOAT, 
         --BIEXT16                 FLOAT, 
         --BIEXT17                 FLOAT, 
         --BIEXT18                 FLOAT, 
         --BIEXT19                 FLOAT, 
         --BIEXT20                 FLOAT, 
         --SERNAC01                FLOAT, 
         --SERNAC02                FLOAT, 
         --SERNAC03                FLOAT, 
         --SERNAC04                FLOAT, 
         --SERNAC05                FLOAT, 
         --SERNAC06                FLOAT, 
         --SERNAC07                FLOAT, 
         --SERNAC08                FLOAT, 
         --SERNAC09                FLOAT, 
         --SERNAC10                FLOAT, 
         --SERNAC11                FLOAT, 
         --SERNAC12                FLOAT, 
         --SERNAC13                FLOAT, 
         --SERNAC14                FLOAT, 
         --SERNAC15                FLOAT, 
         --SERNAC16                FLOAT, 
         --SERNAC17                FLOAT, 
         --SERNAC18                FLOAT, 
         --SERNAC19                FLOAT, 
         --SERNAC20                FLOAT, 
         --SEREXT01                FLOAT, 
         --SEREXT02                FLOAT, 
         --SEREXT03                FLOAT, 
         --SEREXT04                FLOAT, 
         --SEREXT05                FLOAT, 
         --SEREXT06                FLOAT, 
         --SEREXT07                FLOAT, 
         --SEREXT08                FLOAT, 
         --SEREXT09                FLOAT, 
         --SEREXT10                FLOAT, 
         --SEREXT11                FLOAT, 
         --SEREXT12                FLOAT, 
         --SEREXT13                FLOAT, 
         --SEREXT14                FLOAT, 
         --SEREXT15                FLOAT, 
         --SEREXT16                FLOAT, 
         --SEREXT17                FLOAT, 
         --SEREXT18                FLOAT, 
         --SEREXT19                FLOAT, 
         --SEREXT20                FLOAT, 
         --CAPNAC01                FLOAT, 
         --CAPNAC02                FLOAT, 
         --CAPNAC03                FLOAT, 
         --CAPNAC04                FLOAT, 
         --CAPNAC05                FLOAT, 
         --CAPNAC06                FLOAT, 
         --CAPNAC07                FLOAT, 
         --CAPNAC08                FLOAT, 
         --CAPNAC09                FLOAT, 
         --CAPNAC10                FLOAT, 
         --CAPNAC11                FLOAT, 
         --CAPNAC12                FLOAT, 
         --CAPNAC13                FLOAT, 
         --CAPNAC14                FLOAT, 
         --CAPNAC15                FLOAT, 
         --CAPNAC16                FLOAT, 
         --CAPNAC17                FLOAT, 
         --CAPNAC18                FLOAT, 
         --CAPNAC19                FLOAT, 
         --CAPNAC20                FLOAT, 
         --CAPEXT01                FLOAT, 
         --CAPEXT02                FLOAT, 
         --CAPEXT03                FLOAT, 
         --CAPEXT04                FLOAT, 
         --CAPEXT05                FLOAT, 
         --CAPEXT06                FLOAT, 
         --CAPEXT07                FLOAT, 
         --CAPEXT08                FLOAT, 
         --CAPEXT09                FLOAT, 
         --CAPEXT10                FLOAT, 
         --CAPEXT11                FLOAT, 
         --CAPEXT12                FLOAT, 
         --CAPEXT13                FLOAT, 
         --CAPEXT14                FLOAT, 
         --CAPEXT15                FLOAT, 
         --CAPEXT16                FLOAT, 
         --CAPEXT17                FLOAT, 
         --CAPEXT18                FLOAT, 
         --CAPEXT19                FLOAT, 
         --CAPEXT20                FLOAT, 
         --TRANSTEC01              FLOAT, 
         --TRANSTEC02              FLOAT, 
         --TRANSTEC03              FLOAT, 
         --TRANSTEC04              FLOAT, 
         --TRANSTEC05              FLOAT, 
         --TRANSTEC06              FLOAT, 
         --TRANSTEC07              FLOAT, 
         --TRANSTEC08              FLOAT, 
         --TRANSTEC09              FLOAT, 
         --TRANSTEC10              FLOAT, 
         --TRANSTEC11              FLOAT, 
         --TRANSTEC12              FLOAT, 
         --TRANSTEC13              FLOAT, 
         --TRANSTEC14              FLOAT, 
         --TRANSTEC15              FLOAT, 
         --TRANSTEC16              FLOAT, 
         --TRANSTEC17              FLOAT, 
         --TRANSTEC18              FLOAT, 
         --TRANSTEC19              FLOAT, 
         --TRANSTEC20              FLOAT, 
         --INFRASOC01              FLOAT, 
         --INFRASOC02              FLOAT, 
         --INFRASOC03              FLOAT, 
         --INFRASOC04              FLOAT, 
         --INFRASOC05              FLOAT, 
         --INFRASOC06              FLOAT, 
         --INFRASOC07              FLOAT, 
         --INFRASOC08              FLOAT, 
         --INFRASOC09              FLOAT, 
         --INFRASOC10              FLOAT, 
         --INFRASOC11              FLOAT, 
         --INFRASOC12              FLOAT, 
         --INFRASOC13              FLOAT, 
         --INFRASOC14              FLOAT, 
         --INFRASOC15              FLOAT, 
         --INFRASOC16              FLOAT, 
         --INFRASOC17              FLOAT, 
         --INFRASOC18              FLOAT, 
         --INFRASOC19              FLOAT, 
         --INFRASOC20              FLOAT
         );

         /*TODAS LAS FACTURAS*/

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
                FROM dbo.CO_Registro R
                     JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                     JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                     JOIN dbo.CO_LineaPresupuestoMes LPM ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Servicio S ON S.IdServicio = LPM.IdServicio
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = F.IdMoneda
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

         /*Facturas Con Tipo de Cambio de Transferencia*/

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
          IdRegistro      INT
         );
         --
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
                FROM dbo.FI_Transfer T
                     JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR ON CPDR.IdDocumento = FCPDR.UUID
                                                  AND F.IdContrato = FCPDR.IdContrato
                     JOIN dbo.PV_TipoMoneda TM ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
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
                FROM dbo.FI_Transfer T
                     JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_Factura F ON CP.IdFactura = F.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                     JOIN dbo.FI_Factura FCPDR ON CPDR.IdDocumento = FCPDR.UUID
                                                  AND F.IdContrato = FCPDR.IdContrato
                     JOIN dbo.PV_TipoMoneda TM ON CP.MonedaP = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
                                                              AND TCD.IdMoneda <> FCPDR.IdMoneda
                                                              AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                              AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                              AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
                      AND TCD.IdMoneda <> FCPDR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         CP.FormaDePagoP, 
                         CP.MonedaP, 
                         F.TipoComprobante, 
                         CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)), 
                         #Facturas.IdRegistro;
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
          IdMoneda        INT
         );
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
                SELECT MCF.IdRegistro, 
                       MCF.UUID, 
                       MCF.Idfactura, 
                       MCF.MontoRegistro, 
                       MCF.TipoComprobante, 
                       SUM(CASE
                               WHEN ISNULL(MCF.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(MCF.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END), 
                       MCF.MetodoPago, 
                       TCD.TipoCambio, 
                       TCD.Fecha, 
                       MCF.IdMoneda
                FROM #Facturas MCF
                     JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = MCF.Idfactura
                     JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = MCF.IdMoneda
                                                              AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                              AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                              AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE MCF.MetodoPago = 'PUE'
                GROUP BY MCF.IdRegistro, 
                         MCF.UUID, 
                         MCF.Idfactura, 
                         MCF.MontoRegistro, 
                         MCF.TipoComprobante, 
                         MCF.MetodoPago, 
                         TCD.TipoCambio, 
                         TCD.Fecha, 
                         MCF.IdMoneda;

/*DECLARE 
	@IdProgramaActividad INT,
	@MesReporte	DATE

SELECT
	@IdProgramaActividad = 10058,
	@MesReporte	=	'20180801'*/

         IF(@IdContrato = 10036)
             BEGIN
                 INSERT INTO #DATOS
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                   THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.FI_Transfer T
                             JOIN dbo.FI_TransferFactura TF ON T.IdTransferencia = TF.IdTransfer
                             JOIN dbo.FI_Factura F ON TF.IdFactura = F.IdFactura
                                                      AND T.IdContrato = F.IdContrato
                             JOIN dbo.CO_Registro R ON F.IdFactura = R.IdFactura
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                                                       AND F.IdContrato = S.IdContrato
                             JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda = TCD.IdMoneda
                                                                 AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                 AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                 AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= '2019-08-01'
                              AND R.IdEstado = 10004
                              AND R.CvTipoDocFacturacion = 1
                              AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                              AND S.NombreServicio NOT LIKE '%No elegibles%'
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro,
                                 CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                     ELSE 0
                                 END
                        UNION
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                   THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.CO_Registro R
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.FI_PedimentoComprobante PC ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                             JOIN dbo.FI_TransferFactura TF ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                             JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                                       AND PC.IdContrato = T.IdContrato
                             JOIN dbo.CO_TipoCambioDiario TCD ON PC.IdMoneda = TCD.IdMoneda
                                                                 AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                 AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                 AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= @Mes
                              AND R.IdEstado = 10004
                              AND R.CvTipoDocFacturacion IN(2, 3)
                             AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                             AND S.NombreServicio NOT LIKE '%No elegibles%'
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro,
                                 CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                     ELSE 0
                                 END
                        UNION
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                        AND TTF.TipoComprobante IN('I', 'N', 'P')
                                   THEN TTF.RC2122
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.FI_Transfer T
                             JOIN dbo.FI_TransferFactura TF ON T.IdTransferencia = TF.IdTransfer
                             JOIN dbo.FI_Factura F ON TF.IdFactura = F.IdFactura
                                                      AND T.IdContrato = F.IdContrato
                             JOIN dbo.CO_Registro R ON F.IdFactura = R.IdFactura
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                                                       AND F.IdContrato = S.IdContrato
                             JOIN #MontosTotalTransferenciaPUE TTF ON TTF.Idfactura = R.IdFactura
                                                                      AND TTF.IdRegistro = R.IdRegistro
                             JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda = TCD.IdMoneda
                                                                 AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                 AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                 AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= @Mes
                              AND R.IdEstado = 10004
                              AND R.CvTipoDocFacturacion = 1
                              AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                              AND S.NombreServicio NOT LIKE '%No elegibles%'
                              AND TTF.MetodoPago = 'PUE'
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro,
                                 CASE
                                     WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                          AND TTF.TipoComprobante IN('I', 'N', 'P')
                                     THEN TTF.RC2122
                                     ELSE 0
                                 END
                        UNION
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                        AND TTF.TipoComprobante IN('I', 'N', 'P')
                                   THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.CO_Registro R
                             JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                             JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
                             JOIN dbo.FI_ComplementoDePago CP ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                             JOIN #MontosTotalTransferenciaPPD TTF ON CP.IdFactura = TTF.IdFacturaCP
                                                                      AND R.IdRegistro = TTF.IdRegistro
                             JOIN dbo.FI_Factura FCP ON CP.IdFactura = FCP.IdFactura
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                                                       AND F.IdContrato = S.IdContrato
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= @Mes
                              AND R.IdEstado = 10004
                              AND R.CvTipoDocFacturacion = 1
                              AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                              AND S.NombreServicio NOT LIKE '%No elegibles%'
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro,
                                 CASE
                                     WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                                          AND TTF.TipoComprobante IN('I', 'N', 'P')
                                     THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2))
                                     ELSE 0
                                 END;
             END;
         IF(@IdContrato <> 10036)
             BEGIN
                 INSERT INTO #DATOS
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                   THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.CO_Registro R
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                             JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
                             JOIN dbo.FI_ComplementoDePago CP ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                             JOIN dbo.FI_Factura FCP ON CP.IdFactura = FCP.IdFactura
                             JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = FCP.IdFactura
                             JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                                       AND F.IdContrato = T.IdContrato
                             JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda = TCD.IdMoneda
                                                                 AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                 AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                 AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= @Mes
                              AND R.CvTipoDocFacturacion = 1
                              AND S.NombreServicio NOT LIKE '%No elegibles%'
                              AND R.IdEstado = 10004
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro,
                                 CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                     ELSE 0
                                 END
                        UNION
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                   THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.CO_Registro R
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                             JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                             JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                                       AND F.IdContrato = T.IdContrato
                             JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda = TCD.IdMoneda
                                                                 AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                 AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                 AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= @Mes
                              AND R.CvTipoDocFacturacion = 1
                              AND (F.MetodoPago LIKE '%exhibi%'
                                   OR F.MetodoPago LIKE '%PUE%'
                                   OR F.FormaPago LIKE '%exhibi%'
                                   OR F.FormaPago LIKE '%PUE%')
                              AND S.NombreServicio NOT LIKE '%No elegibles%'
                              AND R.IdEstado = 10004
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro, 
                                 --(
                                 CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                     ELSE 0
                                 END
                        UNION
                        SELECT PA.IdTipoProgramaActividad, 
                               LPM.IdActividadPetrolera, 
                               LPM.IdSubactividadPetrolera, 
                               LPM.IdTareaPetrolera, 
                               LPM.IdServicio, 
                               R.IdGastoRubro,
                               CASE
                                   WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                   THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                   ELSE 0
                               END AS MontoRegistro, 
                               R.MesPresentacion, 
                               ISNULL(R.PCN, 0) AS PCN, 
                               AC.Inicio AS [InicioPresup], 
                               YEAR(R.MesPresentacion) AS [ANIO], 
                               MONTH(R.MesPresentacion) AS [MES], 
                               R.IdRegistro, 
                               R.MesPresentacion
                        FROM dbo.CO_Registro R
                             JOIN dbo.CO_LineaPresupuestoMes LPM ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                             JOIN dbo.FI_PedimentoComprobante PC ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                             JOIN dbo.FI_TransferFactura TF ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                             JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                                       AND PC.IdContrato = T.IdContrato
                             JOIN dbo.CO_TipoCambioDiario TCD ON PC.IdMoneda = TCD.IdMoneda
                                                                 AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                 AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                 AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                             JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                        WHERE P.IdProgramaActividad = @IdProgramaActividad
                              AND R.MesPresentacion <= @Mes
                              AND R.CvTipoDocFacturacion IN(2, 3)
                             AND S.NombreServicio NOT LIKE '%No elegibles%'
                             AND R.IdEstado = 10004
                        GROUP BY ISNULL(R.PCN, 0), 
                                 YEAR(R.MesPresentacion), 
                                 MONTH(R.MesPresentacion), 
                                 PA.IdTipoProgramaActividad, 
                                 LPM.IdActividadPetrolera, 
                                 LPM.IdSubactividadPetrolera, 
                                 LPM.IdTareaPetrolera, 
                                 LPM.IdServicio, 
                                 R.IdGastoRubro, 
                                 R.MesPresentacion, 
                                 AC.Inicio, 
                                 R.IdRegistro,
                                 CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                                     ELSE 0
                                 END;
             END;

/****RELLENAR LAS TAREAS SIN DATOS
         INSERT INTO #datos
                SELECT pa.IdTipoProgramaActividad, 
                       ap.IdActividadPetrolera, 
                       sap.IdSubactividadPetrolera, 
                       tp.IdTareaPetrolera, 
                       s.IdServicio, 
                       IdGastoRubro = NULL, 
                       MontoRegistro = 0, 
                       MesPresentacion = NULL, 
                       PCN = NULL, 
                       Inicio = NULL, 
                       [ANIO] = 0, 
                       [MES] = 0, 
                       IdRegistro = 0, 
                       MesPresentacion = NULL
                FROM dbo.CO_ProgramaActividad pa
                     INNER JOIN dbo.CO_LineaProgramaActividadMes pam ON pam.IdProgramaActividad = pa.IdProgramaActividad
                     INNER JOIN dbo.CO_ActividadPetroleraCNH ap ON ap.IdActividadPetrolera = pam.IdActividadPetrolera
                     INNER JOIN dbo.CO_SubactividadPetrolera sap ON sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera
                     INNER JOIN dbo.CO_TareaPetrolera tp ON tp.IdTareaPetrolera = pam.IdTareaPetrolera
                     INNER JOIN dbo.CO_Servicio s ON s.IdServicio = pam.IdSubTareaPetrolera
                WHERE pa.IdProgramaActividad = @IdProgramaActividad
                      AND NOT EXISTS
                (
                    SELECT 1
                    FROM #datos tmp
                    WHERE tmp.IdTipoProgramaActividad = pa.IdTipoProgramaActividad
                          AND tmp.IdActividadPetrolera = ap.IdActividadPetrolera
                          AND tmp.IdSubactividadPetrolera = sap.IdSubactividadPetrolera
                          AND tmp.IdTareaPetrolera = tp.IdTareaPetrolera
                          AND tmp.IdServicio = s.IdServicio
                );****/
/*
Calcular primer mes para vaciar los datos en la plantilla
*/

         DECLARE @diferenciames INT= 0;
         SELECT @diferenciames = 1 - MONTH(InicioPresup)--marzo =-2
         FROM #DATOS;
         --
         UPDATE #DATOS
           SET 
               MesPresentacion = DATEADD(month, @diferenciames, MesPresentacion); --=1
         --anio = YEAR(DATEADD(month, @diferenciames, MesPresentacion)), 
         --mes = MONTH(DATEADD(month, @diferenciames, MesPresentacion));
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

         /**/

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
         --SELECT anio, 
         --       Mes, 
         --       MesPresentacion, 
         --       IdTipoProgramaActividad, 
         --       IdActividadPetrolera, 
         --       IdSubactividadPetrolera, 
         --       IdTareaPetrolera, 
         --       IdServicio, 
         --       PCN, 
         --       InicioPresup, 
         --       ISNULL([1], 0) * ISNULL(PCN, 0) AS [MONac], 
         --       ISNULL([1], 0) * (1 - ISNULL(PCN, 0)) AS [MOExt], 
         --       ISNULL([2], 0) * ISNULL(PCN, 0) AS [BiNac], 
         --       ISNULL([2], 0) * (1 - ISNULL(PCN, 0)) AS [BiExt], 
         --       ISNULL([3], 0) * ISNULL(PCN, 0) AS [SerNac], 
         --       ISNULL([3], 0) * (1 - ISNULL(PCN, 0)) AS [SerExt], 
         --       ISNULL([4], 0) * ISNULL(PCN, 0) AS [CapNac], 
         --       ISNULL([4], 0) * (1 - ISNULL(PCN, 0)) AS [CapExt], 
         --       ISNULL([5], 0) * ISNULL(PCN, 0) AS [TransTec], 
         --       ISNULL([6], 0) * ISNULL(PCN, 0) AS [InfraSoc]
         --FROM
         --(
         --    SELECT IdTipoProgramaActividad, 
         --           IdActividadPetrolera, 
         --           IdSubactividadPetrolera, 
         --           IdTareaPetrolera, 
         --           IdServicio, 
         --           IdGastoRubro, 
         --           MontoRegistro, 
         --           MesPresentacion, 
         --           Mes, 
         --           ANIO, 
         --           PCN, 
         --           InicioPresup
         --    FROM #DATOS
         --) AS SourceTable PIVOT(SUM(MontoRegistro) FOR IdGastoRubro IN([1], 
         --                                                              [2], 
         --                                                              [3], 
         --                                                              [4], 
         --                                                              [5], 
         --                                                              [6])) AS PivotTable;

         /**/

         INSERT INTO #RESULTADO
                SELECT IdTipoProgramaActividad, 
                       IdActividadPetrolera, 
                       IdSubactividadPetrolera, 
                       IdTareaPetrolera, 
                       IdServicio, 
                       ISNULL([1], 0), 
                       ISNULL([2], 0), 
                       ISNULL([3], 0), 
                       ISNULL([4], 0), 
                       ISNULL([5], 0), 
                       ISNULL([6], 0), 
                       ISNULL([7], 0), 
                       ISNULL([8], 0), 
                       ISNULL([9], 0), 
                       ISNULL([10], 0), 
                       ISNULL([11], 0), 
                       ISNULL([12], 0), 
                       ISNULL([13], 0), 
                       ISNULL([14], 0), 
                       ISNULL([15], 0), 
                       ISNULL([16], 0), 
                       ISNULL([17], 0), 
                       ISNULL([18], 0), 
                       ISNULL([19], 0), 
                       ISNULL([20], 0)--, 
                --ISNULL([21], 0), 
                --ISNULL([22], 0), 
                --ISNULL([23], 0), 
                --ISNULL([24], 0), 
                --ISNULL([25], 0)
                --SUM(ISNULL([1], 0)), 
                --SUM(ISNULL([2], 0)), 
                --SUM(ISNULL([3], 0)), 
                --SUM(ISNULL([4], 0)), 
                --SUM(ISNULL([5], 0)), 
                --SUM(ISNULL([6], 0)), 
                --SUM(ISNULL([7], 0)), 
                --SUM(ISNULL([8], 0)), 
                --SUM(ISNULL([9], 0)), 
                --SUM(ISNULL([10], 0)), 
                --SUM(ISNULL([11], 0)), 
                --SUM(ISNULL([12], 0)), 
                --SUM(ISNULL([13], 0)), 
                --SUM(ISNULL([14], 0)), 
                --SUM(ISNULL([15], 0)), 
                --SUM(ISNULL([16], 0)), 
                --SUM(ISNULL([17], 0)), 
                --SUM(ISNULL([18], 0)), 
                --SUM(ISNULL([19], 0)), 
                --SUM(ISNULL([20], 0)), 
                --SUM(ISNULL([21], 0)), 
                --SUM(ISNULL([22], 0)), 
                --SUM(ISNULL([23], 0)), 
                --SUM(ISNULL([24], 0)), 
                --SUM(ISNULL([25], 0)) 
                --SUM(ISNULL([201], 0)), 
                --SUM(ISNULL([202], 0)), 
                --SUM(ISNULL([203], 0)), 
                --SUM(ISNULL([204], 0)), 
                --SUM(ISNULL([205], 0)), 
                --SUM(ISNULL([206], 0)), 
                --SUM(ISNULL([207], 0)), 
                --SUM(ISNULL([208], 0)), 
                --SUM(ISNULL([209], 0)), 
                --SUM(ISNULL([210], 0)), 
                --SUM(ISNULL([211], 0)), 
                --SUM(ISNULL([212], 0)), 
                --SUM(ISNULL([213], 0)), 
                --SUM(ISNULL([214], 0)), 
                --SUM(ISNULL([215], 0)), 
                --SUM(ISNULL([216], 0)), 
                --SUM(ISNULL([217], 0)), 
                --SUM(ISNULL([218], 0)), 
                --SUM(ISNULL([219], 0)), 
                --SUM(ISNULL([220], 0)), 
                --SUM(ISNULL([301], 0)), 
                --SUM(ISNULL([302], 0)), 
                --SUM(ISNULL([303], 0)), 
                --SUM(ISNULL([304], 0)), 
                --SUM(ISNULL([305], 0)), 
                --SUM(ISNULL([306], 0)), 
                --SUM(ISNULL([307], 0)), 
                --SUM(ISNULL([308], 0)), 
                --SUM(ISNULL([309], 0)), 
                --SUM(ISNULL([310], 0)), 
                --SUM(ISNULL([311], 0)), 
                --SUM(ISNULL([312], 0)), 
                --SUM(ISNULL([313], 0)), 
                --SUM(ISNULL([314], 0)), 
                --SUM(ISNULL([315], 0)), 
                --SUM(ISNULL([316], 0)), 
                --SUM(ISNULL([317], 0)), 
                --SUM(ISNULL([318], 0)), 
                --SUM(ISNULL([319], 0)), 
                --SUM(ISNULL([320], 0)), 
                --SUM(ISNULL([401], 0)), 
                --SUM(ISNULL([402], 0)), 
                --SUM(ISNULL([403], 0)), 
                --SUM(ISNULL([404], 0)), 
                --SUM(ISNULL([405], 0)), 
                --SUM(ISNULL([406], 0)), 
                --SUM(ISNULL([407], 0)), 
                --SUM(ISNULL([408], 0)), 
                --SUM(ISNULL([409], 0)), 
                --SUM(ISNULL([410], 0)), 
                --SUM(ISNULL([411], 0)), 
                --SUM(ISNULL([412], 0)), 
                --SUM(ISNULL([413], 0)), 
                --SUM(ISNULL([414], 0)), 
                --SUM(ISNULL([415], 0)), 
                --SUM(ISNULL([416], 0)), 
                --SUM(ISNULL([417], 0)), 
                --SUM(ISNULL([418], 0)), 
                --SUM(ISNULL([419], 0)), 
                --SUM(ISNULL([420], 0)), 
                --SUM(ISNULL([501], 0)), 
                --SUM(ISNULL([502], 0)), 
                --SUM(ISNULL([503], 0)), 
                --SUM(ISNULL([504], 0)), 
                --SUM(ISNULL([505], 0)), 
                --SUM(ISNULL([506], 0)), 
                --SUM(ISNULL([507], 0)), 
                --SUM(ISNULL([508], 0)), 
                --SUM(ISNULL([509], 0)), 
                --SUM(ISNULL([510], 0)), 
                --SUM(ISNULL([511], 0)), 
                --SUM(ISNULL([512], 0)), 
                --SUM(ISNULL([513], 0)), 
                --SUM(ISNULL([514], 0)), 
                --SUM(ISNULL([515], 0)), 
                --SUM(ISNULL([516], 0)), 
                --SUM(ISNULL([517], 0)), 
                --SUM(ISNULL([518], 0)), 
                --SUM(ISNULL([519], 0)), 
                --SUM(ISNULL([520], 0)), 
                --SUM(ISNULL([601], 0)), 
                --SUM(ISNULL([602], 0)), 
                --SUM(ISNULL([603], 0)), 
                --SUM(ISNULL([604], 0)), 
                --SUM(ISNULL([605], 0)), 
                --SUM(ISNULL([606], 0)), 
                --SUM(ISNULL([607], 0)), 
                --SUM(ISNULL([608], 0)), 
                --SUM(ISNULL([609], 0)), 
                --SUM(ISNULL([610], 0)), 
                --SUM(ISNULL([611], 0)), 
                --SUM(ISNULL([612], 0)), 
                --SUM(ISNULL([613], 0)), 
                --SUM(ISNULL([614], 0)), 
                --SUM(ISNULL([615], 0)), 
                --SUM(ISNULL([616], 0)), 
                --SUM(ISNULL([617], 0)), 
                --SUM(ISNULL([618], 0)), 
                --SUM(ISNULL([619], 0)), 
                --SUM(ISNULL([620], 0)), 
                --SUM(ISNULL([701], 0)), 
                --SUM(ISNULL([702], 0)), 
                --SUM(ISNULL([703], 0)), 
                --SUM(ISNULL([704], 0)), 
                --SUM(ISNULL([705], 0)), 
                --SUM(ISNULL([706], 0)), 
                --SUM(ISNULL([707], 0)), 
                --SUM(ISNULL([708], 0)), 
                --SUM(ISNULL([709], 0)), 
                --SUM(ISNULL([710], 0)), 
                --SUM(ISNULL([711], 0)), 
                --SUM(ISNULL([712], 0)), 
                --SUM(ISNULL([713], 0)), 
                --SUM(ISNULL([714], 0)), 
                --SUM(ISNULL([715], 0)), 
                --SUM(ISNULL([716], 0)), 
                --SUM(ISNULL([717], 0)), 
                --SUM(ISNULL([718], 0)), 
                --SUM(ISNULL([719], 0)), 
                --SUM(ISNULL([720], 0)), 
                --SUM(ISNULL([801], 0)), 
                --SUM(ISNULL([802], 0)), 
                --SUM(ISNULL([803], 0)), 
                --SUM(ISNULL([804], 0)), 
                --SUM(ISNULL([805], 0)), 
                --SUM(ISNULL([806], 0)), 
                --SUM(ISNULL([807], 0)), 
                --SUM(ISNULL([808], 0)), 
                --SUM(ISNULL([809], 0)), 
                --SUM(ISNULL([810], 0)), 
                --SUM(ISNULL([811], 0)), 
                --SUM(ISNULL([812], 0)), 
                --SUM(ISNULL([813], 0)), 
                --SUM(ISNULL([814], 0)), 
                --SUM(ISNULL([815], 0)), 
                --SUM(ISNULL([816], 0)), 
                --SUM(ISNULL([817], 0)), 
                --SUM(ISNULL([818], 0)), 
                --SUM(ISNULL([819], 0)), 
                --SUM(ISNULL([820], 0)), 
                --SUM(ISNULL([901], 0)), 
                --SUM(ISNULL([902], 0)), 
                --SUM(ISNULL([903], 0)), 
                --SUM(ISNULL([904], 0)), 
                --SUM(ISNULL([905], 0)), 
                --SUM(ISNULL([906], 0)), 
                --SUM(ISNULL([907], 0)), 
                --SUM(ISNULL([908], 0)), 
                --SUM(ISNULL([909], 0)), 
                --SUM(ISNULL([910], 0)), 
                --SUM(ISNULL([911], 0)), 
                --SUM(ISNULL([912], 0)), 
                --SUM(ISNULL([913], 0)), 
                --SUM(ISNULL([914], 0)), 
                --SUM(ISNULL([915], 0)), 
                --SUM(ISNULL([916], 0)), 
                --SUM(ISNULL([917], 0)), 
                --SUM(ISNULL([918], 0)), 
                --SUM(ISNULL([919], 0)), 
                --SUM(ISNULL([920], 0)), 
                --SUM(ISNULL([1001], 0)), 
                --SUM(ISNULL([1002], 0)), 
                --SUM(ISNULL([1003], 0)), 
                --SUM(ISNULL([1004], 0)), 
                --SUM(ISNULL([1005], 0)), 
                --SUM(ISNULL([1006], 0)), 
                --SUM(ISNULL([1007], 0)), 
                --SUM(ISNULL([1008], 0)), 
                --SUM(ISNULL([1009], 0)), 
                --SUM(ISNULL([1010], 0)), 
                --SUM(ISNULL([1011], 0)), 
                --SUM(ISNULL([1012], 0)), 
                --SUM(ISNULL([1013], 0)), 
                --SUM(ISNULL([1014], 0)), 
                --SUM(ISNULL([1015], 0)), 
                --SUM(ISNULL([1016], 0)), 
                --SUM(ISNULL([1017], 0)), 
                --SUM(ISNULL([1018], 0)), 
                --SUM(ISNULL([1019], 0)), 
                --SUM(ISNULL([1020], 0))
                FROM
                (
                    SELECT IdTipoProgramaActividad, 
                           IdActividadPetrolera, 
                           IdSubactividadPetrolera, 
                           IdTareaPetrolera, 
                           IdServicio, 
                           InicioPresup, 
                           Mes, 
                           --Mes + 200 AS [Mes2], 
                           --Mes + 300 AS [Mes3], 
                           --Mes + 400 AS [Mes4], 
                           --Mes + 500 AS [Mes5], 
                           --Mes + 600 AS [Mes6], 
                           --Mes + 700 AS [Mes7], 
                           --Mes + 800 AS [Mes8], 
                           --Mes + 900 AS [Mes9], 
                           --Mes + 1000 AS [Mes10], 
                           ANIO, 
                           --MONac, 
                           --MOExt, 
                           --BiNac, 
                           --BiExt, 
                           --SerNac, 
                           --SerExt, 
                           --CapNac, 
                           --CapExt, 
                           --TransTec, 
                           --InfraSoc
                           MonoRegistro
                    FROM #PIVOT
                ) AS SourceTable PIVOT(SUM(MonoRegistro) FOR MES IN([1], 
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
                                                                    [20]--, 
                --[21], 
                --[22], 
                --[23], 
                --[24], 
                --[25]
                )) AS PV1 
                --PIVOT(SUM(MOExt) FOR MES2 IN([201], 
                --                                                                                        [202], 
                --                                                                                        [203], 
                --                                                                                        [204], 
                --                                                                                        [205], 
                --                                                                                        [206], 
                --                                                                                        [207], 
                --                                                                                        [208], 
                --                                                                                        [209], 
                --                                                                                        [210], 
                --                                                                                        [211], 
                --                                                                                        [212], 
                --                                                                                        [213], 
                --                                                                                        [214], 
                --                                                                                        [215], 
                --                                                                                        [216], 
                --                                                                                        [217], 
                --                                                                                        [218], 
                --                                                                                        [219], 
                --                                                                                        [220])) AS PV2 PIVOT(SUM(BiNac) FOR MES3 IN([301], 
                --                                                                                                                                    [302], 
                --                                                                                                                                    [303], 
                --                                                                                                                                    [304], 
                --                                                                                                                                    [305], 
                --                                                                                                                                    [306], 
                --                                                                                                                                    [307], 
                --                                                                                                                                    [308], 
                --                                                                                                                                    [309], 
                --                                                                                                                                    [310], 
                --                                                                                                                                    [311], 
                --                                                                                                                                    [312], 
                --                                                                                                                                    [313], 
                --                                                                                                                                    [314], 
                --                                                                                                                                    [315], 
                --                                                                                                                                    [316], 
                --                                                                                                                                    [317], 
                --                                                                                                                                    [318], 
                --                                                                                                                                    [319], 
                --                                                                                                                                    [320])) AS PV3 PIVOT(SUM(BiExt) FOR MES4 IN([401], 
                --                                                                                                                                                                                [402], 
                --                                                                                                                                                                                [403], 
                --                                                                                                                                                                                [404], 
                --                                                                                                                                                                                [405], 
                --                                                                                                                                                                                [406], 
                --                                                                                                                                                                                [407], 
                --                                                                                                                                                                                [408], 
                --                                                                                                                                                                                [409], 
                --                                                                                                                                                                                [410], 
                --                                                                                                                                                                                [411], 
                --                                                                                                                                                                                [412], 
                --                                                                                                                                                                                [413], 
                --                                                                                                                                                                                [414], 
                --                                                                                                                                                                                [415], 
                --                                                                                                                                                                                [416], 
                --                                                                                                                                                                                [417], 
                --                                                                                                                                                                                [418], 
                --                                                                                                                                                                                [419], 
                --                                                                                                                                                                                [420])) AS PV4 PIVOT(SUM(SerNac) FOR MES5 IN([501], 
                --                                                                                                                                                                                                                             [502], 
                --                                                                                                                                                                                                                             [503], 
                --                                                                                                                                                                                                                             [504], 
                --                                                                                                                                                                                                                             [505], 
                --                                                                                                                                                                                                                             [506], 
                --                                                                                                                                                                                                                             [507], 
                --                                                                                                                                                                                                                             [508], 
                --                                                                                                                                                                                                                             [509], 
                --                                                                                                                                                                                                                             [510], 
                --                                                                                                                                                                                                                             [511], 
                --                                                                                                                                                                                                                             [512], 
                --                                                                                                                                                                                                                             [513], 
                --                                                                                                                                                                                                                             [514], 
                --                                                                                                                                                                                                                             [515], 
                --                                                                                                                                                                                                                             [516], 
                --                                                                                                                                                                                                                             [517], 
                --                                                                                                                                                                                                                             [518], 
                --                                                                                                                                                                                                                             [519], 
                --                                                                                                                                                                                                                             [520])) AS PV5 PIVOT(SUM(SerExt) FOR MES6 IN([601], 
                --                                                                                                                                                                                                                                                                          [602], 
                --                                                                                                                                                                                                                                                                          [603], 
                --                                                                                                                                                                                                                                                                          [604], 
                --                                                                                                                                                                                                                                                                          [605], 
                --                                                                                                                                                                                                                                                                          [606], 
                --                                                                                                                                                                                                                                                                          [607], 
                --                                                                                                                                                                                                                                                                          [608], 
                --                                                                                                                                                                                                                                                                          [609], 
                --                                                                                                                                                                                                                                                                          [610], 
                --                                                                                                                                                                                                                                                                          [611], 
                --                                                                                                                                                                                                                                                                          [612], 
                --                                                                                                                                                                                                                                                                          [613], 
                --                                                                                                                                                                                                                                                                          [614], 
                --                                                                                                                                                                                                                                                                          [615], 
                --                                                                                                                                                                                                                                                                          [616], 
                --                                                                                                                                                                                                                                                                          [617], 
                --                                                                                                                                                                                                                                                                          [618], 
                --                                                                                                                                                                                                                                                                          [619], 
                --                                                                                                                                                                                                                                                                          [620])) AS PV6 PIVOT(SUM(CapNac) FOR MES7 IN([701], 
                --                                                                                                                                                                                                                                                                                                                       [702], 
                --                                                                                                                                                                                                                                                                                                                       [703], 
                --                                                                                                                                                                                                                                                                                                                       [704], 
                --                                                                                                                                                                                                                                                                                                                       [705], 
                --                                                                                                                                                                                                                                                                                                                       [706], 
                --                                                                                                                                                                                                                                                                                                                       [707], 
                --                                                                                                                                                                                                                                                                                                                       [708], 
                --                                                                                                                                                                                                                                                                                                                       [709], 
                --                                                                                                                                                                                                                                                                                                                       [710], 
                --                                                                                                                                                                                                                                                                                                                       [711], 
                --                                                                                                                                                                                                                                                                                                                       [712], 
                --                                                                                                                                                                                                                                                                                                                       [713], 
                --                                                                                                                                                                                                                                                                                                                       [714], 
                --                                                                                                                                                                                                                                                                                                                       [715], 
                --                                                                                                                                                                                                                                                                                                                       [716], 
                --                                                                                                                                                                                                                                                                                                                       [717], 
                --                                                                                                                                                                                                                                                                                                                       [718], 
                --                                                                                                                                                                                                                                                                                                                       [719], 
                --                                                                                                                                                                                                                                                                                                                       [720])) AS PV7 PIVOT(SUM(CapExt) FOR MES8 IN([801], 
                --                                                                                                                                                                                                                                                                                                                                                                    [802], 
                --                                                                                                                                                                                                                                                                                                                                                                    [803], 
                --                                                                                                                                                                                                                                                                                                                                                                    [804], 
                --                                                                                                                                                                                                                                                                                                                                                                    [805], 
                --                                                                                                                                                                                                                                                                                                                                                                    [806], 
                --                                                                                                                                                                                                                                                                                                                                                                    [807], 
                --                                                                                                                                                                                                                                                                                                                                                                    [808], 
                --                                                                                                                                                                                                                                                                                                                                                                    [809], 
                --                                                                                                                                                                                                                                                                                                                                                                    [810], 
                --                                                                                                                                                                                                                                                                                                                                                                    [811], 
                --                                                                                                                                                                                                                                                                                                                                                                    [812], 
                --                                                                                                                                                                                                                                                                                                                                                                    [813], 
                --                                                                                                                                                                                                                                                                                                                                                                    [814], 
                --                                                                                                                                                                                                                                                                                                                                                                    [815], 
                --                                                                                                                                                                                                                                                                                                                                                                    [816], 
                --                                                                                                                                                                                                                                                                                                                                                                    [817], 
                --                                                                                                                                                                                                                                                                                                                                                                    [818], 
                --                                                                                                                                                                                                                                                                                                                                                                    [819], 
                --                                                                                                                                                                                                                                                                                                                                                                    [820])) AS PV8 PIVOT(SUM(TransTec) FOR MES9 IN([901], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [902], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [903], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [904], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [905], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [906], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [907], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [908], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [909], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [910], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [911], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [912], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [913], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [914], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [915], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [916], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [917], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [918], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [919], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                   [920])) AS PV9 PIVOT(SUM(InfraSoc) FOR MES10 IN([1001], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1002], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1003], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1004], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1005], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1006], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1007], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1008], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1009], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1010], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1011], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1012], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1013], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1014], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1015], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1016], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1017], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1018], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1019], 
                --                                                                                                                                                                                                                                                                                                                                                                                                                                                                   [1020])) AS PV10
                GROUP BY IdTipoProgramaActividad, 
                         IdActividadPetrolera, 
                         IdSubactividadPetrolera, 
                         IdTareaPetrolera, 
                         IdServicio, 
                         ISNULL([1], 0), 
                         ISNULL([2], 0), 
                         ISNULL([3], 0), 
                         ISNULL([4], 0), 
                         ISNULL([5], 0), 
                         ISNULL([6], 0), 
                         ISNULL([7], 0), 
                         ISNULL([8], 0), 
                         ISNULL([9], 0), 
                         ISNULL([10], 0), 
                         ISNULL([11], 0), 
                         ISNULL([12], 0), 
                         ISNULL([13], 0), 
                         ISNULL([14], 0), 
                         ISNULL([15], 0), 
                         ISNULL([16], 0), 
                         ISNULL([17], 0), 
                         ISNULL([18], 0), 
                         ISNULL([19], 0), 
                         ISNULL([20], 0);--, 
         --ISNULL([21], 0), 
         --ISNULL([22], 0), 
         --ISNULL([23], 0), 
         --ISNULL([24], 0), 
         --ISNULL([25], 0);

         /**/

         SELECT
         --MesPresentacion,
         UPPER(dbo.RemoverAcentos(TPA.TipoPrograma)) AS TipoPrograma, 
         UPPER(dbo.RemoverAcentos(AP.DescripcionActividadPetrolera)) AS DescripcionActividadPetrolera, 
         UPPER(dbo.RemoverAcentos(SAP.SubactividadPetrolera)) AS SubactividadPetrolera, 
         UPPER(dbo.RemoverAcentos(TP.TareaPetrolera)) AS TareaPetrolera, 
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
         0 AS MONAC21, 
         0 AS MONAC22, 
         0 AS MONAC23, 
         0 AS MONAC24, 
         0 AS MONAC25, 
         FORMAT((R.MONAC01 + R.MONAC02 + R.MONAC03 + R.MONAC04 + R.MONAC05 + R.MONAC06 + R.MONAC07 + R.MONAC08 + R.MONAC09 + R.MONAC10 + R.MONAC11 + R.MONAC12 + R.MONAC13 + R.MONAC14 + R.MONAC15 + R.MONAC16 + R.MONAC17 + R.MONAC18 + R.MONAC19 + R.MONAC20), '#,#0.0000') AS Total
         --R.MONAC01, 
         --R.MOEXT01, 
         --R.BINAC01, 
         --R.BIEXT01, 
         --R.SERNAC01, 
         --R.SEREXT01, 
         --R.CAPNAC01, 
         --R.CAPEXT01, 
         --R.TRANSTEC01, 
         --R.INFRASOC01, 
         --R.MONAC02, 
         --R.MOEXT02, 
         --R.BINAC02, 
         --R.BIEXT02, 
         --R.SERNAC02, 
         --R.SEREXT02, 
         --R.CAPNAC02, 
         --R.CAPEXT02, 
         --R.TRANSTEC02, 
         --R.INFRASOC02, 
         --R.MONAC03, 
         --R.MOEXT03, 
         --R.BINAC03, 
         --R.BIEXT03, 
         --R.SERNAC03, 
         --R.SEREXT03, 
         --R.CAPNAC03, 
         --R.CAPEXT03, 
         --R.TRANSTEC03, 
         --R.INFRASOC03, 
         --R.MONAC04, 
         --R.MOEXT04, 
         --R.BINAC04, 
         --R.BIEXT04, 
         --R.SERNAC04, 
         --R.SEREXT04, 
         --R.CAPNAC04, 
         --R.CAPEXT04, 
         --R.TRANSTEC04, 
         --R.INFRASOC04, 
         --R.MONAC05, 
         --R.MOEXT05, 
         --R.BINAC05, 
         --R.BIEXT05, 
         --R.SERNAC05, 
         --R.SEREXT05, 
         --R.CAPNAC05, 
         --R.CAPEXT05, 
         --R.TRANSTEC05, 
         --R.INFRASOC05, 
         --R.MONAC06, 
         --R.MOEXT06, 
         --R.BINAC06, 
         --R.BIEXT06, 
         --R.SERNAC06, 
         --R.SEREXT06, 
         --R.CAPNAC06, 
         --R.CAPEXT06, 
         --R.TRANSTEC06, 
         --R.INFRASOC06, 
         --R.MONAC07, 
         --R.MOEXT07, 
         --R.BINAC07, 
         --R.BIEXT07, 
         --R.SERNAC07, 
         --R.SEREXT07, 
         --R.CAPNAC07, 
         --R.CAPEXT07, 
         --R.TRANSTEC07, 
         --R.INFRASOC07, 
         --R.MONAC08, 
         --R.MOEXT08, 
         --R.BINAC08, 
         --R.BIEXT08, 
         --R.SERNAC08, 
         --R.SEREXT08, 
         --R.CAPNAC08, 
         --R.CAPEXT08, 
         --R.TRANSTEC08, 
         --R.INFRASOC08, 
         --R.MONAC09, 
         --R.MOEXT09, 
         --R.BINAC09, 
         --R.BIEXT09, 
         --R.SERNAC09, 
         --R.SEREXT09, 
         --R.CAPNAC09, 
         --R.CAPEXT09, 
         --R.TRANSTEC09, 
         --R.INFRASOC09, 
         --R.MONAC10, 
         --R.MOEXT10, 
         --R.BINAC10, 
         --R.BIEXT10, 
         --R.SERNAC10, 
         --R.SEREXT10, 
         --R.CAPNAC10, 
         --R.CAPEXT10, 
         --R.TRANSTEC10, 
         --R.INFRASOC10, 
         --R.MONAC11, 
         --R.MOEXT11, 
         --R.BINAC11, 
         --R.BIEXT11, 
         --R.SERNAC11, 
         --R.SEREXT11, 
         --R.CAPNAC11, 
         --R.CAPEXT11, 
         --R.TRANSTEC11, 
         --R.INFRASOC11, 
         --R.MONAC12, 
         --R.MOEXT12, 
         --R.BINAC12, 
         --R.BIEXT12, 
         --R.SERNAC12, 
         --R.SEREXT12, 
         --R.CAPNAC12, 
         --R.CAPEXT12, 
         --R.TRANSTEC12, 
         --R.INFRASOC12, 
         --R.MONAC13, 
         --R.MOEXT13, 
         --R.BINAC13, 
         --R.BIEXT13, 
         --R.SERNAC13, 
         --R.SEREXT13, 
         --R.CAPNAC13, 
         --R.CAPEXT13, 
         --R.TRANSTEC13, 
         --R.INFRASOC13, 
         --R.MONAC14, 
         --R.MOEXT14, 
         --R.BINAC14, 
         --R.BIEXT14, 
         --R.SERNAC14, 
         --R.SEREXT14, 
         --R.CAPNAC14, 
         --R.CAPEXT14, 
         --R.TRANSTEC14, 
         --R.INFRASOC14, 
         --R.MONAC15, 
         --R.MOEXT15, 
         --R.BINAC15, 
         --R.BIEXT15, 
         --R.SERNAC15, 
         --R.SEREXT15, 
         --R.CAPNAC15, 
         --R.CAPEXT15, 
         --R.TRANSTEC15, 
         --R.INFRASOC15, 
         --R.MONAC16, 
         --R.MOEXT16, 
         --R.BINAC16, 
         --R.BIEXT16, 
         --R.SERNAC16, 
         --R.SEREXT16, 
         --R.CAPNAC16, 
         --R.CAPEXT16, 
         --R.TRANSTEC16, 
         --R.INFRASOC16, 
         --R.MONAC17, 
         --R.MOEXT17, 
         --R.BINAC17, 
         --R.BIEXT17, 
         --R.SERNAC17, 
         --R.SEREXT17, 
         --R.CAPNAC17, 
         --R.CAPEXT17, 
         --R.TRANSTEC17, 
         --R.INFRASOC17, 
         --R.MONAC18, 
         --R.MOEXT18, 
         --R.BINAC18, 
         --R.BIEXT18, 
         --R.SERNAC18, 
         --R.SEREXT18, 
         --R.CAPNAC18, 
         --R.CAPEXT18, 
         --R.TRANSTEC18, 
         --R.INFRASOC18, 
         --R.MONAC19, 
         --R.MOEXT19, 
         --R.BINAC19, 
         --R.BIEXT19, 
         --R.SERNAC19, 
         --R.SEREXT19, 
         --R.CAPNAC19, 
         --R.CAPEXT19, 
         --R.TRANSTEC19, 
         --R.INFRASOC19, 
         --R.MONAC20, 
         --R.MOEXT20, 
         --R.BINAC20, 
         --R.BIEXT20, 
         --R.SERNAC20, 
         --R.SEREXT20, 
         --R.CAPNAC20, 
         --R.CAPEXT20, 
         --R.TRANSTEC20, 
         --R.INFRASOC20, 
         --0 AS MONAC21, 
         --0 AS MOEXT21, 
         --0 AS BINAC21, 
         --0 AS BIEXT21, 
         --0 AS SERNAC21, 
         --0 AS SEREXT21, 
         --0 AS CAPNAC21, 
         --0 AS CAPEXT21, 
         --0 AS TRANSTEC21, 
         --0 AS INFRASOC21, 
         --0 AS MONAC22, 
         --0 AS MOEXT22, 
         --0 AS BINAC22, 
         --0 AS BIEXT22, 
         --0 AS SERNAC22, 
         --0 AS SEREXT22, 
         --0 AS CAPNAC22, 
         --0 AS CAPEXT22, 
         --0 AS TRANSTEC22, 
         --0 AS INFRASOC22, 
         --0 AS MONAC23, 
         --0 AS MOEXT23, 
         --0 AS BINAC23, 
         --0 AS BIEXT23, 
         --0 AS SERNAC23, 
         --0 AS SEREXT23, 
         --0 AS CAPNAC23, 
         --0 AS CAPEXT23, 
         --0 AS TRANSTEC23, 
         --0 AS INFRASOC23, 
         --0 AS MONAC24, 
         --0 AS MOEXT24, 
         --0 AS BINAC24, 
         --0 AS BIEXT24, 
         --0 AS SERNAC24, 
         --0 AS SEREXT24, 
         --0 AS CAPNAC24, 
         --0 AS CAPEXT24, 
         --0 AS TRANSTEC24, 
         --0 AS INFRASOC24, 
         --0 AS MONAC25, 
         --0 AS MOEXT25, 
         --0 AS BINAC25, 
         --0 AS BIEXT25, 
         --0 AS SERNAC25, 
         --0 AS SEREXT25, 
         --0 AS CAPNAC25, 
         --0 AS CAPEXT25, 
         --0 AS TRANSTEC25, 
         --0 AS INFRASOC25, 
         --FORMAT((R.MONAC01 + R.MOEXT01 + R.BINAC01 + R.BIEXT01 + R.SERNAC01 + R.SEREXT01 + R.CAPNAC01 + R.CAPEXT01 + R.TRANSTEC01 + R.INFRASOC01 + R.MONAC02 + R.MOEXT02 + R.BINAC02 + R.BIEXT02 + R.SERNAC02 + R.SEREXT02 + R.CAPNAC02 + R.CAPEXT02 + R.TRANSTEC02 + R.INFRASOC02 + R.MONAC03 + R.MOEXT03 + R.BINAC03 + R.BIEXT03 + R.SERNAC03 + R.SEREXT03 + R.CAPNAC03 + R.CAPEXT03 + R.TRANSTEC03 + R.INFRASOC03 + R.MONAC04 + R.MOEXT04 + R.BINAC04 + R.BIEXT04 + R.SERNAC04 + R.SEREXT04 + R.CAPNAC04 + R.CAPEXT04 + R.TRANSTEC04 + R.INFRASOC04 + R.MONAC05 + R.MOEXT05 + R.BINAC05 + R.BIEXT05 + R.SERNAC05 + R.SEREXT05 + R.CAPNAC05 + R.CAPEXT05 + R.TRANSTEC05 + R.INFRASOC05 + R.MONAC06 + R.MOEXT06 + R.BINAC06 + R.BIEXT06 + R.SERNAC06 + R.SEREXT06 + R.CAPNAC06 + R.CAPEXT06 + R.TRANSTEC06 + R.INFRASOC06 + R.MONAC07 + R.MOEXT07 + R.BINAC07 + R.BIEXT07 + R.SERNAC07 + R.SEREXT07 + R.CAPNAC07 + R.CAPEXT07 + R.TRANSTEC07 + R.INFRASOC07 + R.MONAC08 + R.MOEXT08 + R.BINAC08 + R.BIEXT08 + R.SERNAC08 + R.SEREXT08 + R.CAPNAC08 + R.CAPEXT08 + R.TRANSTEC08 + R.INFRASOC08 + R.MONAC09 + R.MOEXT09 + R.BINAC09 + R.BIEXT09 + R.SERNAC09 + R.SEREXT09 + R.CAPNAC09 + R.CAPEXT09 + R.TRANSTEC09 + R.INFRASOC09 + R.MONAC10 + R.MOEXT10 + R.BINAC10 + R.BIEXT10 + R.SERNAC10 + R.SEREXT10 + R.CAPNAC10 + R.CAPEXT10 + R.TRANSTEC10 + R.INFRASOC10 + R.MONAC11 + R.MOEXT11 + R.BINAC11 + R.BIEXT11 + R.SERNAC11 + R.SEREXT11 + R.CAPNAC11 + R.CAPEXT11 + R.TRANSTEC11 + R.INFRASOC11 + R.MONAC12 + R.MOEXT12 + R.BINAC12 + R.BIEXT12 + R.SERNAC12 + R.SEREXT12 + R.CAPNAC12 + R.CAPEXT12 + R.TRANSTEC12 + R.INFRASOC12 + R.MONAC13 + R.MOEXT13 + R.BINAC13 + R.BIEXT13 + R.SERNAC13 + R.SEREXT13 + R.CAPNAC13 + R.CAPEXT13 + R.TRANSTEC13 + R.INFRASOC13 + R.MONAC14 + R.MOEXT14 + R.BINAC14 + R.BIEXT14 + R.SERNAC14 + R.SEREXT14 + R.CAPNAC14 + R.CAPEXT14 + R.TRANSTEC14 + R.INFRASOC14 + R.MONAC15 + R.MOEXT15 + R.BINAC15 + R.BIEXT15 + R.SERNAC15 + R.SEREXT15 + R.CAPNAC15 + R.CAPEXT15 + R.TRANSTEC15 + R.INFRASOC15 + R.MONAC16 + R.MOEXT16 + R.BINAC16 + R.BIEXT16 + R.SERNAC16 + R.SEREXT16 + R.CAPNAC16 + R.CAPEXT16 + R.TRANSTEC16 + R.INFRASOC16 + R.MONAC17 + R.MOEXT17 + R.BINAC17 + R.BIEXT17 + R.SERNAC17 + R.SEREXT17 + R.CAPNAC17 + R.CAPEXT17 + R.TRANSTEC17 + R.INFRASOC17 + R.MONAC18 + R.MOEXT18 + R.BINAC18 + R.BIEXT18 + R.SERNAC18 + R.SEREXT18 + R.CAPNAC18 + R.CAPEXT18 + R.TRANSTEC18 + R.INFRASOC18 + R.MONAC19 + R.MOEXT19 + R.BINAC19 + R.BIEXT19 + R.SERNAC19 + R.SEREXT19 + R.CAPNAC19 + R.CAPEXT19 + R.TRANSTEC19 + R.INFRASOC19 + R.MONAC20 + R.MOEXT20 + R.BINAC20 + R.BIEXT20 + R.SERNAC20 + R.SEREXT20 + R.CAPNAC20 + R.CAPEXT20 + R.TRANSTEC20 + R.INFRASOC20), '#,#0.0000') AS Total
         INTO #tmpResultFinal
         FROM #RESULTADO R
              INNER JOIN dbo.CO_ActividadPetroleraCNH AP ON AP.IdActividadPetrolera = R.IdActividadPetrolera
              INNER JOIN dbo.CO_SubactividadPetrolera SAP ON SAP.IdSubactividadPetrolera = R.IdSubactividadPetrolera
              INNER JOIN dbo.CO_TareaPetrolera TP ON TP.IdTareaPetrolera = R.IdTareaPetrolera
              INNER JOIN dbo.CO_Servicio S ON S.IdServicio = R.IdServicio
              INNER JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = R.IdTipoProgramaActividad
         --WHERE UPPER(dbo.RemoverAcentos(TP.TareaPetrolera)) <> ''
         ORDER BY TipoPrograma, 
                  DescripcionActividadPetrolera, 
                  SubactividadPetrolera, 
                  TareaPetrolera;

/*

         SELECT R.IdLinea, 
                (R.MONAC01 + R.MOEXT01 + R.BINAC01 + R.BIEXT01 + R.SERNAC01 + R.SEREXT01 + R.CAPNAC01 + R.CAPEXT01 + R.TRANSTEC01 + R.INFRASOC01 + R.MONAC02 + R.MOEXT02 + R.BINAC02 + R.BIEXT02 + R.SERNAC02 + R.SEREXT02 + R.CAPNAC02 + R.CAPEXT02 + R.TRANST
EC02 + R.INFRASOC02 + R.MONAC03 + R.MOEXT03 + R.BINAC03 + R.BIEXT03 + R.SERNAC03 + R.SEREXT03 + R.CAPNAC03 + R.CAPEXT03 + R.TRANSTEC03 + R.INFRASOC03 + R.MONAC04 + R.MOEXT04 + R.BINAC04 + R.BIEXT04 + R.SERNAC04 + R.SEREXT04 + R.CAPNAC04 + R.CAPEXT04 + R.T
RANSTEC04 + R.INFRASOC04 + R.MONAC05 + R.MOEXT05 + R.BINAC05 + R.BIEXT05 + R.SERNAC05 + R.SEREXT05 + R.CAPNAC05 + R.CAPEXT05 + R.TRANSTEC05 + R.INFRASOC05 + R.MONAC06 + R.MOEXT06 + R.BINAC06 + R.BIEXT06 + R.SERNAC06 + R.SEREXT06 + R.CAPNAC06 + R.CAPEXT06 
+ R.TRANSTEC06 + R.INFRASOC06 + R.MONAC07 + R.MOEXT07 + R.BINAC07 + R.BIEXT07 + R.SERNAC07 + R.SEREXT07 + R.CAPNAC07 + R.CAPEXT07 + R.TRANSTEC07 + R.INFRASOC07 + R.MONAC08 + R.MOEXT08 + R.BINAC08 + R.BIEXT08 + R.SERNAC08 + R.SEREXT08 + R.CAPNAC08 + R.CAPE
XT08 + R.TRANSTEC08 + R.INFRASOC08 + R.MONAC09 + R.MOEXT09 + R.BINAC09 + R.BIEXT09 + R.SERNAC09 + R.SEREXT09 + R.CAPNAC09 + R.CAPEXT09 + R.TRANSTEC09 + R.INFRASOC09 + R.MONAC10 + R.MOEXT10 + R.BINAC10 + R.BIEXT10 + R.SERNAC10 + R.SEREXT10 + R.CAPNAC10 + R
.CAPEXT10 + R.TRANSTEC10 + R.INFRASOC10 + R.MONAC11 + R.MOEXT11 + R.BINAC11 + R.BIEXT11 + R.SERNAC11 + R.SEREXT11 + R.CAPNAC11 + R.CAPEXT11 + R.TRANSTEC11 + R.INFRASOC11 + R.MONAC12 + R.MOEXT12 + R.BINAC12 + R.BIEXT12 + R.SERNAC12 + R.SEREXT12 + R.CAPNAC1
2 + R.CAPEXT12 + R.TRANSTEC12 + R.INFRASOC12) AS Total
         FROM #RESULTADO R
         ORDER BY R.IdTipoProgramaActividad, 
                  R.IdActividadPetrolera, 
                  R.IdSubactividadPetrolera, 
                  R.IdTareaPetrolera;*/

         --  select TipoPrograma ,
         SELECT TipoPrograma, 
                DescripcionActividadPetrolera, 
                SubactividadPetrolera, 
                TareaPetrolera, 
                NombreServicio, 
                --TOT01 = FORMAT(MONAC01 + MOEXT01 + BINAC01 + BIEXT01 + SERNAC01 + SEREXT01 + CAPNAC01 + CAPEXT01 + TRANSTEC01 + INFRASOC01, '#,#0.0000'), 
                --TOT02 = FORMAT(MONAC02 + MOEXT02 + BINAC02 + BIEXT02 + SERNAC02 + SEREXT02 + CAPNAC02 + CAPEXT02 + TRANSTEC02 + INFRASOC02, '#,#0.0000'), 
                --TOT03 = FORMAT(MONAC03 + MOEXT03 + BINAC03 + BIEXT03 + SERNAC03 + SEREXT03 + CAPNAC03 + CAPEXT03 + TRANSTEC03 + INFRASOC03, '#,#0.0000'), 
                --TOT04 = FORMAT(MONAC04 + MOEXT04 + BINAC04 + BIEXT04 + SERNAC04 + SEREXT04 + CAPNAC04 + CAPEXT04 + TRANSTEC04 + INFRASOC04, '#,#0.0000'), 
                --TOT05 = FORMAT(MONAC05 + MOEXT05 + BINAC05 + BIEXT05 + SERNAC05 + SEREXT05 + CAPNAC05 + CAPEXT05 + TRANSTEC05 + INFRASOC05, '#,#0.0000'), 
                --TOT06 = FORMAT(MONAC06 + MOEXT06 + BINAC06 + BIEXT06 + SERNAC06 + SEREXT06 + CAPNAC06 + CAPEXT06 + TRANSTEC06 + INFRASOC06, '#,#0.0000'), 
                --TOT07 = FORMAT(MONAC07 + MOEXT07 + BINAC07 + BIEXT07 + SERNAC07 + SEREXT07 + CAPNAC07 + CAPEXT07 + TRANSTEC07 + INFRASOC07, '#,#0.0000'), 
                --TOT08 = FORMAT(MONAC08 + MOEXT08 + BINAC08 + BIEXT08 + SERNAC08 + SEREXT08 + CAPNAC08 + CAPEXT08 + TRANSTEC08 + INFRASOC08, '#,#0.0000'), 
                --TOT09 = FORMAT(MONAC09 + MOEXT09 + BINAC09 + BIEXT09 + SERNAC09 + SEREXT09 + CAPNAC09 + CAPEXT09 + TRANSTEC09 + INFRASOC09, '#,#0.0000'), 
                --TOT10 = FORMAT(MONAC10 + MOEXT10 + BINAC10 + BIEXT10 + SERNAC10 + SEREXT10 + CAPNAC10 + CAPEXT10 + TRANSTEC10 + INFRASOC10, '#,#0.0000'), 
                --TOT11 = FORMAT(MONAC11 + MOEXT11 + BINAC11 + BIEXT11 + SERNAC11 + SEREXT11 + CAPNAC11 + CAPEXT11 + TRANSTEC11 + INFRASOC11, '#,#0.0000'), 
                --TOT12 = FORMAT(MONAC12 + MOEXT12 + BINAC12 + BIEXT12 + SERNAC12 + SEREXT12 + CAPNAC12 + CAPEXT12 + TRANSTEC12 + INFRASOC12, '#,#0.0000'), 
                --TOT13 = FORMAT(MONAC13 + MOEXT13 + BINAC13 + BIEXT13 + SERNAC13 + SEREXT13 + CAPNAC13 + CAPEXT13 + TRANSTEC13 + INFRASOC13, '#,#0.0000'), 
                --TOT14 = FORMAT(MONAC14 + MOEXT14 + BINAC14 + BIEXT14 + SERNAC14 + SEREXT14 + CAPNAC14 + CAPEXT14 + TRANSTEC14 + INFRASOC14, '#,#0.0000'), 
                --TOT15 = FORMAT(MONAC15 + MOEXT15 + BINAC15 + BIEXT15 + SERNAC15 + SEREXT15 + CAPNAC15 + CAPEXT15 + TRANSTEC15 + INFRASOC15, '#,#0.0000'), 
                --TOT16 = FORMAT(MONAC16 + MOEXT16 + BINAC16 + BIEXT16 + SERNAC16 + SEREXT16 + CAPNAC16 + CAPEXT16 + TRANSTEC16 + INFRASOC16, '#,#0.0000'), 
                --TOT17 = FORMAT(MONAC17 + MOEXT17 + BINAC17 + BIEXT17 + SERNAC17 + SEREXT17 + CAPNAC17 + CAPEXT17 + TRANSTEC17 + INFRASOC17, '#,#0.0000'), 
                --TOT18 = FORMAT(MONAC18 + MOEXT18 + BINAC18 + BIEXT18 + SERNAC18 + SEREXT18 + CAPNAC18 + CAPEXT18 + TRANSTEC18 + INFRASOC18, '#,#0.0000'), 
                --TOT19 = FORMAT(MONAC19 + MOEXT19 + BINAC19 + BIEXT19 + SERNAC19 + SEREXT19 + CAPNAC19 + CAPEXT19 + TRANSTEC19 + INFRASOC19, '#,#0.0000'), 
                --TOT20 = FORMAT(MONAC20 + MOEXT20 + BINAC20 + BIEXT20 + SERNAC20 + SEREXT20 + CAPNAC20 + CAPEXT20 + TRANSTEC20 + INFRASOC20, '#,#0.0000'), 
                --TOT21 = FORMAT(MONAC21 + MOEXT21 + BINAC21 + BIEXT21 + SERNAC21 + SEREXT21 + CAPNAC21 + CAPEXT21 + TRANSTEC21 + INFRASOC21, '#,#0.0000'), 
                --TOT22 = FORMAT(MONAC22 + MOEXT22 + BINAC22 + BIEXT22 + SERNAC22 + SEREXT22 + CAPNAC22 + CAPEXT22 + TRANSTEC22 + INFRASOC22, '#,#0.0000'), 
                --TOT23 = FORMAT(MONAC23 + MOEXT23 + BINAC23 + BIEXT23 + SERNAC23 + SEREXT23 + CAPNAC23 + CAPEXT23 + TRANSTEC23 + INFRASOC23, '#,#0.0000'), 
                --TOT24 = FORMAT(MONAC24 + MOEXT24 + BINAC24 + BIEXT24 + SERNAC24 + SEREXT24 + CAPNAC24 + CAPEXT24 + TRANSTEC24 + INFRASOC24, '#,#0.0000'), 
                --TOT25 = FORMAT(MONAC25 + MOEXT25 + BINAC25 + BIEXT25 + SERNAC25 + SEREXT25 + CAPNAC25 + CAPEXT25 + TRANSTEC25 + INFRASOC25, '#,#0.0000'), 
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
                Total
         FROM #tmpResultFinal
         ORDER BY TipoPrograma, 
                  DescripcionActividadPetrolera, 
                  SubactividadPetrolera, 
                  TareaPetrolera;
     END;