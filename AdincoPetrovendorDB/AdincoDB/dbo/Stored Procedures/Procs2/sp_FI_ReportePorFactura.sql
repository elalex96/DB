CREATE PROCEDURE dbo.sp_FI_ReportePorFactura 
	@IdFactura INT
AS
BEGIN
-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-05-11
-- Description:
-- =============================================
SET NOCOUNT ON;

        SELECT S.NombreServicio AS Servicio,
            I.NombreInstalacion AS InstalacionPresupuestada,
            LPM.AC_FEC_INI AS FechaInicio,
            LPM.AC_FEC_FIN AS FechaFin,
            F.Fecha AS FechaFactura,
            SUM(CASE
                    WHEN ISNULL(R.MontoRegistro, 0) <> 0
                    THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio
                    ELSE 0
                END) AS MontoUSD,
            F.Serie+'-'+ F.Folio AS NumeroFactura,
            PVS.RazonSocial AS Subcontratista,
            IR.NombreInstalacion AS InstalacionRegistro,
            R.InicioEjecucion,
            R.FinEjecucion,
            U.Nombre AS CreadoPor,
            R.MontoRegistro,
            TM.TipoMonedaCorto AS Moneda,
            R.MesPresentacion AS MesPresentacion,
            TS.NombreTipoServicio AS TipoDeServicio,
            ACIEP.NombreActividad AS Actividad,
            SACIEP.NombreSubactividad AS SubActividad,
            R.IdRegistro AS NumeroOperacion,
            ER.NombreEstado AS EstadoValidacion,
            AR.NombreArea AS Area,
            R.Comentarios,
            CA4.ClasificacionAnexo4 AS Anexo4,
            F.IdFactura AS IdentificadorFactura,
            LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
            P.Nombre AS Presupuesto,
			CFDIC.Descripcion,
			CFDIC.Cantidad,
			CFDIC.Unidad,
			CFDIC.ValorUnitario,
			CFDIC.Importe

        FROM dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
            LEFT JOIN dbo.CO_Servicio S (NOLOCK)
					ON LPM.IdServicio = S.IdServicio
            LEFT JOIN dbo.CO_Instalacion I (NOLOCK)
					ON LPM.IdInstalacion = I.IdInstalacion
            LEFT JOIN dbo.CO_Registro R (NOLOCK)
					ON R.IdPrograma = LPM.IdLineaPresupuestoMes
            LEFT JOIN dbo.FI_Factura F (NOLOCK)
					ON F.IdFactura = R.IdFactura
            LEFT JOIN dbo.PV_Subcontratista PVS (NOLOCK)
					ON F.IdSubcontratista = PVS.IdSubcontratista
            LEFT JOIN dbo.CO_Instalacion AS IR (NOLOCK)
					ON R.IdInstalacion = IR.IdInstalacion
            LEFT JOIN dbo.AP_Usuario U (NOLOCK)
					ON R.IdUsuarioCreadoPor = U.UsuarioID
            LEFT JOIN dbo.CO_TipoServicio TS (NOLOCK)
					ON LPM.IdTipoServicio = TS.IdTipoServicio
            LEFT JOIN dbo.CO_ActividadCIEP ACIEP (NOLOCK)
					ON LPM.IdActividad = ACIEP.IdActividad
            LEFT JOIN dbo.CO_SubactividadCIEP SACIEP (NOLOCK)
					ON LPM.IdSubactividad = SACIEP.IdSubactividad
            LEFT JOIN dbo.CO_EstadoRegistro ER (NOLOCK)
					ON R.IdEstado = ER.IdEstadoRegistro
            LEFT JOIN dbo.CO_Area AR (NOLOCK)
					ON AR.IdArea = LPM.IdArea
            LEFT JOIN dbo.PV_TipoMoneda TM (NOLOCK)
					ON TM.IdMoneda = F.IdMoneda
            LEFT JOIN dbo.CO_TipoCambioMensual TCM (NOLOCK)
					ON TCM.IdMoneda = F.IdMoneda
                        AND TCM.IdMes = MONTH(R.MesPresentacion)
                        AND TCM.Anio = YEAR(R.MesPresentacion)
            LEFT JOIN dbo.CO_ClasificacionAnexo4 CA4 (NOLOCK)
					ON LPM.IdAnexo4 = CA4.IdAnexo4
            LEFT JOIN dbo.CO_Presupuesto P (NOLOCK)
					ON LPM.IdPresupuesto = P.IdPresupuesto
			LEFT JOIN dbo.FI_CFDIConcepto CFDIC (NOLOCK)
					ON F.IdFactura = CFDIC.IdFactura

        WHERE F.IdFactura = @IdFactura
    GROUP BY S.NombreServicio,
                I.NombreInstalacion,
                LPM.AC_FEC_INI,
                LPM.AC_FEC_FIN,
                F.Fecha,
                F.Serie+'-'+ F.Folio,
                PVS.RazonSocial,
                IR.NombreInstalacion,
                R.InicioEjecucion,
                R.FinEjecucion,
                F.Fecha,
                U.Nombre,
                R.MontoRegistro,
                TM.TipoMonedaCorto,
                R.MesPresentacion,
                TS.NombreTipoServicio,
                ACIEP.NombreActividad,
                SACIEP.NombreSubactividad,
                R.IdRegistro,
                ER.NombreEstado,
                AR.NombreArea,
                R.Comentarios,
                CA4.ClasificacionAnexo4,
                F.IdFactura,
                IR.CUIP,
                IR.WelIID,
                LPM.IdLineaPresupuestoMes,
                IR.IdInstalacion,
                P.Nombre,
                R.Fila,
				CFDIC.Descripcion,
				CFDIC.Cantidad,
				CFDIC.Unidad,
				CFDIC.ValorUnitario,
				CFDIC.Importe
        ORDER BY R.Fila;

         --EXEC sp_FI_ReportePorFactura 13458
END;