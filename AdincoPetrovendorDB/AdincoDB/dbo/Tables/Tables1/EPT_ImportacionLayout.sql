CREATE TABLE [dbo].[EPT_ImportacionLayout](
	Id int IDENTITY(1,1) NOT NULL,
	ArchivoImportado varchar(max) NULL,
	UsuarioId INT NOT NULL,
	ContratoId INT NOT NULL,
	CreadoEn DATETIME NOT NULL,
	CONSTRAINT [PK_EPT_ImportacionLayout] PRIMARY KEY(Id),
	CONSTRAINT [FK_EPT_ImportacionLayout_Usuario] FOREIGN KEY(UsuarioId) REFERENCES AP_USUARIO (UsuarioID),
	CONSTRAINT [FK_EPT_ImportacionLayout_Contratos] FOREIGN KEY(ContratoId) REFERENCES CO_CONTRATO (IdContrato)
);