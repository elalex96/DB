--╔════════════════════════════════════════════╗
--║Uso de SP en Sistema de ADINCO y PETROVENDOR║
--╚════════════════════════════════════════════╝
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	10 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK 
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPrograma]
    @IdPrograma int = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(month, CO_LineaPresupuestoMes.AC_PRESUP_MES),
                     ' ',
                     YEAR(CO_LineaPresupuestoMes.AC_PRESUP_MES)
                 ) AS Mes_Presupuestado,
           CO_Area.NombreArea AS Area,
           CO_TipoServicio.ID_TIPOSER,
           CO_TipoServicio.NombreTipoServicio AS CO_TipoServicio,
           CO_ActividadCIEP.ID_CATACTIV,
           CO_ActividadCIEP.NombreActividad AS Actividad,
           CO_SubactividadCIEP.ID_CATSUBACTIV,
           CO_RubroInterno.NombreRubro AS SubActividad,
           CO_ClasificacionAnexo4.ClasificacionAnexo4 AS Anexo4,
           CO_LineaPresupuestoMes.ID_PADRE,
           CO_Servicio.NombreServicio AS Servicio,
           CO_Instalacion.NombreInstalacion AS Instalacion,
           CO_Instalacion.IdInstalacionPemex AS ID_PEMEX,
           CO_LineaPresupuestoMes.Monto AS [Presupuesto (USD)],
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                      ELSE
                          0
                  END
              ) AS [Registrado (USD)],
           CO_LineaPresupuestoMes.Monto
           - SUM(   CASE
                        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                            ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE
                            0
                    END
                ) AS [Saldo (USD)],
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                      ELSE
                          0
                  END
              ) / CO_LineaPresupuestoMes.Monto * 100 AS Porcentaje,
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                      ELSE
                          0
                  END
              ) / CO_LineaPresupuestoMes.Monto * 100 AS Progreso100,
           CASE
               WHEN ((SUM(   CASE
                                 WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                                     ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                                 ELSE
                                     0
                             END
                         ) / monto
                     ) * 100
                    ) > 100 THEN
           ((SUM(   CASE
                        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                            ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE
                            0
                    END
                ) / monto
            ) * 100
           ) - 100
               ELSE
                   0
           END AS ProgresoM100,
           CO_LineaPresupuestoMes.IdExcel AS ID,
           CO_ActividadPetroleraCNH.id_Actividad,
           CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
           CO_SubactividadPetrolera.[id_Sub-actividad],
           CO_SubactividadPetrolera.SubactividadPetrolera,
           CO_TareaPetrolera.id_Tarea,
           CO_TareaPetrolera.TareaPetrolera
    FROM CO_LineaPresupuestoMes (NOLOCK)
        INNER JOIN CO_ActividadPetroleraCNH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        INNER JOIN CO_SubactividadPetrolera (NOLOCK)
            ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        INNER JOIN CO_TareaPetrolera (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        LEFT OUTER JOIN CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        LEFT OUTER JOIN CO_TipoServicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
        LEFT OUTER JOIN CO_SubactividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
        LEFT OUTER JOIN CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT OUTER JOIN CO_Area (NOLOCK)
            ON CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
        LEFT OUTER JOIN CO_Instalacion (NOLOCK)
            ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        LEFT OUTER JOIN CO_Registro (NOLOCK)
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        LEFT OUTER JOIN CO_ClasificacionAnexo4 (NOLOCK)
            ON CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
        LEFT OUTER JOIN FI_Factura (NOLOCK)
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
        LEFT OUTER JOIN CO_TipoCambioMensual (NOLOCK)
            ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
               AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
               AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
        LEFT OUTER JOIN CO_RubroInterno (NOLOCK)
            ON CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
    WHERE CO_LineaPresupuestoMes.IdLineaPresupuestoMes = @IdPrograma
    GROUP BY CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
             CO_LineaPresupuestoMes.AC_PRESUP_MES,
             CO_Area.NombreArea,
             CO_TipoServicio.ID_TIPOSER,
             CO_TipoServicio.NombreTipoServicio,
             CO_ActividadCIEP.ID_CATACTIV,
             CO_ActividadCIEP.NombreActividad,
             CO_SubactividadCIEP.ID_CATSUBACTIV,
             CO_SubactividadCIEP.NombreSubactividad,
             CO_LineaPresupuestoMes.ID_PADRE,
             CO_ClasificacionAnexo4.ClasificacionAnexo4,
             CO_Servicio.NombreServicio,
             CO_Instalacion.NombreInstalacion,
             CO_Instalacion.IdInstalacionPemex,
             CO_LineaPresupuestoMes.Monto,
             CO_LineaPresupuestoMes.IdExcel,
             CO_RubroInterno.NombreRubro,
             CO_ActividadPetroleraCNH.id_Actividad,
             CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
             CO_SubactividadPetrolera.[id_Sub-actividad],
             CO_SubactividadPetrolera.SubactividadPetrolera,
             CO_TareaPetrolera.id_Tarea,
             CO_TareaPetrolera.TareaPetrolera
    ORDER BY Mes_Presupuestado,
             CO_LineaPresupuestoMes.AC_PRESUP_MES,
             Area
END
