CREATE PROCEDURE dbo.sp_COM_ConsultaComercializaciones
	@IdContrato	INT
AS
BEGIN


SELECT c.IdOperacionComercializacion,
	c.IdContrato,
	c.MesReporte,
	c.FechaTransaccion,
	c.IdTipoHidrocarburo,
	c.VolumenVendido,
	c.PrecioVentaUnitario,
	c.CostoUnitarioComercializacion,
	c.PrecioPuntoMedicion,
	c.IdFactura,
	c.NumeroFolioPedimento,
	c.EPT,
	c.OperacionBajoReglasMercado,
	c.ClasificacionDocumentoSoporte,
	c.CreadoPor,
	c.CreadoEl,
	c.ModificadoPor,
	c.ModificadoEl,
	c.Activo,
	c.NuevoPrecioVentaUnitario,
	c.PVUAnterior,
	c.PPMAnterior,
	c.PuntoEntregaID,
	--c.EsCondensable ,
		Nombre	AS [PuntoEntrega],
		CASE WHEN ISNULL(fac.Serie,'')  = '' then isnull(fac.Folio,'')
			eLSE  ISNULl(fac.Serie,'') +''+ isnull(fac.Folio,0)
		END		AS [Factura]
FROM
	[COM_OperacionComercializacion] c
left JOIN
	CO_PuntosdeEntrega pe on pe.PuntoEntregaID = c.PuntoEntregaID
left JOIN
	FI_Factura fac on fac.IdFactura = c.IdFactura
 WHERE
	c.[IdContrato] = @IdContrato
 ORDER BY
	c.FechaTransaccion DESC 

 END

