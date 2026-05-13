-- p_MPY_NC_RevisionSAP_Grd 10037
CREATE PROC p_MPY_NC_RevisionSAP_Grd
@pIdContrato int
as

	SELECT PO = ap.IdPedido ,
		AceptacionNC = anc.IdAceptacionNotaCredito,
		UUIDNC = fac.UUID,
		Subtotal = fac.SubTotal,
		Moneda = m.TipoMonedaCorto,
		Estatus = e.Nombre,
		Revisado = isnull(RevisionSAP,0),
		FechaRevision = anc.RevisionSAPEl
	FROM  [dbo].[MPY_MM_AceptacionNotaCredito] anc
	inner join [MPY_MM_AceptacionPedido] ap on ap.IdAceptacionPedido = anc.IdAceptacionPedido
	inner join FI_Factura fac on fac.IdFactura=anc.IdFacturaNotaCredito
	inner join PV_TipoMoneda m on m.IdMoneda = fac.IdMoneda
	inner join TA_Estatus e on e.IdEstatus = anc.IdEstatus
	where e.IdEstatus = 2 --Solo aprobadas
	--and isnull(RevisionSAP,0) = 0 --Aun si revisar
	and ap.IdContrato = @pIdContrato 
	
