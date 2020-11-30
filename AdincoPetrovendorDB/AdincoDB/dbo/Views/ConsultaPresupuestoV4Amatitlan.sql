CREATE VIEW dbo.ConsultaPresupuestoV4Amatitlan
AS
    SELECT CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
        CO_Presupuesto.Nombre AS Presupuesto,
        CO_TipoServicio.ID_TIPOSER,
        CASE
            WHEN C.IdTipoContrato = 1
            THEN CO_TipoServicio.NombreTipoServicio
            ELSE apc.DescripcionActividadPetrolera
        END AS NombreTipoServicio,
        CO_TipoServicio.Orden,
        CO_ActividadCIEP.ID_CATACTIV,
        CASE
            WHEN c.IdTipoContrato = 1
            THEN CO_ActividadCIEP.NombreActividad
            ELSE sap.SubactividadPetrolera
        END AS NombreActividad,
        CO_SubactividadCIEP.ID_CATSUBACTIV,
        CO_SubactividadCIEP.NombreSubactividad,
        CO_Clasificacion.NombreClasificacion,
        CO_LineaPresupuestoMes.AC_TERMINADO,
        CO_Instalacion.IdInstalacionPemex,
        CO_Instalacion.NombreInstalacion,
        CO_Instalacion.EsBolsa,
        CO_LineaPresupuestoMes.AC_PRESUP_MES,
        CO_Servicio.NombreServicio,
        CO_Unidad.Unidad,
        CO_LineaPresupuestoMes.AC_FEC_INI,
        CO_LineaPresupuestoMes.AC_FEC_FIN,
        CO_ActividadHidrocarburoCIEP.ID_CATACTHC,
        CO_ActividadHidrocarburoCIEP.NombreActividadHidrocarburo,
        CO_LineaPresupuestoMes.ID_PADRE,
        CO_Area.NombreArea,
        CO_Rubro.ID_RUBRO1,
        CO_Rubro.ID_RUBRO2,
        CO_Rubro.ID_RUBRO3,
        CO_Rubro.CLAVE_RUBRO,
        CO_Rubro.NombreRubro,
        CO_LineaPresupuestoMes.Volumetria,
        CO_LineaPresupuestoMes.PrecioUnitario,
        CO_LineaPresupuestoMes.Monto,
        CO_ClasificacionAnexo4.ClasificacionAnexo4,
        CO_ClasificacionAnexo4.Clave,
        CASE
            WHEN c.IdTipoContrato = 1
            THEN CO_RubroInterno.NombreRubro
            ELSE tp.TareaPetrolera
        END AS RubroInterno,
        CO_RubroInterno.Clave AS Expr2,
        CO_LineaPresupuestoMes.CPXOPX,
        CO_LineaPresupuestoMes.IdLineaProgramaActividadMes
    FROM CO_LineaPresupuestoMes (NOLOCK)
        LEFT JOIN CO_Instalacion (NOLOCK)
			ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        LEFT JOIN CO_Servicio (NOLOCK)
			ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
							AND CO_Servicio.Activo = 1
        LEFT JOIN CO_Unidad (NOLOCK)
			ON CO_Servicio.IdUnidad = CO_Unidad.IdUnidad
        LEFT JOIN CO_ActividadHidrocarburoCIEP (NOLOCK)
			ON CO_LineaPresupuestoMes.IdActvidadHidrocarburo = CO_ActividadHidrocarburoCIEP.IdActividadHidrocarburo
        LEFT JOIN CO_Area (NOLOCK)
			ON CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
        LEFT JOIN CO_Rubro (NOLOCK)
			ON CO_LineaPresupuestoMes.IdRubro = CO_Rubro.IdRubro
        LEFT JOIN CO_ClasificacionAnexo4 (NOLOCK)
			ON CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
        LEFT JOIN CO_RubroInterno (NOLOCK)
			ON CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
        LEFT JOIN CO_ActividadCIEP (NOLOCK)
			ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
                                    AND CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
        LEFT JOIN CO_Presupuesto (NOLOCK)
			ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
        LEFT JOIN CO_TipoServicio (NOLOCK)
			ON CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.IdTipoServicio
        LEFT JOIN CO_SubactividadCIEP (NOLOCK)
			ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
                                        AND CO_ActividadCIEP.IdActividad = CO_SubactividadCIEP.IdActividad
        LEFT JOIN CO_Clasificacion (NOLOCK)
			ON CO_LineaPresupuestoMes.IdClasificacion = CO_Clasificacion.IdClasificacion
        LEFT JOIN dbo.CO_ActividadPetroleraCNH APC (NOLOCK)
			ON apc.IdActividadPetrolera = dbo.CO_LineaPresupuestoMes.IdActividadPetrolera
        LEFT JOIN dbo.CO_SubactividadPetrolera SAP (NOLOCK)
			ON sap.IdSubactividadPetrolera = dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera
        LEFT JOIN dbo.CO_TareaPetrolera TP (NOLOCK)
			ON tp.IdTareaPetrolera = dbo.CO_LineaPresupuestoMes.IdTareaPetrolera
        LEFT JOIN dbo.CO_Presupuesto P (NOLOCK)
			ON P.IdPresupuesto = dbo.CO_LineaPresupuestoMes.IdPresupuesto
        LEFT JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
			ON PA.IdProgramaActividad = p.IdProgramaActividad
        LEFT JOIN dbo.CO_AnioContractual AC (NOLOCK)
			ON ac.IdAnioContractual = P.IdAnioContractual
        LEFT JOIN dbo.CO_Contrato C (NOLOCK)
			ON C.IdContrato = AC.IdContrato
    WHERE CO_LineaPresupuestoMes.idPresupuesto = 10065