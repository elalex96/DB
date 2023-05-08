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
CREATE PROCEDURE [dbo].[SP_CNH_FormatoPlanes_Inversion_2019_BAAC]
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

/*DROP TABLE #DATOS;
DROP TABLE #PIVOT;
DROP TABLE #RESULTADO;*/

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
--          PCN                     FLOAT, 
          InicioPresup            DATE,
		  MontoRegistro			FLOAT
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
          MONAC20                 FLOAT
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
                        /*SELECT PA.IdTipoProgramaActividad, 
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
                        UNION*/
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
             ELSE
             BEGIN
                 INSERT INTO #DATOS
                 SELECT PA.IdTipoProgramaActividad, 
                        LPM.IdActividadPetrolera, 
                        LPM.IdSubactividadPetrolera, 
                        LPM.IdTareaPetrolera, 
                        LPM.IdServicio, 
                        R.IdGastoRubro, 
                        --(
                        CASE
                            WHEN ISNULL(R.MontoRegistro, 0) <> 0
                            THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                            ELSE 0
                        END
                        --) * 1.16 
                        AS MontoRegistro, 
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
                          --(
                          CASE
                              WHEN ISNULL(R.MontoRegistro, 0) <> 0
                              THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                              ELSE 0
                          END
                 --) * 1.16
                 UNION
                 SELECT PA.IdTipoProgramaActividad, 
                        LPM.IdActividadPetrolera, 
                        LPM.IdSubactividadPetrolera, 
                        LPM.IdTareaPetrolera, 
                        LPM.IdServicio, 
                        R.IdGastoRubro, 
                        --(
                        CASE
                            WHEN ISNULL(R.MontoRegistro, 0) <> 0
                            THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                            ELSE 0
                        END
                        --) * 1.16 
                        AS MontoRegistro, 
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
                            OR F.FormaPago LIKE '%PUE%'
							)
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
                 --) * 1.16
                 UNION
                 SELECT PA.IdTipoProgramaActividad, 
                        LPM.IdActividadPetrolera, 
                        LPM.IdSubactividadPetrolera, 
                        LPM.IdTareaPetrolera, 
                        LPM.IdServicio, 
                        R.IdGastoRubro, 
                        --(
                        CASE
                            WHEN ISNULL(R.MontoRegistro, 0) <> 0
                            THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                            ELSE 0
                        END
                        --) * 1.16 
                        AS MontoRegistro, 
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
                          --(
                          CASE
                              WHEN ISNULL(R.MontoRegistro, 0) <> 0
                              THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                              ELSE 0
                          END;
                 --) * 1.16;
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
                    FROM #DATOS

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
                       SUM(ISNULL([20], 0))
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
                           ISNULL(MontoRegistro,0) AS MontoRegistro 
                    FROM #PIVOT
                ) AS SourceTable PIVOT(SUM(MontoRegistro) 
					FOR MES IN([1], 
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
                                [20])) AS PV1 
				 GROUP BY IdTipoProgramaActividad, 
                         IdActividadPetrolera, 
                         IdSubactividadPetrolera, 
                         IdTareaPetrolera, 
                         IdServicio;

         /**/

         SELECT
         --MesPresentacion,
         UPPER(dbo.RemoverAcentos(TPA.TipoPrograma)) AS TipoPrograma, 
         UPPER(dbo.RemoverAcentos(LTRIM(AP.id_Actividad) + ' ' + LTRIM(AP.DescripcionActividadPetrolera))) AS DescripcionActividadPetrolera, 
         UPPER(dbo.RemoverAcentos(LTRIM(SAP.[id_Sub-actividad]) + ' ' + LTRIM(SAP.SubactividadPetrolera))) AS SubactividadPetrolera, 
         UPPER(dbo.RemoverAcentos(LTRIM(TP.id_Tarea) + ' ' + LTRIM(TP.TareaPetrolera))) AS TareaPetrolera, 
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
        FORMAT((R.MONAC01 + R.MONAC02 + R.MONAC03 + R.MONAC04 + R.MONAC05 + 
				R.MONAC06 + R.MONAC07 + R.MONAC08 + R.MONAC09 + R.MONAC10 + 
				R.MONAC11 + R.MONAC12 + R.MONAC13 + R.MONAC14 + R.MONAC15 + 
				R.MONAC16 + R.MONAC17 + R.MONAC18 + R.MONAC19 + R.MONAC20), '#,#0.0000') AS Total
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
