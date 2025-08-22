IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_SE_A5_MPY'
    )
    DROP PROCEDURE SP_SE_A5_MPY;
GO

CREATE PROCEDURE [dbo].[SP_SE_A5_MPY] 
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
        /*Facturas de Adinco*/
        CREATE TABLE #FacturasAdinco
            (
                IdFactura             INT,
                UUID                  VARCHAR(500),
                RFC                   VARCHAR(50),
                EncontradoPetrovendor INT,
				SubTotal              money,
                IdSubcontratista      INT,
                IdContrato            INT,
                IdMoneda              INT,
                Fecha                 datetime
            );
        CREATE TABLE #DATOS
            (
                NoCapacitacion            INT NULL,
                Descripcion               VARCHAR(50),
                RazonSocial               VARCHAR(300),
                RFC                       VARCHAR(100),
                SubTotal                  FLOAT,
                SubTotalOriginal          FLOAT,
                PCN                       FLOAT,
                IdFactura                 INT,
                IdAceptacionPedidoDetalle INT
            )

		    DECLARE
            @Peso                                 INT = 1,
            @Dolar                                INT = 2,
            @EsPresupuestoJaguarPantera                        INT = 0,
            @EsPresupuestoGuardadosJaguarPanteraExploracion    INT = 0,
            @EsPresupuestoSeleccionadoJaguarPanteraExploracion INT = 0,
			@EstatusAprobado INT = 2,
			@Jaguar INT = 10005,	
			@Pantera INT = 10006,
			@Capacitaciones INT = 4;

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
                                INNER JOIN
                                    CO_Presupuesto     CP (NOLOCK)
                                        ON CPA.IdProgramaActividad = CP.IdProgramaActividad
                            WHERE
                                CPC.IdPeriodo = @IdPeriodo
                                AND CP.Activo = 1

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
                                                   );
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
                                    SELECT
                                        @IdPresupuesto;
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
						#Presupuestos                       PP
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
                                ON S.IdSubcontratista = F.IdSubcontratista
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

        INSERT INTO #DATOS
            (
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                PCN,
                IdFactura,
                IdAceptacionPedidoDetalle
            )
                    SELECT
                        ISNULL(APD.DESCRIPCIONCORTA, '')      AS Descripcion,
                        ISNULL(SV.VendorName, PR.RazonSocial) AS RazonSocial,
                        ISNULL(SV.TaxID, PR.RFC)              AS RFC,
                        PV.ValorFactura                       AS SubTotal,
                        APD.PCN                               AS PCN,
                        FA.IdFactura,
                        APD.IdAceptacionPedidoDetalle
                    FROM
                        #FacturasAdinco                                    FA
                        JOIN
                            Petrovendor.dbo.FI_Factura                     FP  (NOLOCK)
                                on FA.UUID = FP.UUID collate SQL_Latin1_General_CP1_CI_AS
                        JOIN
                            Petrovendor.dbo.MPY_MM_Aceptacionfactura       AF  (NOLOCK)
                                on FP.IdFactura = AF.IdFactura
                        JOIN
                            petrovendor.dbo.MPY_MM_AceptacionPedido        AP  (NOLOCK)
                                On AF.IdAceptacionPedido = AP.IdAceptacionPedido
                        JOIN
                            Petrovendor.dbo.MPY_MM_AceptacionCartaPCN      ACP  (NOLOCK)
                                on AP.IdAceptacionPedido = ACP.IdAceptacionPedido
                                   AND ACP.IdEstatus = @EstatusAprobado
                        JOIN
                            Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD  (NOLOCK)
                                on AP.IdAceptacionPedido = APD.IdAceptacionPedido
								AND		APD.ClasificacionCN = @Capacitaciones
                        LEFT JOIN
                            Petrovendor.dbo.MPY_MM_PCN_ValoresPesos        PV  (NOLOCK)
                                ON APD.IdAceptacionPedidoDetalle = PV.IdAceptacionPedidoDetalle
                        LEFT JOIN
                            Petrovendor.dbo.MM_BS_Actividad                AS BSA  (NOLOCK)
                                ON BSA.IdActividad = PV.IdCatalogoHidrocarburos
                        LEFT JOIN
                            Petrovendor.dbo.S_Proveedor                    AS PR (NOLOCK)
                                ON AP.IdSubContratista = PR.RFC
                                   AND PR.Activo = 1 -->CTE
                        LEFT JOIN
                            dbo.CO_SAPVendor                               AS SV (NOLOCK)
                                ON AP.IdSubContratista = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
                    WHERE
                        APD.ClasificacionCN = @Capacitaciones --Capacitaciones


        /*APARTADO ADINCO, se obtienen valores de adinco, ya que las facturas no existen en procura*/
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
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                PCN,
                IdFactura,
                IdAceptacionPedidoDetalle
            )
                    SELECT
                        R.Comentarios AS Descripcion,
                        S.RazonSocial AS RazonSocial,
                        S.RFC         AS RFC,
                        SUM(   CASE
                                   WHEN FA.IdMoneda = 1
                                       THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0)), 2) AS DECIMAL(20, 2))
                                   ELSE
                                       CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, FA.Fecha) AS DECIMAL(20, 2))
                               END
                           )          AS SubTotal,
                        R.PCN         AS PCN,
                        FA.IdFactura,
                        R.IdAceptacionPedidoDetalle
                    FROM
					   #FacturasAdinco                                    FA
                        JOIN
							dbo.CO_Registro                  R (NOLOCK)
							ON R.IdFactura = FA.IdFactura
                                   AND FA.EncontradoPetrovendor = 0
								   AND	R.IdGastoRubro = @Capacitaciones
                        JOIN
                            dbo.PV_Subcontratista        S (NOLOCK)
                                ON FA.IdSubcontratista = S.IdSubcontratista
                        JOIN
                            dbo.CO_LineaPresupuestoMes   L (NOLOCK)
                                ON R.IdPrograma = L.IdLineaPresupuestoMeS
                        JOIN
                            #Presupuestos                PP
                                ON L.IdPresupuesto = PP.IdPresupuesto
                    WHERE
                        R.IdGastoRubro = @Capacitaciones
                        AND S.RFC NOT IN (
                                             SELECT
                                                 RFC
                                             FROM
                                                 #RFC
                                         )
                        AND ISNULL(R.PCN, 0) >= 0
                        AND FA.IdFactura IN (
                                                SELECT
                                                    IdFactura
                                                FROM
                                                    #FacturasAdinco
                                                WHERE
                                                    EncontradoPetrovendor = 0
                                            )
                        AND FA.IdMoneda IN (
                                              @Peso, @Dolar
                                          )
                    GROUP BY
                        R.Comentarios,
                        S.RazonSocial,
                        S.RFC,
                        R.PCN,
                        FA.IdFactura,
                        R.IdAceptacionPedidoDetalle
                    ORDER BY
                        FA.IdFactura;

        /*SELECT FINAL*/
        SELECT
            ROW_NUMBER() OVER (ORDER BY
                                   Descripcion
                              )                                            AS NoCapacitacion,
            Descripcion,
            RazonSocial,
            RFC,
            ISNULL(CAST(SUM(SubTotal) AS DECIMAL(20, 2)), 0)               AS SubTotal,
            ISNULL(CAST(SUM(PCN) / COUNT(IdFactura) AS DECIMAL(20, 3)), 0) AS PCN,
            ISNULL(
                      CAST(CAST(SUM(SubTotal) AS DECIMAL(20, 2)) * CAST(SUM(PCN) / COUNT(IdFactura) AS DECIMAL(20, 3)) AS DECIMAL(20, 2)),
                      0
                  )                                                        AS CN,
            IdFactura
        FROM
            #DATOS
        GROUP BY
            Descripcion,
            RazonSocial,
            RFC,
            IdFactura;

    END
