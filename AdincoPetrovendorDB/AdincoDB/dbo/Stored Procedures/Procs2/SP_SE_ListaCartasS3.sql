-- =============================================  
-- Author:  Manuel CD  
-- Create date: 2018-10-16  
-- Description:   
-- =============================================  
CREATE PROCEDURE [dbo].[SP_SE_ListaCartasS3]
-- Add the parameters for the stored procedure here  
-- SP_SE_ListaCartasS3 3,1,3,'2018-01-01','2019-12-01'
-- SP_SE_ListaCartasS3 10036,1,10053,'2018-01-01','2018-12-01'
-- [SP_SE_ListaCartasS3] 10018,1,10079,'2019-01-01','2019-12-01'
@IdContrato    INT, 
@IdUsuario     INT, 
@IdPresupuesto INT, 
@FInicio       DATE, 
@FFin          DATE
AS
     BEGIN  
         --
         SET NOCOUNT ON;
         CREATE TABLE #Presupuestos(IdPresupuesto INT);
         CREATE TABLE #RFC(RFC VARCHAR(25));

         /**/

         --IF 1 =
         --(
         --    SELECT COUNT(1)
         --    FROM dbo.CO_Presupuesto P
         --         JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
         --         JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
         --    WHERE P.idpresupuesto = @IdPresupuesto
         --          AND P.nombre LIKE '%provisional%'
         --          AND C.IdContratista IN(10005, 10006)
         --)
         --    BEGIN
         --        INSERT INTO #Presupuestos(IdPresupuesto)
         --               SELECT P.IdPresupuesto
         --               FROM dbo.CO_Presupuesto P
         --                    JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
         --                    JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
         --               WHERE C.IdContrato = @IdContrato
         --                     AND P.nombre LIKE '%provisional%'
         --                     AND C.IdContratista IN(10005, 10006);
         --    END;
         IF 1 =
         (
             SELECT COUNT(1)
             FROM dbo.CO_Presupuesto P
                  JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                  JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
             WHERE P.idpresupuesto = @IdPresupuesto
                   AND P.nombre LIKE '%exploración%'
                   AND C.IdContratista IN(10005, 10006)
         )
             BEGIN
                 INSERT INTO #Presupuestos(IdPresupuesto)
                        SELECT P.IdPresupuesto
                        FROM dbo.CO_Presupuesto P
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
                        WHERE C.IdContrato = @IdContrato
                              AND P.nombre LIKE '%exploración%'
                              AND C.IdContratista IN(10005, 10006);
             END;
             ELSE
             BEGIN
                 INSERT INTO #Presupuestos(IdPresupuesto)
             SELECT @IdPresupuesto;
             END;

         /**/

         INSERT INTO #RFC(RFC)
                SELECT 'FMP140930MW3'
                UNION
                SELECT 'SAT970701NN3';
         IF 1 =
         (
             SELECT COUNT(1)
             FROM dbo.CO_Presupuesto P
                  JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                  JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
             WHERE P.idpresupuesto = @IdPresupuesto
                   AND C.IdContratista IN(10005, 10006)
         )
             BEGIN
                 INSERT INTO #RFC(RFC)
                        SELECT 'FMO930803PB1'
                        UNION
                        SELECT 'GMS971110BTA';
             END;

         /*Facturas de Adinco*/

         CREATE TABLE #FacturasAdinco
         (IdFactura INT, 
          UUID      VARCHAR(500), 
          RFC       VARCHAR(50)
         );
         INSERT INTO #FacturasAdinco
         (IdFactura, 
          UUID, 
          RFC
         )
                SELECT DISTINCT 
                       F.IdFactura, 
                       F.UUID, 
                       S.RFC
                FROM Adinco.dbo.CO_Registro R
                     JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
                     JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
                     JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
                     JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto
                     JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = PP.IdPresupuesto
                     JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                     JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                     JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                                AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                                AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                                AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                     LEFT JOIN Adinco.dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                      AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                     AND S.RFC NOT IN
                (
                    SELECT RFC
                    FROM #RFC
                )
                     AND F.IdContrato = @IdContrato
                     AND ISNULL(R.PCN, 0) <> 0
                     AND TCD.IdMoneda IN(1, 2)
                     AND (F.IdFactura IS NOT NULL
                          AND F.UUID IS NOT NULL
                          AND F.UUID <> '');

         /*Cartas de Petrovendor*/

         CREATE TABLE #CartasPetrovendor
         (Identificador   VARCHAR(500), 
          Carpeta         VARCHAR(500), 
          Ruta            VARCHAR(500), 
          Cubeta          VARCHAR(500), 
          NombreDocumento VARCHAR(500), 
          IdFactura       INT, 
          UUID            VARCHAR(500)
         );
         INSERT INTO #CartasPetrovendor
         (Identificador, 
          Carpeta, 
          Ruta, 
          Cubeta, 
          NombreDocumento, 
          IdFactura, 
          UUID
         )
                SELECT DOC.Identificador, 
                       DOC.Carpeta, 
                       CONCAT(DOC.Carpeta, DOC.Identificador) AS Ruta, 
                       'petrovendor-pr' AS Cubeta, 
                       CONCAT('CCN-', VEN.TaxID COLLATE DATABASE_DEFAULT, '-', ROW_NUMBER() OVER(ORDER BY DOC.Identificador), '.pdf') AS NombreDocumento, 
                       AF.IdFactura, 
                       FP.UUID
                FROM Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AS ACCN
                     JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AS AP ON ACCN.IdAceptacionPedido = AP.IdAceptacionPedido
                     JOIN Petrovendor.dbo.S_Documento_S3 AS DOC ON DOC.IdDocumento = ACCN.IdDocumento
                                                                   AND ACCN.IdEstatus = 2
                     JOIN Adinco.dbo.CO_SAPVendor AS VEN ON AP.IdSubContratista COLLATE DATABASE_DEFAULT = VEN.VendorIDSAP
                     JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AS AF ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                     JOIN Petrovendor.dbo.FI_Factura AS FP ON FP.IdFactura = AF.IdFactura
                WHERE AP.IdContrato = @IdContrato
                      AND (CAST(FP.Fecha AS DATE) >= @FInicio
                           AND CAST(FP.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND (FP.IdFactura IS NOT NULL
                           AND FP.UUID IS NOT NULL
                           AND FP.UUID <> '')
                ----------------
                UNION
                ----------------  
                SELECT D.Identificador, 
                       D.Carpeta, 
                       CONCAT(D.Carpeta, D.Identificador) AS Ruta, 
                       'petrovendor-pr' AS Cubeta, 
                       CONCAT('CCN-', PR.RFC COLLATE DATABASE_DEFAULT, '-', ROW_NUMBER() OVER(ORDER BY D.Identificador), '.pdf') AS NombreDocumento, 
                       AF.IdFactura, 
                       FP.UUID
                FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS AC
                     JOIN Petrovendor.dbo.S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
                                                                 AND AC.IdEstatus = 2
                                                                 AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                     JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                     JOIN Petrovendor.dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                     JOIN Petrovendor.dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
                     JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
                     JOIN Petrovendor.dbo.MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador
                     LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                     LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                     LEFT JOIN Petrovendor.dbo.FI_Factura FP ON FP.IdFactura = AF.IdFactura
                                                                AND FP.UUID IS NOT NULL
                                                                AND FP.Activa = 1
                                                                AND ISNULL(FP.IsEliminado, 0) <> 1
                WHERE FP.UUID IN
                (
                    SELECT UUID COLLATE DATABASE_DEFAULT
                    FROM #FacturasAdinco
                )
                GROUP BY D.Identificador, 
                         D.Carpeta, 
                         CONCAT(D.Carpeta, D.Identificador), 
                         PR.RFC, 
                         AF.IdFactura, 
                         FP.UUID;

         /*Consulta final*/

         SELECT UPPER(D.UUIDAmazon) AS Identificador, 
                D.Folder AS Carpeta, 
                CONCAT(D.Folder, D.UUIDAmazon) AS Ruta, 
                D.Bucket AS Cubeta, 
                CONCAT('CCN-', FA.RFC, '-', ROW_NUMBER() OVER(ORDER BY D.UUIDAmazon), '.pdf') AS NombreDocumento, 
                FA.IdFactura, 
                FA.UUID
         FROM #FacturasAdinco FA
              JOIN AWS_DocAwsDocAdinco DAD ON FA.IdFactura = DAD.IdDocAdinco
              JOIN dbo.AWS_Documentos D ON DAD.AWSDocumentoId = D.AWSDocumentoId
         WHERE FA.UUID NOT IN
         (
             SELECT UUID
             FROM #CartasPetrovendor
         )
         ----------------
         UNION
         ----------------
         SELECT Identificador, 
                Carpeta, 
                Ruta, 
                Cubeta, 
                NombreDocumento, 
                IdFactura, 
                UUID
         FROM #CartasPetrovendor
         ORDER BY Carpeta;
     END;