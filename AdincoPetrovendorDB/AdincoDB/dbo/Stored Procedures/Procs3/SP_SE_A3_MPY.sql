IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_SE_A3_MPY'
    )
    DROP PROCEDURE SP_SE_A3_MPY;
GO
CREATE PROCEDURE [dbo].[SP_SE_A3_MPY]
    @IdContrato    INT,
    @IdUsuario     INT,
    @IdPresupuesto INT,
    @FInicio       DATE,
    @FFin          DATE,
    @IdPeriodo     INT,
    @Etapa         VARCHAR(20)
AS
    BEGIN
        CREATE TABLE #Presupuestos (IdPresupuesto INT);
        CREATE TABLE #RFC (RFC VARCHAR(25));
        CREATE TABLE #DATOS
            (
                IdRegistro                INT NULL,
                Codigo                    VARCHAR(50),
                Descripcion               VARCHAR(300),
                RazonSocial               VARCHAR(300),
                RFC                       VARCHAR(100),
                SubTotal                  MONEY,
                SubTotalOriginal          MONEY,
                PCN                       FLOAT,
                IdFactura                 INT,
                IdAceptacionPedidoDetalle INT
            )
        CREATE TABLE #FacturasAdinco
            (
                IdFactura             INT,
                UUID                  VARCHAR(500),
                RFC                   VARCHAR(50),
                EncontradoPetrovendor INT,
                SubTotal              MONEY,
                IdSubcontratista      INT,
                IdContrato            INT,
                IdMoneda              INT,
                Fecha                 datetime
            );
        CREATE TABLE #FINAL
            (
                Codigo      VARCHAR(50),
                Descripcion VARCHAR(300),
                RazonSocial VARCHAR(300),
                RFC         VARCHAR(100),
                SubTotal    MONEY,
                PCN         FLOAT,
                IdFactura   INT
            );
			
        DECLARE
            @Peso                                 INT = 1,
            @Dolar                                INT = 2,
            @TipoComprobanteExtranjero            INT = 3,
            @Servicios                            INT = 3,
            @EsPresupuestoJaguarPantera                        INT = 0,
            @EsPresupuestoGuardadosJaguarPanteraExploracion    INT = 0,
            @EsPresupuestoSeleccionadoJaguarPanteraExploracion INT = 0,
			@EstatusAprobado INT = 2,
			@Jaguar INT = 10005,	
			@Pantera INT = 10006;

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
                               AND P.nombre LIKE '%exploración%'
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
                        DELETE FROM #Presupuestos;
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
                                                   AND P.nombre LIKE '%exploración%'
												   AND AC.IdContrato  = @IdContrato
                                        JOIN
                                            dbo.CO_Contrato        C (NOLOCK)
                                                ON AC.IdContrato = C.IdContrato
                                    WHERE
                                        C.IdContrato  = @IdContrato
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
                               AND P.nombre LIKE '%exploración%'
                               AND P.IdPresupuesto = @IdPresupuesto
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
												   AND	AC.IdContrato  = @IdContrato
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
                                    
									SELECT @IdPresupuesto;
                    END;
            END
        /*RFC*/

        INSERT INTO #RFC
            (
                RFC
            )
        VALUES
            (
                'FMP140930MW3'
            ),
            (
                'SAT970701NN3'
            );

        SELECT
            @EsPresupuestoJaguarPantera = COUNT(1)
        FROM
            dbo.CO_Presupuesto         P (NOLOCK)
            JOIN
                dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                       AND P.idpresupuesto = @IdPresupuesto
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
                VALUES
                    (
                        'FMO930803PB1'
                    ),
                    (
                        'GMS971110BTA'
                    );
            END;

        /*Facturas de Adinco*/
        -- BUSCA LAS FACTURAS QUE SE ENCUENTRAN EN ADINCO
        INSERT INTO #FacturasAdinco
            (
                IdFactura,
                UUID,
                RFC,
                EncontradoPetrovendor,
                SubTotal,
                IdSubcontratista,
                IdContrato,
                IdMoneda,
                Fecha
            )
                    SELECT DISTINCT
                        F.IdFactura,
                        F.UUID,
                        S.RFC,
                        0,
                        F.SubTotal,
                        F.IdSubcontratista,
                        F.IdContrato,
                        F.IdMoneda,
                        F.Fecha
                    FROM
                        #Presupuestos                           PP
                        JOIN
                            Adinco.dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                                ON PP.IdPresupuesto = L.IdPresupuesto
                        JOIN
                            Adinco.dbo.CO_Registro              R (NOLOCK)
                                ON L.IdLineaPresupuestoMes = R.IdPrograma
                        JOIN
                            Adinco.dbo.FI_Factura               F (NOLOCK)
                                ON R.IdFactura = F.IdFactura
                                   AND F.IdContrato = @IdContrato
                        JOIN
                            Adinco.dbo.PV_Subcontratista        S (NOLOCK)
                                ON F.IdSubcontratista = S.IdSubcontratista
                        JOIN
                            Adinco.dbo.CO_TipoCambioDiario      TCD (NOLOCK)
                                ON F.IdMoneda <> TCD.IdMoneda
                                   AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                   AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                   AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                        LEFT JOIN
                            Adinco.dbo.MM_BS_Actividad          A (NOLOCK)
                                ON R.IdCBSISH = A.IdActividad
                    WHERE
                        (
                            CAST(F.Fecha AS DATE) >= @FInicio
                            AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
                        )
                        AND S.RFC NOT IN (
                                             SELECT
                                                 RFC
                                             FROM
                                                 #RFC
                                         )
                        AND F.IdContrato = @IdContrato
                        AND TCD.IdMoneda IN (
                                                @Peso, @Dolar
                                            )
                        AND (
                                F.IdFactura IS NOT NULL
                                AND F.UUID IS NOT NULL
                                AND F.UUID <> ''
                            );

        -- PRIMERO BUSCA LO QUE SE ENCUENTRA EN PROCURA DE MPY
        INSERT INTO #DATOS
            (
                Codigo,
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                SubTotalOriginal,
                PCN,
                IdFactura,
                IdAceptacionPedidoDetalle
            )
                    SELECT
                        ISNULL(BSA.Codigo, 'SinClasificar')   AS Codigo,
                        ISNULL(BSA.Nombre, 'SinClasificar')   AS Descripcion,
                        ISNULL(SV.VendorName, PR.RazonSocial) AS RazonSocial,
                        ISNULL(SV.TaxID, PR.RFC)              AS RFC,
                        PV.ValorFactura                       AS SubTotal,
                        FP.SubTotal                           AS SubTotalOriginal,
                        APD.PCN                               AS PCN,
                        FA.IdFactura,
                        APD.IdAceptacionPedidoDetalle
                    FROM
                        #FacturasAdinco                                    FA
                        JOIN
                            Petrovendor.dbo.FI_Factura                     FP (NOLOCK)
                                on FA.UUID = FP.uuid collate SQL_Latin1_General_CP1_CI_AS
                        JOIN
                            Petrovendor.dbo.MPY_MM_Aceptacionfactura       AF (NOLOCK)
                                on FP.IdFactura = AF.IdFactura
                        JOIN
                            petrovendor.dbo.MPY_MM_AceptacionPedido        AP (NOLOCK)
                                On AF.IdAceptacionPedido = AP.IdAceptacionPedido
                        JOIN
                            Petrovendor.dbo.MPY_MM_AceptacionCartaPCN      ACP (NOLOCK)
                                on AP.IdAceptacionPedido = ACP.IdAceptacionPedido
                                   AND ACP.IdEstatus = @EstatusAprobado
                        JOIN
                            Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD (NOLOCK)
                                on AP.IdAceptacionPedido = APD.IdAceptacionPedido
                                   AND APD.ClasificacionCN = @Servicios
                        LEFT JOIN
                            Petrovendor.dbo.MPY_MM_PCN_ValoresPesos        PV (NOLOCK)
                                ON APD.IdAceptacionPedidoDetalle = PV.IdAceptacionPedidoDetalle
                        LEFT JOIN
                            Petrovendor.dbo.MM_BS_Actividad                AS BSA (NOLOCK)
                                ON BSA.IdActividad = PV.IdCatalogoHidrocarburos
                        LEFT JOIN
                            Petrovendor.dbo.S_Proveedor                    AS PR (NOLOCK)
                                ON AP.IdSubContratista = PR.RFC
                                   AND PR.Activo = 1 -->CTE
                        LEFT JOIN
                            dbo.CO_SAPVendor                               AS SV (NOLOCK)
                                ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
                    WHERE
                        APD.ClasificacionCN = @Servicios --servicios

        /*APARTADO ADINCO, se obtienen valores de adinco, ya que las facturas no existen en procura*/
        -- SE AJUSTA COMO ENCONTRADO LO QUE YA SE GUARDO DE PROCURA DE LAS FACTURAS EXISTENTES
        UPDATE
            FA
        SET
            FA.EncontradoPetrovendor = 1
        FROM
            #FacturasAdinco FA
            JOIN
                #DATOS      D
                    ON FA.IdFactura = D.IdFactura;

        INSERT INTO #DATOS
            (
                IdRegistro,
                Codigo,
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                SubTotalOriginal,
                PCN,
                IdFactura,
                IdAceptacionPedidoDetalle
            )
                    SELECT
                        r.IdRegistro,
                        ISNULL(A.Codigo, 'SinClasificar') AS Codigo,
                        ISNULL(A.Nombre, 'SinClasificar') AS Descripcion,
                        S.RazonSocial                     AS RazonSocial,
                        S.RFC                             AS RFC,
                        CASE
                            WHEN FA.IdMoneda = @Peso
                                THEN CAST(R.MontoRegistro AS DECIMAL(20, 2))
                            ELSE
                                CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, FA.Fecha) AS DECIMAL(20, 2))
                        END                               AS SubTotal,
                        FA.SubTotal                       AS SubTotalOriginal,
                        R.PCN                             AS PCN,
                        FA.IdFactura,
                        R.IdAceptacionPedidoDetalle
                    FROM
                        #FacturasAdinco                  FA
                        JOIN
                            dbo.CO_Registro              R (NOLOCK)
                                ON FA.IdFactura = R.IdFactura
                                   AND FA.EncontradoPetrovendor = 0
                                   AND R.IdGastoRubro = @Servicios
                                   AND FA.IdContrato = @IdContrato
                        JOIN
                            dbo.PV_Subcontratista        S (NOLOCK)
                                ON FA.IdSubcontratista = S.IdSubcontratista
                                   AND S.TipoPersonaFiscalID = 2
                        JOIN
                            dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                                ON R.IdPrograma = L.IdLineaPresupuestoMeS
                        JOIN
                            #Presupuestos                PP
                                ON L.IdPresupuesto = PP.IdPresupuesto
                        LEFT JOIN
                            dbo.MM_BS_Actividad          A (NOLOCK)
                                ON R.IdCBSISH = A.IdActividad
                    WHERE
                        R.IdGastoRubro = @Servicios
                        AND S.RFC NOT IN (
                                             SELECT
                                                 RFC
                                             FROM
                                                 #RFC
                                         )
                        AND FA.IdContrato = @IdContrato
                        AND ISNULL(R.PCN, 0) >= 0
                        AND FA.IdMoneda IN (
                                               @Peso, @Dolar
                                           )
                        AND FA.IdFactura IN (
                                                SELECT
                                                    IdFactura
                                                FROM
                                                    #FacturasAdinco
                                                WHERE
                                                    EncontradoPetrovendor = 0
                                            )
                    --  
                    UNION
                    --  
                    SELECT
                        r.IdRegistro,
                        ISNULL(A.Codigo, 'SinClasificar') AS Codigo,
                        ISNULL(A.Nombre, 'SinClasificar') AS Descripcion,
                        S.RazonSocial                     AS RazonSocial,
                        S.RFC                             AS RFC,
                        CASE
                            WHEN FA.IdMoneda <> @Peso
                                then CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, FA.Fecha) AS DECIMAL(20, 2))
                            ELSE
                                ISNULL(R.MontoRegistro, 0)
                        END                               AS SubTotal,
                        FA.SubTotal                       AS SubTotalOriginal,
                        R.PCN                             AS PCN,
                        FA.IdFactura,
                        R.IdAceptacionPedidoDetalle
                    FROM
                        #FacturasAdinco                  FA
                        JOIN
                            dbo.CO_Registro              R (NOLOCK)
                                ON FA.IdFactura = R.IdFactura
                                   AND FA.EncontradoPetrovendor = 0
                                   AND FA.IdContrato = @IdContrato
                                   AND ISNULL(R.PCN, 0) >= 0
                                   AND R.IdGastoRubro = @Servicios
                        JOIN
                            dbo.PV_Subcontratista        S (NOLOCK)
                                ON FA.IdSubcontratista = S.IdSubcontratista
                                   AND S.TipoPersonaFiscalID = 1
                        JOIN
                            dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                                ON R.IdPrograma = L.IdLineaPresupuestoMeS
                        JOIN
                            #Presupuestos                PP (NOLOCK)
                                ON L.IdPresupuesto = PP.IdPresupuesto
                        LEFT JOIN
                            dbo.MM_BS_Actividad          A (NOLOCK)
                                ON R.IdCBSISH = A.IdActividad
                    WHERE
                        R.IdGastoRubro = @Servicios
                        AND S.RFC NOT IN (
                                             SELECT
                                                 RFC
                                             FROM
                                                 #RFC
                                         )
                        AND FA.IdContrato = @IdContrato
                        AND ISNULL(R.PCN, 0) >= 0
                        AND FA.IdMoneda IN (
                                               @Peso, @Dolar
                                           )
                        AND FA.IdFactura IN (
                                                SELECT
                                                    IdFactura
                                                FROM
                                                    #FacturasAdinco
                                                WHERE
                                                    EncontradoPetrovendor = 0
                                            )
                    ORDER BY
                        ISNULL(A.Nombre, 'SinClasificar');

        INSERT INTO #DATOS
            (
                IdRegistro,
                Codigo,
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                SubTotalOriginal,
                PCN,
                IdFactura,
                IdAceptacionPedidoDetalle
            )
                    SELECT DISTINCT
                        CO_Registro.IdRegistro,
                        ISNULL(MM_BS_Actividad.Codigo, 'SinClasificar') AS Codigo,
                        ISNULL(MM_BS_Actividad.Nombre, 'SinClasificar') AS Descripcion,
                        PV_Subcontratista.RazonSocial                   AS RazonSocial,
                        PV_Subcontratista.RFC                           AS RFC,
                        CASE
                            WHEN FI_PedimentoComprobante.IdMoneda = @Peso
                                THEN CAST(CO_Registro.MontoRegistro AS DECIMAL(20, 2))
                            ELSE
                                CAST([dbo].[FN_DolaresPesosTipoCambio](
                                                                          CO_Registro.MontoRegistro,
                                                                          FI_PedimentoComprobante.FechaPago
                                                                      ) AS DECIMAL(20, 2))
                        END                                             AS SubTotal,
                        FI_PedimentoComprobanteDetalle.PrecioUnitario   AS SubTotalOriginal,
                        CO_Registro.PCN                                 AS PCN,
                        FI_PedimentoComprobante.IdPedimentoComprobante,
                        CO_Registro.IdAceptacionPedidoDetalle
                    FROM
                        FI_PedimentoComprobante WITH (NOLOCK)
                        INNER JOIN
                            FI_PedimentoComprobanteDetalle WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
                                   AND FI_PedimentoComprobante.IdContrato = @IdContrato
                        INNER JOIN
                            PV_Subcontratista WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
                        INNER JOIN
                            CO_Registro WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
                                   AND CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero
                                   AND FI_PedimentoComprobante.IdContrato = @IdContrato
                                   AND ISNULL(CO_Registro.PCN, 0) >= 0
                                   AND CO_Registro.IdGastoRubro IN (
                                                                       @Servicios, NULL
                                                                   )
                        INNER JOIN
                            CO_LineaPresupuestoMes WITH (NOLOCK)
                                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                        INNER JOIN
                            #Presupuestos
                                ON CO_LineaPresupuestoMes.IdPresupuesto = #Presupuestos.IdPresupuesto
                        LEFT JOIN
                            dbo.MM_BS_Actividad WITH (NOLOCK)
                                ON CO_Registro.IdCBSISH = MM_BS_Actividad.IdActividad
                    WHERE
                        (
                            CAST(FI_PedimentoComprobante.FechaPago AS DATE) >= @FInicio
                            AND CAST(FI_PedimentoComprobante.FechaPago AS DATE) <= EOMONTH(@FFin)
                        )
                        AND FI_PedimentoComprobante.IdContrato = @IdContrato
                        AND ISNULL(CO_Registro.PCN, 0) >= 0


        /****************************/
        /*SELECT FINAL*/

        INSERT INTO #FINAL
            (
                Codigo,
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                PCN,
                IdFactura
            )
                    SELECT
                        Codigo,
                        Descripcion,
                        RazonSocial,
                        RFC,
                        SUM(SubTotal)       AS SubTotal,
                        SUM(SubTotal * PCN) AS PCN,
                        IdFactura
                    FROM
                        #DATOS
                    GROUP BY
                        Codigo,
                        Descripcion,
                        RazonSocial,
                        RFC,
                        IdFactura;

        /**/
        SELECT
            Codigo,
            Descripcion,
            RazonSocial,
            RFC,
            ISNULL(SUM(SubTotal), 0) AS SubTotal,
            CASE
                WHEN SUM(SubTotal) = 0
                    THEN 0
                ELSE
                    ISNULL(
                              CAST(SUBSTRING(
                                                LTRIM(SUM(PCN) / SUM(SubTotal)), 1,
                                                CHARINDEX('.', LTRIM(SUM(PCN) / SUM(SubTotal))) + 3
                                            ) AS FLOAT), 0
                          )
            END                      AS PCN,
            CASE
                WHEN SUM(SubTotal) = 0
                    THEN 0
                ELSE
                    ISNULL(
                              (SUM(SubTotal)
                               * CAST(SUBSTRING(
                                                   LTRIM(SUM(PCN) / SUM(SubTotal)), 1,
                                                   CHARINDEX('.', LTRIM(SUM(PCN) / SUM(SubTotal))) + 3
                                               ) AS FLOAT)
                              ), 0
                          )
            END                      AS CN,
            IdFactura
        FROM
            #FINAL
        GROUP BY
            Codigo,
            Descripcion,
            RazonSocial,
            RFC,
            IdFactura
        ORDER BY
            RazonSocial,
            Descripcion,
            IdFactura
    END
