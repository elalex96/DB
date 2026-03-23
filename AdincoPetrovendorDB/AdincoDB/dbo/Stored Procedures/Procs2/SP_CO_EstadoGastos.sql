IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_CO_EstadoGastos'
)
    DROP PROCEDURE dbo.SP_CO_EstadoGastos;
GO

CREATE PROCEDURE [dbo].[SP_CO_EstadoGastos]
    @IdPresupuesto INT,
    @IdUsuario     INT,
    @IdContrato    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @TipoFactura     TINYINT = 1,
            @TipoPedimento   TINYINT = 2,
            @TipoComprobante TINYINT = 3,
            @Dolar           TINYINT = 2,
            @Peso            TINYINT = 1;

    ;WITH Datos AS
    (
        SELECT
            r.IdRegistro,
            r.IdFactura,

            s.NombreServicio        AS Servicio,
            i.NombreInstalacion     AS InstalacionPresupuestada,
            lpm.AC_FEC_INI          AS FechaInicio,
            lpm.AC_FEC_FIN          AS FechaFin,

            er.NombreEstado         AS Estado,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura     THEN 'CF'
                WHEN r.CvTipoDocFacturacion = @TipoPedimento   THEN 'PI'
                WHEN r.CvTipoDocFacturacion = @TipoComprobante THEN 'PE'
            END AS TipoDocumento,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura
                    THEN LTRIM(RTRIM(ISNULL(f.Serie, '') + ' ' + ISNULL(f.Folio, '')))
                WHEN r.CvTipoDocFacturacion = @TipoPedimento
                    THEN pc.NumeroPedimento
                WHEN r.CvTipoDocFacturacion = @TipoComprobante
                    THEN pc.FolioComprobante
            END AS Numero,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura
                    THEN f.Fecha
                WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante)
                    THEN pc.FechaPago
            END AS FechaDocumento,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura
                    THEN sf.RazonSocial
                WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante)
                    THEN spc.RazonSocial
                ELSE NULL
            END AS Subcontratista,

            ir.NombreInstalacion AS InstalacionRegistro,
            r.InicioEjecucion,
            r.FinEjecucion,

            uc.Nombre AS CreadoPor,

            CAST(r.MontoRegistro AS DECIMAL(18,6)) AS MontoRegistro,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura THEN mf.TipoMonedaCorto
                WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN mpc.TipoMonedaCorto
                ELSE NULL
            END AS Moneda,

            r.MesPresentacion AS MesPresentacion,

            CASE
                WHEN p.ciep = 1 THEN ts.NombreTipoServicio
                ELSE acnh.DescripcionActividadPetrolera
            END AS TipoDeServicio,

            CASE
                WHEN p.ciep = 1 THEN aciep.NombreActividad
                ELSE sap.SubactividadPetrolera
            END AS Actividad,

            CASE
                WHEN p.ciep = 1 THEN ri.NombreRubro
                ELSE tp.TareaPetrolera
            END AS SubActividad,

            er2.NombreEstado AS EstadoValidacion,
            a.NombreArea     AS Area,

            r.Comentarios,
            ca.ClasificacionAnexo4 AS Anexo4,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura
                    THEN f.IdFactura
                WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante)
                    THEN pc.IdPedimentoComprobante
                ELSE NULL
            END AS Identificador,

            lpm.IdLineaPresupuestoMes AS LineaPresupuesto,
            p.Nombre                  AS Presupuesto,

            ir.NombreInstalacion      AS NombreInstalacion,

            um.Nombre                 AS ModificadoPor,

            r.Poliza,

            CASE
                WHEN r.CvTipoDocFacturacion = @TipoFactura THEN mf.IdMoneda
                WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN mpc.IdMoneda
                ELSE NULL
            END AS IdMonedaDoc,

            CONVERT(DATE,
                CASE
                    WHEN r.CvTipoDocFacturacion = @TipoFactura THEN f.Fecha
                    WHEN r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante) THEN pc.FechaPago
                    ELSE NULL
                END
            ) AS FechaDocDate
        FROM dbo.CO_LineaPresupuestoMes lpm WITH (NOLOCK)

        INNER JOIN dbo.CO_Presupuesto p WITH (NOLOCK)
            ON lpm.IdPresupuesto = p.IdPresupuesto
            AND lpm.IdPresupuesto = @IdPresupuesto

        INNER JOIN dbo.CO_Registro r WITH (NOLOCK)
            ON lpm.IdLineaPresupuestoMes = r.IdPrograma

        INNER JOIN dbo.CO_EstadoRegistro_V2 er2 WITH (NOLOCK)
            ON r.IdEstado = er2.IdClvEstado
           AND er2.IdContrato = @IdContrato

        LEFT JOIN dbo.CO_Servicio s WITH (NOLOCK)
            ON lpm.IdServicio = s.IdServicio

        LEFT JOIN dbo.CO_Instalacion i WITH (NOLOCK)
            ON lpm.IdInstalacion = i.IdInstalacion

        LEFT JOIN dbo.FI_Factura f WITH (NOLOCK)
            ON r.IdFactura = f.IdFactura
           AND r.CvTipoDocFacturacion = @TipoFactura

        LEFT JOIN dbo.FI_pedimentocomprobante pc WITH (NOLOCK)
            ON r.IdPedimentoComprobante = pc.IdPedimentoComprobante
           AND r.CvTipoDocFacturacion IN (@TipoPedimento, @TipoComprobante)

        LEFT JOIN dbo.PV_Subcontratista sf WITH (NOLOCK)
            ON f.IdSubcontratista = sf.IdSubcontratista

        LEFT JOIN dbo.PV_Subcontratista spc WITH (NOLOCK)
            ON pc.IdSubcontratistaExportador = spc.IdSubcontratista

        LEFT JOIN dbo.CO_Instalacion ir WITH (NOLOCK)
            ON r.IdInstalacion = ir.IdInstalacion

        INNER JOIN dbo.AP_Usuario uc WITH (NOLOCK)
            ON r.IdUsuarioCreadoPor = uc.UsuarioID

        LEFT JOIN dbo.AP_Usuario um WITH (NOLOCK)
            ON r.IdUsuarioModPor = um.UsuarioID

        LEFT JOIN dbo.CO_TipoServicio ts WITH (NOLOCK)
            ON lpm.IdTipoServicio = ts.IdTipoServicio

        LEFT JOIN dbo.CO_ActividadCIEP aciep WITH (NOLOCK)
            ON lpm.IdActividad = aciep.IdActividad

        LEFT JOIN dbo.CO_EstadoRegistro er WITH (NOLOCK)
            ON r.IdEstado = er.IdEstadoRegistro

        LEFT JOIN dbo.CO_Area a WITH (NOLOCK)
            ON lpm.IdArea = a.IdArea

        LEFT JOIN dbo.PV_TipoMoneda mf WITH (NOLOCK)
            ON f.IdMoneda = mf.IdMoneda

        LEFT JOIN dbo.PV_TipoMoneda mpc WITH (NOLOCK)
            ON pc.IdMoneda = mpc.IdMoneda

        LEFT JOIN dbo.CO_ClasificacionAnexo4 ca WITH (NOLOCK)
            ON lpm.IdAnexo4 = ca.IdAnexo4

        LEFT JOIN dbo.CO_ActividadPetroleraCNH acnh WITH (NOLOCK)
            ON lpm.IdActividadPetrolera = acnh.IdActividadPetrolera

        LEFT JOIN dbo.CO_SubactividadPetrolera sap WITH (NOLOCK)
            ON lpm.IdSubactividadPetrolera = sap.IdSubactividadPetrolera

        LEFT JOIN dbo.CO_RubroInterno ri WITH (NOLOCK)
            ON lpm.IdRubroInterno = ri.IdRubroInterno

        LEFT JOIN dbo.CO_TareaPetrolera tp WITH (NOLOCK)
            ON lpm.IdTareaPetrolera = tp.IdTareaPetrolera

        WHERE lpm.IdPresupuesto = @IdPresupuesto
          AND r.IdRegistro IS NOT NULL
    )
    SELECT
        d.IdRegistro,
        d.IdFactura,
        d.Servicio,
        d.InstalacionPresupuestada,
        d.FechaInicio,
        d.FechaFin,
        d.Estado,
        d.TipoDocumento,
        d.Numero,
        d.FechaDocumento,

        MontoUSD =
            CASE
                WHEN ISNULL(d.MontoRegistro, 0) = 0 THEN 0
                WHEN d.IdMonedaDoc = @Dolar THEN d.MontoRegistro
                WHEN d.IdMonedaDoc <> @Peso THEN 0
                ELSE
                    d.MontoRegistro / NULLIF(
                        COALESCE(tcmCur.TipoCambio, tcmPrev.TipoCambio),
                        0
                    )
            END,

        d.Subcontratista,
        d.InstalacionRegistro,
        d.InicioEjecucion,
        d.FinEjecucion,
        d.CreadoPor,
        d.MontoRegistro,
        d.Moneda,
        d.MesPresentacion,
        d.TipoDeServicio,
        d.Actividad,
        d.SubActividad,
        d.EstadoValidacion,
        d.Area,
        d.Comentarios,
        d.Anexo4,
        d.Identificador,
        d.LineaPresupuesto,
        d.Presupuesto,
        d.NombreInstalacion,
        d.ModificadoPor,
        d.Poliza,

        TipoCambioUsado =
            CASE
                WHEN d.IdMonedaDoc = @Dolar THEN CAST(1 AS DECIMAL(18,6))
                WHEN d.IdMonedaDoc = @Peso  THEN CAST(COALESCE(tcmCur.TipoCambio, tcmPrev.TipoCambio) AS DECIMAL(18,6))
                ELSE NULL
            END,

        UsaTCMesAnterior =
            CASE
                WHEN d.IdMonedaDoc = @Dolar THEN CAST(0 AS BIT)
                WHEN d.IdMonedaDoc = @Peso
                     AND tcmCur.TipoCambio IS NULL
                     AND tcmPrev.TipoCambio IS NOT NULL
                    THEN CAST(1 AS BIT)
                ELSE CAST(0 AS BIT)
            END
    FROM Datos d
    LEFT JOIN dbo.CO_TipoCambioMensual tcmCur WITH (NOLOCK)
        ON d.IdMonedaDoc = @Peso
       AND tcmCur.IdMoneda = @Peso
       AND tcmCur.Anio     = YEAR(d.FechaDocDate)
       AND tcmCur.IdMes    = MONTH(d.FechaDocDate)

    LEFT JOIN dbo.CO_TipoCambioMensual tcmPrev WITH (NOLOCK)
        ON d.IdMonedaDoc = @Peso
       AND tcmPrev.IdMoneda = @Peso
       AND tcmPrev.Anio     = YEAR(DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(d.FechaDocDate), MONTH(d.FechaDocDate), 1)))
       AND tcmPrev.IdMes    = MONTH(DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(d.FechaDocDate), MONTH(d.FechaDocDate), 1)))

    ORDER BY d.MesPresentacion DESC, d.IdRegistro DESC;
END
GO