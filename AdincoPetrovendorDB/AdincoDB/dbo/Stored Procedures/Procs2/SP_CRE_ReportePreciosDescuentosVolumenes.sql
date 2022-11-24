-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-08-16
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CRE_ReportePreciosDescuentosVolumenes] --10038,1,'2-2019',0
--exec [SP_CRE_ReportePreciosDescuentosVolumenes] 10011,1,'2-2018',0
--exec [SP_CRE_ReportePreciosDescuentosVolumenes] 10011,1,'2-2018',1
--exec [SP_CRE_ReportePreciosDescuentosVolumenes] 10011,1,'2-2018',2
--exec [SP_CRE_ReportePreciosDescuentosVolumenes] 10011,1,'1-2019',0
--exec [SP_CRE_ReportePreciosDescuentosVolumenes] 10011,1,'1-2019',1
--exec [SP_CRE_ReportePreciosDescuentosVolumenes] 10011,1,'1-2019',2
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@Peiodo     NVARCHAR(50), 
@IdHoja     INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @Sem INT;
         DECLARE @Anio INT;
         --DECLARE @Pei NVARCHAR(50) = '1-2018'
         SET @Sem = SUBSTRING(@Peiodo, 1, 1);
         SET @Anio = SUBSTRING(@Peiodo, 3, 4);
         -- Insert statements for procedure here
         /**/

         CREATE TABLE #Datos
         (Num                 INT, 
          Mes                 DATE, 
          Producto            NVARCHAR(100), 
          Cliente             NVARCHAR(100), 
          VolumenFacturado    FLOAT, 
          Precio              FLOAT, 
          Importe             NVARCHAR(100), 
          TipoCambio          FLOAT, 
          ValorTotalDeLaVenta FLOAT
         );

         /**/

         IF(@IdHoja <> 1)
             BEGIN
                 INSERT INTO #Datos
                 (Num, 
                  Mes, 
                  Producto, 
                  Cliente, 
                  VolumenFacturado, 
                  Precio, 
                  Importe, 
                  TipoCambio, 
                  ValorTotalDeLaVenta
                 )
                        SELECT ROW_NUMBER() OVER(ORDER BY PMPE.IdFecha ASC) AS Num, 
                               PMPE.IdFecha AS Mes,
                               CASE
                                   WHEN TH.IdTipoHidrocarburo = 10000
                                   THEN 'Petroleo'
                                   WHEN TH.IdTipoHidrocarburo = 10001
                                   THEN 'Condensado'
                                   WHEN TH.IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                                   THEN 'Gas'
                               END AS Producto, 
                               S.RazonSocial AS Cliente, 
                               SUM(CAST(PMPE.VolumenVendido AS DECIMAL(15, 4))) AS VolumenFacturado, 
                               AVG(CAST(PMPE.Precio AS DECIMAL(15, 4))) AS Precio, 
                               F.Moneda AS Importe,
                               CASE
                                   WHEN F.IdMoneda = 2
                                   THEN TCDD.TipoCambio
                                   ELSE TCDM.TipoCambio
                               END AS TipoCambio, 
                               AVG(CAST(PMPE.Precio AS DECIMAL(15, 4))) AS ValorTotalDeLaVenta
                        FROM dbo.PR_ProduccionMensualPtoEntrega PMPE
                             JOIN dbo.CO_TipoHidrocarburo TH ON TH.IdTipoHidrocarburo = PMPE.IdTipoHidrocarburo
                             JOIN dbo.CO_Contrato C ON C.IdContrato = PMPE.IdContrato
                             JOIN dbo.COM_OperacionComercializacion OC ON OC.IdContrato = PMPE.IdContrato
                                                                          AND OC.IdTipoHidrocarburo = PMPE.IdTipoHidrocarburo
                                                                          AND OC.MesReporte = PMPE.IdFecha
                             --AND OC.PuntoEntregaID = PMPE.PuntoEntregaID 
                             JOIN dbo.FI_Factura F ON OC.IdFactura = F.IdFactura
                             JOIN dbo.PV_Subcontratista S ON F.Receptor = S.RFC
                             JOIN dbo.CO_TipoCambioMensual TCDD ON F.IdMoneda <> TCDD.IdMoneda
                                                                   AND TCDD.IdMes = MONTH(F.Fecha)
                                                                   AND TCDD.Anio = YEAR(F.Fecha)
                             JOIN dbo.CO_TipoCambioMensual TCDM ON F.IdMoneda = TCDM.IdMoneda
                                                                   AND TCDM.IdMes = MONTH(F.Fecha)
                                                                   AND TCDM.Anio = YEAR(F.Fecha)
                        WHERE PMPE.IdContrato = @IdContrato
                        GROUP BY PMPE.IdFecha,
                                 CASE
                                     WHEN TH.IdTipoHidrocarburo = 10000
                                     THEN 'Petroleo'
                                     WHEN TH.IdTipoHidrocarburo = 10001
                                     THEN 'Condensado'
                                     WHEN TH.IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                                     THEN 'Gas'
                                 END, 
                                 S.RazonSocial, 
                                 F.Moneda,
                                 CASE
                                     WHEN F.IdMoneda = 2
                                     THEN TCDD.TipoCambio
                                     ELSE TCDM.TipoCambio
                                 END
                        ORDER BY PMPE.IdFecha;
             END;
             ELSE
             BEGIN
                 INSERT INTO #Datos
                 (Num, 
                  Mes, 
                  Producto, 
                  Cliente, 
                  VolumenFacturado, 
                  Precio, 
                  Importe, 
                  TipoCambio, 
                  ValorTotalDeLaVenta
                 )
                 SELECT ROW_NUMBER() OVER(ORDER BY PMPE.IdFecha ASC) AS Num, 
                        PMPE.IdFecha AS Mes,
                        CASE
                            WHEN TH.IdTipoHidrocarburo = 10000
                            THEN 'Petroleo'
                            WHEN TH.IdTipoHidrocarburo = 10001
                            THEN 'Condensado'
                            WHEN TH.IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                            THEN 'Gas'
                        END AS Producto, 
                        S.RazonSocial AS Cliente, 
                        SUM(CAST(PMPE.VolumenVendido AS DECIMAL(15, 4))) AS VolumenFacturado, 
                        AVG(CAST(PMPE.Precio AS DECIMAL(15, 4))) AS Precio, 
                        F.Moneda AS Importe,
                        CASE
                            WHEN F.IdMoneda = 2
                            THEN TCDD.TipoCambio
                            ELSE TCDM.TipoCambio
                        END AS TipoCambio, 
                        AVG(CAST(PMPE.Precio AS DECIMAL(15, 4))) AS ValorTotalDeLaVenta
                 FROM dbo.PR_ProduccionMensualPtoEntrega PMPE
                      JOIN dbo.CO_TipoHidrocarburo TH ON TH.IdTipoHidrocarburo = PMPE.IdTipoHidrocarburo
                      JOIN dbo.CO_Contrato C ON C.IdContrato = PMPE.IdContrato
                      JOIN dbo.COM_OperacionComercializacion OC ON OC.IdContrato = PMPE.IdContrato
                                                                   AND OC.IdTipoHidrocarburo = PMPE.IdTipoHidrocarburo
                                                                   AND OC.MesReporte = PMPE.IdFecha
                                                                   AND OC.EsCondensable = 1
                      --AND OC.PuntoEntregaID = PMPE.PuntoEntregaID 
                      JOIN dbo.FI_Factura F ON OC.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista S ON F.Receptor = S.RFC
                      JOIN dbo.CO_TipoCambioMensual TCDD ON F.IdMoneda <> TCDD.IdMoneda
                                                            AND TCDD.IdMes = MONTH(F.Fecha)
                                                            AND TCDD.Anio = YEAR(F.Fecha)
                      JOIN dbo.CO_TipoCambioMensual TCDM ON F.IdMoneda = TCDM.IdMoneda
                                                            AND TCDM.IdMes = MONTH(F.Fecha)
                                                            AND TCDM.Anio = YEAR(F.Fecha)
                 WHERE PMPE.IdContrato = @IdContrato
                 GROUP BY PMPE.IdFecha,
                          CASE
                              WHEN TH.IdTipoHidrocarburo = 10000
                              THEN 'Petroleo'
                              WHEN TH.IdTipoHidrocarburo = 10001
                              THEN 'Condensado'
                              WHEN TH.IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                              THEN 'Gas'
                          END, 
                          S.RazonSocial, 
                          F.Moneda,
                          CASE
                              WHEN F.IdMoneda = 2
                              THEN TCDD.TipoCambio
                              ELSE TCDM.TipoCambio
                          END
                 ORDER BY PMPE.IdFecha;
             END;

         /**/

         IF(@Sem = 1
            AND @IdHoja = 0)
             BEGIN
                 SELECT ROW_NUMBER() OVER(ORDER BY Mes ASC), 
                        Mes, 
                        Producto, 
                        Cliente, 
                        (VolumenFacturado * 1.05587) AS VolumenFacturado, 
                        Precio, 
                        Importe AS Importe, 
                        TipoCambio, 
                        ((ValorTotalDeLaVenta * (VolumenFacturado * 1.05587)) * TipoCambio) AS ValorTotalDeLaVenta
                 FROM #Datos
                 WHERE Producto = 'Gas'
                       AND YEAR(Mes) = @Anio
                       AND (MONTH(Mes) >= 1
                            AND MONTH(Mes) <= 6);
             END;
         IF(@Sem = 2
            AND @IdHoja = 0)
             BEGIN
                 SELECT ROW_NUMBER() OVER(ORDER BY Mes ASC), 
                        Mes, 
                        Producto, 
                        Cliente, 
                        (VolumenFacturado * 1.05587) AS VolumenFacturado, 
                        Precio, 
                        Importe AS Importe, 
                        TipoCambio, 
                        ((ValorTotalDeLaVenta * (VolumenFacturado * 1.05587)) * TipoCambio) AS ValorTotalDeLaVenta
                 FROM #Datos
                 WHERE Producto = 'Gas'
                       AND YEAR(Mes) = @Anio
                       AND (MONTH(Mes) >= 7
                            AND MONTH(Mes) <= 12);
             END;

         /**/

         IF(@Sem = 1
            AND @IdHoja = 2)
             BEGIN
                 SELECT ROW_NUMBER() OVER(ORDER BY Mes ASC), 
                        Mes, 
                        Producto, 
                        Cliente, 
                        VolumenFacturado AS VolumenFacturado, 
                        Precio, 
                        Importe AS Importe, 
                        TipoCambio, 
                        ((ValorTotalDeLaVenta * VolumenFacturado) * TipoCambio) AS ValorTotalDeLaVenta
                 FROM #Datos
                 WHERE Producto = 'Petroleo'
                       AND YEAR(Mes) = @Anio
                       AND (MONTH(Mes) >= 1
                            AND MONTH(Mes) <= 6);
             END;
         IF(@Sem = 2
            AND @IdHoja = 2)
             BEGIN
                 SELECT ROW_NUMBER() OVER(ORDER BY Mes ASC), 
                        Mes, 
                        Producto, 
                        Cliente, 
                        VolumenFacturado AS VolumenFacturado, 
                        Precio, 
                        Importe AS Importe, 
                        TipoCambio, 
                        ((ValorTotalDeLaVenta * VolumenFacturado) * TipoCambio) AS ValorTotalDeLaVenta
                 FROM #Datos
                 WHERE Producto = 'Petroleo'
                       AND YEAR(Mes) = @Anio
                       AND (MONTH(Mes) >= 7
                            AND MONTH(Mes) <= 12);
             END;

         /**/

         IF(@Sem = 1
            AND @IdHoja = 1)
             BEGIN
                 SELECT ROW_NUMBER() OVER(ORDER BY Mes ASC), 
                        Mes, 
                        Producto, 
                        Cliente, 
                        (VolumenFacturado * 6.1178632) AS VolumenFacturado, 
                        Precio, 
                        Importe AS Importe, 
                        TipoCambio, 
                        ((ValorTotalDeLaVenta * (VolumenFacturado * 6.1178632)) * TipoCambio) AS ValorTotalDeLaVenta
                 FROM #Datos
                 WHERE Producto = 'Condensado'
                       AND YEAR(Mes) = @Anio
                       AND (MONTH(Mes) >= 1
                            AND MONTH(Mes) <= 6);
             END;
         IF(@Sem = 2
            AND @IdHoja = 1)
             BEGIN
                 SELECT ROW_NUMBER() OVER(ORDER BY Mes ASC), 
                        Mes, 
                        Producto, 
                        Cliente, 
                        (VolumenFacturado * 6.1178632) AS VolumenFacturado, 
                        Precio, 
                        Importe AS Importe, 
                        TipoCambio, 
                        ((ValorTotalDeLaVenta * (VolumenFacturado * 6.1178632)) * TipoCambio) AS ValorTotalDeLaVenta
                 FROM #Datos
                 WHERE Producto = 'Condensado'
                       AND YEAR(Mes) = @Anio
                       AND (MONTH(Mes) >= 7
                            AND MONTH(Mes) <= 12);
             END;
     END;