
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_SE_A6'
    )
    DROP PROCEDURE SP_SE_A6;
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos los presupuestos del periodo
--					seleccionado
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		12 de Abril del 2022
-- Description:		se Actualiza el stored procedure  
--					para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		28 de Abril del 2022
-- Description:		Manda a llamar el nuevo sp para contratos de murphy
-- ============================================
CREATE PROCEDURE [dbo].[SP_SE_A6]
    @IdContrato    INT,
    @IdUsuario     INT,
    @IdPresupuesto INT,
    @FInicio       DATE,
    @FFin          DATE,
    @IdPeriodo     INT,
    @Etapa         VARCHAR(20)
AS
    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #Presupuestos (IdPresupuesto INT);
        CREATE TABLE #RFC (RFC VARCHAR(25));
        DECLARE
            @RazonSocial                                       VARCHAR(100) = '',
            @TipoComprobanteExtranjero                         INT          = 3,
            @TipoPedimento                                     INT          = 2,
            @Jaguar                                            INT          = 10005,
            @Pantera                                           INT          = 10006,
            @EsPresupuestoJaguarPantera                        INT          = 0,
            @EsPresupuestoGuardadosJaguarPanteraExploracion    INT          = 0,
            @EsPresupuestoSeleccionadoJaguarPanteraExploracion INT          = 0,
            @Peso                                              INT          = 1,
            @Dolar                                             INT          = 2,
            @TransferenciaTecnologia                           INT          = 5;

            CREATE TABLE #Montos
            (
                Comentarios               VARCHAR(MAX),
                IdRegistro                INT,
                IdFactura                 INT           NULL,
                IdMoneda                  INT           NULL,
                IdPedimentoComprobante    INT           NULL,
                MontoRegistro             DECIMAL(20, 2),
                MontoUSD                  DECIMAL(20, 2),
                MontoMXN                  DECIMAL(20, 2),
                FechaFactura              DATETIME
            );

        SELECT
            @RazonSocial = CA.RazonSocial
        FROM
            CO_CONTRATO        C
            JOIN
                CO_CONTRATISTA CA
                    ON C.IdContratista = CA.IdContratista
                       AND C.IdContrato = @IdContrato
        WHERE
            C.IdContrato = @IdContrato;

        IF (
               (@RazonSocial = 'Murphy Sur, S. de R.L. de C.V.')
               OR (@RazonSocial = 'El Dorado')
           )
            BEGIN
                EXEC [SP_SE_A6_MPY]
                    @IdContrato,
                    @IdUsuario,
                    @IdPresupuesto,
                    @FInicio,
                    @FFin,
                    @IdPeriodo,
                    @Etapa;
            END
        ELSE
            BEGIN

                /*Se valida si el presupuesto viene en 0 para obtener todos los presupuestos del perido.*/
                IF (@IdPresupuesto = 0)
                    BEGIN
                        INSERT INTO #Presupuestos
                            (
                                IdPresupuesto
                            )
                                    SELECT
                                        CP.IdPresupuesto
                                    FROM
                                        CO_ProgramaActividad   CPA (NOLOCK)
                                        INNER JOIN
                                            CO_PeriodoContrato CPC (NOLOCK)
                                                ON CPA.IdPeriodoContrato = CPC.IdPeriodo
                                                AND CPC.IdPeriodo = @IdPeriodo
                                        INNER JOIN
                                            CO_Presupuesto     CP (NOLOCK)
                                                ON CPA.IdProgramaActividad = CP.IdProgramaActividad
                                    WHERE
                                        CPC.IdPeriodo = @IdPeriodo
                                        AND CP.Activo = 1;

                        SELECT
                            @EsPresupuestoGuardadosJaguarPanteraExploracion = COUNT(1)
                        FROM
                            #Presupuestos              T
                            JOIN
                                dbo.CO_Presupuesto     P (NOLOCK)
                                    ON T.IdPresupuesto = P.IdPresupuesto
                            JOIN
                                dbo.CO_AnioContractual AC (NOLOCK)
                                    ON P.IdAnioContractual = AC.IdAnioContractual
                            JOIN
                                dbo.CO_Contrato        C (NOLOCK)
                                    ON AC.IdContrato = C.IdContrato
                        WHERE
                            P.nombre LIKE '%exploración%'
                            AND C.IdContratista IN (
                                                       @Jaguar, @Pantera
                                                   )

                        IF (1 = @EsPresupuestoGuardadosJaguarPanteraExploracion)
                            BEGIN
                                DELETE FROM #Presupuestos
                                INSERT INTO #Presupuestos
                                    (
                                        IdPresupuesto
                                    )
                                            SELECT
                                                P.IdPresupuesto
                                            FROM
                                                dbo.CO_Presupuesto         P (NOLOCK)
                                                JOIN
                                                    dbo.CO_AnioContractual AC (NOLOCK)
                                                        ON P.IdAnioContractual = AC.IdAnioContractual
                                                JOIN
                                                    dbo.CO_Contrato        C (NOLOCK)
                                                        ON AC.IdContrato = C.IdContrato
                                            WHERE
                                                C.IdContrato = @IdContrato
                                                AND P.nombre LIKE '%exploración%'
                                                AND C.IdContratista IN (
                                                                           10005, 10006
                                                                       );
                            END;
                    END
                ELSE
                    BEGIN
                        SELECT
                            @EsPresupuestoSeleccionadoJaguarPanteraExploracion = COUNT(1)
                        FROM
                            dbo.CO_Presupuesto         P (NOLOCK)
                            JOIN
                                dbo.CO_AnioContractual AC (NOLOCK)
                                    ON P.IdAnioContractual = AC.IdAnioContractual
                            JOIN
                                dbo.CO_Contrato        C (NOLOCK)
                                    ON AC.IdContrato = C.IdContrato
                        WHERE
                            P.IdPresupuesto = @IdPresupuesto
                            AND P.Nombre LIKE '%exploración%'
                            AND C.IdContratista IN (
                                                       @Jaguar, @Pantera
                                                   );

                        IF (1 = @EsPresupuestoSeleccionadoJaguarPanteraExploracion)
                            BEGIN
                                INSERT INTO #Presupuestos
                                    (
                                        IdPresupuesto
                                    )
                                            SELECT
                                                P.IdPresupuesto
                                            FROM
                                                dbo.CO_Presupuesto         P (NOLOCK)
                                                JOIN
                                                    dbo.CO_AnioContractual AC (NOLOCK)
                                                        ON P.IdAnioContractual = AC.IdAnioContractual
                                                JOIN
                                                    dbo.CO_Contrato        C (NOLOCK)
                                                        ON AC.IdContrato = C.IdContrato
                                            WHERE
                                                C.IdContrato = @IdContrato
                                                AND P.Nombre LIKE '%exploración%'
                                                AND C.IdContratista IN (
                                                                          @Jaguar, @Pantera
                                                                       );
                            END;
                        ELSE
                            BEGIN
                                INSERT INTO #Presupuestos
                                    (
                                        IdPresupuesto
                                    )
                                            SELECT
                                                @IdPresupuesto;
                            END;
                    END
                /*RFC*/
                INSERT INTO #RFC
                    (
                        RFC
                    )
                            SELECT
                                'FMP140930MW3'
                            UNION
                            SELECT
                                'SAT970701NN3';
                  SELECT
                    @EsPresupuestoJaguarPantera = COUNT(1)
                FROM
                    dbo.CO_Presupuesto         P (NOLOCK)
                    JOIN
                        dbo.CO_AnioContractual AC (NOLOCK)
                            ON P.IdAnioContractual = AC.IdAnioContractual
                    JOIN
                        dbo.CO_Contrato        C (NOLOCK)
                            ON AC.IdContrato = C.IdContrato
                WHERE
                    P.idpresupuesto = @IdPresupuesto
                    AND C.IdContratista IN (
                                               @Jaguar, @Pantera
                                           );

                IF (@EsPresupuestoJaguarPantera > 0)
                    BEGIN
                        INSERT INTO #RFC
                            (
                                RFC
                            )
                                    SELECT
                                        'FMO930803PB1'
                                    UNION
                                    SELECT
                                        'GMS971110BTA';
                    END;
                /*Consulta final*/
              /*   SELECT
                   ROW_NUMBER() OVER (ORDER BY
                                           R.Comentarios
                                      ) AS NoGasto,
                    R.Comentarios       AS Descripcion,
                    SUM(   CASE
                               WHEN F.IdMoneda = 1
                                   THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0)), 2) AS DECIMAL(20, 2))
                               ELSE
                                   CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, F.Fecha) AS DECIMAL(20, 2))
                           END
                       )                AS SubTotal*/
                       
                INSERT INTO #Montos
                    (
                        Comentarios,
                        IdRegistro,
                        IdFactura,
                        IdMoneda,
                        MontoRegistro,
                        FechaFactura
                    )
                            SELECT
                                R.Comentarios,                                
                                R.IdRegistro,
                                F.IdFactura,
                                F.IdMoneda,
                                R.MontoRegistro,
                                F.Fecha
                FROM
                    dbo.CO_Registro                  R (NOLOCK)
                    JOIN
                        dbo.FI_Factura               F
                            ON R.IdFactura = F.IdFactura
                            AND R.IdGastoRubro = @TransferenciaTecnologia
                            AND F.IdContrato = @IdContrato
                            AND ISNULL(R.PCN, 0) >= 0
                    JOIN
                        dbo.PV_Subcontratista        S (NOLOCK)
                            ON F.IdSubcontratista = S.IdSubcontratista
                    JOIN
                        dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                            ON R.IdPrograma = L.IdLineaPresupuestoMeS
                    JOIN
                        #Presupuestos                PP
                            ON L.IdPresupuesto = PP.IdPresupuesto
                    JOIN
                        dbo.CO_Presupuesto           P (NOLOCK)
                            ON PP.IdPresupuesto = P.IdPresupuesto
                    JOIN
                        dbo.CO_ProgramaActividad     PA (NOLOCK)
                            ON P.IdProgramaActividad = PA.IdProgramaActividad
                    JOIN
                        dbo.CO_TipoProgramaActividad TPA (NOLOCK)
                            ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                WHERE
                    (
                        CAST(F.Fecha AS DATE) >= @FInicio
                        AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
                    )
                    AND R.IdGastoRubro = @TransferenciaTecnologia
                    AND S.RFC NOT IN (
                                         SELECT
                                             RFC
                                         FROM
                                             #RFC
                                     )
                    AND ISNULL(R.PCN, 0) >= 0;

                INSERT INTO #Montos
                    (
                        Comentarios,
                        IdRegistro,
                        IdPedimentoComprobante,
                        IdMoneda,
                        MontoRegistro,
                        FechaFactura
                    )
                            SELECT
                                R.Comentarios,                                
                                R.IdRegistro,
                                PC.IdPedimentoComprobante,
                                PC.IdMoneda,
                                R.MontoRegistro,
                                PC.FechaPago
                            FROM
                                #Presupuestos                   PP
                                JOIN
                                    dbo.CO_LineaPresupuestoMes  L (NOLOCK)
                                        ON PP.IdPresupuesto = L.IdPresupuesto
                                JOIN
                                    dbo.CO_Registro             R (NOLOCK)
                                        ON L.IdLineaPresupuestoMes = R.IdPrograma
                                           AND R.IdGastoRubro = @TransferenciaTecnologia
                                           AND ISNULL(R.PCN, 0) >= 0
                                JOIN
                                    dbo.FI_PedimentoComprobante PC (NOLOCK)
                                        ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                           AND PC.IdContrato = @IdContrato
                                JOIN
                                    dbo.PV_Subcontratista       S (NOLOCK)
                                        ON PC.IdSubcontratistaExportador = S.IdSubcontratista
                            WHERE
                                (
                                    CAST(PC.FechaPago AS DATE) >= @FInicio
                                    AND CAST(PC.FechaPago AS DATE) <= EOMONTH(@FFin)
                                )
                                AND R.IdGastoRubro = @TransferenciaTecnologia
                                AND S.RFC NOT IN (
                                                     SELECT
                                                         RFC
                                                     FROM
                                                         #RFC
                                                 )
                                AND PC.IdContrato = @IdContrato
                                AND ISNULL(R.PCN, 0) >= 0;


                UPDATE
                    #Montos
                SET
                    MontoUSD = MontoRegistro
                FROM
                    #Montos
                WHERE
                    #Montos.IdMoneda = @Dolar;

                UPDATE
                    #Montos
                SET
                    MontoUSD = MontoRegistro / TipoCambio
                FROM
                    #Montos
                    LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK)
                            ON CAST(#Montos.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
                               AND #Montos.IdMoneda = CO_TipoCambioDiario.IdMoneda
                               AND #Montos.IdMoneda <> @Peso
                WHERE
                    #Montos.IdMoneda <> @Peso

                UPDATE
                    #Montos
                SET
                    MontoMXN = MontoRegistro
                FROM
                    #Montos
                WHERE
                    #Montos.IdMoneda = @Peso;

                UPDATE
                    #Montos
                SET
                    MontoMXN = CAST(MontoUSD * TipoCambio AS decimal(20, 2))
                FROM
                    #Montos
                    LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK)
                            ON CAST(#Montos.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
                               AND CO_TipoCambioDiario.IdMoneda = @Peso
                               AND #Montos.IdMoneda <> @Peso
                WHERE
                    #Montos.IdMoneda <> @Peso;

              SELECT
                   ROW_NUMBER() OVER (ORDER BY
                                           Comentarios
                                      ) AS NoGasto,
                    Comentarios       AS Descripcion,
                    SUM(   
                          CAST(ROUND((ISNULL(MontoMXN, 0)), 2) AS DECIMAL(20, 2))
                             
                       )                AS SubTotal
                       FROM 
                        #Montos
                       GROUP BY Comentarios;
            END
    END;

