
-- ================================================================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	13 de Febrero del 2023
-- Descripción:			Primero verifica si hay facturas dentro de ese rango de fechas 
--						Seguido genera la solitud en la tabla correspondiente para proceder cuando se ejecute la tarea de consola
-- ================================================================================
CREATE PROCEDURE [dbo].[SP_EMP_GenerarSolicitudDescargaArchivo]
	@Tipo VARCHAR(MAX),
	@Inicio DATE,
	@Fin DATE,
	@UsuarioId INT,
	@ContratoId INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Cuenta INT = 0;

	IF (@Tipo = 'Facturas Recibidas')
	BEGIN
		SELECT DISTINCT @Cuenta = COUNT(*)
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
		WHERE CONVERT(DATE,FI_Factura.Fecha) BETWEEN @Inicio
				AND @Fin
			AND FI_Factura.TipoComprobante IS NOT NULL
			AND FI_Factura.UUID IS NOT NULL;
	END;

	IF (@Tipo = 'Facturas Emitidas')
	BEGIN
		SELECT DISTINCT @Cuenta = COUNT(*)
		FROM FI_Factura(NOLOCK)
		JOIN CO_Contrato(NOLOCK) ON FI_Factura.IdContrato = CO_Contrato.IdContrato
		JOIN CO_Contratista(NOLOCK) ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
			AND FI_Factura.Emisor = CO_Contratista.RFC
		WHERE FI_Factura.IdContrato = @ContratoId
			AND CONVERT(DATE,FI_Factura.Fecha) BETWEEN @Inicio
				AND @Fin
			AND FI_Factura.TipoComprobante IS NOT NULL
			AND FI_Factura.UUID IS NOT NULL;
	END;

	IF (@Cuenta > 0)
	BEGIN
		INSERT INTO EMP_SolicitudDescargaArchivos (
			FechaInicio,
			FechaFin,
			TipoSolicitud,
			UsuarioId,
			ContratoId,
			FechaSolicitud,
			Procesado
			)
		VALUES (
			@Inicio,
			@Fin,
			@Tipo,
			@UsuarioId,
			@ContratoId,
			GETDATE(),
			0
			)
	END

	/*Regresa el número de facturas encontrados para crear el registro o 
	informar si no se encuentran facturas dentro del rengo de fechas solicitadas*/
	SELECT @Cuenta AS NumeroFacturas
END