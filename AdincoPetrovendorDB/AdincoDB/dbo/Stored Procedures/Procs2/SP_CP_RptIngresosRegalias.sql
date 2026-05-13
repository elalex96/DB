-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-12-06
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CP_RptIngresosRegalias 
-- SP_CP_RptIngresosRegalias 3,1,'2018-01-01','2018-12-01',0
-- SP_CP_RptIngresosRegalias 3,1,'2018-01-01','2018-12-01',1
-- SP_CP_RptIngresosRegalias 10021,1,'2018-01-01','2018-12-01',1
-- SP_CP_RptIngresosRegalias 10014,1,'2018-01-01','2018-12-01',0
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@MesInicio  DATE, 
@MesFinal   DATE, 
@Tipo       INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         /*Creación de tablas*/

         CREATE TABLE #Datos
         (Volumen          FLOAT, 
          PrecioUnitario   FLOAT, 
          IngresoBruto     FLOAT, 
          Mes              DATE, 
          IdContrato       INT, 
          NumeroContrato   NVARCHAR(50), 
          Unidad           NVARCHAR(50), 
          Hidrocarburo     NVARCHAR(50), 
          RegaliaBase      FLOAT, 
          RegaliaAdicional FLOAT, 
          Penalidad        FLOAT, 
          IngresoNeto      FLOAT
         );

         /**/

         CREATE TABLE #Regalias
         (Hidrocarburo     NVARCHAR(50), 
          RegaliaBase      FLOAT, 
          RegaliaAdicional FLOAT, 
          Mes              DATE, 
          NumeroContrato   NVARCHAR(50)
         );

         /**/

         CREATE TABLE #Penalidades
         (Hidrocarburo   NVARCHAR(50), 
          Penalidad      FLOAT, 
          Mes            DATE, 
          NumeroContrato NVARCHAR(50)
         );

         /**/

         CREATE TABLE #DatosPivote
         (Volumen          FLOAT, 
          PrecioUnitario   FLOAT, 
          IngresoBruto     FLOAT, 
          Mes              DATE, 
          NumeroContrato   NVARCHAR(50), 
          Unidad           NVARCHAR(50), 
          Hidrocarburo     NVARCHAR(50), 
          RegaliaBase      FLOAT, 
          RegaliaAdicional FLOAT, 
          Penalidad        FLOAT, 
          IngresoNeto      FLOAT
         );

         /**/

         DECLARE @IdContratista INT;
         SELECT @IdContratista = C.IdContratista
         FROM dbo.CO_Contrato C
              JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
         WHERE C.IdContrato = @IdContrato;

         /**/

         DECLARE @Contratos INT;
         SELECT @Contratos = COUNT(IdContrato)
         FROM dbo.CO_Contrato
         WHERE IdContrato IN(10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024)
         AND IdContrato = @IdContrato;

         /**/

         IF(@Tipo = 0)
             BEGIN

                 /*Volumen e Ingreso bruto por Hidrocarburo*/

                 INSERT INTO #Datos
                 (Volumen, 
                  PrecioUnitario, 
                  IngresoBruto, 
                  Mes, 
                  IdContrato, 
                  NumeroContrato, 
                  Unidad, 
                  Hidrocarburo, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  Penalidad, 
                  IngresoNeto
                 )
                        SELECT ISNULL(PMS.VolumenProgramado, 0) AS Volumen, 
                               0 AS PrecioUnitario,
                               CASE
                                   WHEN PH.ProductoNominacionID = 1000
                                   THEN ISNULL(CV.PrecioGas, 0)
                                   WHEN PH.ProductoNominacionID = 1001
                                   THEN ISNULL(CV.PrecioPetroleo, 0)
                                   WHEN PH.ProductoNominacionID = 1002
                                   THEN ISNULL(CV.PrecioCondensado, 0)
                                   ELSE 0
                               END AS IngresoBruto, 
                               PMS.idFecha AS Mes, 
                               CON.IdContrato, 
                               CON.NumeroContrato, 
                               UM.Abreviatura, 
                               PH.nombre, 
                               0 AS RegaliaBase, 
                               0 AS RegaliaAdicional, 
                               0 AS Penalidad, 
                               0 AS IngresoNeto
                        FROM dbo.CO_CromatografiaValores CV
                             JOIN dbo.CO_Cromatografia C ON C.IdCromatografia = CV.IdCromatografia
                             JOIN dbo.CO_PuntosdeEntregaContrato PEC ON PEC.PuntoEntregaContratoID = CV.IdPuntoEntregaContrato
                             JOIN dbo.PR_ProduccionMensualSipac PMS ON PEC.idContrato = PMS.idContrato
                                                                       AND PMS.PuntoEntregaID = PEC.PuntoEntregaID
                                                                       AND PMS.idFecha = CAST((CONCAT(c.Anio, '-', C.Mes, '-01')) AS DATE)
                             JOIN dbo.CO_UnidadMedida UM ON UM.idUnidadMedida = PMS.idUnidadMedida
                             JOIN dbo.CO_ClasificacionProductoNominacion PH ON PMS.idHidrocarburo = PH.ProductoNominacionID
                             JOIN dbo.CO_Contrato CON ON CON.IdContrato = C.IdContrato
                        WHERE PEC.idContrato = @IdContrato
                              AND PMS.idFecha >= @MesInicio
                              AND PMS.idFecha <= @MesFinal
                        GROUP BY ISNULL(PMS.VolumenProgramado, 0),
                                 CASE
                                     WHEN PH.ProductoNominacionID = 1000
                                     THEN ISNULL(CV.PrecioGas, 0)
                                     WHEN PH.ProductoNominacionID = 1001
                                     THEN ISNULL(CV.PrecioPetroleo, 0)
                                     WHEN PH.ProductoNominacionID = 1002
                                     THEN ISNULL(CV.PrecioCondensado, 0)
                                     ELSE 0
                                 END, 
                                 PMS.idFecha, 
                                 CON.IdContrato, 
                                 CON.NumeroContrato, 
                                 UM.Abreviatura, 
                                 PH.nombre;

                 /*Regalia base y adicional*/

                 INSERT INTO #Regalias
                 (Hidrocarburo, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  Mes
                 )
                        SELECT CASE
                                   WHEN TH.TipoHidrocarburo IN(3, 4, 5, 6)
                                   THEN 'Gas'
                                   WHEN TH.TipoHidrocarburo IN(1)
                                   THEN 'Aceite'
                                   WHEN TH.TipoHidrocarburo IN(2)
                                   THEN 'Condensado'
                               END AS nombre, 
                               SUM(ROUND((ISNULL(MCH.TasaRegalia, 0) / 100) * (ROUND(ISNULL(MCH.Precio, 0), 2) * ISNULL(MCH.Volumen, 0)), 2)) AS RegaliaBase, 
                               SUM(ROUND((ISNULL(C.ValorRegaliaAdicional, 0) / 100) * (ROUND(ISNULL(MCH.Precio, 0), 2) * ISNULL(MCH.Volumen, 0)), 2)) AS RegaliaAdicional, 
                               MCH.Mes
                        FROM dbo.CP_MetodoCalculoHidrocarburoMes MCH
                             JOIN dbo.CO_TipoHidrocarburo TH ON MCH.IdTipoHidrocarburo = TH.TipoHidrocarburo
                             JOIN dbo.CO_Contrato C ON C.IdContrato = MCH.IdContrato
                        WHERE MCH.IdContrato = @IdContrato
                              AND MCH.Mes >= @MesInicio
                              AND MCH.Mes <= @MesFinal
                        GROUP BY CASE
                                     WHEN TH.TipoHidrocarburo IN(3, 4, 5, 6)
                                     THEN 'Gas'
                                     WHEN TH.TipoHidrocarburo IN(1)
                                     THEN 'Aceite'
                                     WHEN TH.TipoHidrocarburo IN(2)
                                     THEN 'Condensado'
                                 END, 
                                 MCH.Mes;
                 --
                 UPDATE D
                   SET 
                       D.RegaliaBase = ISNULL(RB.RegaliaBase, 0), 
                       D.RegaliaAdicional = ISNULL(RB.RegaliaAdicional, 0)
                 FROM #Regalias RB
                      JOIN #Datos D ON D.Mes = RB.Mes
                                       AND D.Hidrocarburo = RB.Hidrocarburo;

                 /*Penalidades*/

                 INSERT INTO #Penalidades
                 (Hidrocarburo, 
                  Penalidad, 
                  Mes
                 )
                        SELECT CASE
                                   WHEN IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                                   THEN 'Gas'
                                   WHEN IdTipoHidrocarburo IN(10000)
                                   THEN 'Aceite'
                                   WHEN IdTipoHidrocarburo IN(10001)
                                   THEN 'Condensado'
                               END AS nombre, 
                               SUM(CASE
                                       WHEN IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                                       THEN ISNULL(PenaEconomica, 0)
                                       WHEN IdTipoHidrocarburo IN(10000)
                                       THEN ISNULL(PenaEconomica, 0)
                                       WHEN IdTipoHidrocarburo IN(10001)
                                       THEN ISNULL(PenaEconomica, 0)
                                   END) AS Penalidad, 
                               MesReporte AS Mes
                        FROM dbo.COM_OperacionComercializacion
                        WHERE IdContrato = @IdContrato
                              AND MesReporte >= @MesInicio
                              AND MesReporte <= @MesFinal
                        GROUP BY CASE
                                     WHEN IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                                     THEN 'Gas'
                                     WHEN IdTipoHidrocarburo IN(10000)
                                     THEN 'Aceite'
                                     WHEN IdTipoHidrocarburo IN(10001)
                                     THEN 'Condensado'
                                 END, 
                                 MesReporte
                        ORDER BY MesReporte;
                 --
                 UPDATE D
                   SET 
                       D.Penalidad = ISNULL(P.Penalidad, 0)
                 FROM #Penalidades AS P
                      JOIN #Datos D ON D.Mes = P.Mes
                                       AND D.Hidrocarburo = P.Hidrocarburo;

                 /*Datos finales*/

                 INSERT INTO #DatosPivote
                 (Volumen, 
                  PrecioUnitario, 
                  IngresoBruto, 
                  Mes, 
                  NumeroContrato, 
                  Unidad, 
                  Hidrocarburo, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  Penalidad, 
                  IngresoNeto
                 )
                        SELECT(SUM(Volumen) * 1000) AS Volumen,
                              CASE
                                  WHEN SUM(IngresoBruto) = 0
                                  THEN 0
                                  ELSE(SUM(IngresoBruto) / (SUM(Volumen) * 1000))
                              END AS PrecioUnitario, 
                              SUM(IngresoBruto) AS IngresoBruto, 
                              Mes, 
                              NumeroContrato, 
                              Unidad AS Unidad, 
                              Hidrocarburo AS Hidrocarburo, 
                              RegaliaBase, 
                              RegaliaAdicional, 
                              Penalidad, 
                              (SUM(IngresoBruto) - RegaliaBase - RegaliaAdicional - Penalidad) AS IngresoNeto
                        FROM #Datos
                        GROUP BY Mes, 
                                 NumeroContrato, 
                                 Unidad, 
                                 Hidrocarburo, 
                                 RegaliaBase, 
                                 RegaliaAdicional, 
                                 Penalidad;

                 /**/

                 SELECT

