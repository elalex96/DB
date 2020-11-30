CREATE VIEW dbo.ReportePresupuestoGastos_Jaguar
AS

SELECT
	ROW_NUMBER() OVER (ORDER BY AREA.NombreAreaContractual, dbo.CO_Presupuesto.Nombre, 
		CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)), CO_ActividadPetroleraCNH.id_Actividad) AS Id

,
	AREA.NombreAreaContractual,
	dbo.CO_Presupuesto.Nombre AS Presupuesto,
	dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
	CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)) AS Mes_Presupuestado,
	CO_Area.NombreArea AS Area,
	CO_ActividadPetroleraCNH.id_Actividad					AS ActPetrolera,
	CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS DescActPetrolera,
	CO_SubactividadPetrolera.[id_Sub-actividad],
	CO_SubactividadPetrolera.SubactividadPetrolera,
	CO_TareaPetrolera.id_Tarea	AS IDTareaPetrolera,
	CO_TareaPetrolera.TareaPetrolera,
	dbo.CO_LineaPresupuestoMes.ID_PADRE,
	CO_Servicio.NombreServicio AS [Servicio/Subtarea],
--	CO_Instalacion.NombreInstalacion AS InstalacionPresupuestada,
	dbo.CO_LineaPresupuestoMes.Monto		AS [Presupuesto (USD)],
	ROUND(SUM(CASE    WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
		THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
		ELSE 0
	END),4)						AS [Registrado (USD)],
	ROUND(dbo.CO_LineaPresupuestoMes.Monto - SUM(CASE    WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
		THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
		ELSE 0
	END),4)						AS [Saldo (USD)],
	CASE WHEN CO_Servicio.NombreServicio LIKE '%NO%ELEGIBLE%' THEN 'NO'
		ELSE 'SI'
	END							AS [Elegible]
FROM
	dbo.CO_LineaPresupuestoMes (NOLOCK)
LEFT JOIN
	CO_ActividadPetroleraCNH (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
LEFT JOIN
	CO_SubactividadPetrolera (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
LEFT JOIN CO_TareaPetrolera (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
LEFT JOIN CO_ActividadCIEP (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
LEFT JOIN
	CO_Servicio (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
LEFT JOIN
	CO_Area (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
LEFT JOIN
	CO_Instalacion (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
LEFT JOIN
	CO_Registro (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
LEFT JOIN
	FI_Factura (NOLOCK)
	ON FI_Factura.IdFactura = CO_Registro.IdFactura
LEFT JOIN
	CO_TipoCambioMensual (NOLOCK)
	ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
    AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
    AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
LEFT JOIN
	CO_RubroInterno (NOLOCK)
	ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
LEFT JOIN
	CO_Presupuesto (NOLOCK)
	ON CO_Presupuesto.idpresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
LEFT JOIN
	dbo.CO_AnioContractual AC (NOLOCK)
	ON AC.IdAnioContractual = CO_Presupuesto.IdAnioContractual
LEFT JOIN
	dbo.CO_Contrato	C (NOLOCK)
	ON	AC.IdContrato	=	C.IdContrato
LEFT JOIN 
	dbo.CO_AreaContractual	AREA (NOLOCK)
	ON	C.IdAreaContractual	=	AREA.IdAreaContractual
WHERE 
	C.IdContrato IN (10014,10015,10016,10017,10018, 10019,10020,10021,10022,10023,10024, 10043, 10052)
GROUP BY
	AREA.NombreAreaContractual,
	dbo.CO_Presupuesto.Nombre,
	dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
	dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
	CO_Area.NombreArea,
	dbo.CO_LineaPresupuestoMes.ID_PADRE,
	CO_Servicio.NombreServicio,
--	CO_Instalacion.NombreInstalacion,
	dbo.CO_LineaPresupuestoMes.Monto,
	CO_RubroInterno.NombreRubro,
	CO_ActividadPetroleraCNH.id_Actividad,
	CO_ActividadPetroleraCNH.IdActividadPetrolera,
	CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
	CO_SubactividadPetrolera.[id_Sub-actividad],
	CO_SubactividadPetrolera.SubactividadPetrolera,
	CO_TareaPetrolera.id_Tarea,
	CO_TareaPetrolera.TareaPetrolera