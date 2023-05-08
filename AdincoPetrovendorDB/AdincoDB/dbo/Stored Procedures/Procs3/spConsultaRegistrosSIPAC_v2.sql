CREATE PROCEDURE [dbo].[spConsultaRegistrosSIPAC_v2]
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
SET NOCOUNT ON;
-- =============================================
DECLARE
	@Inicio	DATE,
	@Fin	DATE
-- SE OBTINE LA FECHA INICIO Y FECHA FIN DEL MES GE CONTRATO
SELECT	TOP 1
	@Inicio	=	MesGE,
	@Fin	=	DATEADD(dd, -1, DATEADD(MM,1,@Inicio))
FROM CO_MesGEActualContrato

	--por cedula
SELECT
    CO_Contratista.IDSIPAC, CO_Contrato.IDRegFiducidiario, 
	CO_Registro.MesPresentacion AS PeriodoReporte, 
	'CF-' AS Identificador, 
	1 AS Referencia, 
	CO_ActividadPetroleraCNH.id_Actividad, 
    CO_SubactividadPetrolera.[id_Sub-actividad], 
	CO_TareaPetrolera.id_Tarea, 
	CO_AreaContractual.NombreAreaContractual AS Campo, 
	CO_Yacimiento.NombreYacimiento, 
	InstalacionRegistro.NombreInstalacion AS Pozo, 
    CO_CatalogoCuentaSH.Nivel3 as NumeroCuenta, 
	CO_CatalogoCuentaSH.Descripcion as DescripcionCuenta, 
	CO_servicio.NombreServicio AS Servicio, 
	CO_instalacion.NombreInstalacion AS Instalacion_Presupuestada, 
	CO_LineaPresupuestoMes.AC_FEC_INI AS FechaInicio, CO_LineaPresupuestoMes.AC_FEC_FIN AS FechaFin, 
    FI_Factura.Fecha AS FechaFactura, 
	SUM(CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_tipocambiomensual.TipoCambio ELSE 0 END) AS monto, 
    FI_Factura.Serie as NumeroFactura, 
	PV_Subcontratista.razonsocial  as NombreSubcontratista, 
	CO_Registro.InicioEjecucion, 
	CO_Registro.FinEjecucion, 
	FI_Factura.Fecha AS FechaFacturaRegistro,
	AP_usuario.usuario AS CreadoPor, 
    CO_Registro.MontoRegistro, PV_tipomoneda.tipomoneda AS Moneda, 
	co_TipoServicio.NombreTipoServicio AS TipoDeServicio, co_Actividadciep.NombreActividad AS Actividad, 
    co_subactividadciep.NombreSubactividad AS SubActividad, CO_Registro.IdRegistro, 
	co_EstadoRegistro.NombreEstado AS EstadoValidacion, 
	CO_Area.NombreArea AS Area
FROM
	CO_LineaPresupuestoMes	(NOLOCK)
JOIN
    CO_servicio (NOLOCK)
	ON CO_LineaPresupuestoMes.IdServicio = CO_servicio.IdServicio
JOIN
    CO_instalacion (NOLOCK)
	ON CO_LineaPresupuestoMes.IdInstalacion = CO_instalacion.IdInstalacion
JOIN
    CO_Registro	(NOLOCK)
	ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
JOIN
    FI_Factura	(NOLOCK)
	ON FI_Factura.IdFactura = CO_Registro.IdFactura
JOIN
    PV_Subcontratista	(NOLOCK)
	ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista 
JOIN
    CO_instalacion AS InstalacionRegistro 
	ON CO_Registro.IdInstalacion = InstalacionRegistro.IdInstalacion 
JOIN
    AP_usuario (NOLOCK)
	ON CO_Registro.IdUsuarioCreadoPor = AP_usuario.UsuarioID 
JOIN
    co_TipoServicio (NOLOCK)
	ON CO_LineaPresupuestoMes.IdTipoServicio = co_TipoServicio.IdTipoServicio 
