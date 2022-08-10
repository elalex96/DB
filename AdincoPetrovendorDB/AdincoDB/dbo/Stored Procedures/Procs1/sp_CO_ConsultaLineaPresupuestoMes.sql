CREATE PROCEDURE [dbo].[sp_CO_ConsultaLineaPresupuestoMes] @presupuesto INT
AS
BEGIN
	--╔════════════════════════════════════════════╗
	--║Uso de SP en Sistema de ADINCO y PETROVENDOR║
	--╚════════════════════════════════════════════╝
    -- =============================================
    -- Author:		Miguel Gomez
    -- Create date: 10 Noviembre 2014
    -- Description:	Presupuestos
    -- =============================================
	-- Modificado Por:			Neri del Angel
	-- Fecha de Modificación:	10 de Agosto del 2022
	-- Descripción:				Se agregan NOLOCK y eliminacion de codigo comentado
	-- =============================================
    SET NOCOUNT ON;
    -- =============================================
    SET LANGUAGE spanish;
    -- =============================================

    SELECT dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES),
                     ' ',
                     YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)
                 ) AS Mes_Presupuestado,
           CO_Area.NombreArea AS Area,
           CASE
               WHEN CO_Presupuesto.ciep = 1 THEN
                   CO_TipoServicio.ID_TIPOSER
               ELSE
                   CO_ActividadPetroleraCNH.IdActividadPetrolera
           END AS ID_TIPOSER,
           CASE
               WHEN CO_Presupuesto.ciep = 1 THEN
                   CO_TipoServicio.NombreTipoServicio
               ELSE
                   CO_ActividadPetroleraCNH.DescripcionActividadPetrolera
           END AS CO_TipoServicio,
           CASE
               WHEN CO_Presupuesto.ciep = 1 THEN
                   CO_ActividadCIEP.ID_CATACTIV
               ELSE
                   CO_SubactividadPetrolera.[id_Sub-actividad]
           END AS ID_CATACTIV,
           CASE
               WHEN CO_Presupuesto.ciep = 1 THEN
                   CO_ActividadCIEP.NombreActividad
               ELSE
                   CO_SubactividadPetrolera.SubactividadPetrolera
           END AS Actividad,
           CASE
               WHEN CO_Presupuesto.ciep = 1 THEN
                   CO_SubactividadCIEP.ID_CATSUBACTIV
               ELSE
                   CO_TareaPetrolera.id_Tarea
           END AS ID_CATSUBACTIV,
           CASE
               WHEN CO_Presupuesto.ciep = 1 THEN
                   CO_RubroInterno.NombreRubro
               ELSE
                   CO_TareaPetrolera.TareaPetrolera
           END AS SubActividad,
           CO_ClasificacionAnexo4.ClasificacionAnexo4 AS Anexo4,
           dbo.CO_LineaPresupuestoMes.ID_PADRE,
           CO_Servicio.NombreServicio AS Servicio,
           CO_Instalacion.NombreInstalacion AS Instalacion,
           CO_Instalacion.IdInstalacionPemex AS ID_PEMEX,
           dbo.CO_LineaPresupuestoMes.Monto AS [Presupuesto (USD)],
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          CAST(ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio AS FLOAT)
                      ELSE
                          0
                  END
              ) AS [Registrado (USD)],
           dbo.CO_LineaPresupuestoMes.Monto
           - SUM(   CASE
                        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                            CAST(ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio AS FLOAT)
                        ELSE
                            0
                    END
                ) AS [Saldo (USD)],
           0 AS Porcentaje,
           0 AS Progreso100,   0 AS ProgresoM100,
           dbo.CO_LineaPresupuestoMes.IdExcel AS ID,
           CO_ActividadPetroleraCNH.id_Actividad,
           CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
           CO_SubactividadPetrolera.[id_Sub-actividad],
           CO_SubactividadPetrolera.SubactividadPetrolera,
           CO_TareaPetrolera.id_Tarea,
           CO_TareaPetrolera.TareaPetrolera
    FROM dbo.CO_LineaPresupuestoMes (NOLOCK)
        LEFT OUTER JOIN CO_ActividadPetroleraCNH (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        LEFT OUTER JOIN CO_SubactividadPetrolera (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        LEFT OUTER JOIN CO_TareaPetrolera (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        LEFT OUTER JOIN CO_ActividadCIEP (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        LEFT OUTER JOIN CO_TipoServicio (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
        LEFT OUTER JOIN CO_SubactividadCIEP (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
        LEFT OUTER JOIN CO_Servicio (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT OUTER JOIN CO_Area (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
        LEFT OUTER JOIN CO_Instalacion (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        LEFT OUTER JOIN CO_Registro (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
        LEFT OUTER JOIN CO_ClasificacionAnexo4 (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
        LEFT OUTER JOIN FI_Factura (NOLOCK)
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
        LEFT OUTER JOIN CO_TipoCambioMensual (NOLOCK)
            ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
               AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
               AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
        LEFT OUTER JOIN CO_RubroInterno (NOLOCK)
            ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
        LEFT JOIN CO_Presupuesto (NOLOCK)
            ON CO_Presupuesto.idpresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
    WHERE (dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto) 
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
             CO_ActividadPetroleraCNH.IdActividadPetrolera,
             CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
             CO_SubactividadPetrolera.[id_Sub-actividad],
             CO_SubactividadPetrolera.SubactividadPetrolera,
             CO_TareaPetrolera.id_Tarea,
             CO_TareaPetrolera.TareaPetrolera,
             CO_Presupuesto.CIEP
    ORDER BY Mes_Presupuestado,
             dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
             Area;
END;