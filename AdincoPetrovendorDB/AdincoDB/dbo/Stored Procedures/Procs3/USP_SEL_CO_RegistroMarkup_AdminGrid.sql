use adinco
go
IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_SEL_CO_RegistroMarkup_AdminGrid'
		)
	DROP PROCEDURE USP_SEL_CO_RegistroMarkup_AdminGrid;
GO
CREATE PROCEDURE dbo.USP_SEL_CO_RegistroMarkup_AdminGrid
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        M.GastoId,
        M.IdEstadoPemex,
        E.NombreEstado AS EstadoActual,
        S.NombreServicio AS Servicio,

        CASE WHEN R.CvTipoDocFacturacion = 1 THEN F.UUID ELSE NULL END AS UUID,
        CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN LTRIM(RTRIM(F.Serie)) + ' ' + LTRIM(RTRIM(F.Folio))
            WHEN R.CvTipoDocFacturacion = 2 THEN PC.NumeroPedimento
            WHEN R.CvTipoDocFacturacion = 3 THEN PC.FolioComprobante
        END AS Numero,
        CASE
            WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha
            WHEN R.CvTipoDocFacturacion IN (2,3) THEN PC.FechaPago
        END AS FechaDocumento,

        IR.NombreInstalacion AS InstalacionRegistro,
        YEAR(R.MesPresentacion) AS Anio,
        FORMAT(R.MesPresentacion, 'MM MMMM', 'es-ES') AS Mes,

        CASE WHEN P.CIEP = 1 THEN TS.NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END AS TipoDeServicio,
        CASE WHEN P.CIEP = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END AS Actividad,
        CASE WHEN P.CIEP = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END AS SubActividad,

        catmo.Nombre AS CatManoObra,
        R.PCN,
        R.MontoRegistro,
        rubro.Descripcion AS Rubro,
        LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
        P.Nombre AS Presupuesto,

        CASE WHEN R.CvTipoDocFacturacion = 1 THEN TMF.TipoMonedaCorto ELSE TMPC.TipoMonedaCorto END AS Moneda,
        CASE WHEN R.CvTipoDocFacturacion = 1 THEN SF.RazonSocial ELSE SPC.RazonSocial END AS Subcontratista,

        CASE
            WHEN R.CvTipoDocFacturacion = 1 AND R.MontoRegistro <> 0 AND TCDF.TipoCambio > 0 
                THEN R.MontoRegistro / TCDF.TipoCambio
            WHEN R.CvTipoDocFacturacion IN (2,3) AND R.MontoRegistro <> 0 AND TCDPC.TipoCambio > 0 
                THEN R.MontoRegistro / TCDPC.TipoCambio
            ELSE 0
        END AS MontoUSD

    FROM dbo.CO_RegistroMarkup M WITH(NOLOCK)
    
    INNER JOIN dbo.CO_Registro R WITH(NOLOCK)
        ON R.IdRegistro = M.GastoId
    
    INNER JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK)
        ON LPM.IdLineaPresupuestoMes = R.IdPrograma
    
    INNER JOIN dbo.CO_Presupuesto P WITH(NOLOCK)
        ON P.IdPresupuesto = LPM.IdPresupuesto
    
    INNER JOIN dbo.CO_EstadoRegistro_V2 E WITH(NOLOCK)
        ON E.IdClvEstado = M.IdEstadoPemex
       AND E.IdContrato = @IdContrato
       AND E.Activo = 1

    LEFT JOIN dbo.CO_Servicio S WITH(NOLOCK)
        ON S.IdServicio = LPM.IdServicio
       AND S.IdContrato = @IdContrato

    LEFT JOIN dbo.CO_Instalacion IR WITH(NOLOCK)
        ON IR.IdInstalacion = R.IdInstalacion

    LEFT JOIN dbo.CO_GastosRubro rubro WITH(NOLOCK)
        ON rubro.IdGastoRubro = R.IdGastoRubro

    LEFT JOIN dbo.CO_CAT_ManoDeObra catmo WITH(NOLOCK)
        ON catmo.Id = R.IdCatManoObra

    -- Factura (solo si es tipo 1)
    LEFT JOIN dbo.FI_Factura F WITH(NOLOCK)
        ON F.IdFactura = R.IdFactura
       AND F.IdContrato = @IdContrato
       AND R.CvTipoDocFacturacion = 1

    -- Pedimento/Comprobante (solo si es tipo 2 o 3)
    LEFT JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK)
        ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
       AND R.CvTipoDocFacturacion IN (2, 3)

    LEFT JOIN dbo.PV_Subcontratista SF WITH(NOLOCK)
        ON SF.IdSubcontratista = F.IdSubcontratista

    LEFT JOIN dbo.PV_Subcontratista SPC WITH(NOLOCK)
        ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador

    LEFT JOIN dbo.PV_TipoMoneda TMF WITH(NOLOCK)
        ON TMF.IdMoneda = F.IdMoneda

    LEFT JOIN dbo.PV_TipoMoneda TMPC WITH(NOLOCK)
        ON TMPC.IdMoneda = PC.IdMoneda

    -- Tipos de cambio (solo si existen las facturas/pedimentos)
    LEFT JOIN dbo.CO_TipoCambioDiario TCDF WITH(NOLOCK)
        ON TCDF.IdMoneda = F.IdMoneda
       AND TCDF.Fecha = CAST(F.Fecha AS DATE)
       AND F.IdFactura IS NOT NULL

    LEFT JOIN dbo.CO_TipoCambioDiario TCDPC WITH(NOLOCK)
        ON TCDPC.IdMoneda = PC.IdMoneda
       AND TCDPC.Fecha = CAST(PC.FechaPago AS DATE)
       AND PC.IdPedimentoComprobante IS NOT NULL

    LEFT JOIN dbo.CO_TipoServicio TS WITH(NOLOCK)
        ON TS.IdTipoServicio = LPM.IdTipoServicio
       AND P.CIEP = 1

    LEFT JOIN dbo.CO_ActividadCIEP ACIEP WITH(NOLOCK)
        ON ACIEP.IdActividad = LPM.IdActividad
       AND P.CIEP = 1

    LEFT JOIN dbo.CO_RubroInterno RI WITH(NOLOCK)
        ON RI.IdRubroInterno = LPM.IdRubroInterno
       AND P.CIEP = 1

    -- CNH (solo si P.CIEP <> 1)
    LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH WITH(NOLOCK)
        ON ACNH.IdActividadPetrolera = LPM.IdActividadPetrolera
       AND P.CIEP <> 1

    LEFT JOIN dbo.CO_SubactividadPetrolera SAP WITH(NOLOCK)
        ON SAP.IdSubactividadPetrolera = LPM.IdSubactividadPetrolera
       AND P.CIEP <> 1

    LEFT JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK)
        ON TP.IdTareaPetrolera = LPM.IdTareaPetrolera
       AND P.CIEP <> 1

    WHERE M.IdEstadoPemex IS NOT NULL
	AND E.NombreEstado <> 'Revisión'
    ORDER BY M.GastoId DESC;

END