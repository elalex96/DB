IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_SC_ConsultaLineaPresupuestoMes'
)
    DROP PROCEDURE p_SC_ConsultaLineaPresupuestoMes
GO
CREATE PROCEDURE [dbo].[p_SC_ConsultaLineaPresupuestoMes]
    @presupuesto varchar(250),
    @pIdSubcontrato int
AS
BEGIN
    -- =============================================-- Author:		Miguel Gomez-- Create date: 10 Noviembre 2014-- Description:	Presupuestos-- =============================================
    SET NOCOUNT ON;
    -- =============================================
    SET LANGUAGE spanish;
    -- =============================================

    SELECT IdPresupuesto = CAST(splitdata AS INT)
    INTO #tmpResult
    FROM [dbo].[fnSplitString](@presupuesto, ',')


    SELECT CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(MONTH, CO_LineaPresupuestoMes.AC_PRESUP_MES),
                     ' ',
                     YEAR(CO_LineaPresupuestoMes.AC_PRESUP_MES)
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
           0 AS Porcentaje,
           dbo.CO_LineaPresupuestoMes.IdExcel AS ID,
           CO_ActividadPetroleraCNH.id_Actividad,
           CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
           CO_SubactividadPetrolera.[id_Sub-actividad],
           CO_SubactividadPetrolera.SubactividadPetrolera,
           CO_TareaPetrolera.id_Tarea,
           CO_TareaPetrolera.TareaPetrolera,
           PresupuestoNombre = p.Nombre
    FROM dbo.CO_LineaPresupuestoMes (NOLOCK)
        INNER JOIN CO_Presupuesto p (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = p.IdPresupuesto 
        INNER JOIN #tmpResult tmp
            ON CO_LineaPresupuestoMes.IdPresupuesto = tmp.IdPresupuesto 
        LEFT OUTER JOIN CO_ActividadPetroleraCNH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera  
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
            ON CO_Registro.IdFactura = FI_Factura.IdFactura  
        LEFT OUTER JOIN CO_TipoCambioMensual (NOLOCK)
            ON FI_Factura.IdMoneda = CO_TipoCambioMensual.IdMoneda 
               AND MONTH(CO_Registro.MesPresentacion) = CO_TipoCambioMensual.IdMes 
               AND YEAR(CO_Registro.MesPresentacion) = CO_TipoCambioMensual.Anio 
        LEFT OUTER JOIN CO_RubroInterno (NOLOCK)
            ON CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
        LEFT JOIN CO_Presupuesto (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.idpresupuesto 
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
             CO_Presupuesto.CIEP,
             p.Nombre
    ORDER BY Mes_Presupuestado,
             dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
             Area;
END;