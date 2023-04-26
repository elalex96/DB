-- =============================================  
-- Author:  Manuel Cruz  
-- Create date: 2018-10-02  
-- Description:   
-- ============================================  
-- Modificado Por: Reyna   
-- Create date:  12 de Abril del 2022  
-- Description:  se Actualiza el stored procedure    
--     para tomar en cuenta gastos con PCN >=0,  
--        tambien para poder retornar montos cuando el usuario selecciona Presupuesto: TODOS  
--     tambien se modifica la conversión de dolares a pesor, ya que los montos no cuadraban con lo que se mostraba en las hojas  
--     (issue 1890 adinco)  
-- ============================================  
-- Modificado Por: Reyna   
-- Create date:  28 de Abril del 2022  
-- Description:  Manda a llamar el nuevo sp para contratos de murphy  
-- ============================================  
CREATE PROCEDURE [dbo].[SP_SE_TotalFacturadoRubro]
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @FInicio DATE,
    @FFin DATE,
    @IdRubro INT,
    @IdPeriodo INT,
    @Etapa VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    /* SE AGREGA LA LLAMADA DEL NUEVO STORED PROCEDURE PARA MURPHY, DONDE MANDA A LLAMAR DATOS DE PROCURA/PETROVENDOR*/
	DECLARE @Jaguar INT = 10005,
            @Pantera INT = 10006,
			@Bienes INT = 2,
			@Servicios INT = 3,
			@Peso INT = 1,
			@Dolar INT = 2,
			@Nacional INT = 1,
			@Extranjera INT = 2

    DECLARE @RazonSocial VARCHAR(100) = '';

    SELECT @RazonSocial = CA.RazonSocial
    FROM CO_CONTRATO C
        JOIN CO_CONTRATISTA CA
            ON C.IdContratista = CA.IdContratista
               AND C.IdContrato = @IdContrato
    WHERE C.IdContrato = @IdContrato


    IF (@RazonSocial = 'Murphy Sur, S. de R.L. de C.V.')
    BEGIN
        EXEC [SP_SE_TotalFacturadoRubro_MPY] @IdContrato,
                                             @IdUsuario,
                                             @IdPresupuesto,
                                             @FInicio,
                                             @FFin,
                                             @IdRubro,
                                             @IdPeriodo,
                                             @Etapa;
    END
    ELSE
    BEGIN
        -- SE AGREGA LA OPCIÓN DE PRESUPUESTOS TODOS ISSUE 1890 RO  
        CREATE TABLE #Presupuestos (IdPresupuesto INT);
        CREATE TABLE #RFC (RFC VARCHAR(25));
        CREATE TABLE #DATOS2
        (
            Codigo VARCHAR(50),
            Descripcion VARCHAR(300),
            RazonSocial VARCHAR(300),
            RFC VARCHAR(100),
            SubTotal FLOAT,
            SubTotalOriginal FLOAT,
            PCN FLOAT,
            IdFactura INT,
            IdAceptacionPedidoDetalle INT,
            IdGastoRubro INT,
            IdRegistro INT
        )

        IF (@IdPresupuesto = 0) -- TODOS  
        BEGIN
            IF 1 =
            (
                SELECT COUNT(1)
                FROM dbo.CO_Presupuesto P (NOLOCK)
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                           AND P.idpresupuesto = @IdPresupuesto
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE P.idpresupuesto = @IdPresupuesto
                      AND P.nombre LIKE '%exploración%'
                      AND C.IdContratista IN ( @Jaguar, @Pantera )
            )
            BEGIN
                INSERT INTO #Presupuestos
                (
                    IdPresupuesto
                )
                SELECT P.IdPresupuesto
                FROM CO_ProgramaActividad CPA (NOLOCK)
                    JOIN CO_PeriodoContrato CPC (NOLOCK)
                        ON CPA.IdPeriodoContrato = CPC.IdPeriodo
                    JOIN CO_Presupuesto P (NOLOCK)
                        ON CPA.IdProgramaActividad = P.IdProgramaActividad
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                           AND P.nombre LIKE '%exploración%'
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE C.IdContrato = @IdContrato
                      AND P.nombre LIKE '%exploración%'
                      AND C.IdContratista IN ( @Jaguar, @Pantera )
                      AND CPC.IdPeriodo = @IdPeriodo
                      AND P.Activo = 1
            END;
            ELSE
            BEGIN

                INSERT INTO #Presupuestos
                (
                    IdPresupuesto
                )
                SELECT CP.IdPresupuesto
                FROM CO_ProgramaActividad CPA (NOLOCK)
                    INNER JOIN CO_PeriodoContrato CPC (NOLOCK)
                        ON CPA.IdPeriodoContrato = CPC.IdPeriodo
                    INNER JOIN CO_Presupuesto CP (NOLOCK)
                        ON CPA.IdProgramaActividad = CP.IdProgramaActividad
                WHERE CPC.IdPeriodo = @IdPeriodo
                      AND CP.Activo = 1
            END;
        END
        ELSE
        BEGIN --VERSION ANTERIOR (SOLO CON UN PRESUPUESTO)  
            IF 1 =
            (
                SELECT COUNT(1)
                FROM dbo.CO_Presupuesto P (NOLOCK)
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                           AND P.idpresupuesto = @IdPresupuesto
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE P.idpresupuesto = @IdPresupuesto
                      AND P.nombre LIKE '%exploración%'
                      AND C.IdContratista IN ( @Jaguar, @Pantera )
            )
            BEGIN
                INSERT INTO #Presupuestos
                (
                    IdPresupuesto
                )
                SELECT P.IdPresupuesto
                FROM dbo.CO_Presupuesto P (NOLOCK)
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                           AND P.nombre LIKE '%exploración%'
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE C.IdContrato = @IdContrato
                      AND P.nombre LIKE '%exploración%'
                      AND C.IdContratista IN ( @Jaguar, @Pantera )
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

        /**/
        INSERT INTO #RFC
        (
            RFC
        )
        SELECT 'FMP140930MW3'
        UNION
        SELECT 'SAT970701NN3';
        /**/
        IF 1 =
        (
            SELECT COUNT(1)
            FROM dbo.CO_Presupuesto P (NOLOCK)
                JOIN dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                       AND P.idpresupuesto = @IdPresupuesto
                JOIN dbo.CO_Contrato C (NOLOCK)
                    ON AC.IdContrato = C.IdContrato
            WHERE P.idpresupuesto = @IdPresupuesto
                  AND C.IdContratista IN ( @Jaguar, @Pantera )
        )
        BEGIN
            INSERT INTO #RFC
            (
                RFC
            )
            SELECT 'FMO930803PB1'
            UNION
            SELECT 'GMS971110BTA';
        END;

        /*Consulta final*/

        IF (@FFin <= '2018-12-01')
        BEGIN
            SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo,
                   CO_Registro.Comentarios AS Descripcion,
                   PV_Subcontratista.RazonSocial AS RazonSocial,
                   PV_Subcontratista.RFC AS RFC,
                   SUM(CAST(ROUND((ISNULL(CO_Registro.MontoRegistro, 0) * CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(20, 2))) AS SubTotal,
                   ISNULL(CO_Registro.PCN, 0) AS PCN,
                   SUM(CAST(ROUND((ISNULL((ISNULL(CO_Registro.PCN, 0) * CO_Registro.MontoRegistro), 0) * CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(20, 2))) AS CN,
                   ROW_NUMBER() OVER (ORDER BY FI_Factura.IdFactura) AS ID,
                   ROW_NUMBER() OVER (PARTITION BY FI_Factura.IdFactura, PV_Subcontratista.RFC ORDER BY CO_Registro.Comentarios) AS Repetido,
                   FI_Factura.IdFactura,
                   CO_Registro.IdGastoRubro
            INTO #DATOS
            FROM #Presupuestos 
                JOIN dbo.CO_LineaPresupuestoMes (NOLOCK)
                    ON #Presupuestos.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                JOIN dbo.CO_Registro (NOLOCK)
                    ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                JOIN dbo.CO_Presupuesto (NOLOCK)
                    ON CO_Presupuesto.IdPresupuesto = #Presupuestos.IdPresupuesto
                JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
                    ON PA.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                JOIN dbo.CO_TipoProgramaActividad (NOLOCK)
                    ON CO_TipoProgramaActividad.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                LEFT JOIN dbo.CO_PCNPorPeriodos PPP (NOLOCK)
                    ON PPP.IdTipoPgrogramaActividad = CO_TipoProgramaActividad.IdTipoProgramaActividad
                LEFT JOIN dbo.FI_Factura (NOLOCK)
                    ON FI_Factura.IdFactura = CO_Registro.IdFactura
                LEFT JOIN dbo.CO_TipoCambioDiario (NOLOCK)
                    ON FI_Factura.IdMoneda <> CO_TipoCambioDiario.IdMoneda
                       AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)
                       AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)
                       AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)
                LEFT JOIN dbo.PV_Subcontratista (NOLOCK)
                    ON PV_Subcontratista.IdSubcontratista = FI_Factura.IdSubcontratista
                LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
                    ON CO_Registro.IdCBSISH = A.IdActividad
            WHERE (
                      CAST(FI_Factura.Fecha AS DATE) >= @FInicio
                      AND CAST(FI_Factura.Fecha AS DATE) <= EOMONTH(@FFin)
                  )
                  AND PV_Subcontratista.RFC NOT IN (
                                       SELECT RFC FROM #RFC
                                   )
                  AND FI_Factura.IdContrato = @IdContrato
                  AND PPP.IdContrato = @IdContrato
            GROUP BY ISNULL(A.Codigo, 'SinClasificar'),
                     CO_Registro.Comentarios,
                     PV_Subcontratista.RazonSocial,
                     PV_Subcontratista.RFC,
                     CAST(ROUND((ISNULL(CO_Registro.MontoRegistro, 0) * CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(20, 2)),
                     ISNULL(CO_Registro.PCN, 0),
                     CAST(ROUND((ISNULL((ISNULL(CO_Registro.PCN, 0) * CO_Registro.MontoRegistro), 0) * CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(20, 2)),
                     FI_Factura.IdFactura,
                     CO_Registro.IdGastoRubro
            ORDER BY PV_Subcontratista.RFC;

            /*RESUMEN*/

            IF (@IdRubro = @Bienes)
            BEGIN
                SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos,
                       IdGastoRubro AS IdRubroGasto
                FROM #DATOS
                WHERE IdGastoRubro = @Bienes
                GROUP BY IdGastoRubro;
            END;
            ELSE
            BEGIN
                SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos,
                       IdGastoRubro AS IdRubroGasto
                FROM #DATOS
                WHERE IdGastoRubro = @Servicios
                GROUP BY IdGastoRubro;
            END;
        END;
        ELSE
        BEGIN

            INSERT INTO #DATOS2
            (
                Codigo,
                Descripcion,
                RazonSocial,
                RFC,
                SubTotal,
                SubTotalOriginal,
                PCN,
                IdFactura,
                IdAceptacionPedidoDetalle,
                IdGastoRubro,
                IdRegistro
            )
            SELECT DISTINCT
                ISNULL(MM_BS_Actividad.Codigo, 'SinClasificar') AS Codigo,
                ISNULL(MM_BS_Actividad.Nombre, 'SinClasificar') AS Descripcion,
                PV_Subcontratista.RazonSocial AS RazonSocial,
                PV_Subcontratista.RFC AS RFC,
                CASE
                    WHEN FI_Factura.IdMoneda <> @Peso then
                        CAST([dbo].[FN_DolaresPesosTipoCambio](CO_Registro.MontoRegistro, FI_Factura.Fecha) AS DECIMAL(20, 2))
                    ELSE
                        ISNULL(CO_Registro.MontoRegistro, 0)
                END AS SubTotal,
                FI_Factura.SubTotal AS SubTotalOriginal,
                CO_Registro.PCN AS PCN,
                FI_Factura.IdFactura,
                CO_Registro.IdAceptacionPedidoDetalle,
                CO_Registro.IdGastoRubro,
                CO_Registro.IdRegistro
            FROM #Presupuestos 
                JOIN dbo.CO_LineaPresupuestoMes (NOLOCK)
                    ON #Presupuestos.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                JOIN dbo.CO_Registro (NOLOCK)
                    ON CO_LineaPresupuestoMes.IdLineaPresupuestoMeS = CO_Registro.IdPrograma
                       AND CO_Registro.IdGastoRubro IN ( @Bienes, @Servicios )
                JOIN dbo.CO_Presupuesto (NOLOCK)
                    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                JOIN dbo.CO_ProgramaActividad (NOLOCK)
                    ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
                JOIN dbo.CO_TipoProgramaActividad (NOLOCK)
                    ON CO_TipoProgramaActividad.IdTipoProgramaActividad = CO_ProgramaActividad.IdTipoProgramaActividad
                LEFT JOIN dbo.FI_Factura (NOLOCK)
                    ON CO_Registro.IdFactura = FI_Factura.IdFactura
					AND FI_Factura.IdContrato = @IdContrato
                LEFT JOIN dbo.PV_Subcontratista (NOLOCK)
                    ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                       AND PV_Subcontratista.TipoPersonaFiscalID = @Extranjera
                LEFT JOIN dbo.MM_BS_Actividad
                    ON CO_Registro.IdCBSISH = MM_BS_Actividad.IdActividad
            WHERE (
                      CAST(FI_Factura.Fecha AS DATE) >= @FInicio
                      AND CAST(FI_Factura.Fecha AS DATE) <= EOMONTH(@FFin)
                  )
                  AND PV_Subcontratista.RFC NOT IN (
                                       SELECT RFC FROM #RFC
                                   )
                  AND FI_Factura.IdContrato = @IdContrato
                  AND FI_Factura.IdMoneda IN ( @Peso, @Dolar )
                  AND CO_Registro.IdGastoRubro IN ( @Bienes, @Servicios )
                  AND ISNULL(CO_Registro.PCN, 0) >= 0 
            --  
            UNION
            --  
            SELECT DISTINCT
                ISNULL(MM_BS_Actividad.Codigo, 'SinClasificar') AS Codigo,
                ISNULL(MM_BS_Actividad.Nombre, 'SinClasificar') AS Descripcion,
                PV_Subcontratista.RazonSocial AS RazonSocial,
                PV_Subcontratista.RFC AS RFC,
                CASE
                    WHEN FI_Factura.IdMoneda <> @Peso then
                        CAST([dbo].[FN_DolaresPesosTipoCambio](CO_Registro.MontoRegistro, FI_Factura.Fecha) AS DECIMAL(20, 2))
                    ELSE
                        ISNULL(CO_Registro.MontoRegistro, 0)
                END AS SubTotal,
                FI_Factura.SubTotal AS SubTotalOriginal,
                CO_Registro.PCN AS PCN,
                FI_Factura.IdFactura,
                CO_Registro.IdAceptacionPedidoDetalle,
                CO_Registro.IdGastoRubro,
                CO_Registro.IdRegistro
            FROM #Presupuestos
                JOIN dbo.CO_LineaPresupuestoMes (NOLOCK)
                    ON #Presupuestos.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                JOIN dbo.CO_Registro (NOLOCK)
                    ON CO_LineaPresupuestoMes.IdLineaPresupuestoMeS = CO_Registro.IdPrograma
                       AND CO_Registro.IdGastoRubro IN ( @Bienes, @Servicios )
                JOIN dbo.CO_Presupuesto (NOLOCK)
                    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                JOIN dbo.CO_ProgramaActividad (NOLOCK)
                    ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
                JOIN dbo.CO_TipoProgramaActividad (NOLOCK)
                    ON CO_TipoProgramaActividad.IdTipoProgramaActividad = CO_ProgramaActividad.IdTipoProgramaActividad
                LEFT JOIN dbo.FI_Factura (NOLOCK)
                    ON CO_Registro.IdFactura = FI_Factura.IdFactura
                LEFT JOIN dbo.PV_Subcontratista (NOLOCK)
                    ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                       AND PV_Subcontratista.TipoPersonaFiscalID = @Nacional
                LEFT JOIN dbo.MM_BS_Actividad (NOLOCK)
                    ON CO_Registro.IdCBSISH = MM_BS_Actividad.IdActividad
            WHERE (
                      CAST(FI_Factura.Fecha AS DATE) >= @FInicio
                      AND CAST(FI_Factura.Fecha AS DATE) <= EOMONTH(@FFin)
                  )
                  AND PV_Subcontratista.RFC NOT IN (
                                       SELECT RFC FROM #RFC
                                   )
                  AND FI_Factura.IdContrato = @IdContrato
                  AND FI_Factura.IdMoneda IN ( @Peso, @Dolar )
                  AND CO_Registro.IdGastoRubro IN ( @Bienes, @Servicios )
                  AND ISNULL(CO_Registro.PCN, 0) >= 0


            /*RESUMEN*/

            IF (@IdRubro = @Bienes)
            BEGIN
                SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos,
                       IdGastoRubro AS IdRubroGasto
                FROM #DATOS2
                WHERE IdGastoRubro = @Bienes
                GROUP BY IdGastoRubro;
            END;
            ELSE
            BEGIN
                SELECT CAST(ISNULL(SUM(SubTotal), 0) AS DECIMAL(20, 2)) AS SubTotalGastos,
                       IdGastoRubro AS IdRubroGasto
                FROM #DATOS2
                WHERE IdGastoRubro = @Servicios
                GROUP BY IdGastoRubro;
            END;
        END;
    END
END;

