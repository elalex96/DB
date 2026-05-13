create PROCEDURE p_NC_ConsultaDetalleNotaCredito
@IdProveedor INT,
@IdAceptacionPedido INT,
@IdNoNotaCredito INT
as
begin

	SELECT 
	NC.IdAceptacionNotaCredito
	, F.ComprobantePDFByte
	, F.ComprobanteXMLByte
	, 'Sin Descripcion' as Descripcion
	, E.Nombre AS Estatus
	, FORMAT(NC.CreadoEl,'dd/MM/yyyy hh:mm tt') AS CreadoEl
	, UC.Nombre as CargadoPor
	, F.IdFactura
	, F.SubTotal
	, '' AS MonedaFacturaNotaCredito
	, F.MontoConIva
	, '0' as IdOperacion
	, ISNULL(CAST(FORMAT(getdate() ,'dd/MM/yyyy hh:mm tt') AS NVARCHAR(MAX)),'N/A') AS FechaCambioEstatus
	, '' AS ComentarioAprobador
	,  F.Moneda
	, '' as NombreFlujo
	, '' AS DetalleFlujo
	, '' AS NombreTipoFlujo
	, ISNULL(NC.IdEstatusEliminada, 0) AS IdEstatusEliminada
	, NC.IdEliminado
	, FORMAT(RE.FechaRegistro,'dd/MM/yyyy hh:mm tt')  AS FechaRegistro
	, RE.ComentarioExterno 
	, RE.ComentarioInterno
	,CONCAT('Nota crédito No. ',CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX))) AS NombreArchivo
	,PV.RazonSocial AS Proveedor
	, po.Currency
	, NC.CFDIRelacionados
	, NC.IdAceptacionPedido
	, 0 as IdEstatusOperacion
	, F.UUID
	from MPY_MM_AceptacionNotaCredito AS NC
	join FI_Factura as F on F.IdFactura = NC.IdFacturaNotaCredito
	join TA_Estatus as E on E.IdEstatus = NC.IdEstatus 
	join S_Usuario as UC on NC.CreadoPor = UC.IdUsuario
	LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion = NC.IdEliminado
	join S_Proveedor as PV on PV.IdProveedor =  @IdProveedor
	join MPY_MM_AceptacionPedido as ap on ap.IdAceptacionPedido =  nc.IdAceptacionPedido 
	join Adinco..CO_SAPPO as po on ap.IdPedido collate SQL_Latin1_General_CP1_CI_AS = po.SAPPONumber collate SQL_Latin1_General_CP1_CI_AS
	where nc.IdAceptacionNotaCredito = @IdNoNotaCredito and NC.IdAceptacionPedido = @IdAceptacionPedido
end