
create proc sp_FI_Transfer_Sel
(
	@IdTransferencia	int
)
as
begin
	declare		@pdf	nvarchar

	select		top 50
				IdTransferencia,		t.IdContrato,		IdComprobantePago,			NombreExtencionArchivo	=	case when NombreExtencionArchivo = '' or NombreExtencionArchivo is null then ReferenciaBancaria + '.pdf' else NombreExtencionArchivo end,
				ReferenciaBancaria,		FechaPago,		IdCuentaOrigen,				IdCuentaDestino,
				MontoPagado,			IdMoneda,		IdClasificacionDocumento,	Concepto,
				IdMetodoPago,			ProcesadoSIPAC,	NumeroPolizaContable,		Intereses,
				PDF						=	case	when len(PDF) > 0 then PDF else null end,
				d.HashSHA256,				IdFacturaPago,				AWSPDFId,
				IdFormaPago,			UUIDAmazon
	from		FI_Transfer				t
	left join	AWS_Documentos			d
	on			t.AWSPDFId				=	d.AWSDocumentoId
	inner join	CO_Contrato				c
	on			c.IdContrato			=	t.IdContrato
	where		IdTransferencia			=	@IdTransferencia
	

end

