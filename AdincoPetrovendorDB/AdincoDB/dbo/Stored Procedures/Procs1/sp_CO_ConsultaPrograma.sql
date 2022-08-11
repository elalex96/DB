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
-- Descripción:				Se agregan NOLOCK y eliminacion de codigo comentado, ajustes de lefts (se eliminan)
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPrograma] @IdPrograma int = 0
AS
BEGIN
    -- =============================================
    SET NOCOUNT ON;
    -- =============================================
    SET LANGUAGE spanish;
    -- =============================================
    CREATE TABLE #TablaPrograma
    (
        IdLineaPresupuestoMes INT,
        Mes_Presupuestado DATE,
        ID_PADRE VARCHAR(100),
        [Presupuesto (USD)] DECIMAL(18, 4),
        Monto DECIMAL(18, 4),
        ID INT,
        ---
        IdActividadPetrolera INT,
        IdActividad INT,
        IdSubactividadPetrolera INT,
        IdTareaPetrolera INT,
        IdTipoServicio INT,
        IdSubactividad INT,
        IdServicio INT,
        IdArea INT,
        IdInstalacion INT,
        IdAnexo4 INT,
        IdRubroInterno INT,
        AC_PRESUP_MES DATE,
        IdPresupuesto INT,
        --
        id_Actividad VARCHAR(50),
        DescripcionActividadPetrolera VARCHAR(50),
        --
        [id_Sub-actividad] VARCHAR(50),
        SubactividadPetrolera VARCHAR(50),
        --
        id_Tarea VARCHAR(50),
        TareaPetrolera VARCHAR(150),
        --
        ID_CATACTIV VARCHAR(50),
        NombreActividad VARCHAR(50),
        --
        ID_TIPOSER INT,
        NombreTipoServicio VARCHAR(50),
        --
        ID_CATSUBACTIV VARCHAR(50),
        --
        NombreServicio VARCHAR(1000),
        --
        NombreArea VARCHAR(50),
        --
        NombreInstalacion VARCHAR(100),
        IdInstalacionPemex VARCHAR(100),
        --
        IdFactura INT,
        MesPresentacion DATE,
        MontoRegistro DECIMAL(18, 4),
        --
        ClasificacionAnexo4 VARCHAR(100),
        --
        IdMoneda INT,
        --
        NombreRubro VARCHAR(50),
        --
        CIEP BIT
    )

    CREATE TABLE #TablaProgramaMontos
    (
        IdLineaPresupuestoMes INT,
        Monto DECIMAL(18, 4)
    )

    INSERT INTO #TablaPrograma
    (
        IdLineaPresupuestoMes,
        Mes_Presupuestado,
        ID_PADRE,
        [Presupuesto (USD)],
        Monto,
        ID,
        ---
        IdActividadPetrolera,
        IdActividad,
        IdSubactividadPetrolera,
        IdTareaPetrolera,
        IdTipoServicio,
        IdSubactividad,
        IdServicio,
        IdArea,
        IdInstalacion,
        IdAnexo4,
        IdRubroInterno,
        AC_PRESUP_MES,
        IdPresupuesto,
        --
        id_Actividad,
        DescripcionActividadPetrolera,
        --
        [id_Sub-actividad],
        SubactividadPetrolera,
        --
        id_Tarea,
        TareaPetrolera,
        --
        ID_CATACTIV,
        NombreActividad,
        --
        ID_TIPOSER,
        NombreTipoServicio,
        --
        ID_CATSUBACTIV,
        --
        NombreServicio,
        --
        NombreArea,
        --
        NombreInstalacion,
        IdInstalacionPemex,
        --
        IdFactura,
        MesPresentacion,
        MontoRegistro,
        --
        ClasificacionAnexo4,
        --
        IdMoneda,
        --
        NombreRubro,
        --
        CIEP
    )
    SELECT dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES),
                     ' ',
                     YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)
                 ) AS Mes_Presupuestado,
           dbo.CO_LineaPresupuestoMes.ID_PADRE,
           dbo.CO_LineaPresupuestoMes.Monto AS [Presupuesto (USD)],
           dbo.CO_LineaPresupuestoMes.Monto,
           dbo.CO_LineaPresupuestoMes.IdExcel AS ID,
           dbo.CO_LineaPresupuestoMes.IdActividadPetrolera,
           dbo.CO_LineaPresupuestoMes.IdActividad,
           dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera,
           dbo.CO_LineaPresupuestoMes.IdTareaPetrolera,
           dbo.CO_LineaPresupuestoMes.IdTipoServicio,
           dbo.CO_LineaPresupuestoMes.IdSubactividad,
           dbo.CO_LineaPresupuestoMes.IdServicio,
           dbo.CO_LineaPresupuestoMes.IdArea,
           dbo.CO_LineaPresupuestoMes.IdInstalacion,
           dbo.CO_LineaPresupuestoMes.IdAnexo4,
           dbo.CO_LineaPresupuestoMes.IdRubroInterno,
           dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
           dbo.CO_LineaPresupuestoMes.IdPresupuesto,
           --
           dbo.CO_ActividadPetroleraCNH.id_Actividad,
           dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
           --
           dbo.CO_SubactividadPetrolera.[id_Sub-actividad],
           dbo.CO_SubactividadPetrolera.SubactividadPetrolera,
           --
           dbo.CO_TareaPetrolera.id_Tarea,
           dbo.CO_TareaPetrolera.TareaPetrolera,
           --
           NULL,
           NULL,
           --
           NULL,
           NULL,
           --
           NULL,
           --
           NULL,
           --
           NULL,
           --
           NULL,
           NULL,
           --
           NULL,
           NULL,
           NULL,
           --
           NULL,
           --
           NULL,
           --
           NULL,
           --
           NULL
    FROM CO_LineaPresupuestoMes (NOLOCK)
        INNER JOIN CO_ActividadPetroleraCNH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = @IdPrograma
               AND CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        INNER JOIN CO_SubactividadPetrolera (NOLOCK)
            ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        INNER JOIN CO_TareaPetrolera (NOLOCK)
            ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
    GROUP BY dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
             dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
             dbo.CO_LineaPresupuestoMes.ID_PADRE,
             dbo.CO_LineaPresupuestoMes.Monto,
             dbo.CO_LineaPresupuestoMes.IdExcel,
             dbo.CO_LineaPresupuestoMes.IdActividadPetrolera,
             dbo.CO_LineaPresupuestoMes.IdActividad,
             dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera,
             dbo.CO_LineaPresupuestoMes.IdTareaPetrolera,
             dbo.CO_LineaPresupuestoMes.IdTipoServicio,
             dbo.CO_LineaPresupuestoMes.IdSubactividad,
             dbo.CO_LineaPresupuestoMes.IdServicio,
             dbo.CO_LineaPresupuestoMes.IdArea,
             dbo.CO_LineaPresupuestoMes.IdInstalacion,
             dbo.CO_LineaPresupuestoMes.IdAnexo4,
             dbo.CO_LineaPresupuestoMes.IdRubroInterno,
             dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
             dbo.CO_LineaPresupuestoMes.IdPresupuesto,
             dbo.CO_ActividadPetroleraCNH.id_Actividad,
             dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
             dbo.CO_SubactividadPetrolera.[id_Sub-actividad],
             dbo.CO_SubactividadPetrolera.SubactividadPetrolera,
             dbo.CO_TareaPetrolera.id_Tarea,
             dbo.CO_TareaPetrolera.TareaPetrolera

    UPDATE #TablaPrograma
    SET #TablaPrograma.ID_CATACTIV = CO_ActividadCIEP.ID_CATACTIV,
        #TablaPrograma.NombreActividad = CO_ActividadCIEP.NombreActividad
    FROM #TablaPrograma
        JOIN CO_ActividadCIEP (NOLOCK)
            ON #TablaPrograma.IdActividad = CO_ActividadCIEP.IdActividad

    UPDATE #TablaPrograma
    SET #TablaPrograma.ID_TIPOSER = CO_TipoServicio.ID_TIPOSER,
        #TablaPrograma.NombreTipoServicio = CO_TipoServicio.NombreTipoServicio
    FROM #TablaPrograma
        JOIN CO_TipoServicio (NOLOCK)
            ON #TablaPrograma.IdTipoServicio = CO_TipoServicio.ID_TIPOSER

    UPDATE #TablaPrograma
    SET #TablaPrograma.ID_CATSUBACTIV = CO_SubactividadCIEP.ID_CATSUBACTIV
    FROM #TablaPrograma
        JOIN CO_SubactividadCIEP (NOLOCK)
            ON #TablaPrograma.IdSubactividad = CO_SubactividadCIEP.IdSubactividad

    UPDATE #TablaPrograma
    SET #TablaPrograma.NombreServicio = CO_Servicio.NombreServicio
    FROM #TablaPrograma
        JOIN CO_Servicio (NOLOCK)
            ON #TablaPrograma.IdServicio = CO_Servicio.IdServicio

    UPDATE #TablaPrograma
    SET #TablaPrograma.NombreArea = CO_Area.NombreArea
    FROM #TablaPrograma
        JOIN CO_Area (NOLOCK)
            ON #TablaPrograma.IdArea = CO_Area.IdArea

    UPDATE #TablaPrograma
    SET #TablaPrograma.NombreInstalacion = CO_Instalacion.NombreInstalacion,
        #TablaPrograma.IdInstalacionPemex = CO_Instalacion.IdInstalacionPemex
    FROM #TablaPrograma
        JOIN CO_Instalacion (NOLOCK)
            ON #TablaPrograma.IdInstalacion = CO_Instalacion.IdInstalacion

    UPDATE #TablaPrograma
    SET #TablaPrograma.IdFactura = CO_Registro.IdFactura,
        #TablaPrograma.MesPresentacion = CO_Registro.MesPresentacion
    FROM #TablaPrograma
        JOIN CO_Registro (NOLOCK)
            ON #TablaPrograma.IdLineaPresupuestoMes = CO_Registro.IdPrograma

    INSERT INTO #TablaProgramaMontos
    (
        IdLineaPresupuestoMes,
        Monto
    )
    SELECT #TablaPrograma.IdLineaPresupuestoMes,
           SUM(CO_Registro.MontoRegistro)
    FROM #TablaPrograma
        JOIN CO_Registro (NOLOCK)
            ON #TablaPrograma.IdLineaPresupuestoMes = CO_Registro.IdPrograma
    GROUP BY CO_Registro.MontoRegistro,
             #TablaPrograma.IdLineaPresupuestoMes

    UPDATE #TablaPrograma
    SET #TablaPrograma.ClasificacionAnexo4 = CO_ClasificacionAnexo4.ClasificacionAnexo4
    FROM #TablaPrograma
        JOIN CO_ClasificacionAnexo4 (NOLOCK)
            ON #TablaPrograma.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4

    UPDATE #TablaPrograma
    SET #TablaPrograma.IdMoneda = FI_Factura.IdMoneda
    FROM #TablaPrograma
        JOIN FI_Factura (NOLOCK)
            ON #TablaPrograma.IdFactura = FI_Factura.IdFactura

    UPDATE #TablaPrograma
    SET #TablaPrograma.NombreRubro = CO_RubroInterno.NombreRubro
    FROM #TablaPrograma
        JOIN CO_RubroInterno (NOLOCK)
            ON #TablaPrograma.IdRubroInterno = CO_RubroInterno.IdRubroInterno

    UPDATE #TablaPrograma
    SET #TablaPrograma.CIEP = CO_Presupuesto.CIEP
    FROM #TablaPrograma
        JOIN CO_Presupuesto (NOLOCK)
            ON #TablaPrograma.IdPresupuesto = CO_Presupuesto.IdPresupuesto

    SELECT #TablaPrograma.IdLineaPresupuestoMes,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(#TablaPrograma.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(month, #TablaPrograma.AC_PRESUP_MES),
                     ' ',
                     YEAR(#TablaPrograma.AC_PRESUP_MES)
                 ) AS Mes_Presupuestado,
           #TablaPrograma.NombreArea AS Area,
           #TablaPrograma.ID_TIPOSER,
           #TablaPrograma.NombreTipoServicio AS CO_TipoServicio,
           #TablaPrograma.ID_CATACTIV,
           #TablaPrograma.NombreActividad AS Actividad,
           #TablaPrograma.ID_CATSUBACTIV,
           #TablaPrograma.NombreRubro AS SubActividad,
           #TablaPrograma.ClasificacionAnexo4 AS Anexo4,
           #TablaPrograma.ID_PADRE,
           #TablaPrograma.NombreServicio AS Servicio,
           #TablaPrograma.NombreInstalacion AS Instalacion,
           #TablaPrograma.IdInstalacionPemex AS ID_PEMEX,
           #TablaPrograma.[Presupuesto (USD)] AS [Presupuesto (USD)],
           SUM(   CASE
                      WHEN ISNULL(#TablaProgramaMontos.Monto, 0) <> 0 THEN
                          ISNULL(#TablaProgramaMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio
                      ELSE
                          0
                  END
              ) AS [Registrado (USD)],
           #TablaPrograma.Monto
           - SUM(   CASE
                        WHEN ISNULL(#TablaProgramaMontos.Monto, 0) <> 0 THEN
                            ISNULL(#TablaProgramaMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE
                            0
                    END
                ) AS [Saldo (USD)],
           SUM(   CASE
                      WHEN ISNULL(#TablaProgramaMontos.Monto, 0) <> 0 THEN
                          ISNULL(#TablaProgramaMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio
                      ELSE
                          0
                  END
              ) / #TablaPrograma.Monto * 100 AS Porcentaje,
           SUM(   CASE
                      WHEN ISNULL(#TablaProgramaMontos.Monto, 0) <> 0 THEN
                          ISNULL(#TablaProgramaMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio
                      ELSE
                          0
                  END
              ) / #TablaPrograma.Monto * 100 AS Progreso100,
           CASE
               WHEN ((SUM(   CASE
                                 WHEN ISNULL(#TablaProgramaMontos.Monto, 0) <> 0 THEN
                                     ISNULL(#TablaProgramaMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio
                                 ELSE
                                     0
                             END
                         ) / #TablaPrograma.Monto
                     ) * 100
                    ) > 100 THEN
           ((SUM(   CASE
                        WHEN ISNULL(#TablaProgramaMontos.Monto, 0) <> 0 THEN
                            ISNULL(#TablaProgramaMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio
                        ELSE
                            0
                    END
                ) / #TablaPrograma.Monto
            ) * 100
           ) - 100
               ELSE
                   0
           END AS ProgresoM100,
           #TablaPrograma.ID AS ID,
           #TablaPrograma.id_Actividad,
           #TablaPrograma.DescripcionActividadPetrolera,
           #TablaPrograma.[id_Sub-actividad],
           #TablaPrograma.SubactividadPetrolera,
           #TablaPrograma.id_Tarea,
           #TablaPrograma.TareaPetrolera
    FROM #TablaPrograma
        LEFT JOIN #TablaProgramaMontos (NOLOCK)
            ON #TablaPrograma.IdLineaPresupuestoMes = #TablaProgramaMontos.IdLineaPresupuestoMes
        LEFT JOIN CO_TipoCambioMensual (NOLOCK)
            ON #TablaPrograma.IdMoneda = CO_TipoCambioMensual.IdMoneda
               AND CO_TipoCambioMensual.IdMes = MONTH(#TablaPrograma.MesPresentacion)
               AND CO_TipoCambioMensual.Anio = YEAR(#TablaPrograma.MesPresentacion)
    GROUP BY #TablaPrograma.IdLineaPresupuestoMes,
             #TablaPrograma.AC_PRESUP_MES,
             #TablaPrograma.NombreArea,
             #TablaPrograma.ID_TIPOSER,
             #TablaPrograma.NombreTipoServicio,
             #TablaPrograma.ID_CATACTIV,
             #TablaPrograma.NombreActividad,
             #TablaPrograma.ID_CATSUBACTIV,
             #TablaPrograma.ID_PADRE,
             #TablaPrograma.ClasificacionAnexo4,
             #TablaPrograma.NombreServicio,
             #TablaPrograma.NombreInstalacion,
             #TablaPrograma.IdInstalacionPemex,
             #TablaPrograma.[Presupuesto (USD)],
             #TablaPrograma.Monto,
             #TablaPrograma.ID,
             #TablaPrograma.NombreRubro,
             #TablaPrograma.id_Actividad,
             #TablaPrograma.IdActividadPetrolera,
             #TablaPrograma.DescripcionActividadPetrolera,
             #TablaPrograma.[id_Sub-actividad],
             #TablaPrograma.SubactividadPetrolera,
             #TablaPrograma.id_Tarea,
             #TablaPrograma.TareaPetrolera,
             #TablaPrograma.CIEP
    ORDER BY Mes_Presupuestado,
             #TablaPrograma.AC_PRESUP_MES,
             Area;
END
