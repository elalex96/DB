IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_SE_A4'
    )
    DROP PROCEDURE SP_SE_A4;
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos	los presupuestos del periodo
--					seleccionado
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		13 de Abril del 2022
-- Description:		se Actualiza el stored procedure para mostrar el nuevo catalogo 
--					de mano de obra y para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================
CREATE PROCEDURE [dbo].[SP_SE_A4] --10038,10109,0,'20210101','20211201',10195,'Exploración'
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
        CREATE TABLE #Sueldos
            (
                SueldosSalarios         DECIMAL(20, 2),
                SueldosSalariosNacional DECIMAL(20, 2),
                Catalogo                VARCHAR(25),
                CatalogoId              INT
            );
        CREATE TABLE #DATOS
            (
                SueldosSalarios         DECIMAL(20, 2),
                SueldosSalariosNacional DECIMAL(20, 2),
                IdCatManoObra           INT
            );


        CREATE TABLE #SueldosMontos
            (
                MontoRegistro DECIMAL(20, 2),
                MontoUSD      DECIMAL(20, 2),
                FechaFactura  DATETIME,
                IdCatManoObra INT,
                PCN           FLOAT,
                IdRegistro    INT,
                IdMoneda      INT,
                MontoMXN      DECIMAL(20, 2)
            );

        DECLARE @CatalogoOtrosId int = 0;
        /* SE AGREGA LA LLAMADA DEL NUEVO STORED PROCEDURE PARA MURPHY, DONDE MANDA A LLAMAR DATOS DE PROCURA/PETROVENDOR*/
        DECLARE
            @RazonSocial                                       VARCHAR(100) = '',
            @TipoComprobanteExtranjero                         INT          = 3,
            @TipoPedimento                                     INT          = 2,
            @Jaguar                                            INT          = 10005,
            @Pantera                                           INT          = 10006,
            @EsPresupuestoJaguarPantera                        INT          = 0,
            @EsPresupuestoGuardadosJaguarPanteraExploracion    INT          = 0,
            @EsPresupuestoSeleccionadoJaguarPanteraExploracion INT          = 0,
            @ManoObra                                          INT          = 1,
            @Peso                                              INT          = 1,
            @Dolar                                             INT          = 2;

        SELECT
            @RazonSocial = CA.RazonSocial
        FROM
            CO_CONTRATO        C (NOLOCK)
            JOIN
                CO_CONTRATISTA CA (NOLOCK)
                    ON C.IdContratista = CA.IdContratista
                       AND C.IdContrato = @IdContrato
        WHERE
            C.IdContrato = @IdContrato;

        IF (
               (@RazonSocial = 'Murphy Sur, S. de R.L. de C.V.')
               OR (@RazonSocial = 'El Dorado')
           )
            BEGIN
                EXEC [SP_SE_A4_MPY]
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

                SELECT
                    @CatalogoOtrosId = ID
                FROM
                    CO_CAT_ManoDeObra;

                INSERT INTO #Sueldos
                    (
                        SueldosSalarios,
                        SueldosSalariosNacional,
                        Catalogo,
                        CatalogoId
                    )
                            SELECT
                                0,
                                0,
                                Nombre,
                                Id
                            FROM
                                CO_CAT_ManoDeObra;

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
                                                           AND AC.IdContrato = @IdContrato
                                                           AND P.nombre LIKE '%exploración%'
                                                JOIN
                                                    dbo.CO_Contrato        C (NOLOCK)
                                                        ON AC.IdContrato = C.IdContrato
                                            WHERE
                                                C.IdContrato = @IdContrato
                                                AND P.nombre LIKE '%exploración%'
                                                AND C.IdContratista IN (
                                                                           @Jaguar, @Pantera
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
                                                           AND P.Nombre LIKE '%exploración%'
                                                           AND AC.IdContrato = @IdContrato
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


                INSERT INTO #SueldosMontos
                    (
                        MontoRegistro,
                        FechaFactura,
                        IdCatManoObra,
                        PCN,
                        IdRegistro,
                        IdMoneda
                    )
                            SELECT
                                R.MontoRegistro,
                                F.Fecha,
                                ISNULL(R.IdCatManoObra, @CatalogoOtrosId),
                                R.PCN,
                                R.IdRegistro,
                                F.IdMoneda
                            FROM
                                #Presupuestos                  PP
                                JOIN
                                    dbo.CO_LineaPresupuestoMes L (NOLOCK)
                                        ON PP.IdPresupuesto = L.IdPresupuesto
                                JOIN
                                    dbo.CO_Registro            R (NOLOCK)
                                        ON L.IdLineaPresupuestoMes = R.IdPrograma
                                           AND R.IdGastoRubro = @ManoObra
                                JOIN
                                    dbo.FI_Factura             F (NOLOCK)
                                        ON R.IdFactura = F.IdFactura
                                           AND F.IdContrato = @IdContrato
                                JOIN
                                    dbo.PV_Subcontratista      S (NOLOCK)
                                        ON F.IdSubcontratista = S.IdSubcontratista
                            WHERE
                                (
                                    CAST(F.Fecha AS DATE) >= @FInicio
                                    AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
                                )
                                AND R.IdGastoRubro = @ManoObra
                                AND S.RFC NOT IN (
                                                     SELECT
                                                         RFC
                                                     FROM
                                                         #RFC
                                                 )
                                AND F.IdContrato = @IdContrato
                                AND ISNULL(R.PCN, 0) >= 0;

                INSERT INTO #SueldosMontos
                    (
                        MontoRegistro,
                        FechaFactura,
                        IdCatManoObra,
                        PCN,
                        IdRegistro,
                        IdMoneda
                    )
                            SELECT
                                R.MontoRegistro,
                                PC.FechaPago,
                                ISNULL(R.IdCatManoObra, @CatalogoOtrosId),
                                R.PCN,
                                R.IdRegistro,
                                PC.IdMoneda
                            FROM
                                #Presupuestos                   PP
                                JOIN
                                    dbo.CO_LineaPresupuestoMes  L (NOLOCK)
                                        ON PP.IdPresupuesto = L.IdPresupuesto
                                JOIN
                                    dbo.CO_Registro             R (NOLOCK)
                                        ON L.IdLineaPresupuestoMes = R.IdPrograma
                                           AND R.IdGastoRubro = @ManoObra
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
                                AND R.IdGastoRubro = @ManoObra
                                AND S.RFC NOT IN (
                                                     SELECT
                                                         RFC
                                                     FROM
                                                         #RFC
                                                 )
                                AND PC.IdContrato = @IdContrato
                                AND ISNULL(R.PCN, 0) >= 0;

                UPDATE
                    #SueldosMontos
                SET
                    MontoUSD = MontoRegistro
                FROM
                    #SueldosMontos
                WHERE
                    #SueldosMontos.IdMoneda = @Dolar;


                UPDATE
                    #SueldosMontos
                SET
                    MontoUSD = MontoRegistro / TipoCambio
                FROM
                    #SueldosMontos
                    LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK)
                            ON CAST(#SueldosMontos.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
                               AND #SueldosMontos.IdMoneda = CO_TipoCambioDiario.IdMoneda
                               AND #SueldosMontos.IdMoneda <> @Peso
                WHERE
                    #SueldosMontos.IdMoneda <> @Peso

                UPDATE
                    #SueldosMontos
                SET
                    MontoMXN = MontoRegistro
                FROM
                    #SueldosMontos
                WHERE
                    #SueldosMontos.IdMoneda = @Peso;

                UPDATE
                    #SueldosMontos
                SET
                    MontoMXN = CAST(MontoUSD * TipoCambio AS decimal(20, 2))
                FROM
                    #SueldosMontos
                    LEFT JOIN
                        CO_TipoCambioDiario (NOLOCK)
                            ON CAST(#SueldosMontos.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
                               AND CO_TipoCambioDiario.IdMoneda = @Peso
                               AND #SueldosMontos.IdMoneda <> @Peso
                WHERE
                    #SueldosMontos.IdMoneda <> @Peso


                INSERT INTO #DATOS
                    (
                        SueldosSalarios,
                        SueldosSalariosNacional,
                        IdCatManoObra
                    )
                            SELECT
                                SUM(MontoMXN)                               AS SueldosSalarios,
                                SUM(MontoMXN * CAST(PCN AS DECIMAL(20, 3))) AS SueldosSalariosNacional,
                                IdCatManoObra
                            FROM
                                #SueldosMontos
                            GROUP BY
                                IdCatManoObra;

                UPDATE
                    S
                SET
                    S.SueldosSalarios = D.SueldosSalarios,
                    S.SueldosSalariosNacional = D.SueldosSalariosNacional
                FROM
                    #SUELDOS   S
                    JOIN
                        #DATOS D
                            ON S.CatalogoId = D.IdCatManoObra;


                SELECT
                    SueldosSalarios,
                    SueldosSalariosNacional,
                    Catalogo
                FROM
                    #SUELDOS;
            END
    END;
