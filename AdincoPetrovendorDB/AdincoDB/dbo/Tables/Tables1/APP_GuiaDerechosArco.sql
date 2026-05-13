CREATE TABLE APP_GuiaDerechosArco(
	Id INT Identity(10000,1),
	DerechosArco VARCHAR(MAX),
	Activo BIT
	CONSTRAINT PK_GuiaDerechosArco PRIMARY KEY (Id)
	);

	