JOIN
    co_Actividadciep (NOLOCK)
	ON CO_LineaPresupuestoMes.IdActividad = co_Actividadciep.IdActividad 
JOIN
    co_subactividadciep (NOLOCK)
	ON CO_LineaPresupuestoMes.IdSubactividad = co_subactividadciep.IdSubactividad 
JOIN
    co_EstadoRegistro (NOLOCK)
	ON CO_Registro.IdEstado = co_EstadoRegistro.IdEstadoRegistro 
JOIN
    CO_Area (NOLOCK)
	ON CO_Area.IdArea = CO_LineaPresupuestoMes.IdArea 
JOIN
    PV_tipomoneda (NOLOCK)
	ON PV_tipomoneda.IdMoneda = FI_Factura.IdMoneda 
JOIN
    CO_tipocambiomensual (NOLOCK)
	ON CO_tipocambiomensual.IdMoneda = FI_Factura.IdMoneda 
	AND CO_tipocambiomensual.IdMes = MONTH(CO_Registro.MesPresentacion) 
	AND CO_tipocambiomensual.Anio = YEAR(CO_Registro.MesPresentacion) 
JOIN
    CO_Contrato (NOLOCK)
	ON FI_Factura.IdContrato = CO_Contrato.IdContrato 
JOIN
    CO_Contratista (NOLOCK)
	ON CO_Contrato.IdContratista = CO_Contratista.IdContratista 
JOIN
    CO_ActividadPetroleraCNH (NOLOCK)
	ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera 
JOIN
    CO_SubactividadPetrolera (NOLOCK)
	ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera 
JOIN
    CO_TareaPetrolera (NOLOCK)
	ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera 
JOIN
    CO_AreaContractual (NOLOCK)
	ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual 
JOIN
    CO_Yacimiento (NOLOCK)
	ON InstalacionRegistro.IdYacimiento = CO_Yacimiento.IdYacimiento 
JOIN
    CO_CatalogoCuentaSH (NOLOCK)
	ON CO_LineaPresupuestoMes.IdCatalogoCuentasSH = CO_CatalogoCuentaSH.IdCatalogoCuentasSH
WHERE
	(CO_Registro.MesPresentacion >= @inicio) 
	AND (CO_Registro.MesPresentacion <= @fin) 
	AND CO_LineaPresupuestoMes.IdPresupuesto = 10000	--@IdPresupuesto
GROUP BY
	CO_servicio.NombreServicio, 
	CO_instalacion.NombreInstalacion, 
	CO_LineaPresupuestoMes.AC_FEC_INI, 
	CO_LineaPresupuestoMes.AC_FEC_FIN, 
	FI_Factura.Fecha, FI_Factura.serie, 
	PV_Subcontratista.razonsocial, 
    InstalacionRegistro.NombreInstalacion, 
	CO_Registro.InicioEjecucion, 
	CO_Registro.FinEjecucion, 
	FI_Factura.Fecha, 
	AP_usuario.usuario, 
	CO_Registro.MontoRegistro, 
	PV_tipomoneda.tipoMoneda, 
    CO_Registro.MesPresentacion, 
	co_TipoServicio.NombreTipoServicio, 
	co_Actividadciep.NombreActividad, 
	co_subactividadciep.NombreSubactividad, 
	CO_Registro.IdRegistro, 
	co_EstadoRegistro.NombreEstado, 
	CO_Area.NombreArea, 
    CO_Contratista.IDSIPAC, 
	CO_Contrato.IDRegFiducidiario, 
	CO_ActividadPetroleraCNH.id_Actividad, 
	CO_SubactividadPetrolera.[id_Sub-actividad], 
	CO_TareaPetrolera.id_Tarea, 
	CO_AreaContractual.NombreAreaContractual, 
    CO_Yacimiento.NombreYacimiento, 
	CO_CatalogoCuentaSH.Nivel3, 
	CO_CatalogoCuentaSH.Descripcion
 
 
 END

