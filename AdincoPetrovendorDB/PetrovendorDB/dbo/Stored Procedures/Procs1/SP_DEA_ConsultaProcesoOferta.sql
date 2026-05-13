-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultaProcesoOferta]
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @DATOSOFERTA TABLE(
	IdSolicitudPedido INT,
	Folio NVARCHAR(1),
	Descripcion NVARCHAR(1),
	CentroCosto NVARCHAR(1),
	Fecha1aAsignacionFechaCargaPR NVARCHAR(1),
	CompradorAsignado1 NVARCHAR(1),
	Fecha2aAsignacion NVARCHAR(1),
	CompradorAsignado2 NVARCHAR(1),
	Dias2aAsignacion NVARCHAR(1),--
	Comprador NVARCHAR(1),
	NumeroProveedores NVARCHAR(1),
	FechaEnvioCotizacion NVARCHAR(1),
	FechaRecepcion1raCotizacion NVARCHAR(1),
	DiasEnvioCotizacion NVARCHAR(1),--
	DiasCotizacion NVARCHAR(1),
	DiasSolicitudOferta NVARCHAR(1),
	NumeroProveedoresCotizaron NVARCHAR(1),
	FechaRecepcionUltimaCotizacion NVARCHAR(1),
	FechaVigenciaCotizacion NVARCHAR(1),
	DiasRecepcionCotizacion NVARCHAR(1),
	FechaEnvioPedido NVARCHAR(1),
	NumeroPedido NVARCHAR(1),
	DiasEnvioPedido NVARCHAR(1),
	FechaAprobacionPedido NVARCHAR(1),
	FechaRecepcionPOSAP NVARCHAR(1),
	DiasAprobacionPedido NVARCHAR(1),
	EstatusAprobacionPedido NVARCHAR(1),
	DiasAsignacionProveedor NVARCHAR(1),
	NumeroPOSAP NVARCHAR(1),
	FechaRelacionPOSAP NVARCHAR(1),
	DiasRelacionPOSAP NVARCHAR(1),
	FechaConfirmacionPedido NVARCHAR(1),
	DiasConfirmacionPedido NVARCHAR(1),
	DiasTotal NVARCHAR(1),
	EstatusFinal NVARCHAR(1)
)


SELECT
	IdSolicitudPedido,
	Folio,
	Descripcion,
	CentroCosto,
	Fecha1aAsignacionFechaCargaPR,
	CompradorAsignado1,
	Fecha2aAsignacion,
	CompradorAsignado2,
	Dias2aAsignacion,--
	Comprador,
	NumeroProveedores,
	FechaEnvioCotizacion,
	FechaRecepcion1raCotizacion,
	DiasEnvioCotizacion,--
	DiasCotizacion,
	DiasSolicitudOferta,
	NumeroProveedoresCotizaron,
	FechaRecepcionUltimaCotizacion,
	FechaVigenciaCotizacion,
	DiasRecepcionCotizacion,
	FechaEnvioPedido,
	NumeroPedido,
	DiasEnvioPedido,
	FechaAprobacionPedido,
	FechaRecepcionPOSAP,
	DiasAprobacionPedido,
	EstatusAprobacionPedido,
	DiasAsignacionProveedor,
	NumeroPOSAP,
	FechaRelacionPOSAP,
	DiasRelacionPOSAP,
	FechaConfirmacionPedido,
	DiasConfirmacionPedido,
	DiasTotal,
	EstatusFinal
FROM @DATOSOFERTA
ORDER BY IdSolicitudPedido DESC;

END
