-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		01 de Abril del 2022
-- Description:	    Se agrega join faltante, 
--					se ajusta caso al final 
--					de la consulta de si 
--					subtotal = 0 se regrese 0
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos
--					los presupuestos del periodo
--					seleccionado
-- =============================================
-- Modificado Por:	Reyna 
-- Create date:		12 de Abril del 2022
-- Description:		se Actualiza el stored procedure 
--                  para tomar en cuenta gastos con PCN >=0 (issue 1890 adinco)
-- ============================================
-- Modificado Por:	Reyna 
-- Create date:		28 de Abril del 2022
-- Description:		Manda a llamar el nuevo sp para contratos de murphy
-- ============================================
CREATE PROCEDURE [dbo].[SP_SE_A2]
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @FInicio DATE,
    @FFin DATE,
    @IdPeriodo INT,
    @Etapa VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RazonSocial VARCHAR(100) = '',
			@Peso INT = 1,
			@Dolar INT = 2,
			@Nacional INT = 1,
			@Extranjera INT = 2,
			@Jaguar INT = 10005,
			@Pantera INT = 10006,
			@Bienes INT = 2,
            @Aprobado                  INT = 10004,
            @TipoComprobanteExtranjero INT = 3


    SELECT @RazonSocial = CA.RazonSocial
    FROM CO_CONTRATO C
        JOIN CO_CONTRATISTA CA
            ON C.IdContratista = CA.IdContratista
               AND C.IdContrato = @IdContrato
    WHERE C.IdContrato = @IdContrato


    IF (@RazonSocial = 'Murphy Sur, S. de R.L. de C.V.')
    BEGIN
        EXEC [SP_SE_A2_MPY] @IdContrato,
                            @IdUsuario,
                            @IdPresupuesto,
                            @FInicio,
                            @FFin,
                            @IdPeriodo,
                            @Etapa;
    END
    ELSE
    BEGIN

        CREATE TABLE #Presupuestos (IdPresupuesto INT);
        CREATE TABLE #RFC (RFC VARCHAR(25));
        /*Se valida si el presupuesto viene en 0 para obtener todos los presupuestos del perido.*/
        IF (@IdPresupuesto = 0)
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
            IF 1 =
            (
                SELECT COUNT(1)
                FROM #Presupuestos T
                    JOIN dbo.CO_Presupuesto P (NOLOCK)
                        ON T.IdPresupuesto = P.IdPresupuesto
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE P.nombre LIKE '%exploración%'
                      AND C.IdContratista IN ( @Jaguar, @Pantera )
            )
            BEGIN
                DELETE FROM #Presupuestos
                INSERT INTO #Presupuestos
                (
                    IdPresupuesto
                )
                SELECT P.IdPresupuesto
                FROM dbo.CO_Presupuesto P (NOLOCK)
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE C.IdContrato = @IdContrato
                      AND P.nombre LIKE '%exploración%'
                      AND C.IdContratista IN ( @Jaguar, @Pantera )
            END;
        END
        ELSE
        BEGIN
            IF 1 =
            (
                SELECT COUNT(1)
                FROM dbo.CO_Presupuesto P (NOLOCK)
                    JOIN dbo.CO_AnioContractual AC (NOLOCK)
                        ON P.IdAnioContractual = AC.IdAnioContractual
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE P.IdPresupuesto = @IdPresupuesto
                      AND P.Nombre LIKE '%exploración%'
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
                    JOIN dbo.CO_Contrato C (NOLOCK)
                        ON AC.IdContrato = C.IdContrato
                WHERE C.IdContrato = @IdContrato
                      AND P.Nombre LIKE '%exploración%'
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
        /*RFC*/
        INSERT INTO #RFC
        (
            RFC
        )
        SELECT 'FMP140930MW3'
        UNION
        SELECT 'SAT970701NN3';
        IF 1 =
        (
            SELECT COUNT(1)
            FROM dbo.CO_Presupuesto P (NOLOCK)
                JOIN dbo.CO_AnioContractual AC (NOLOCK)
                    ON P.IdAnioContractual = AC.IdAnioContractual
                JOIN dbo.CO_Contrato C (NOLOCK)
                    ON AC.IdContrato = C.IdContrato
            WHERE P.IdPresupuesto = CASE
                                        WHEN @IdPresupuesto = 0 THEN
                                            P.IdPresupuesto
                                        ELSE
                                            @IdPresupuesto
                                    END
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
                   R.Comentarios AS Descripcion,
                   S.RazonSocial AS RazonSocial,
                   S.RFC AS RFC,
                   SUM(   CASE
                              WHEN F.IdMoneda = @Peso THEN
                                  CAST(ROUND((ISNULL(R.MontoRegistro, 0)), 2) AS DECIMAL(20, 2))
                              ELSE
                                  CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro, F.Fecha) AS DECIMAL(20, 2))
                          END
                      ) AS SubTotal,
                   ISNULL(R.PCN, 0) AS PCN,
                   SUM(CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2))) AS CN,
                   ROW_NUMBER() OVER (ORDER BY F.IdFactura) AS ID,
                   ROW_NUMBER() OVER (PARTITION BY F.IdFactura, S.RFC ORDER BY R.Comentarios) AS Repetido,
                   F.IdFactura
            FROM dbo.CO_Registro R (NOLOCK)
                JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
                    ON L.IdLineaPresupuestoMes = R.IdPrograma
                JOIN #Presupuestos PP
                    ON L.IdPresupuesto = PP.IdPresupuesto
                JOIN dbo.CO_Presupuesto P (NOLOCK)
                    ON P.IdPresupuesto = PP.IdPresupuesto
                JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
                    ON PA.IdProgramaActividad = P.IdProgramaActividad
                JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
                    ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                LEFT JOIN dbo.CO_PCNPorPeriodos PPP (NOLOCK)
                    ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
                LEFT JOIN dbo.FI_Factura F (NOLOCK)
                    ON F.IdFactura = R.IdFactura
                JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
                    ON F.IdMoneda <> TCD.IdMoneda
                       AND DAY(TCD.Fecha) = DAY(F.Fecha)
                       AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                       AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                LEFT JOIN dbo.PV_Subcontratista S (NOLOCK)
                    ON S.IdSubcontratista = F.IdSubcontratista
                LEFT JOIN dbo.MM_BS_Actividad A (NOLOCK)
                    ON R.IdCBSISH = A.IdActividad
                LEFT JOIN dbo.CO_Servicio SE (NOLOCK)
                    ON SE.IdServicio = L.IdServicio
            WHERE (
                      CAST(F.Fecha AS DATE) >= @FInicio
                      AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin)
                  )
                  AND R.IdGastoRubro = @Bienes
                  AND S.RFC NOT IN (
                                       SELECT RFC FROM #RFC
                                   )
                  AND F.IdContrato = @IdContrato
                  AND ISNULL(R.PCN, 0) >= 0
                  AND PPP.IdContrato = @IdContrato
            GROUP BY ISNULL(A.Codigo, 'SinClasificar'),
                     R.Comentarios,
                     S.RazonSocial,
                     S.RFC,
                     ISNULL(R.PCN, 0),
                     F.IdFactura,
                     F.IdMoneda
            ORDER BY S.RFC;
        END;
        ELSE
        BEGIN
            CREATE TABLE #DATOS
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
				IdMoneda INT,
				SubtotalDls FLOAT,
				FechaFactura DATETIME,
				MontoRegistro FLOAT
            )
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
                IdAceptacionPedidoDetalle,
				IdMoneda,
				FechaFactura,
				MontoRegistro
            )
            SELECT ISNULL(MM_BS_Actividad.Codigo, 'SinClasificar') AS Codigo,
                   ISNULL(MM_BS_Actividad.Nombre, 'SinClasificar') AS Descripcion,
                   PV_Subcontratista.RazonSocial AS RazonSocial,
                   PV_Subcontratista.RFC AS RFC,
                   CASE
                       WHEN FI_Factura.IdMoneda = @Peso THEN
                           CAST(CO_Registro.MontoRegistro AS DECIMAL(20, 2))
                   END AS SubTotal,
                   FI_Factura.SubTotal AS SubTotalOriginal,
                   CO_Registro.PCN AS PCN,
                   FI_Factura.IdFactura,
                   CO_Registro.IdAceptacionPedidoDetalle,
				   FI_Factura.IdMoneda,
				   FI_Factura.Fecha,
				   CO_Registro.MontoRegistro
            FROM dbo.CO_Registro (NOLOCK)
                JOIN dbo.FI_Factura (NOLOCK)
                    ON CO_Registro.IdFactura = FI_Factura.IdFactura
                JOIN dbo.PV_Subcontratista (NOLOCK)
                    ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                       AND PV_Subcontratista.TipoPersonaFiscalID = @Extranjera
                JOIN dbo.CO_LineaPresupuestoMes (NOLOCK)
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMeS
                JOIN #Presupuestos
                    ON CO_LineaPresupuestoMes.IdPresupuesto = #Presupuestos.IdPresupuesto
                JOIN dbo.CO_Presupuesto (NOLOCK)
                    ON #Presupuestos.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                JOIN dbo.CO_ProgramaActividad (NOLOCK)
                    ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
                JOIN dbo.CO_TipoProgramaActividad (NOLOCK)
                    ON CO_ProgramaActividad.IdTipoProgramaActividad = CO_TipoProgramaActividad.IdTipoProgramaActividad
                LEFT JOIN dbo.MM_BS_Actividad (NOLOCK)
                    ON CO_Registro.IdCBSISH = MM_BS_Actividad.IdActividad
            WHERE (
                      CAST(FI_Factura.Fecha AS DATE) >= @FInicio
                      AND CAST(FI_Factura.Fecha AS DATE) <= EOMONTH(@FFin)
                  )
                  AND CO_Registro.IdGastoRubro = @Extranjera
                  AND PV_Subcontratista.RFC NOT IN (
                                       SELECT RFC FROM #RFC
                                   )
                  AND FI_Factura.IdContrato = @IdContrato
                  AND ISNULL(CO_Registro.PCN, 0) >= 0

            --    
            UNION
            --    
            SELECT ISNULL(MM_BS_Actividad.Codigo, 'SinClasificar') AS Codigo,
                   ISNULL(MM_BS_Actividad.Nombre, 'SinClasificar') AS Descripcion,
                   PV_Subcontratista.RazonSocial AS RazonSocial,
                   PV_Subcontratista.RFC AS RFC,
                   CASE
                       WHEN FI_Factura.IdMoneda = @Peso THEN
                           CAST(CO_Registro.MontoRegistro AS DECIMAL(20, 2))
                   END AS SubTotal,
                   FI_Factura.SubTotal AS SubTotalOriginal,
                   CO_Registro.PCN AS PCN,
                   FI_Factura.IdFactura,
                   CO_Registro.IdAceptacionPedidoDetalle,
				   FI_Factura.IdMoneda,
				   FI_Factura.Fecha,
				   CO_Registro.MontoRegistro
            FROM dbo.CO_Registro (NOLOCK)
                JOIN dbo.FI_Factura (NOLOCK)
                    ON CO_Registro.IdFactura = FI_Factura.IdFactura
                JOIN dbo.PV_Subcontratista (NOLOCK)
                    ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                       AND PV_Subcontratista.TipoPersonaFiscalID = @Nacional
                JOIN dbo.CO_LineaPresupuestoMes (NOLOCK)
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMeS
                JOIN #Presupuestos
                    ON CO_LineaPresupuestoMes.IdPresupuesto = #Presupuestos.IdPresupuesto
                JOIN dbo.CO_Presupuesto (NOLOCK)
                    ON #Presupuestos.IdPresupuesto = CO_Presupuesto.IdPresupuesto
                JOIN dbo.CO_ProgramaActividad (NOLOCK)
                    ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
                JOIN dbo.CO_TipoProgramaActividad (NOLOCK)
                    ON CO_TipoProgramaActividad.IdTipoProgramaActividad = CO_ProgramaActividad.IdTipoProgramaActividad
                JOIN dbo.CO_TipoCambioDiario (NOLOCK)
                    ON FI_Factura.IdMoneda <> CO_TipoCambioDiario.IdMoneda
                       AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)
                       AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)
                       AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)
                LEFT JOIN dbo.MM_BS_Actividad (NOLOCK)
                    ON CO_Registro.IdCBSISH = MM_BS_Actividad.IdActividad
            WHERE (
                      CAST(FI_Factura.Fecha AS DATE) >= @FInicio
                      AND CAST(FI_Factura.Fecha AS DATE) <= EOMONTH(@FFin)
                  )
                  AND CO_Registro.IdGastoRubro = @Bienes
                  AND PV_Subcontratista.RFC NOT IN (
                                       SELECT RFC FROM #RFC
                                   )
                  AND FI_Factura.IdContrato = @IdContrato
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
						WHEN FI_PedimentoComprobante.IdMoneda = @Peso THEN
							CAST(CO_Registro.MontoRegistro AS DECIMAL(20, 2))
					END AS SubTotal,
					FI_PedimentoComprobanteDetalle.PrecioUnitario AS SubTotalOriginal,
					CO_Registro.PCN AS PCN,
					FI_PedimentoComprobante.IdPedimentoComprobante,
					CO_Registro.IdAceptacionPedidoDetalle,
					FI_PedimentoComprobante.IdMoneda,
					FI_PedimentoComprobante.FechaPago,
					CO_Registro.MontoRegistro
			FROM FI_PedimentoComprobante WITH (NOLOCK)
			INNER JOIN FI_PedimentoComprobanteDetalle
				ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
				AND FI_PedimentoComprobante.IdContrato = @IdContrato
			INNER JOIN PV_Subcontratista WITH (NOLOCK)
			    ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
			INNER JOIN CO_Registro WITH (NOLOCK)
				ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
				AND CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero
				AND CO_Registro.IdGastoRubro = @Bienes
			    AND CO_Registro.IdEstado = @Aprobado	
			INNER JOIN CO_LineaPresupuestoMes WITH (NOLOCK)
			    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
			INNER JOIN #Presupuestos
			    ON CO_LineaPresupuestoMes.IdPresupuesto = #Presupuestos.IdPresupuesto
			INNER JOIN CO_Presupuesto WITH (NOLOCK)
			    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
				AND CO_LineaPresupuestoMes.IdPresupuesto = #Presupuestos.IdPresupuesto
			INNER JOIN dbo.CO_ProgramaActividad WITH (NOLOCK)
			    ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
			INNER JOIN dbo.CO_TipoProgramaActividad WITH (NOLOCK)
			    ON CO_ProgramaActividad.IdTipoProgramaActividad = CO_TipoProgramaActividad.IdTipoProgramaActividad
			LEFT JOIN dbo.MM_BS_Actividad WITH (NOLOCK)
			    ON CO_Registro.IdCBSISH = MM_BS_Actividad.IdActividad
			WHERE (CAST(FI_PedimentoComprobante.FechaPago AS DATE) >= @FInicio
			        AND CAST(FI_PedimentoComprobante.FechaPago AS DATE) <= EOMONTH(@FFin)
			                )
					AND FI_PedimentoComprobante.IdContrato = @IdContrato
					AND ISNULL(CO_Registro.PCN, 0) >= 0

			
			-- CONVERSION A DLS
			UPDATE #DATOS
			SET SubtotalDls = MontoRegistro / TipoCambio  
			FROM #DATOS
			LEFT JOIN CO_TipoCambioDiario
				ON CAST(#DATOS.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
				AND #DATOS.IdMoneda = CO_TipoCambioDiario.IdMoneda
				AND #DATOS.IdMoneda <> @Peso
			WHERE #DATOS.IdMoneda <> @Peso

			-- CONVERSION A PESOS
			UPDATE #DATOS
			SET SubTotal = CAST(SubtotalDls * TipoCambio AS decimal(20, 2)) 
			FROM #DATOS
			LEFT JOIN CO_TipoCambioDiario
				ON CAST(#DATOS.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
				AND CO_TipoCambioDiario.IdMoneda = @Peso
				AND #DATOS.IdMoneda <> @Peso
			WHERE #DATOS.IdMoneda <> @Peso


            /*SELECT FINAL*/
            SELECT Codigo,
                   Descripcion,
                   RazonSocial,
                   RFC,
                   SUM(SubTotal) AS SubTotal,
                   SUM(SubTotal * PCN) AS PCN,
                   IdFactura
            INTO #FINAL
            FROM #DATOS
            GROUP BY Codigo,
                     Descripcion,
                     RazonSocial,
                     RFC,
                     IdFactura;
            /**/
            SELECT Codigo,
                   Descripcion,
                   RazonSocial,
                   RFC,
                   ISNULL(SUM(SubTotal), 0) AS SubTotal,
                   CASE
                       WHEN SUM(SubTotal) = 0 THEN
                           0
                       ELSE
                           ISNULL(
                                     CAST(SUBSTRING(
                                                       LTRIM(SUM(PCN) / SUM(SubTotal)),
                                                       1,
                                                       CHARINDEX('.', LTRIM(SUM(PCN) / SUM(SubTotal))) + 3
                                                   ) AS FLOAT),
                                     0
                                 )
                   END AS PCN,
                   CASE
                       WHEN SUM(SubTotal) = 0 THEN
                           0
                       ELSE
                           ISNULL(
                                     (SUM(SubTotal)
                                      * CAST(SUBSTRING(
                                                          LTRIM(SUM(PCN) / SUM(SubTotal)),
                                                          1,
                                                          CHARINDEX('.', LTRIM(SUM(PCN) / SUM(SubTotal))) + 3
                                                      ) AS FLOAT)
                                     ),
                                     0
                                 )
                   END AS CN,
                   IdFactura
            FROM #FINAL
            GROUP BY Codigo,
                     Descripcion,
                     RazonSocial,
                     RFC,
                     IdFactura
            ORDER BY RazonSocial,
                     Descripcion,
                     IdFactura
        END;
    END;
END;