/*CASE
                    WHEN UnPivotTable.Tipo = 'Volumen'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), '###,###.####')
                    WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'IngresoBruto'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'RegaliaBase'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'Penalidad'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'IngresoNeto'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                END*/

                 Valores AS Valores,
                 CASE
                     WHEN UnPivotTable.Tipo = 'Volumen'
                     THEN 'Volúmen'
                     WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                     THEN 'Precio'
                     WHEN UnPivotTable.Tipo = 'IngresoBruto'
                     THEN 'Ingreso Bruto'
                     WHEN UnPivotTable.Tipo = 'RegaliaBase'
                     THEN 'Regalia Base'
                     WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                     THEN 'Regalia Adicional'
                     WHEN UnPivotTable.Tipo = 'Penalidad'
                     THEN 'Penalidad'
                     WHEN UnPivotTable.Tipo = 'IngresoNeto'
                     THEN 'Ingreso Neto'
                 END AS Tipo, 
                 NumeroContrato, 
                 Unidad, 
                 Hidrocarburo, 
                 Mes,
                 CASE
                     WHEN UnPivotTable.Tipo = 'Volumen'
                     THEN '[BBL] / [MMPC]'
                     WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                     THEN '[USD/BBL] / [USD/MPC]'
                     WHEN UnPivotTable.Tipo = 'IngresoBruto'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'RegaliaBase'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'Penalidad'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'IngresoNeto'
                     THEN '[USD]'
                 END AS Unidades,
                 CASE
                     WHEN UnPivotTable.Tipo = 'Volumen'
                     THEN 1
                     WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                     THEN 2
                     WHEN UnPivotTable.Tipo = 'IngresoBruto'
                     THEN 3
                     WHEN UnPivotTable.Tipo = 'RegaliaBase'
                     THEN 4
                     WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                     THEN 5
                     WHEN UnPivotTable.Tipo = 'Penalidad'
                     THEN 6
                     WHEN UnPivotTable.Tipo = 'IngresoNeto'
                     THEN 7
                 END AS Orden
                 FROM
                 (
                     SELECT Volumen, 
                            PrecioUnitario, 
                            IngresoBruto, 
                            Mes, 
                            NumeroContrato, 
                            Unidad, 
                            Hidrocarburo, 
                            RegaliaBase, 
                            RegaliaAdicional, 
                            Penalidad, 
                            IngresoNeto
                     FROM #DatosPivote
                 ) AS SourceTable UNPIVOT(Valores FOR Tipo IN(Volumen, 
                                                              PrecioUnitario, 
                                                              IngresoBruto, 
                                                              RegaliaBase, 
                                                              RegaliaAdicional, 
                                                              Penalidad, 
                                                              IngresoNeto)) AS UnPivotTable
                 ORDER BY Mes;
             END;

                 /*Reporte por contratista*/

             ELSE
             BEGIN

                 /*Volumen e Ingreso bruto por Hidrocarburo*/

                 INSERT INTO #Datos
                 (Volumen, 
                  PrecioUnitario, 
                  IngresoBruto, 
                  Mes, 
                  IdContrato, 
                  NumeroContrato, 
                  Unidad, 
                  Hidrocarburo, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  Penalidad, 
                  IngresoNeto
                 )
                 SELECT ISNULL(PMS.VolumenProgramado, 0) AS Volumen, 
                        0 AS PrecioUnitario,
                        CASE
                            WHEN PH.ProductoNominacionID = 1000
                            THEN ISNULL(CV.PrecioGas, 0)
                            WHEN PH.ProductoNominacionID = 1001
                            THEN ISNULL(CV.PrecioPetroleo, 0)
                            WHEN PH.ProductoNominacionID = 1002
                            THEN ISNULL(CV.PrecioCondensado, 0)
                            ELSE 0
                        END AS IngresoBruto, 
                        PMS.idFecha AS Mes, 
                        CON.IdContrato, 
                        CON.NumeroContrato, 
                        UM.Abreviatura, 
                        PH.nombre, 
                        0 AS RegaliaBase, 
                        0 AS RegaliaAdicional, 
                        0 AS Penalidad, 
                        0 AS IngresoNeto
                 FROM dbo.CO_CromatografiaValores CV
                      JOIN dbo.CO_Cromatografia C ON C.IdCromatografia = CV.IdCromatografia
                      JOIN dbo.CO_PuntosdeEntregaContrato PEC ON PEC.PuntoEntregaContratoID = CV.IdPuntoEntregaContrato
                      JOIN dbo.PR_ProduccionMensualSipac PMS ON PEC.idContrato = PMS.idContrato
                                                                AND PMS.PuntoEntregaID = PEC.PuntoEntregaID
                                                                AND PMS.idFecha = CAST((CONCAT(c.Anio, '-', C.Mes, '-01')) AS DATE)
                      JOIN dbo.CO_UnidadMedida UM ON UM.idUnidadMedida = PMS.idUnidadMedida
                      JOIN dbo.CO_ClasificacionProductoNominacion PH ON PMS.idHidrocarburo = PH.ProductoNominacionID
                      JOIN dbo.CO_Contrato CON ON CON.IdContrato = C.IdContrato
                 WHERE(CON.IdContratista = @IdContratista
                       OR (CON.IdContrato IN(10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024)
                      AND @Contratos > 0))
                      AND PMS.idFecha >= @MesInicio
                      AND PMS.idFecha <= @MesFinal
                 GROUP BY ISNULL(PMS.VolumenProgramado, 0),
                          CASE
                              WHEN PH.ProductoNominacionID = 1000
                              THEN ISNULL(CV.PrecioGas, 0)
                              WHEN PH.ProductoNominacionID = 1001
                              THEN ISNULL(CV.PrecioPetroleo, 0)
                              WHEN PH.ProductoNominacionID = 1002
                              THEN ISNULL(CV.PrecioCondensado, 0)
                              ELSE 0
                          END, 
                          PMS.idFecha, 
                          CON.IdContrato, 
                          CON.NumeroContrato, 
                          UM.Abreviatura, 
                          PH.nombre;

                 /*Regalia base y adicional*/

                 INSERT INTO #Regalias
                 (Hidrocarburo, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  Mes, 
                  NumeroContrato
                 )
                 SELECT CASE
                            WHEN TH.TipoHidrocarburo IN(3, 4, 5, 6)
                            THEN 'Gas'
                            WHEN TH.TipoHidrocarburo IN(1)
                            THEN 'Aceite'
                            WHEN TH.TipoHidrocarburo IN(2)
                            THEN 'Condensado'
                        END AS nombre, 
                        SUM(ROUND((ISNULL(MCH.TasaRegalia, 0) / 100) * (ROUND(ISNULL(MCH.Precio, 0), 2) * ISNULL(MCH.Volumen, 0)), 2)) AS RegaliaBase, 
                        SUM(ROUND((ISNULL(CON.ValorRegaliaAdicional, 0) / 100) * (ROUND(ISNULL(MCH.Precio, 0), 2) * ISNULL(MCH.Volumen, 0)), 2)) AS RegaliaAdicional, 
                        MCH.Mes, 
                        CON.NumeroContrato
                 FROM dbo.CP_MetodoCalculoHidrocarburoMes MCH
                      JOIN dbo.CO_TipoHidrocarburo TH ON MCH.IdTipoHidrocarburo = TH.TipoHidrocarburo
                      JOIN dbo.CO_Contrato CON ON CON.IdContrato = MCH.IdContrato
                 WHERE(CON.IdContratista = @IdContratista
                       OR (CON.IdContrato IN(10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024)
                      AND @Contratos > 0))
                      AND MCH.Mes >= @MesInicio
                      AND MCH.Mes <= @MesFinal
                 GROUP BY CASE
                              WHEN TH.TipoHidrocarburo IN(3, 4, 5, 6)
                              THEN 'Gas'
                              WHEN TH.TipoHidrocarburo IN(1)
                              THEN 'Aceite'
                              WHEN TH.TipoHidrocarburo IN(2)
                              THEN 'Condensado'
                          END, 
                          MCH.Mes, 
                          CON.NumeroContrato
                 --
                 UPDATE D
                   SET 
                       D.RegaliaBase = ISNULL(RB.RegaliaBase, 0), 
                       D.RegaliaAdicional = ISNULL(RB.RegaliaAdicional, 0)
                 FROM #Regalias RB
                      JOIN #Datos D ON D.Mes = RB.Mes
                                       AND D.Hidrocarburo = RB.Hidrocarburo
                                       AND D.NumeroContrato = RB.NumeroContrato

                 /*Penalidades*/

                 INSERT INTO #Penalidades
                 (Hidrocarburo, 
                  Penalidad, 
                  Mes, 
                  NumeroContrato
                 )
                 SELECT CASE
                            WHEN IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                            THEN 'Gas'
                            WHEN IdTipoHidrocarburo IN(10000)
                            THEN 'Aceite'
                            WHEN IdTipoHidrocarburo IN(10001)
                            THEN 'Condensado'
                        END AS nombre, 
                        SUM(CASE
                                WHEN IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                                THEN ISNULL(PenaEconomica, 0)
                                WHEN IdTipoHidrocarburo IN(10000)
                                THEN ISNULL(PenaEconomica, 0)
                                WHEN IdTipoHidrocarburo IN(10001)
                                THEN ISNULL(PenaEconomica, 0)
                            END) AS Penalidad, 
                        MesReporte AS Mes, 
                        CON.NumeroContrato
                 FROM dbo.COM_OperacionComercializacion OC
                      JOIN dbo.CO_Contrato CON ON CON.IdContrato = OC.IdContrato
                 WHERE(CON.IdContratista = @IdContratista
                       OR (CON.IdContrato IN(10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024)
                      AND @Contratos > 0))
                      AND MesReporte >= @MesInicio
                      AND MesReporte <= @MesFinal
                 GROUP BY CASE
                              WHEN IdTipoHidrocarburo IN(10002, 10003, 10004, 10005)
                              THEN 'Gas'
                              WHEN IdTipoHidrocarburo IN(10000)
                              THEN 'Aceite'
                              WHEN IdTipoHidrocarburo IN(10001)
                              THEN 'Condensado'
                          END, 
                          MesReporte, 
                          CON.NumeroContrato
                 ORDER BY MesReporte;
                 --
                 UPDATE D
                   SET 
                       D.Penalidad = ISNULL(P.Penalidad, 0)
                 FROM #Penalidades AS P
                      JOIN #Datos D ON D.Mes = P.Mes
                                       AND D.Hidrocarburo = P.Hidrocarburo
                                       AND D.NumeroContrato = P.NumeroContrato

                 /*Datos finales*/

                 INSERT INTO #DatosPivote
                 (Volumen, 
                  PrecioUnitario, 
                  IngresoBruto, 
                  Mes, 
                  NumeroContrato, 
                  Unidad, 
                  Hidrocarburo, 
                  RegaliaBase, 
                  RegaliaAdicional, 
                  Penalidad, 
                  IngresoNeto
                 )
                 SELECT(SUM(Volumen) * 1000) AS Volumen,
                       CASE
                           WHEN SUM(IngresoBruto) = 0
                           THEN 0
                           ELSE(SUM(IngresoBruto) / (SUM(Volumen) * 1000))
                       END AS PrecioUnitario, 
                       SUM(IngresoBruto) AS IngresoBruto, 
                       Mes, 
                       NumeroContrato, 
                       Unidad AS Unidad, 
                       Hidrocarburo AS Hidrocarburo, 
                       RegaliaBase, 
                       RegaliaAdicional, 
                       Penalidad, 
                       (SUM(IngresoBruto) - RegaliaBase - RegaliaAdicional - Penalidad) AS IngresoNeto
                 FROM #Datos
                 GROUP BY Mes, 
                          NumeroContrato, 
                          Unidad, 
                          Hidrocarburo, 
                          RegaliaBase, 
                          RegaliaAdicional, 
                          Penalidad;

                 /**/

                 SELECT

