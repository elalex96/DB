IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ReporteGINBDCN'
    )
    DROP PROCEDURE USP_SEL_CO_ReporteGINBDCN
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ReporteGINBDCN] -- 10,10007,'20231201'
    @UsuarioId  INT,
    @ContratoId INT,
    @Fecha      DATE
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Peso INT = 1;
        CREATE TABLE #TempGinBDCN
            (
                PPTO           VARCHAR(5000),
                TipoDeServicio VARCHAR(5000),
                Actividad      VARCHAR(5000),
                Servicio       VARCHAR(5000),
                NumeroFactura  VARCHAR(5000),
                Subcontratista VARCHAR(5000),
                FechaFactura   DATE,
                MontoRegistro  FLOAT,
                Moneda         VARCHAR(10),
                MesGE          DATE,
                MontoGEUSD     FLOAT,
                IDCN           VARCHAR(5000),
                TCBANXICOCN    FLOAT,
                HOMOLMXN       FLOAT,
                IdMoneda       INT,
                IdRegistro     int,
				UUID VARCHAR   (500)
            )

        INSERT INTO #TempGinBDCN
            (
                PPTO,
                TipoDeServicio,
                Actividad,
                Servicio,
                NumeroFactura,
                Subcontratista,
                FechaFactura,
                MontoRegistro,
                Moneda,
                MesGE,
                MontoGEUSD,
                IDCN,
                HOMOLMXN,
                IdMoneda,
                IdRegistro,
				UUID
            )
                    SELECT
                        CO_Presupuesto.Nombre                     AS PPTO,
                        CASE
                            WHEN CO_Presupuesto.ciep = 1
                                THEN CO_TipoServicio.NombreTipoServicio
                            ELSE
                                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                        END                                       AS TipoDeServicio,
                        CO_ActividadCIEP.NombreActividad          AS Actividad,
                        CO_Servicio.NombreServicio                AS Servicio,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN LTRIM(RTRIM(isnull(FI_Factura.Serie, '') + ' ' + isnull(FI_Factura.Folio, '')))
                            WHEN CO_Registro.CvTipoDocFacturacion = 2
                                THEN FI_PedimentoComprobante.NumeroPedimento
                            WHEN CO_Registro.CvTipoDocFacturacion = 3
                                THEN FI_PedimentoComprobante.FolioComprobante
                        END                                       AS NumeroFactura,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN SF.RazonSocial
                            WHEN.CO_Registro.CvTipoDocFacturacion IN (
                                                                         2, 3
                                                                     )
                                THEN SPC.RazonSocial
                        END                                       AS Subcontratista,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN CAST(FI_Factura.Fecha AS DATE)
                            WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                         2, 3
                                                                     )
                                THEN CAST(FI_PedimentoComprobante.FechaPago AS DATE)
                        END                                       AS FechaFactura,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN (CASE
                                          WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                               OR FI_Factura.TipoComprobante LIKE 'E%'
                                              THEN CAST(ROUND(
                                                                 ISNULL(
                                                                           (ABS(ISNULL(CO_Registro.MontoRegistro, 0))
                                                                            * -1
                                                                           ), 0
                                                                       ), 2
                                                             ) AS DECIMAL(15, 2))
                                          ELSE
                                              CAST(ROUND(CO_Registro.MontoRegistro, 2) AS DECIMAL(15, 2))
                                      END
                                     )
                            ELSE
                                CAST(ROUND(CO_Registro.MontoRegistro, 2) AS DECIMAL(15, 2))
                        END                                       AS MontoRegistro,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN TMF.TipoMonedaCorto
                            WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                         2, 3
                                                                     )
                                THEN TMPC.TipoMonedaCorto
                        END                                       AS Moneda,
                        CAST(CO_Registro.MesPresentacion AS DATE) AS MesGE,
                        SUM(   CAST((CASE
                                         WHEN CO_Registro.CvTipoDocFacturacion = 1
                                             THEN (CASE
                                                       WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                                            OR FI_Factura.TipoComprobante LIKE 'E%'
                                                           THEN ISNULL(
                                                                          (ABS(ISNULL(
                                                                                         ABS(ISNULL(
                                                                                                       CO_RegistroMarkup.MontoGasto,
                                                                                                       CO_Registro.MontoRegistro
                                                                                                   )
                                                                                            )
                                                                                         + ABS(ISNULL(
                                                                                                         CO_RegistroMarkup.MontoEquivalente,
                                                                                                         0
                                                                                                     )
                                                                                              ), 0
                                                                                     )
                                                                              ) * -1
                                                                          ), 0
                                                                      )
                                                       ELSE
                                                           ISNULL(
                                                                     ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                                                     + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0), 0
                                                                 )
                                                   END
                                                  )
                                         ELSE
                                             ISNULL(
                                                       ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                                       + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0), 0
                                                   )
                                     END
                                    ) / (CASE
                                             WHEN CO_Registro.CvTipoDocFacturacion = 1
                                                 THEN ISNULL(CO_RegistroMarkup.TipoCambio, TCDF.TipoCambio)
                                             WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                                          2, 3
                                                                                      )
                                                 THEN ISNULL(CO_RegistroMarkup.TipoCambio, TCDPC.TipoCambio)
                                             ELSE
                                                 0
                                         END
                                        ) AS DECIMAL(15, 2))
                           )                                      AS 'MontoGE (USD)',
                        CONCAT('CN-', YEAR(@Fecha),
						CASE  WHEN 
							UPPER(CO_GastosRubro.Descripcion) = 'BIENES'
									THEN '-CNB' 
							WHEN 
							UPPER(CO_GastosRubro.Descripcion) = 'CAPACITACION'
									THEN '-CNC'
							WHEN 
							UPPER(CO_GastosRubro.Descripcion) = 'SERVICIOS' AND CO_Registro.CvTipoDocFacturacion IN (2, 3)
									THEN '-S-E'
							WHEN 
							UPPER(CO_GastosRubro.Descripcion) = 'SERVICIOS'
									THEN '-CNS'
							WHEN 
							UPPER(CO_GastosRubro.Descripcion) = 'INFRAESTRUCTURA (SOCIAL)'
									THEN '-I'
							ELSE
								''
							END
							) AS IDCN,
                        SUM(   CAST((CASE
                                         WHEN CO_Registro.CvTipoDocFacturacion = 1
                                             THEN (CASE
                                                       WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                                            OR FI_Factura.TipoComprobante LIKE 'E%'
                                                           THEN ISNULL(
                                                                          (ABS(ISNULL(
                                                                                         ABS(ISNULL(
                                                                                                       CO_RegistroMarkup.MontoGasto,
                                                                                                       CO_Registro.MontoRegistro
                                                                                                   )
                                                                                            )
                                                                                         + ABS(ISNULL(
                                                                                                         CO_RegistroMarkup.MontoEquivalente,
                                                                                                         0
                                                                                                     )
                                                                                              ), 0
                                                                                     )
                                                                              ) * -1
                                                                          ), 0
                                                                      )
                                                       ELSE
                                                           ISNULL(
                                                                     ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                                                     + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0), 0
                                                                 )
                                                   END
                                                  )
                                         ELSE
                                             ISNULL(
                                                       ISNULL(CO_RegistroMarkup.MontoGasto, CO_Registro.MontoRegistro)
                                                       + ISNULL(CO_RegistroMarkup.MontoEquivalente, 0), 0
                                                   )
                                     END
                                    ) AS DECIMAL(15, 2))
                           )                                      AS HOMOLMXN,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN FI_Factura.IdMoneda
                            ELSE
                                FI_PedimentoComprobante.IdMoneda
                        END                                       AS IdMoneda,
                        IdRegistro,
						FI_Factura.UUID
                    FROM
                        CO_AnioContractual (NOLOCK)
                        JOIN
                            CO_Presupuesto (NOLOCK)
                                ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
                                   AND CO_AnioContractual.IdContrato = @ContratoId
                        JOIN
                            CO_LineaPresupuestoMes (NOLOCK)
                                ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
                        JOIN
                            CO_Registro (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
                        LEFT JOIN
                            dbo.CO_Servicio (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                        LEFT JOIN
                            dbo.CO_ActividadPetroleraCNH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                        LEFT JOIN
                            dbo.CO_TipoServicio			 WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
                        LEFT JOIN
                            dbo.CO_ActividadCIEP WITH (NOLOCK)
                                ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
                        LEFT JOIN
                            dbo.FI_Factura		WITH (NOLOCK)
                                ON CO_Registro.IdFactura = FI_Factura.IdFactura
                        LEFT JOIN
                            dbo.FI_PedimentoComprobante WITH (NOLOCK)
                                ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                        LEFT JOIN
                            dbo.PV_Subcontratista       AS SF WITH (NOLOCK)
                                ON FI_Factura.IdSubcontratista = SF.IdSubcontratista
                        LEFT JOIN
                            dbo.PV_Subcontratista       AS SPC WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdSubcontratistaExportador = SPC.IdSubcontratista
                        LEFT JOIN
                            dbo.PV_TipoMoneda           AS TMF WITH (NOLOCK)
                                ON FI_Factura.IdMoneda = TMF.IdMoneda
                        LEFT JOIN
                            dbo.CO_TipoCambioMensual    AS TCDF WITH (NOLOCK)
                                ON TMF.IdMoneda = TCDF.IdMoneda
                                   AND TCDF.Anio = YEAR(FI_Factura.Fecha)
                                   AND TCDF.IdMes = MONTH(FI_Factura.Fecha)
                        LEFT JOIN
                            dbo.PV_TipoMoneda           AS TMPC WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdMoneda = TMPC.IdMoneda
                        LEFT JOIN
                            dbo.CO_TipoCambioMensual    AS TCDPC WITH (NOLOCK)
                                ON TMPC.IdMoneda = TCDPC.IdMoneda
                                   AND TCDPC.Anio = YEAR(FI_PedimentoComprobante.FechaPago)
                                   AND TCDPC.IdMes = MONTH(FI_PedimentoComprobante.FechaPago)
                        LEFT JOIN
                            CO_RegistroMarkup            (NOLOCK)
                                ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
						LEFT JOIN dbo.CO_GastosRubro (NOLOCK)
							ON CO_Registro.IdGastoRubro = CO_GastosRubro.IdGastoRubro
                    WHERE
                        (
                            (YEAR(FI_Factura.Fecha) = YEAR(@Fecha))
                            OR (YEAR(FI_PedimentoComprobante.FechaPago) = YEAR(@Fecha))
                        )
                    group by
                        CO_Presupuesto.Nombre,
                        CASE
                            WHEN CO_Presupuesto.ciep = 1
                                THEN CO_TipoServicio.NombreTipoServicio
                            ELSE
                                CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
                        END,
                        CO_ActividadCIEP.NombreActividad,
                        CO_Servicio.NombreServicio,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN LTRIM(RTRIM(isnull(FI_Factura.Serie, '') + ' ' + isnull(FI_Factura.Folio, '')))
                            WHEN CO_Registro.CvTipoDocFacturacion = 2
                                THEN FI_PedimentoComprobante.NumeroPedimento
                            WHEN CO_Registro.CvTipoDocFacturacion = 3
                                THEN FI_PedimentoComprobante.FolioComprobante
                        END,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN SF.RazonSocial
                            WHEN.CO_Registro.CvTipoDocFacturacion IN (
                                                                         2, 3
                                                                     )
                                THEN SPC.RazonSocial
                        END,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN CAST(FI_Factura.Fecha AS DATE)
                            WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                         2, 3
                                                                     )
                                THEN CAST(FI_PedimentoComprobante.FechaPago AS DATE)
                        END,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN (CASE
                                          WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                               OR FI_Factura.TipoComprobante LIKE 'E%'
                                              THEN CAST(ROUND(
                                                                 ISNULL(
                                                                           (ABS(ISNULL(CO_Registro.MontoRegistro, 0))
                                                                            * -1
                                                                           ), 0
                                                                       ), 2
                                                             ) AS DECIMAL(15, 2))
                                          ELSE
                                              CAST(ROUND(CO_Registro.MontoRegistro, 2) AS DECIMAL(15, 2))
                                      END
                                     )
                            ELSE
                                CAST(ROUND(CO_Registro.MontoRegistro, 2) AS DECIMAL(15, 2))
                        END,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN TMF.TipoMonedaCorto
                            WHEN CO_Registro.CvTipoDocFacturacion IN (
                                                                         2, 3
                                                                     )
                                THEN TMPC.TipoMonedaCorto
                        END,
                        CAST(CO_Registro.MesPresentacion AS DATE),
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN ISNULL(CO_RegistroMarkup.TipoCambio, TCDF.TipoCambio)
                            WHEN CO_Registro.CvTipoDocFacturacion in (
                                                                         2, 3
                                                                     )
                                THEN ISNULL(CO_RegistroMarkup.TipoCambio, TCDPC.TipoCambio)
                        END,
                        CASE
                            WHEN CO_Registro.CvTipoDocFacturacion = 1
                                THEN FI_Factura.IdMoneda
                            ELSE
                                FI_PedimentoComprobante.IdMoneda
                        END,
                        co_registro.IdRegistro,
						CO_GastosRubro.Descripcion,
						CO_Registro.CvTipoDocFacturacion,
						FI_Factura.UUID


        --SELECT * FROM #TempGinBDCN
        UPDATE
            #TempGinBDCN
        SET
            HOMOLMXN = CAST((HOMOLMXN * TipoCambio) AS decimal(20, 2))
        FROM
            #TempGinBDCN
            JOIN
                CO_TipoCambioDiario
                    ON CAST(#TempGinBDCN.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
                       AND CO_TipoCambioDiario.IdMoneda = @Peso
                       AND #TempGinBDCN.IdMoneda <> @Peso
        WHERE
            #TempGinBDCN.IdMoneda <> @Peso

        UPDATE
            #TempGinBDCN
        SET
            TCBANXICOCN = TipoCambio
        FROM
            #TempGinBDCN
            JOIN
                CO_TipoCambioDiario
                    ON CAST(#TempGinBDCN.FechaFactura AS date) = CAST(CO_TipoCambioDiario.Fecha AS date)
                       AND CO_TipoCambioDiario.IdMoneda = @Peso


        SELECT
            PPTO,
            TipoDeServicio,
            Actividad,
            Servicio,
			UUID,
            NumeroFactura,
            Subcontratista,
            FechaFactura,
            MontoRegistro,
            Moneda,
            MesGE,
            MontoGEUSD,
            IDCN,
            TCBANXICOCN,
            HOMOLMXN		
        FROM
            #TempGinBDCN;

    END