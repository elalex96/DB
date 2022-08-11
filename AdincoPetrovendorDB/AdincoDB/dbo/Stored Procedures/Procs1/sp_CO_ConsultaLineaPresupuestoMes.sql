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
    -- Descripción:				Se agregan NOLOCK y eliminacion de codigo comentado, ajustes de lefts (se eliminan)
    -- =============================================
    SET NOCOUNT ON;
    -- =============================================
    SET LANGUAGE spanish;
    -- =============================================

    CREATE TABLE #TablaLineaPresupuestoMes
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
        id_Actividad VARCHAR(10),
        DescripcionActividadPetrolera VARCHAR(10),
        --
        [id_Sub-actividad] VARCHAR(10),
        SubactividadPetrolera VARCHAR(50),
        --
        id_Tarea VARCHAR(10),
        TareaPetrolera VARCHAR(150),
        --
        ID_CATACTIV VARCHAR(10),
        NombreActividad VARCHAR(50),
        --
        ID_TIPOSER INT,
        NombreTipoServicio VARCHAR(50),
        --
        ID_CATSUBACTIV VARCHAR(10),
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

    CREATE TABLE #TablaLineaPresupuestoMesMontos
    (
        IdLineaPresupuestoMes INT,
        Monto DECIMAL(18, 4)
    )

    INSERT INTO #TablaLineaPresupuestoMes
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
           NULL,
           NULL,
           --
           NULL,
           NULL,
           --
           NULL,
           NULL,
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
    FROM CO_LineaPresupuestoMes
    WHERE dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto
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
             dbo.CO_LineaPresupuestoMes.IdPresupuesto

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.DescripcionActividadPetrolera = CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
        #TablaLineaPresupuestoMes.id_Actividad = CO_ActividadPetroleraCNH.id_Actividad
    FROM #TablaLineaPresupuestoMes
        JOIN CO_ActividadPetroleraCNH
            ON #TablaLineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.[id_Sub-actividad] = CO_SubactividadPetrolera.[id_Sub-actividad],
        #TablaLineaPresupuestoMes.SubactividadPetrolera = CO_SubactividadPetrolera.SubactividadPetrolera
    FROM #TablaLineaPresupuestoMes
        JOIN CO_SubactividadPetrolera
            ON #TablaLineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.id_Tarea = CO_TareaPetrolera.id_Tarea,
        #TablaLineaPresupuestoMes.TareaPetrolera = CO_TareaPetrolera.TareaPetrolera
    FROM #TablaLineaPresupuestoMes
        JOIN CO_TareaPetrolera
            ON #TablaLineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.ID_CATACTIV = CO_ActividadCIEP.ID_CATACTIV,
        #TablaLineaPresupuestoMes.NombreActividad = CO_ActividadCIEP.NombreActividad
    FROM #TablaLineaPresupuestoMes
        JOIN CO_ActividadCIEP
            ON #TablaLineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.ID_TIPOSER = CO_TipoServicio.ID_TIPOSER,
        #TablaLineaPresupuestoMes.NombreTipoServicio = CO_TipoServicio.NombreTipoServicio
    FROM #TablaLineaPresupuestoMes
        JOIN CO_TipoServicio
            ON #TablaLineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.ID_CATSUBACTIV = CO_SubactividadCIEP.ID_CATSUBACTIV
    FROM #TablaLineaPresupuestoMes
        JOIN CO_SubactividadCIEP
            ON #TablaLineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.NombreServicio = CO_Servicio.NombreServicio
    FROM #TablaLineaPresupuestoMes
        JOIN CO_Servicio
            ON #TablaLineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.NombreArea = CO_Area.NombreArea
    FROM #TablaLineaPresupuestoMes
        JOIN CO_Area
            ON #TablaLineaPresupuestoMes.IdArea = CO_Area.IdArea

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.NombreInstalacion = CO_Instalacion.NombreInstalacion,
        #TablaLineaPresupuestoMes.IdInstalacionPemex = CO_Instalacion.IdInstalacionPemex
    FROM #TablaLineaPresupuestoMes
        JOIN CO_Instalacion
            ON #TablaLineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.IdFactura = CO_Registro.IdFactura,
        #TablaLineaPresupuestoMes.MesPresentacion = CO_Registro.MesPresentacion
    FROM #TablaLineaPresupuestoMes
        JOIN CO_Registro
            ON #TablaLineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma

    INSERT INTO #TablaLineaPresupuestoMesMontos
    (
        IdLineaPresupuestoMes,
        Monto
    )
    SELECT #TablaLineaPresupuestoMes.IdLineaPresupuestoMes,
           SUM(CO_Registro.MontoRegistro)
    FROM #TablaLineaPresupuestoMes
        JOIN CO_Registro
            ON #TablaLineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
    GROUP BY CO_Registro.MontoRegistro,
             #TablaLineaPresupuestoMes.IdLineaPresupuestoMes

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.ClasificacionAnexo4 = CO_ClasificacionAnexo4.ClasificacionAnexo4
    FROM #TablaLineaPresupuestoMes
        JOIN CO_ClasificacionAnexo4
            ON #TablaLineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.IdMoneda = FI_Factura.IdMoneda
    FROM #TablaLineaPresupuestoMes
        JOIN FI_Factura
            ON #TablaLineaPresupuestoMes.IdFactura = FI_Factura.IdFactura

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.NombreRubro = CO_RubroInterno.NombreRubro
    FROM #TablaLineaPresupuestoMes
        JOIN CO_RubroInterno
            ON #TablaLineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno

    UPDATE #TablaLineaPresupuestoMes
    SET #TablaLineaPresupuestoMes.CIEP = CO_Presupuesto.CIEP
    FROM #TablaLineaPresupuestoMes
        JOIN CO_Presupuesto
            ON #TablaLineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto

    SELECT #TablaLineaPresupuestoMes.IdLineaPresupuestoMes,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(#TablaLineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(month, #TablaLineaPresupuestoMes.AC_PRESUP_MES),
                     ' ',
                     YEAR(#TablaLineaPresupuestoMes.AC_PRESUP_MES)
                 ) AS Mes_Presupuestado,
           #TablaLineaPresupuestoMes.NombreArea AS Area,
           CASE
               WHEN #TablaLineaPresupuestoMes.ciep = 1 THEN
                   #TablaLineaPresupuestoMes.ID_TIPOSER
               ELSE
                   #TablaLineaPresupuestoMes.IdActividadPetrolera
           END AS ID_TIPOSER,
           CASE
               WHEN #TablaLineaPresupuestoMes.ciep = 1 THEN
                   #TablaLineaPresupuestoMes.NombreTipoServicio
               ELSE
                   #TablaLineaPresupuestoMes.DescripcionActividadPetrolera
           END AS CO_TipoServicio,
           CASE
               WHEN #TablaLineaPresupuestoMes.ciep = 1 THEN
                   #TablaLineaPresupuestoMes.ID_CATACTIV
               ELSE
                   #TablaLineaPresupuestoMes.[id_Sub-actividad]
           END AS ID_CATACTIV,
           CASE
               WHEN #TablaLineaPresupuestoMes.ciep = 1 THEN
                   #TablaLineaPresupuestoMes.NombreActividad
               ELSE
                   #TablaLineaPresupuestoMes.SubactividadPetrolera
           END AS Actividad,
           CASE
               WHEN #TablaLineaPresupuestoMes.ciep = 1 THEN
                   #TablaLineaPresupuestoMes.ID_CATSUBACTIV
               ELSE
                   #TablaLineaPresupuestoMes.id_Tarea
           END AS ID_CATSUBACTIV,
           CASE
               WHEN #TablaLineaPresupuestoMes.ciep = 1 THEN
                   #TablaLineaPresupuestoMes.NombreRubro
               ELSE
                   #TablaLineaPresupuestoMes.TareaPetrolera
           END AS SubActividad,
           #TablaLineaPresupuestoMes.ClasificacionAnexo4 AS Anexo4,
           #TablaLineaPresupuestoMes.ID_PADRE,
           #TablaLineaPresupuestoMes.NombreServicio AS Servicio,
           #TablaLineaPresupuestoMes.NombreInstalacion AS Instalacion,
           #TablaLineaPresupuestoMes.IdInstalacionPemex AS ID_PEMEX,
           #TablaLineaPresupuestoMes.[Presupuesto (USD)] AS [Presupuesto (USD)],
           SUM(   CASE
                      WHEN ISNULL(#TablaLineaPresupuestoMesMontos.Monto, 0) <> 0 THEN
                          CAST(ISNULL(#TablaLineaPresupuestoMesMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio AS FLOAT)
                      ELSE
                          0
                  END
              ) AS [Registrado (USD)],
           #TablaLineaPresupuestoMes.Monto
           - SUM(   CASE
                        WHEN ISNULL(#TablaLineaPresupuestoMesMontos.Monto, 0) <> 0 THEN
                            CAST(ISNULL(#TablaLineaPresupuestoMesMontos.Monto, 0) / CO_TipoCambioMensual.TipoCambio AS FLOAT)
                        ELSE
                            0
                    END
                ) AS [Saldo (USD)],
           0 AS Porcentaje,
           0 AS Progreso100,
           0 AS ProgresoM100,
           #TablaLineaPresupuestoMes.ID,
           #TablaLineaPresupuestoMes.id_Actividad,
           #TablaLineaPresupuestoMes.DescripcionActividadPetrolera,
           #TablaLineaPresupuestoMes.[id_Sub-actividad],
           #TablaLineaPresupuestoMes.SubactividadPetrolera,
           #TablaLineaPresupuestoMes.id_Tarea,
           #TablaLineaPresupuestoMes.TareaPetrolera
    FROM #TablaLineaPresupuestoMes
        LEFT JOIN #TablaLineaPresupuestoMesMontos
            ON #TablaLineaPresupuestoMes.IdLineaPresupuestoMes = #TablaLineaPresupuestoMesMontos.IdLineaPresupuestoMes
        LEFT JOIN CO_TipoCambioMensual
            ON #TablaLineaPresupuestoMes.IdMoneda = CO_TipoCambioMensual.IdMoneda
               AND CO_TipoCambioMensual.IdMes = MONTH(#TablaLineaPresupuestoMes.MesPresentacion)
               AND CO_TipoCambioMensual.Anio = YEAR(#TablaLineaPresupuestoMes.MesPresentacion)
    GROUP BY #TablaLineaPresupuestoMes.IdLineaPresupuestoMes,
             #TablaLineaPresupuestoMes.AC_PRESUP_MES,
             #TablaLineaPresupuestoMes.NombreArea,
             #TablaLineaPresupuestoMes.ID_TIPOSER,
             #TablaLineaPresupuestoMes.NombreTipoServicio,
             #TablaLineaPresupuestoMes.ID_CATACTIV,
             #TablaLineaPresupuestoMes.NombreActividad,
             #TablaLineaPresupuestoMes.ID_CATSUBACTIV,
             #TablaLineaPresupuestoMes.ID_PADRE,
             #TablaLineaPresupuestoMes.ClasificacionAnexo4,
             #TablaLineaPresupuestoMes.NombreServicio,
             #TablaLineaPresupuestoMes.NombreInstalacion,
             #TablaLineaPresupuestoMes.IdInstalacionPemex,
             #TablaLineaPresupuestoMes.[Presupuesto (USD)],
             #TablaLineaPresupuestoMes.Monto,
             #TablaLineaPresupuestoMes.ID,
             #TablaLineaPresupuestoMes.NombreRubro,
             #TablaLineaPresupuestoMes.id_Actividad,
             #TablaLineaPresupuestoMes.IdActividadPetrolera,
             #TablaLineaPresupuestoMes.DescripcionActividadPetrolera,
             #TablaLineaPresupuestoMes.[id_Sub-actividad],
             #TablaLineaPresupuestoMes.SubactividadPetrolera,
             #TablaLineaPresupuestoMes.id_Tarea,
             #TablaLineaPresupuestoMes.TareaPetrolera,
             #TablaLineaPresupuestoMes.CIEP
    ORDER BY Mes_Presupuestado,
             #TablaLineaPresupuestoMes.AC_PRESUP_MES,
             Area;
END;