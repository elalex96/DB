create table BitacoraReversaComprobantesExtranjeros
	(
		IdBitacoraReversaComprobanteExtranjero	int,
		Motivo									varchar(max),
		Fecha									datetime,
		IdOperacion								int
		constraint								PK_BitacoraReversaComprobantesExtranjeros	primary key(IdBitacoraReversaComprobanteExtranjero)
	)