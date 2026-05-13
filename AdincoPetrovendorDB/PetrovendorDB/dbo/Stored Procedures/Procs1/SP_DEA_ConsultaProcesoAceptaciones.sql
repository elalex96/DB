-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/05/2020>
-- Description:	<Consulta de las aceptaciones referentes a dea>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultaProcesoAceptaciones] 
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @DATOSACEPTACIONES TABLE(
	IdSolicitudPedido INT,
	Folio NVARCHAR(1),
	Descripcion NVARCHAR(1),
	CentroCosto NVARCHAR(1),
	NumeroPedido NVARCHAR(1),
	Proveedor NVARCHAR(1),
	FechaPedidoFechaConfirmacionPedido NVARCHAR(1),
	TipoEntrega NVARCHAR(1),
	UsuarioAceptaPedido NVARCHAR(1),
	FechaAceptacionPedido NVARCHAR(1),
	DiasAceptacionPedido NVARCHAR(1),
	NumeroAceptacionPedido NVARCHAR(1),
	FechaRecepcionCartaCN NVARCHAR(1),
	DiasRecepcionCartaCartaCN NVARCHAR(1),
	UsuarioApruebaCartaCN NVARCHAR(1),
	FechaAprobacionCartaCN NVARCHAR(1),
	DiasAprobacionCartaCN NVARCHAR(1),
	EstatusCartaCN NVARCHAR(1),
	FechaRecepcionFactura NVARCHAR(1),
	DiasRecepcionFactura NVARCHAR(1),
	FolioFactura NVARCHAR(1),
	Responsable1aAprobacion NVARCHAR(1),
	Fecha1aAprobacion NVARCHAR(1),
	DiasEspera1aAprobacion NVARCHAR(1),
	Estatus1aAprobacion NVARCHAR(1),
	Responsable2aAprobacion NVARCHAR(1),
	Fecha2aAprobacion NVARCHAR(1),
	Estatus2aAprobacion NVARCHAR(1),
	DiasEnAprobacion NVARCHAR(1),
	DiasTotal NVARCHAR(1),
	EstatusAprobacionFactura NVARCHAR(1)
);

SELECT 
	IdSolicitudPedido,
	Folio,
	Descripcion,
	CentroCosto,
	NumeroPedido,
	Proveedor,
	FechaPedidoFechaConfirmacionPedido,
	TipoEntrega,
	UsuarioAceptaPedido,
	FechaAceptacionPedido,
	DiasAceptacionPedido,
	NumeroAceptacionPedido,
	FechaRecepcionCartaCN,
	DiasRecepcionCartaCartaCN,
	UsuarioApruebaCartaCN,
	FechaAprobacionCartaCN,
	DiasAprobacionCartaCN,
	EstatusCartaCN,
	FechaRecepcionFactura,
	DiasRecepcionFactura,
	FolioFactura,
	Responsable1aAprobacion,
	Fecha1aAprobacion,
	DiasEspera1aAprobacion,
	Estatus1aAprobacion,
	Responsable2aAprobacion,
	Fecha2aAprobacion,
	Estatus2aAprobacion,
	DiasEnAprobacion,
	DiasTotal,
	EstatusAprobacionFactura
FROM @DATOSACEPTACIONES
ORDER BY IdSolicitudPedido DESC

END