/*CASE
                    WHEN UnPivotTable.Tipo = 'Volumen'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), '###,###.####')
                    WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'IngresoBruto'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'RegaliaBase'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'Penalidad'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                    WHEN UnPivotTable.Tipo = 'IngresoNeto'
                    THEN FORMAT(CONVERT(FLOAT, UnPivotTable.Valores), 'C4', 'en-us')
                END*/

                 Valores AS Valores,
                 CASE
                     WHEN UnPivotTable.Tipo = 'Volumen'
                     THEN 'Volúmen'
                     WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                     THEN 'Precio'
                     WHEN UnPivotTable.Tipo = 'IngresoBruto'
                     THEN 'Ingreso Bruto'
                     WHEN UnPivotTable.Tipo = 'RegaliaBase'
                     THEN 'Regalia Base'
                     WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                     THEN 'Regalia Adicional'
                     WHEN UnPivotTable.Tipo = 'Penalidad'
                     THEN 'Penalidad'
                     WHEN UnPivotTable.Tipo = 'IngresoNeto'
                     THEN 'Ingreso Neto'
                 END AS Tipo, 
                 NumeroContrato, 
                 Unidad, 
                 Hidrocarburo, 
                 Mes,
                 CASE
                     WHEN UnPivotTable.Tipo = 'Volumen'
                     THEN '[BBL] / [MMPC]'
                     WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                     THEN '[USD/BBL] / [USD/MPC]'
                     WHEN UnPivotTable.Tipo = 'IngresoBruto'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'RegaliaBase'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'Penalidad'
                     THEN '[USD]'
                     WHEN UnPivotTable.Tipo = 'IngresoNeto'
                     THEN '[USD]'
                 END AS Unidades,
                 CASE
                     WHEN UnPivotTable.Tipo = 'Volumen'
                     THEN 1
                     WHEN UnPivotTable.Tipo = 'PrecioUnitario'
                     THEN 2
                     WHEN UnPivotTable.Tipo = 'IngresoBruto'
                     THEN 3
                     WHEN UnPivotTable.Tipo = 'RegaliaBase'
                     THEN 4
                     WHEN UnPivotTable.Tipo = 'RegaliaAdicional'
                     THEN 5
                     WHEN UnPivotTable.Tipo = 'Penalidad'
                     THEN 6
                     WHEN UnPivotTable.Tipo = 'IngresoNeto'
                     THEN 7
                 END AS Orden
                 FROM
                 (
                     SELECT Volumen, 
                            PrecioUnitario, 
                            IngresoBruto, 
                            Mes, 
                            NumeroContrato, 
                            Unidad, 
                            Hidrocarburo, 
                            RegaliaBase, 
                            RegaliaAdicional, 
                            Penalidad, 
                            IngresoNeto
                     FROM #DatosPivote
                 ) AS SourceTable UNPIVOT(Valores FOR Tipo IN(Volumen, 
                                                              PrecioUnitario, 
                                                              IngresoBruto, 
                                                              RegaliaBase, 
                                                              RegaliaAdicional, 
                                                              Penalidad, 
                                                              IngresoNeto)) AS UnPivotTable
                 ORDER BY Mes;
             END;
     END;
