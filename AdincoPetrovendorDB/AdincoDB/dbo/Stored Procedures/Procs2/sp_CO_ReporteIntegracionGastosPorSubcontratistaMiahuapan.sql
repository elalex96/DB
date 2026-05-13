CREATE PROCEDURE [dbo].[sp_CO_ReporteIntegracionGastosPorSubcontratistaMiahuapan] 
-- Add the parameters for the stored procedure here
@Anio          INT = 0,
@Mes           INT = 0,
@IdPresupuesto INT = 0
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel
         -- Create date: Domingo 1 Diciembre 2016 19:49 p.m.
         -- Description:	Reporte de Integración de Gastos a Nivel Actividad
         -- =============================================
	    
SELECT        RTRIM(P.RazonSocial) AS Prestadora_de_Servicios, RTRIM(TS.NombreTipoServicio) AS Servicio, RTRIM(A.NombreActividad) AS Actividad, LTRIM(MONTH(R.MesPresentacion)) 
                         + '-' + LTRIM(YEAR(R.MesPresentacion) - 2000) AS Periodo, SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ISNULL(R.MontoRegistro, 0) / TCM.TipoCambio ELSE 0 END) AS Importe, 
                         CASE P.Relacionada WHEN 1 THEN 'Relacionadas' ELSE 'Prestadora de Servicios' END AS Segmento, datefromparts(@anio, @mes, 1) AS Fecha, F.Serie + ' ' + F.Folio AS NumeroFactura, 
                         F.Fecha AS FechaFactura, TS.NombreTipoServicio
FROM            CO_Registro AS R LEFT OUTER JOIN
                         CO_LineaPresupuestoMes AS C ON R.IdPrograma = C.IdLineaPresupuestoMes LEFT OUTER JOIN
                         CO_Servicio AS S ON C.IdServicio = S.IdServicio LEFT OUTER JOIN
                         CO_TipoServicio AS TS ON C.IdTipoServicio = TS.IdTipoServicio LEFT OUTER JOIN
                         FI_Factura AS F ON F.IdFactura = R.IdFactura LEFT OUTER JOIN
                         PV_Subcontratista AS P ON F.IdSubcontratista = P.IdSubcontratista LEFT OUTER JOIN
                         CO_ActividadCIEP AS A ON C.IdActividad = A.IdActividad LEFT OUTER JOIN
                         CO_TipoCambioMensual AS TCM ON TCM.IdMoneda = F.IdMoneda AND TCM.IdMes = MONTH(R.MesPresentacion) AND TCM.Anio = YEAR(R.MesPresentacion)
WHERE        (YEAR(R.MesPresentacion) = @anio) AND (MONTH(R.MesPresentacion) = @mes) AND (C.IdPresupuesto = @IdPresupuesto)
GROUP BY RTRIM(P.RazonSocial), RTRIM(TS.NombreTipoServicio), RTRIM(A.NombreActividad), LTRIM(MONTH(R.MesPresentacion)) + '-' + LTRIM(YEAR(R.MesPresentacion) - 2000), P.Relacionada, F.Serie + ' ' + F.Folio, 
                         F.Fecha, TS.NombreTipoServicio
ORDER BY Servicio, Actividad, Prestadora_de_Servicios
     END;