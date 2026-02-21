IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_RegistroGastoCIEP'
)
    DROP PROCEDURE dbo.USP_SEL_CO_RegistroGastoCIEP;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_RegistroGastoCIEP]
    @IdRegistro INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @TipoFactura      TINYINT = 1,
            @TipoPedimento    TINYINT = 2,
            @TipoComprobante  TINYINT = 3,
            @Dolar            TINYINT = 2,
            @Peso             TINYINT = 1;

    SELECT
        -- Información del servicio y presupuesto
        s.NombreServicio AS Servicio,
        i.NombreInstalacion AS InstalacionPresupuestada,
        lpm.AC_FEC_INI AS FechaInicio,
        lpm.AC_FEC_FIN AS FechaFin,
        p.Nombre AS Presupuesto,
        lpm.IdLineaPresupuestoMes AS LineaPresupuesto,

        -- Información del documento (Factura/Pedimento/Comprobante)
        CASE
            WHEN r.CvTipoDocFacturacion = @TipoFactura THEN f.Fecha
            WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN pc.FechaPago
            ELSE NULL
        END AS FechaFactura,

        CASE
            WHEN r.CvTipoDocFacturacion = @TipoFactura THEN (ISNULL(f.Serie, '') + '-' + ISNULL(f.Folio, ''))
            WHEN r.CvTipoDocFacturacion = @TipoPedimento THEN pc.NumeroPedimento
            WHEN r.CvTipoDocFacturacion = @TipoComprobante THEN pc.FolioComprobante
            ELSE ''
        END AS NumeroFactura,

        CASE
            WHEN r.CvTipoDocFacturacion = @TipoFactura THEN f.IdFactura
            WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN pc.IdPedimentoComprobante
            ELSE NULL
        END AS IdentificadorFactura,

        -- Montos
        r.MontoRegistro,
        CASE
            WHEN r.CvTipoDocFacturacion = @TipoFactura THEN mf.TipoMonedaCorto
            WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN mpc.TipoMonedaCorto
            ELSE ''
        END AS Moneda,

        CASE
            WHEN ISNULL(r.MontoRegistro, 0) <> 0
                 AND NULLIF(tc.TipoCambioUsado, 0) IS NOT NULL THEN
                ISNULL(r.MontoRegistro, 0) / NULLIF(tc.TipoCambioUsado, 0)
            ELSE
                0
        END AS MontoUSD,

        tc.TipoCambioUsado,
        tc.UsaTCMesAnterior,

        CASE
            WHEN (
                    (r.CvTipoDocFacturacion = @TipoFactura AND mf.IdMoneda = @Peso)
                 OR (r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) AND mpc.IdMoneda = @Peso)
                 )
                 AND (tc.TipoCambioUsado IS NULL OR tc.TipoCambioUsado = 0)
                THEN CAST(1 AS BIT)
            ELSE
                CAST(0 AS BIT)
        END AS SinTipoCambio,

        -- Partes involucradas
        CASE
            WHEN r.CvTipoDocFacturacion = @TipoFactura THEN scf.RazonSocial
            WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN scpc.RazonSocial
            ELSE ''
        END AS Subcontratista,

        u.Nombre AS CreadoPor,

        -- Ejecución
        ir.NombreInstalacion AS InstalacionRegistro,
        r.InicioEjecucion,
        r.FinEjecucion,
        r.MesPresentacion,

        -- Clasificación
        ts.NombreTipoServicio AS TipoDeServicio,
        act.NombreActividad AS Actividad,
        sub.NombreSubactividad AS SubActividad,
        a.NombreArea AS Area,
        an4.ClasificacionAnexo4 AS Anexo4,

        -- Estado y trazabilidad
        r.IdRegistro AS NumeroOperacion,
        er.NombreEstado AS EstadoValidacion,
        r.Comentarios
    FROM dbo.CO_Registro r WITH (NOLOCK)
    LEFT JOIN dbo.CO_LineaPresupuestoMes lpm WITH (NOLOCK)
        ON r.IdPrograma = lpm.IdLineaPresupuestoMes
        AND r.IdRegistro = @IdRegistro
    LEFT JOIN dbo.CO_Servicio s WITH (NOLOCK)
        ON lpm.IdServicio = s.IdServicio
    LEFT JOIN dbo.CO_Instalacion i WITH (NOLOCK)
        ON lpm.IdInstalacion = i.IdInstalacion
    LEFT JOIN dbo.CO_TipoServicio ts WITH (NOLOCK)
        ON lpm.IdTipoServicio = ts.IdTipoServicio
    LEFT JOIN dbo.CO_ActividadCIEP act WITH (NOLOCK)
        ON lpm.IdActividad = act.IdActividad
    LEFT JOIN dbo.CO_SubactividadCIEP sub WITH (NOLOCK)
        ON lpm.IdSubactividad = sub.IdSubactividad
    LEFT JOIN dbo.CO_Area a WITH (NOLOCK)
        ON lpm.IdArea = a.IdArea
    LEFT JOIN dbo.CO_ClasificacionAnexo4 an4 WITH (NOLOCK)
        ON lpm.IdAnexo4 = an4.IdAnexo4
    LEFT JOIN dbo.CO_Presupuesto p WITH (NOLOCK)
        ON lpm.IdPresupuesto = p.IdPresupuesto

    -- Factura
    LEFT JOIN dbo.FI_Factura f WITH (NOLOCK)
        ON r.IdFactura = f.IdFactura
    LEFT JOIN dbo.PV_Subcontratista scf WITH (NOLOCK)
        ON f.IdSubcontratista = scf.IdSubcontratista
    LEFT JOIN dbo.PV_TipoMoneda mf WITH (NOLOCK)
        ON f.IdMoneda = mf.IdMoneda

    -- Pedimento/Comprobante
    LEFT JOIN dbo.FI_PedimentoComprobante pc WITH (NOLOCK)
        ON r.IdPedimentoComprobante = pc.IdPedimentoComprobante
    LEFT JOIN dbo.PV_Subcontratista scpc WITH (NOLOCK)
        ON pc.IdSubcontratistaExportador = scpc.IdSubcontratista
    LEFT JOIN dbo.PV_TipoMoneda mpc WITH (NOLOCK)
        ON pc.IdMoneda = mpc.IdMoneda

    -- Datos del registro
    LEFT JOIN dbo.CO_Instalacion ir WITH (NOLOCK)
        ON r.IdInstalacion = ir.IdInstalacion
    LEFT JOIN dbo.AP_Usuario u WITH (NOLOCK)
        ON r.IdUsuarioCreadoPor = u.UsuarioID
    LEFT JOIN dbo.CO_EstadoRegistro er WITH (NOLOCK)
        ON r.IdEstado = er.IdEstadoRegistro

    /* ============================================================
       FechaDoc: para TC mensual (Factura vs Pedimento/Comprobante)
       - Factura (1): FI_Factura.Fecha
       - Pedimento/Comprobante (2,3): FI_PedimentoComprobante.FechaPago
       ============================================================ */
    OUTER APPLY
    (
        SELECT
            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura THEN CAST(f.Fecha AS DATE)
                WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN CAST(pc.FechaPago AS DATE)
                ELSE NULL
            END AS FechaDoc
    ) FD
    OUTER APPLY
    (
        SELECT
            YEAR(FD.FechaDoc) AS AnioDoc,
            MONTH(FD.FechaDoc) AS MesDoc,
            YEAR(DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(FD.FechaDoc), MONTH(FD.FechaDoc), 1))) AS AnioPrev,
            MONTH(DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(FD.FechaDoc), MONTH(FD.FechaDoc), 1))) AS MesPrev
        WHERE FD.FechaDoc IS NOT NULL
    ) CTC

    /* ============================================================
       Tipo de cambio (CIEP mensual) siguiendo la misma idea del SP base:
       - Si la moneda del doc es USD => TC = 1
       - Si la moneda del doc es MXN => buscar CO_TipoCambioMensual (IdMoneda = 1) por mes doc,
         y si no existe usar mes anterior.
       ============================================================ */
    OUTER APPLY
    (
        SELECT TOP (1)
            CAST(
                CASE
                    WHEN (
                            (r.CvTipoDocFacturacion = @TipoFactura AND mf.IdMoneda = @Dolar)
                         OR (r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) AND mpc.IdMoneda = @Dolar)
                         )
                        THEN 1
                    WHEN (
                            (r.CvTipoDocFacturacion = @TipoFactura AND mf.IdMoneda = @Peso)
                         OR (r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) AND mpc.IdMoneda = @Peso)
                         )
                        THEN tcm.TipoCambio
                    ELSE NULL
                END
            AS DECIMAL(18,6)) AS TipoCambioUsado,

            CAST(
                CASE
                    WHEN (
                            (r.CvTipoDocFacturacion = @TipoFactura AND mf.IdMoneda = @Dolar)
                         OR (r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) AND mpc.IdMoneda = @Dolar)
                         )
                        THEN 0
                    WHEN tcm.Anio = CTC.AnioDoc AND tcm.IdMes = CTC.MesDoc THEN 0
                    ELSE 1
                END
            AS BIT) AS UsaTCMesAnterior
        FROM dbo.CO_TipoCambioMensual tcm WITH (NOLOCK)
        WHERE tcm.IdMoneda = @Peso
          AND CTC.AnioDoc IS NOT NULL
          AND (
                (tcm.Anio = CTC.AnioDoc AND tcm.IdMes = CTC.MesDoc)
             OR (tcm.Anio = CTC.AnioPrev AND tcm.IdMes = CTC.MesPrev)
          )
        ORDER BY
            CASE
                WHEN tcm.Anio = CTC.AnioDoc AND tcm.IdMes = CTC.MesDoc THEN 0
                ELSE 1
            END
    ) tc
    WHERE r.IdRegistro = @IdRegistro
    ORDER BY r.Fila;
END
GO
