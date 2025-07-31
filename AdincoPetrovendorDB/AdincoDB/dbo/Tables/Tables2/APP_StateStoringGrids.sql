CREATE TABLE APP_StateStoringGrids (
    UsuarioId INT NOT NULL,
    ContratoId INT NOT NULL,
    Grid VARCHAR(100) NOT NULL,
    Body VARCHAR(8000) NOT NULL,
	FechaDel DATETIME NULL,
	FechaAl DATETIME NULL,
	Pantalla VARCHAR(200),
    CreadoEn DATETIME NOT NULL DEFAULT GETDATE(),
    ModificadoEn DATETIME NULL,
    CONSTRAINT PK_StateStoring PRIMARY KEY (UsuarioId, ContratoId, Grid)
);
