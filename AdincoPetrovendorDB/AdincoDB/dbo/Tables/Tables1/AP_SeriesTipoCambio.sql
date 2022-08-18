	CREATE TABLE AP_SeriesTipoCambio(
	Id INT IDENTITY(1,1),
	IdMoneda INT,
	Pediodicidad VARCHAR(150),
	SerieBanxico VARCHAR(150),
	Tipo VARCHAR(150),
	Descripcion VARCHAR(300),
	CreadoPor INT,
	CreadoEl DATETIME
	CONSTRAINT PK_SeriesTipoCambio PRIMARY KEY (Id),
	CONSTRAINT AP_SeriesTipoCambioPV_TipoMoneda FOREIGN KEY (IdMoneda)
	REFERENCES PV_TipoMoneda(IdMoneda),
	CONSTRAINT AP_SeriesTipoCambioCreadoPor FOREIGN KEY (CreadoPor)
	REFERENCES AP_Usuario(UsuarioID)
	)