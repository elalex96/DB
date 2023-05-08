
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	14 de Febrero del 2023
-- Descripción:			Consulta de solicitudes de descarga de archivos de la tabla EMP_SolicitudDescargaArchivos en Adinco
-- =============================================
CREATE PROCEDURE [dbo].[SP_EM_ConsultaSolicitudesDescargarArchivosPendientes]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT EMP_SolicitudDescargaArchivos.Id,
		EMP_SolicitudDescargaArchivos.ContratoId,
		EMP_SolicitudDescargaArchivos.UsuarioId,
		EMP_SolicitudDescargaArchivos.TipoSolicitud,
		ISNULL(EMP_SolicitudDescargaArchivos.Carpeta, '') AS Carpeta,
		EMP_SolicitudDescargaArchivos.FechaInicio,
		EMP_SolicitudDescargaArchivos.FechaFin,
		CO_Contrato.NumeroContrato
	FROM EMP_SolicitudDescargaArchivos(NOLOCK)
	JOIN CO_Contrato(NOLOCK) ON EMP_SolicitudDescargaArchivos.ContratoId = CO_Contrato.IdContrato
	WHERE Procesado = 0
END