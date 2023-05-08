CREATE PROCEDURE [dbo].[sp_ObtenerFilaLineaPresupuesto](@IdLineaPresupuesto INT, @IdPresupuesto INT)
AS 
BEGIN
DECLARE	@maxLinea INT
		

DECLARE @tablaAuxiliar TABLE (fila int, idPresupuesto INT, agrupado INT)
DECLARE @contador INT = 0, @contador2 INT = 0

INSERT INTO @tablaAuxiliar
(
    fila,
    idPresupuesto
)
	SELECT ROW_NUMBER() OVER(ORDER BY dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), CO_LineaPresupuestoMes.IdLineaPresupuestoMes
         FROM dbo.CO_LineaPresupuestoMes
              LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
              LEFT OUTER JOIN CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
              LEFT OUTER JOIN CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
              LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Area ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
              LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              LEFT OUTER JOIN CO_Registro ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
              LEFT OUTER JOIN CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
              LEFT OUTER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
              LEFT OUTER JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                      AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                      AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
              LEFT OUTER JOIN CO_RubroInterno ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
         GROUP BY dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                  dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
                  CO_Area.NombreArea,
                  CO_TipoServicio.ID_TIPOSER,
                  CO_TipoServicio.NombreTipoServicio,
                  CO_ActividadCIEP.ID_CATACTIV,
                  CO_ActividadCIEP.NombreActividad,
                  CO_SubactividadCIEP.ID_CATSUBACTIV,
                  CO_SubactividadCIEP.NombreSubactividad,
                  dbo.CO_LineaPresupuestoMes.ID_PADRE,
                  CO_ClasificacionAnexo4.ClasificacionAnexo4,
                  CO_Servicio.NombreServicio,
                  CO_Instalacion.NombreInstalacion,
                  CO_Instalacion.IdInstalacionPemex,
                  dbo.CO_LineaPresupuestoMes.Monto,
                  dbo.CO_LineaPresupuestoMes.IdExcel,
                  CO_RubroInterno.NombreRubro,
                  CO_ActividadPetroleraCNH.id_Actividad,
                  CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                  CO_SubactividadPetrolera.[id_Sub-actividad],
                  CO_SubactividadPetrolera.SubactividadPetrolera,
                  CO_TareaPetrolera.id_Tarea,
                  CO_TareaPetrolera.TareaPetrolera
				 ORDER BY dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES

				SELECT TOP 1
					@maxLinea = fila
				FROM @tablaAuxiliar
				ORDER BY fila DESC

				WHILE (@contador <= @maxLinea)
				BEGIN
					IF (@contador % 4 != 0)
					BEGIN
						UPDATE @tablaAuxiliar
						SET agrupado = @contador2
						WHERE fila = @contador
					END
					ELSE
					BEGIN
						UPDATE @tablaAuxiliar
						SET agrupado = @contador2
						WHERE fila = @contador
						SET @contador2 += 1
					END
					SET @contador += 1
				END --fin del while

				SELECT agrupado - 1,
					   fila - 1
				FROM @tablaAuxiliar
				WHERE idPresupuesto = @IdLineaPresupuesto

END
