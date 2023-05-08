
-- ================================================================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	13 de Febrero del 2023
-- Descripción:			Consulta de las solicitudes de descarga de archivos de pdf,
--						de las facturas emitidas y recibidas por contratos
-- ================================================================================
CREATE PROCEDURE [dbo].[SP_EMP_ObtenSolicitudesDescargarArchivos] 
	@ContratoId INT,
	@UsuarioId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT EMP_SolicitudDescargaArchivos.FechaSolicitud,
		AP_Usuario.Nombre AS SolicitadoPor,
		CASE 
			WHEN ISNULL(LTRIM(RTRIM(EMP_SolicitudDescargaArchivos.NombreArchivo)), '') = 'FACTURAS_SIN_ARCHIVOS'
				THEN 'Sin Archivos PDF'
			WHEN ISNULL(EMP_SolicitudDescargaArchivos.Procesado, 0) = 0
				THEN 'Procesando Solicitud...'
			WHEN ISNULL(EMP_SolicitudDescargaArchivos.Procesado, 0) = 1
				THEN 'Listo para Descargar'
			END AS Estatus,
		CASE 
			WHEN ISNULL(LTRIM(RTRIM(EMP_SolicitudDescargaArchivos.NombreArchivo)), '') = 'FACTURAS_SIN_ARCHIVOS'
				THEN 'label label-danger'
			WHEN ISNULL(EMP_SolicitudDescargaArchivos.Procesado, 0) = 0
				THEN 'label label-warning'
			WHEN ISNULL(EMP_SolicitudDescargaArchivos.Procesado, 0) = 1
				THEN 'label label-success'
			END AS span,
		EMP_SolicitudDescargaArchivos.Carpeta,
		EMP_SolicitudDescargaArchivos.UUIDAmazon,
		EMP_SolicitudDescargaArchivos.NombreArchivo,
		EMP_SolicitudDescargaArchivos.Meta,
		EMP_SolicitudDescargaArchivos.Size,
		EMP_SolicitudDescargaArchivos.TipoSolicitud,
		EMP_SolicitudDescargaArchivos.FechaInicio,
		EMP_SolicitudDescargaArchivos.FechaFin
	FROM EMP_SolicitudDescargaArchivos(NOLOCK)
	JOIN AP_Usuario(NOLOCK) ON EMP_SolicitudDescargaArchivos.UsuarioId = AP_Usuario.UsuarioID
	WHERE EMP_SolicitudDescargaArchivos.ContratoId = @ContratoId
		AND LTRIM(RTRIM(EMP_SolicitudDescargaArchivos.TipoSolicitud)) IN (
			'Facturas Emitidas',
			'Facturas Recibidas'
			)
	ORDER BY EMP_SolicitudDescargaArchivos.FechaSolicitud DESC;
END