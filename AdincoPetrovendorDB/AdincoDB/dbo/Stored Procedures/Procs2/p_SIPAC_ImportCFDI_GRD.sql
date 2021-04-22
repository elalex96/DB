CREATE proc p_SIPAC_ImportCFDI_GRD
@IdBitacora int
as

	select	b.IdBitacora,
			f.UUID,
			f.Moneda,
			F.Subtotal,
			b.CreadoEl
	from SIPAC_ImportCFDI b
	inner join FI_Factura f on f.IdFactura = b.IdFactura
	where IdBitacora = @IdBitacora







