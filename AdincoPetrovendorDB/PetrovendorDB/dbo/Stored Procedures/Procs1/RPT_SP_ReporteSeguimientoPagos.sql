
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-12-2018>
-- Description:	<Reporte de seguimiento de pagos>
-- =============================================

CREATE PROCEDURE RPT_SP_ReporteSeguimientoPagos	--420
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT 
		ROW_NUMBER() OVER(ORDER BY ps.IdPedido DESC) AS Identificador,
		ps.IdPedido,
		CONVERT(NVARCHAR(100), hft.Fecha, 103) AS FechaAprobacionPedido, 
		ap.IdAceptacionPedido,
		CASE WHEN f.IdFactura IS NULL THEN 'Sin factura'
			WHEN hftf.Fecha IS NULL THEN 'Factura no aprobada'
			ELSE CONVERT(NVARCHAR(100), hftf.Fecha, 103) END AS FechaAprobacionFactura,
		CASE WHEN tr.PDF IS NULL THEN 'No pagado'
            WHEN tr.PDF IS NOT NULL THEN CONVERT(NVARCHAR(100), tr.FechaPago, 103)
            WHEN af.IdFactura IS NULL THEN 'En proceso' END AS FechaPago,
		CASE WHEN hftf.Fecha IS NOT NULL THEN DATEDIFF(DAY, hft.Fecha, hftf.Fecha) END DiasAprobacionFactura,
		CASE WHEN tr.PDF IS NOT NULL THEN DATEDIFF(DAY, hftf.Fecha, tr.FechaPago) END DiasPago,
		CASE WHEN tr.PDF IS NOT NULL THEN tr.IdTransferencia ELSE 0 END AS TienePago
	FROM dbo.MM_Pedidos ps
		INNER JOIN dbo.MM_Pedido p ON p.IdPedido = ps.IdIdentificador
		INNER JOIN dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido AND o.NoVersion = p.Version
		INNER JOIN dbo.TA_HistorialFlujoTarea hft ON hft.IdOperacion = o.IdOperacion AND hft.IdEstadoFlujo = 7
		LEFT JOIN dbo.MM_AceptacionPedido ap ON ap.IdPedido = p.IdPedido
		LEFT JOIN dbo.MM_AceptacionFactura apf ON apf.IdAceptacionPedido = ap.IdAceptacionPedido
		LEFT JOIN dbo.TA_Operacion opf ON opf.IdDocumento = apf.IdAceptacionFactura AND opf.IdEstatusOperacion = 2 AND opf.IdTipoOperacion = 10
		LEFT JOIN dbo.TA_HistorialFlujoTarea hftf ON hftf.IdOperacion = opf.IdOperacion AND hftf.IdEstadoFlujo = 7
		LEFT JOIN dbo.FI_Factura f ON f.IdFactura = apf.IdFactura
		LEFT JOIN Adinco.dbo.FI_Factura af ON af.UUID = f.UUID COLLATE Modern_Spanish_CI_AS
        LEFT JOIN Adinco.dbo.FI_TransferFactura tf ON tf.IdFactura = af.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer tr ON tr.IdTransferencia = tf.IdTransfer
	WHERE ps.IdProveedorCliente = @IdProveedor
		AND o.IdEstatusOperacion = 2
		AND o.IdTipoOperacion = 9
END
