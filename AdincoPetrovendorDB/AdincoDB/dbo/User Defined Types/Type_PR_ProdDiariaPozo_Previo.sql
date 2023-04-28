CREATE TYPE Type_PR_ProdDiariaPozo_Previo AS TABLE
(
    Fecha DATETIME,
	Estacion INT,
	Pozo INT,
	Nominal VARCHAR(100),	
	Fuente VARCHAR(100),
	Operando BIT,
	Est_64Plg FLOAT,
	Cabeza FLOAT,
	Linea FLOAT,
	GastoGas FLOAT,
	ProdAceiteNeto FLOAT,
	ProdPetroleoBruto FLOAT,
	Agua FLOAT,
	Comentarios VARCHAR(250),
	IdUnidad INT,
	IdSistema INT,
	EPM FLOAT,
	NombreEstacion VARCHAR(200),
	ProgramaInmediato VARCHAR(5000),
	Seguimiento VARCHAR(5000)
)

	
