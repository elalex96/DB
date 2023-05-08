--╔══════════════════════════════════╗
--║Create Author: Marcos Garcia      ║
--║Create date:   2020-03-18         ║
--║Description:	  Consulta ICN Murphy║
--╚══════════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_SE_ICN_Murphy]
--[SP_SE_ICN_Murphy] 0,0,3,'2019-01-01','2019-12-01'
@IdContrato INT, 
@IdUsuario  INT, 
@IdHoja     INT, 
@FInicio    DATE, 
@FFin       DATE
AS
     BEGIN
         SET NOCOUNT ON;
         --╔═════════════════════════════╗
         --║Limpieza de Tablas Temporales║
         --╚═════════════════════════════╝
         IF OBJECT_ID('tempdb..#TMurphyA2', 'U') IS NOT NULL
             DROP TABLE #TMurphyA2;
         IF OBJECT_ID('tempdb..#FINALA2', 'U') IS NOT NULL
             DROP TABLE #FINALA2;
         IF OBJECT_ID('tempdb..#TMurphyA3', 'U') IS NOT NULL
             DROP TABLE #TMurphyA3;
         IF OBJECT_ID('tempdb..#FINALA3', 'U') IS NOT NULL
             DROP TABLE #FINALA3;
         IF OBJECT_ID('tempdb..#TMurphyA5', 'U') IS NOT NULL
             DROP TABLE #TMurphyA5;
         IF OBJECT_ID('tempdb..#FINALA5', 'U') IS NOT NULL
             DROP TABLE #FINALA5;
         IF OBJECT_ID('tempdb..#Anexo6', 'U') IS NOT NULL
             DROP TABLE #Anexo6;
         IF OBJECT_ID('tempdb..#Anexo7', 'U') IS NOT NULL
             DROP TABLE #Anexo7;
         --╔══════════════════════════════════════════╗
         --║Anexo 1 - Porcentaje de Contenido Nacional║
         --╚══════════════════════════════════════════╝
         IF(@IdHoja = 1)
             BEGIN
                 SELECT DISTINCT 
                        C.NumeroContrato, 
                        CAST(@FInicio AS DATE) AS Inicio, 
                        CAST(@FFin AS DATE) AS Fin, 
                        PPA.PCNMinimo AS PCNC, 
                        PPP.Anios AS DuracionEtapa, 
                        UPPER(CONCAT(CC.Representante, ', ', CC.PuestoRepresentante, ', ', CC.RazonSocial)) AS Firma
                 FROM dbo.CO_Registro R
                      JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMes
                      JOIN Adinco.dbo.CO_Presupuesto P ON L.IdPresupuesto = P.IdPresupuesto
                      JOIN Adinco.dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad
                      JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON PA.IdTipoProgramaActividad = TPA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON TPA.IdTipoProgramaActividad = PPP.IdTipoPgrogramaActividad
                      LEFT JOIN Adinco.dbo.CO_PCNPeriodosPorAnios PPA ON PPP.IdPCNPorPeriodo = PPA.IdPCNPorPeriodo
                      LEFT JOIN Adinco.dbo.CO_Contrato C ON PPP.IdContrato = C.IdContrato
                      LEFT JOIN Adinco.dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
                 WHERE C.IdContrato = 10039
                       AND PPA.Anio = YEAR(@FInicio);
             END;
         --╔══════════════════════════════════════════════╗
         --║Anexo 2 - Contenido Nacional en Bienes Finales║         
         --╚══════════════════════════════════════════════╝
         IF(@IdHoja = 2)
             BEGIN
                 CREATE TABLE #TMurphyA2
                 (Codigo            NVARCHAR(100), 
                  Descripcion       NVARCHAR(300), 
                  RazonSocial       NVARCHAR(MAX), 
                  RFC               VARCHAR(30), 
                  ValorFacturaPesos MONEY, 
                  PCN               FLOAT, 
                  CN                FLOAT, 
                  IdFactura         INT
                 );
                 INSERT INTO #TMurphyA2
                 (Codigo, 
                  Descripcion, 
                  RazonSocial, 
                  RFC, 
                  ValorFacturaPesos, 
                  PCN, 
                  CN, 
                  IdFactura
                 )
                        SELECT A.Codigo, 
                               A.Nombre AS Descripcion, 
                               PE.RazonSocial, 
                               PE.RFC, 
                               VP.ValorFactura AS ValorFacturaPesos, 
                               APD.PCN, 
                               (APD.PCN * VP.ValorFactura) AS CN, 
                               F.IdFactura
                        FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD(NOLOCK)
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                             JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP(NOLOCK) ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC(NOLOCK) ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                                                                                          AND AC.IdEstatus = 2
                             JOIN Petrovendor.dbo.MM_BS_Actividad A(NOLOCK) ON VP.IdCatalogoHidrocarburos = A.IdActividad
                             JOIN Petrovendor.dbo.FI_Factura F(NOLOCK) ON AF.IdFactura = F.IdFactura
                             JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN(NOLOCK) ON APD.ClasificacionCN = CN.IdClasificacionSH
                             JOIN Petrovendor.dbo.S_Documento_S3 S3(NOLOCK) ON AC.IdDocumento = S3.IdDocumento
                             JOIN Petrovendor.dbo.S_Proveedor PE(NOLOCK) ON F.Emisor = PE.RFC
                             JOIN Petrovendor.dbo.S_Proveedor PR(NOLOCK) ON F.Receptor = PR.RFC
                             JOIN Adinco.dbo.CO_TipoCambioDiario TCD(NOLOCK) ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                                AND TCD.IdMoneda <> F.IdMoneda
                                                                                AND TCD.IdMoneda <> 10000
                        WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                              AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                             AND F.IdContrato = 10039
                             AND APD.PCN <> 0
                             AND CN.ClasificacionNombreL = 'Bienes';                        
                 --Tabla Temporal Final
                 SELECT T.Codigo, 
                        T.Descripcion, 
                        T.RazonSocial, 
                        T.RFC, 
                        SUM(T.ValorFacturaPesos) AS ValorFacturaPesos, 
                        SUM(T.ValorFacturaPesos * PCN) AS PCN, 
                        T.IdFactura
                 INTO #FINALA2
                 FROM #TMurphyA2 T
                 GROUP BY T.Codigo, 
                          T.Descripcion, 
                          T.RazonSocial, 
                          T.RFC, 
                          T.IdFactura;                         
                 --== Select Final
                 SELECT Codigo, 
                        Descripcion, 
                        RazonSocial, 
                        RFC, 
                        SUM(ValorFacturaPesos) AS ValorFacturaPesos, 
                        CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)))+3) AS FLOAT) AS PCN, 
                        (SUM(ValorFacturaPesos)*CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)))+3) AS FLOAT)) AS CN, 
                        IdFactura
                 FROM #FINALA2
                 GROUP BY Codigo, 
                          Descripcion, 
                          RazonSocial, 
                          RFC, 
                          IdFactura
                 ORDER BY IdFactura, 
                          RFC ASC, 
                          Descripcion;
                 --==
                 --SUMA TOTAL INCLUYENDO FACTURAS CON CONTENIDO EN 0
                 SELECT SUM(VP.ValorFactura) AS ValorFacturaPesos, 
                        CN.ClasificacionNombreL
                 FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD(NOLOCK)
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                      JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP(NOLOCK) ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC(NOLOCK) ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                                                                                   AND AC.IdEstatus = 2
                      JOIN Petrovendor.dbo.MM_BS_Actividad A(NOLOCK) ON VP.IdCatalogoHidrocarburos = A.IdActividad
                      JOIN Petrovendor.dbo.FI_Factura F(NOLOCK) ON AF.IdFactura = F.IdFactura
                      JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN(NOLOCK) ON APD.ClasificacionCN = CN.IdClasificacionSH
                      JOIN Petrovendor.dbo.S_Documento_S3 S3(NOLOCK) ON AC.IdDocumento = S3.IdDocumento
                      JOIN Petrovendor.dbo.S_Proveedor PE(NOLOCK) ON F.Emisor = PE.RFC
                      JOIN Petrovendor.dbo.S_Proveedor PR(NOLOCK) ON F.Receptor = PR.RFC
                      JOIN Adinco.dbo.CO_TipoCambioDiario TCD(NOLOCK) ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                         AND TCD.IdMoneda <> F.IdMoneda
                                                                         AND TCD.IdMoneda <> 10000
                 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                       AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND F.IdContrato = 10039
                      --AND APD.PCN <> 0
                      AND CN.ClasificacionNombreL = 'Bienes'
                 GROUP BY CN.ClasificacionNombreL;
             END;
         --╔═════════════════════════════════════════╗
         --║Anexo 3 - Contenido Nacional en Servicios║         
         --╚═════════════════════════════════════════╝
         IF(@IdHoja = 3)
             BEGIN
                 CREATE TABLE #TMurphyA3
                 (Codigo            NVARCHAR(100), 
                  Descripcion       NVARCHAR(300), 
                  RazonSocial       NVARCHAR(MAX), 
                  RFC               VARCHAR(30), 
                  ValorFacturaPesos MONEY, 
                  PCN               FLOAT, 
                  CN                FLOAT, 
                  IdFactura         INT
                 );
                 INSERT INTO #TMurphyA3
                 (Codigo, 
                  Descripcion, 
                  RazonSocial, 
                  RFC, 
                  ValorFacturaPesos, 
                  PCN, 
                  CN, 
                  IdFactura
                 )
                        SELECT A.Codigo, 
                               A.Nombre AS Descripcion, 
                               PE.RazonSocial, 
                               PE.RFC, 
                               VP.ValorFactura AS ValorFacturaPesos, 
                               APD.PCN, 
                               (APD.PCN * VP.ValorFactura) AS CN, 
                               F.IdFactura
                        FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD(NOLOCK)
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                             JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP(NOLOCK) ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC(NOLOCK) ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                                                                                          AND AC.IdEstatus = 2
                             JOIN Petrovendor.dbo.MM_BS_Actividad A(NOLOCK) ON VP.IdCatalogoHidrocarburos = A.IdActividad
                             JOIN Petrovendor.dbo.FI_Factura F(NOLOCK) ON AF.IdFactura = F.IdFactura
                             JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN(NOLOCK) ON APD.ClasificacionCN = CN.IdClasificacionSH
                             JOIN Petrovendor.dbo.S_Documento_S3 S3(NOLOCK) ON AC.IdDocumento = S3.IdDocumento
                             JOIN Petrovendor.dbo.S_Proveedor PE(NOLOCK) ON F.Emisor = PE.RFC
                             JOIN Petrovendor.dbo.S_Proveedor PR(NOLOCK) ON F.Receptor = PR.RFC
                             JOIN Adinco.dbo.CO_TipoCambioDiario TCD(NOLOCK) ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                                AND TCD.IdMoneda <> F.IdMoneda
                                                                                AND TCD.IdMoneda <> 10000
                        WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                              AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                             AND F.IdContrato = 10039
                             AND APD.PCN <> 0
                             AND CN.ClasificacionNombreL = 'Servicios';  
                 --Tabla Temporal Final
                 SELECT T.Codigo, 
                        T.Descripcion, 
                        T.RazonSocial, 
                        T.RFC, 
                        SUM(T.ValorFacturaPesos) AS ValorFacturaPesos, 
                        SUM(T.ValorFacturaPesos * PCN) AS PCN, 
                        T.IdFactura
                 INTO #FINALA3
                 FROM #TMurphyA3 T
                 GROUP BY T.Codigo, 
                          T.Descripcion, 
                          T.RazonSocial, 
                          T.RFC, 
                          T.IdFactura;                          
                 --== Select Final
                 SELECT Codigo, 
                        Descripcion, 
                        RazonSocial, 
                        RFC, 
                        SUM(ValorFacturaPesos) AS ValorFacturaPesos, 
                        CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)))+3) AS FLOAT) AS PCN, 
                        (SUM(ValorFacturaPesos)*CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)))+3) AS FLOAT)) AS CN, 
                        IdFactura
                 FROM #FINALA3
                 GROUP BY Codigo, 
                          Descripcion, 
                          RazonSocial, 
                          RFC, 
                          IdFactura
                 ORDER BY IdFactura, 
                          RFC, 
                          Descripcion;
                 --==
                 --SUMA TOTAL INCLUYENDO FACTURAS CON CONTENIDO EN 0
                 SELECT SUM(VP.ValorFactura) AS ValorFacturaPesos, 
                        CN.ClasificacionNombreL
                 FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD(NOLOCK)
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                      JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP(NOLOCK) ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC(NOLOCK) ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                                                                                   AND AC.IdEstatus = 2
                      JOIN Petrovendor.dbo.MM_BS_Actividad A(NOLOCK) ON VP.IdCatalogoHidrocarburos = A.IdActividad
                      JOIN Petrovendor.dbo.FI_Factura F(NOLOCK) ON AF.IdFactura = F.IdFactura
                      JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN(NOLOCK) ON APD.ClasificacionCN = CN.IdClasificacionSH
                      JOIN Petrovendor.dbo.S_Documento_S3 S3(NOLOCK) ON AC.IdDocumento = S3.IdDocumento
                      JOIN Petrovendor.dbo.S_Proveedor PE(NOLOCK) ON F.Emisor = PE.RFC
                      JOIN Petrovendor.dbo.S_Proveedor PR(NOLOCK) ON F.Receptor = PR.RFC
                      JOIN Adinco.dbo.CO_TipoCambioDiario TCD(NOLOCK) ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                         AND TCD.IdMoneda <> F.IdMoneda
                                                                         AND TCD.IdMoneda <> 10000
                 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                       AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND F.IdContrato = 10039
                      --AND APD.PCN <> 0
                      AND CN.ClasificacionNombreL = 'Servicios'
                 GROUP BY CN.ClasificacionNombreL;
             END;
         --╔════════════════════════════════════════════╗
         --║Anexo 4 - Contenido Nacional en Mano de Obra║
         --╚════════════════════════════════════════════╝
         IF(@IdHoja = 4)
             BEGIN
                 DECLARE @Cero DECIMAL(20, 2)= 0;
                 SELECT @Cero AS SueldosSalarios, 
                        @Cero AS SueldosSalariosNacional, 
                        GR.IdGastoRubro
                 FROM Adinco.dbo.CO_GastosRubro GR
                 WHERE GR.IdGastoRubro NOT IN(6, 7)
                 ORDER BY GR.IdGastoRubro DESC;
             END;
         --╔═════════════════════════════════════════════════════════╗
         --║Anexo 5 - Contenido Nacional en Servicios de Capacitacíon║
         --╚═════════════════════════════════════════════════════════╝
         IF(@IdHoja = 5)
             BEGIN
                 CREATE TABLE #TMurphyA5
                 (NoCapacitacion    NVARCHAR(300), 
                  Codigo            NVARCHAR(100), 
                  Descripcion       NVARCHAR(300), 
                  RazonSocial       NVARCHAR(MAX), 
                  RFC               VARCHAR(30), 
                  ValorFacturaPesos MONEY, 
                  PCN               FLOAT, 
                  CN                FLOAT, 
                  IdFactura         INT
                 );
                 INSERT INTO #TMurphyA5
                 (NoCapacitacion, 
                  Codigo, 
                  Descripcion, 
                  RazonSocial, 
                  RFC, 
                  ValorFacturaPesos, 
                  PCN, 
                  CN, 
                  IdFactura
                 )
                        SELECT ROW_NUMBER() OVER(ORDER BY A.Nombre) AS NoCapacitacion, 
                               A.Codigo, 
                               A.Nombre AS Descripcion, 
                               PE.RazonSocial, 
                               PE.RFC, 
                               VP.ValorFactura AS ValorFacturaPesos, 
                               APD.PCN, 
                               (APD.PCN * VP.ValorFactura) AS CN, 
                               F.IdFactura
                        FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD(NOLOCK)
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                             JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP(NOLOCK) ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                             JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC(NOLOCK) ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                                                                                          AND AC.IdEstatus = 2
                             JOIN Petrovendor.dbo.MM_BS_Actividad A(NOLOCK) ON VP.IdCatalogoHidrocarburos = A.IdActividad
                             JOIN Petrovendor.dbo.FI_Factura F(NOLOCK) ON AF.IdFactura = F.IdFactura
                             JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN(NOLOCK) ON APD.ClasificacionCN = CN.IdClasificacionSH
                             JOIN Petrovendor.dbo.S_Documento_S3 S3(NOLOCK) ON AC.IdDocumento = S3.IdDocumento
                             JOIN Petrovendor.dbo.S_Proveedor PE(NOLOCK) ON F.Emisor = PE.RFC
                             JOIN Petrovendor.dbo.S_Proveedor PR(NOLOCK) ON F.Receptor = PR.RFC
                             JOIN Adinco.dbo.CO_TipoCambioDiario TCD(NOLOCK) ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                                AND TCD.IdMoneda <> F.IdMoneda
                                                                                AND TCD.IdMoneda <> 10000
                        WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                              AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                             AND F.IdContrato = 10039
                             AND APD.PCN <> 0
                             AND CN.ClasificacionNombreL = 'Capacitación';                      
                 --Tabla Temporal Final
                 SELECT T.NoCapacitacion, 
                        T.Codigo, 
                        T.Descripcion, 
                        T.RazonSocial, 
                        T.RFC, 
                        SUM(T.ValorFacturaPesos) AS ValorFacturaPesos, 
                        SUM(T.ValorFacturaPesos * PCN) AS PCN, 
                        T.IdFactura
                 INTO #FINALA5
                 FROM #TMurphyA5 T
                 GROUP BY T.NoCapacitacion, 
                          T.Codigo, 
                          T.Descripcion, 
                          T.RazonSocial, 
                          T.RFC, 
                          T.IdFactura;
                 --== Select Final
                 SELECT NoCapacitacion, 
                        Codigo, 
                        Descripcion, 
                        RazonSocial, 
                        RFC, 
                        SUM(ValorFacturaPesos) AS ValorFacturaPesos, 
                        CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)))+3) AS FLOAT) AS PCN, 
                        (SUM(ValorFacturaPesos)*CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(ValorFacturaPesos)))+3) AS FLOAT)) AS CN, 
                        IdFactura
                 FROM #FINALA5
                 GROUP BY NoCapacitacion, 
                          Codigo, 
                          Descripcion, 
                          RazonSocial, 
                          RFC, 
                          IdFactura
                 ORDER BY IdFactura, 
                          RFC, 
                          Descripcion;
                 --==
                 --SUMA TOTAL INCLUYENDO FACTURAS CON CONTENIDO EN 0
                 SELECT SUM(VP.ValorFactura) AS ValorFacturaPesos, 
                        CN.ClasificacionNombreL
                 FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD(NOLOCK)
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF(NOLOCK) ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                      JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP(NOLOCK) ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                      JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC(NOLOCK) ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                                                                                   AND AC.IdEstatus = 2
                      JOIN Petrovendor.dbo.MM_BS_Actividad A(NOLOCK) ON VP.IdCatalogoHidrocarburos = A.IdActividad
                      JOIN Petrovendor.dbo.FI_Factura F(NOLOCK) ON AF.IdFactura = F.IdFactura
                      JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN(NOLOCK) ON APD.ClasificacionCN = CN.IdClasificacionSH
                      JOIN Petrovendor.dbo.S_Documento_S3 S3(NOLOCK) ON AC.IdDocumento = S3.IdDocumento
                      JOIN Petrovendor.dbo.S_Proveedor PE(NOLOCK) ON F.Emisor = PE.RFC
                      JOIN Petrovendor.dbo.S_Proveedor PR(NOLOCK) ON F.Receptor = PR.RFC
                      JOIN Adinco.dbo.CO_TipoCambioDiario TCD(NOLOCK) ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                         AND TCD.IdMoneda <> F.IdMoneda
                                                                         AND TCD.IdMoneda <> 10000
                 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                       AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND F.IdContrato = 10039
                      --AND APD.PCN <> 0
                      AND CN.ClasificacionNombreL = 'Capacitación'
                 GROUP BY CN.ClasificacionNombreL;
             END;
         --╔═════════════════════════════════════╗
         --║Anexo 6 - Transferencia de Tecnología║
         --╚═════════════════════════════════════╝
         IF(@IdHoja = 6)
             BEGIN
                 CREATE TABLE #Anexo6
                 (NoGasto     NVARCHAR(MAX), 
                  Descripcion NVARCHAR(MAX), 
                  Subtotal    DECIMAL(18, 4)
                 );
                 SELECT NoGasto, 
                        Descripcion, 
                        SubTotal
                 FROM #Anexo6;
             END;
         --╔═══════════════════════════════════════════════════════════════════════════════╗
         --║Anexo 7 - Inversión en Infraestructura Física Local y regional en el Territorio║
         --╚═══════════════════════════════════════════════════════════════════════════════╝
         IF(@IdHoja = 7)
             BEGIN
                 CREATE TABLE #Anexo7
                 (NoGasto     NVARCHAR(MAX), 
                  Descripcion NVARCHAR(MAX), 
                  Subtotal    DECIMAL(18, 4)
                 );
                 SELECT NoGasto, 
                        Descripcion, 
                        SubTotal
                 FROM #Anexo7;
             END;
     END;