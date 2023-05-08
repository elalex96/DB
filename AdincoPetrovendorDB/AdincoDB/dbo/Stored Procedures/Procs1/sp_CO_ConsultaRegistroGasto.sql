-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CO_ConsultaRegistroGasto 
	-- Add the parameters for the stored procedure here
	@IdRegistro int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        TOP (100) PERCENT dbo.CO_Servicio.NombreServicio AS Servicio, dbo.CO_Instalacion.NombreInstalacion AS InstalacionPresupuestada, dbo.CO_LineaPresupuestoMes.AC_FEC_INI AS FechaInicio, 
                         dbo.CO_LineaPresupuestoMes.AC_FEC_FIN AS FechaFin, dbo.FI_Factura.Fecha AS FechaFactura, SUM(CASE WHEN ISNULL(co_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(co_Registro.MontoRegistro, 0) 
                         / CO_TipoCambioMensual.TipoCambio ELSE 0 END) AS MontoUSD, dbo.FI_Factura.Serie + '-' + dbo.FI_Factura.Folio AS NumeroFactura, dbo.PV_Subcontratista.RazonSocial AS Subcontratista, 
                         InstalacionRegistro.NombreInstalacion AS InstalacionRegistro, dbo.CO_Registro.InicioEjecucion, dbo.CO_Registro.FinEjecucion, dbo.AP_Usuario.Nombre AS CreadoPor, dbo.CO_Registro.MontoRegistro, 
                         dbo.PV_TipoMoneda.TipoMonedaCorto AS Moneda, dbo.CO_Registro.MesPresentacion, dbo.CO_TipoServicio.NombreTipoServicio AS TipoDeServicio, dbo.CO_ActividadCIEP.NombreActividad AS Actividad, 
                         dbo.CO_SubactividadCIEP.NombreSubactividad AS SubActividad, dbo.CO_Registro.IdRegistro AS NumeroOperacion, dbo.CO_EstadoRegistro.NombreEstado AS EstadoValidacion, 
                         dbo.CO_Area.NombreArea AS Area, dbo.CO_Registro.Comentarios, dbo.CO_ClasificacionAnexo4.ClasificacionAnexo4 AS Anexo4, dbo.FI_Factura.IdFactura AS IdentificadorFactura, 
                         dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes AS LineaPresupuesto, dbo.CO_Presupuesto.Nombre AS Presupuesto
FROM            dbo.CO_LineaPresupuestoMes LEFT OUTER JOIN
                         dbo.CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = dbo.CO_Servicio.IdServicio LEFT OUTER JOIN
                         dbo.CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = dbo.CO_Instalacion.IdInstalacion LEFT OUTER JOIN
                         dbo.CO_Registro ON dbo.CO_Registro.IdPrograma = dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes LEFT OUTER JOIN
                         dbo.FI_Factura ON dbo.FI_Factura.IdFactura = dbo.CO_Registro.IdFactura LEFT OUTER JOIN
                         dbo.PV_Subcontratista ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista LEFT OUTER JOIN
                         dbo.CO_Instalacion AS InstalacionRegistro ON dbo.CO_Registro.IdInstalacion = InstalacionRegistro.IdInstalacion LEFT OUTER JOIN
                         dbo.AP_Usuario ON dbo.CO_Registro.IdUsuarioCreadoPor = dbo.AP_Usuario.UsuarioID LEFT OUTER JOIN
                         dbo.CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = dbo.CO_TipoServicio.IdTipoServicio LEFT OUTER JOIN
                         dbo.CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = dbo.CO_ActividadCIEP.IdActividad LEFT OUTER JOIN
                         dbo.CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = dbo.CO_SubactividadCIEP.IdSubactividad LEFT OUTER JOIN
                         dbo.CO_EstadoRegistro ON dbo.CO_Registro.IdEstado = dbo.CO_EstadoRegistro.IdEstadoRegistro LEFT OUTER JOIN
                         dbo.CO_Area ON dbo.CO_Area.IdArea = dbo.CO_LineaPresupuestoMes.IdArea LEFT OUTER JOIN
                         dbo.PV_TipoMoneda ON dbo.PV_TipoMoneda.IdMoneda = dbo.FI_Factura.IdMoneda LEFT OUTER JOIN
                         dbo.CO_TipoCambioMensual ON dbo.CO_TipoCambioMensual.IdMoneda = dbo.FI_Factura.IdMoneda AND dbo.CO_TipoCambioMensual.IdMes = MONTH(dbo.CO_Registro.MesPresentacion) AND 
                         dbo.CO_TipoCambioMensual.Anio = YEAR(dbo.CO_Registro.MesPresentacion) LEFT OUTER JOIN
                         dbo.CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = dbo.CO_ClasificacionAnexo4.IdAnexo4 LEFT OUTER JOIN
                         dbo.CO_Presupuesto ON dbo.CO_LineaPresupuestoMes.IdPresupuesto = dbo.CO_Presupuesto.IdPresupuesto
WHERE         (dbo.CO_Registro.IdRegistro=@IdRegistro)
GROUP BY dbo.CO_Servicio.NombreServicio, dbo.CO_Instalacion.NombreInstalacion, dbo.CO_LineaPresupuestoMes.AC_FEC_INI, dbo.CO_LineaPresupuestoMes.AC_FEC_FIN, dbo.FI_Factura.Fecha, 
                         dbo.FI_Factura.Serie + '-' + dbo.FI_Factura.Folio, dbo.PV_Subcontratista.RazonSocial, InstalacionRegistro.NombreInstalacion, dbo.CO_Registro.InicioEjecucion, dbo.CO_Registro.FinEjecucion, 
                         dbo.FI_Factura.Fecha, dbo.AP_Usuario.Nombre, dbo.CO_Registro.MontoRegistro, dbo.PV_TipoMoneda.TipoMonedaCorto, dbo.CO_Registro.MesPresentacion, dbo.CO_TipoServicio.NombreTipoServicio, 
                         dbo.CO_ActividadCIEP.NombreActividad, dbo.CO_SubactividadCIEP.NombreSubactividad, dbo.CO_Registro.IdRegistro, dbo.CO_EstadoRegistro.NombreEstado, dbo.CO_Area.NombreArea, 
                         dbo.CO_Registro.Comentarios, dbo.CO_ClasificacionAnexo4.ClasificacionAnexo4, dbo.FI_Factura.IdFactura, InstalacionRegistro.CUIP, InstalacionRegistro.WelIID, 
                         dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes, InstalacionRegistro.IdInstalacion, dbo.CO_Presupuesto.Nombre, dbo.CO_Registro.Fila
ORDER BY dbo.CO_Registro.Fila
END
