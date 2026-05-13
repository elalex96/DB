
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	14 de Febrero del 2023
-- Descripción:			Obtiene todos los archivos pdf de las facturas,
--						dentro del rango de fecha especificados en la solicitud
-- =============================================
CREATE PROCEDURE [dbo].[SP_EM_ObtenArchivosSolicitudDescargaArchivoPendiente]
	@Id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TipoSolicitud VARCHAR(100),
		@ContratoId INT = 0,
		@Inicio DATE,
		@Fin DATE;

	SELECT TOP 1 @TipoSolicitud = TipoSolicitud,
		@ContratoId = ContratoId,
		@Inicio = FechaInicio,
		@Fin = FechaFin
	FROM EMP_SolicitudDescargaArchivos(NOLOCK)
	WHERE Id = @Id

	IF (@TipoSolicitud = 'Facturas Recibidas')
	BEGIN
		SELECT FI_Factura.IdFactura,
			FI_Factura.UUID,
			FI_Documento.DocumentoByte
		FROM FI_Factura(NOLOCK)
		LEFT JOIN FI_FacturaContrato(NOLOCK) ON FI_Factura.IdFactura = FI_FacturaContrato.IdFactura
		JOIN PV_Subcontratista(NOLOCK) ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
		JOIN CO_Contrato(NOLOCK) ON FI_Factura.IdContrato = CO_Contrato.IdContrato
			AND (
				FI_Factura.IdContrato = @ContratoId
				OR FI_FacturaContrato.IdContrato = @ContratoId
				)
		JOIN CO_Contratista(NOLOCK) ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
			AND CO_Contratista.RFC <> FI_Factura.Emisor
		JOIN FI_Documento(NOLOCK) ON FI_Factura.IdFactura = FI_Documento.IdFactura
		WHERE CONVERT(DATE, FI_Factura.Fecha) BETWEEN @Inicio
				AND @Fin
			AND FI_Factura.TipoComprobante IS NOT NULL
			AND FI_Factura.UUID IS NOT NULL
	END;

	IF (@TipoSolicitud = 'Facturas Emitidas')
	BEGIN
		SELECT FI_Factura.IdFactura,
			FI_Factura.UUID,
			FI_Documento.DocumentoByte
		FROM FI_Factura(NOLOCK)
		JOIN CO_Contrato(NOLOCK) ON FI_Factura.IdContrato = CO_Contrato.IdContrato
		JOIN CO_Contratista(NOLOCK) ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
			AND FI_Factura.Emisor = CO_Contratista.RFC
		JOIN FI_Documento(NOLOCK) ON FI_Factura.IdFactura = FI_Documento.IdFactura
		WHERE FI_Factura.IdContrato = @ContratoId
			AND CONVERT(DATE, FI_Factura.Fecha) BETWEEN @Inicio
				AND @Fin
			AND FI_Factura.TipoComprobante IS NOT NULL
			AND FI_Factura.UUID IS NOT NULL
	END;
END