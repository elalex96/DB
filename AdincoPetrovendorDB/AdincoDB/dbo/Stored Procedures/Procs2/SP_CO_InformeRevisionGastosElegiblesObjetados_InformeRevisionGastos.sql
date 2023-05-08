CREATE PROCEDURE [dbo].[SP_CO_InformeRevisionGastosElegiblesObjetados_InformeRevisionGastos]
    @IdPresupuesto INT,
    @MesPresentacion DATE
AS
BEGIN
    DECLARE @Contrato INT;

    SELECT TOP 1
        @Contrato = CO_PeriodoContrato.IdContrato
    FROM CO_Presupuesto (NOLOCK)
        JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
        JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
    WHERE CO_Presupuesto.IdPresupuesto = @IdPresupuesto

    SELECT ISNULL(CO_Presupuesto.Nombre, '') AS 'Plan',
           ISNULL(CO_TipoServicio.NombreTipoServicio, '') AS 'Clasificación General',
           ISNULL(CO_ActividadCIEP.NombreActividad, '') AS 'Actividad',
           ISNULL(CO_Servicio.NombreServicio, '') AS Servicio,
           CASE
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NOT NULL THEN
                   ISNULL(PV_Subcontratista_RefacturasF.RazonSocial, '')
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NULL THEN
                   ISNULL(PV_Subcontratista_Factura.RazonSocial, '')
               WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NOT NULL THEN
                   ISNULL(PV_Subcontratista_RefacturasPEPI.RazonSocial, '')
               WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NULL THEN
                   ISNULL(PV_Subcontratista_Extranjero.RazonSocial, '')
               ELSE
                   ''
           END AS 'Proveedor',
           CASE
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NOT NULL THEN
                   LTRIM(RTRIM(CONCAT(
                                         ISNULL(FI_Factura_RefacturasF.Serie, ''),
                                         ' ',
                                         ISNULL(FI_Factura_RefacturasF.Folio, '')
                                     )
                              )
                        )
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NULL THEN
                   LTRIM(RTRIM(CONCAT(ISNULL(FI_Factura.Serie, ''), ' ', ISNULL(FI_Factura.Folio, ''))))
               WHEN CO_Registro.CvTipoDocFacturacion = 2
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NOT NULL THEN
                   LTRIM(RTRIM(CONCAT(
                                         ISNULL(FI_Factura_RefacturasPEPI.Serie, ''),
                                         ' ',
                                         ISNULL(FI_Factura_RefacturasPEPI.Folio, '')
                                     )
                              )
                        )
               WHEN CO_Registro.CvTipoDocFacturacion = 2
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NULL THEN
                   LTRIM(RTRIM(CONCAT('PI', ' ', ISNULL(FI_PedimentoComprobante.NumeroPedimento, ''))))
               WHEN CO_Registro.CvTipoDocFacturacion = 3
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NOT NULL THEN
                   LTRIM(RTRIM(CONCAT(
                                         ISNULL(FI_Factura_RefacturasPEPI.Serie, ''),
                                         ' ',
                                         ISNULL(FI_Factura_RefacturasPEPI.Folio, '')
                                     )
                              )
                        )
               WHEN CO_Registro.CvTipoDocFacturacion = 3
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NULL THEN
                   LTRIM(RTRIM(CONCAT('PE', ' ', ISNULL(FI_PedimentoComprobante.FolioComprobante, ''))))
               ELSE
                   ''
           END AS 'Factura',
           CASE
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NOT NULL
                    AND FI_Factura_RefacturasF.FechaTimbrado IS NOT NULL THEN
                   CONCAT(
                             RIGHT('00' + CAST(DATEPART(DD, FI_Factura_RefacturasF.FechaTimbrado) AS VARCHAR(2)), 2),
                             '/',
                             RIGHT('00' + CAST(DATEPART(MM, FI_Factura_RefacturasF.FechaTimbrado) AS VARCHAR(2)), 2),
                             '/',
                             CAST(YEAR(FI_Factura_RefacturasF.FechaTimbrado) AS VARCHAR(4))
                         )
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NULL
                    AND FI_Factura.FechaTimbrado IS NOT NULL THEN
                   CONCAT(
                             RIGHT('00' + CAST(DATEPART(DD, FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                             '/',
                             RIGHT('00' + CAST(DATEPART(MM, FI_Factura.FechaTimbrado) AS VARCHAR(2)), 2),
                             '/',
                             CAST(YEAR(FI_Factura.FechaTimbrado) AS VARCHAR(4))
                         )
               WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NOT NULL
                    AND FI_Factura_RefacturasPEPI.FechaTimbrado IS NOT NULL THEN
                   CONCAT(
                             RIGHT('00' + CAST(DATEPART(DD, FI_Factura_RefacturasPEPI.FechaTimbrado) AS VARCHAR(2)), 2),
                             '/',
                             RIGHT('00' + CAST(DATEPART(MM, FI_Factura_RefacturasPEPI.FechaTimbrado) AS VARCHAR(2)), 2),
                             '/',
                             CAST(YEAR(FI_Factura_RefacturasPEPI.FechaTimbrado) AS VARCHAR(4))
                         )
               WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NULL
                    AND FI_PedimentoComprobante.FechaPago IS NOT NULL THEN
                   CONCAT(
                             RIGHT('00' + CAST(DATEPART(DD, FI_PedimentoComprobante.FechaPago) AS VARCHAR(2)), 2),
                             '/',
                             RIGHT('00' + CAST(DATEPART(MM, FI_PedimentoComprobante.FechaPago) AS VARCHAR(2)), 2),
                             '/',
                             CAST(YEAR(FI_PedimentoComprobante.FechaPago) AS VARCHAR(4))
                         )
               ELSE
                   ''
           END AS 'Fecha Factura',
           CASE
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NOT NULL THEN
                   PV_TipoMoneda_RefacturasF.TipoMonedaCorto
               WHEN CO_Registro.CvTipoDocFacturacion = 1
                    AND FI_Factura_RefacturasF.IdFactura IS NULL THEN
                   PV_TipoMoneda_Factura.TipoMonedaCorto
               WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NOT NULL THEN
                   PV_TipoMoneda_RefacturasPEPI.TipoMonedaCorto
               WHEN CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
                    AND FI_Factura_RefacturasPEPI.IdFactura IS NULL THEN
                   PV_TipoMoneda.TipoMonedaCorto
               ELSE
                   ''
           END AS Moneda,
           ISNULL(CAST(CO_Registro.MontoRegistro AS DECIMAL(10, 2)), 0.00) AS 'Monto Registro',
           ISNULL(CAST(GastosAmatitlan2020.TipoCambio AS DECIMAL(10, 4)), 0.0000) AS 'T. C.',
           ISNULL(CAST(GastosAmatitlan2020.MontoUSDConMarkup AS DECIMAL(10, 2)), 0.00) AS 'Importe G.E. USD'
    FROM CO_LineaPresupuestoMes (NOLOCK)
        JOIN CO_Presupuesto (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
               AND CO_Presupuesto.IdPresupuesto = @IdPresupuesto
        JOIN CO_Registro (NOLOCK)
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
               AND CO_Registro.IdRegistro IS NOT NULL
        JOIN CO_RegistroMarkup (NOLOCK)
            ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
        JOIN CO_EstadoRegistro_V2 (NOLOCK)
            ON ISNULL(CO_RegistroMarkup.IdEstadoPemex, 0) = CO_EstadoRegistro_V2.IdClvEstado
               AND CO_RegistroMarkup.MesEstadoPemex = @MesPresentacion
               AND CO_EstadoRegistro_V2.NombreEstado = 'Aclaración'
               AND CO_EstadoRegistro_V2.IdContrato = @Contrato
        JOIN GastosAmatitlan2020 (NOLOCK)
            ON CO_Registro.IdRegistro = GastosAmatitlan2020.IdRegistro
        LEFT JOIN CO_TipoServicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
        LEFT JOIN CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        LEFT JOIN CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT JOIN FI_Factura (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura
        LEFT JOIN FI_PedimentoComprobante (NOLOCK)
            ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        LEFT JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        LEFT JOIN PV_TipoMoneda PV_TipoMoneda_Factura (NOLOCK)
            ON FI_Factura.IdMoneda = PV_TipoMoneda_Factura.IdMoneda
        LEFT JOIN PV_Subcontratista PV_Subcontratista_Factura (NOLOCK)
            ON FI_Factura.IdSubcontratista = PV_Subcontratista_Factura.IdSubcontratista
        LEFT JOIN PV_Subcontratista PV_Subcontratista_Extranjero (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista_Extranjero.IdSubcontratista
        LEFT JOIN FI_RelacionRefacturas (NOLOCK)
            ON CO_Registro.IdFactura = FI_RelacionRefacturas.idFacturaHijo
        LEFT JOIN FI_RelacionPedimento (NOLOCK)
            ON CO_Registro.IdPedimentoComprobante = FI_RelacionPedimento.IdPedimentoHijo
        LEFT JOIN FI_Factura FI_Factura_RefacturasF (NOLOCK)
            ON FI_RelacionRefacturas.idFacturaPadre = FI_Factura_RefacturasF.IdFactura
        LEFT JOIN FI_Factura FI_Factura_RefacturasPEPI (NOLOCK)
            ON FI_RelacionPedimento.IdFacturaPadre = FI_Factura_RefacturasPEPI.IdFactura
        LEFT JOIN PV_Subcontratista PV_Subcontratista_RefacturasF (NOLOCK)
            ON FI_Factura_RefacturasF.IdSubcontratista = PV_Subcontratista_RefacturasF.IdSubcontratista
        LEFT JOIN PV_Subcontratista PV_Subcontratista_RefacturasPEPI (NOLOCK)
            ON FI_Factura_RefacturasPEPI.IdSubcontratista = PV_Subcontratista_RefacturasPEPI.IdSubcontratista
        LEFT JOIN PV_TipoMoneda PV_TipoMoneda_RefacturasF (NOLOCK)
            ON FI_Factura_RefacturasF.IdMoneda = PV_TipoMoneda_RefacturasF.IdMoneda
        LEFT JOIN PV_TipoMoneda PV_TipoMoneda_RefacturasPEPI (NOLOCK)
            ON FI_Factura_RefacturasPEPI.IdMoneda = PV_TipoMoneda_RefacturasPEPI.IdMoneda
    ORDER BY CO_Registro.IdRegistro DESC;
END;
