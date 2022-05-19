CREATE TABLE [dbo].[EPT_ImportacionLayoutDetalle](
	Id int IDENTITY(1,1) NOT NULL,
	ImportacionLayoutId INT NOT NULL,
	Contratista varchar(max) NULL,
	Contrato varchar(max) NULL,
	IdentificadorDocumento varchar(max) NULL,
	NombreDocumento varchar(max) NULL,
	Mes INT,
	Anio INT,
	CreadoEn DATETIME NOT NULL,
	CONSTRAINT [PK_EPT_ImportacionLayoutDetalle] PRIMARY KEY(Id),
	CONSTRAINT [FK_EPT_ImportacionLayoutDetalle_Importacion] FOREIGN KEY(ImportacionLayoutId) REFERENCES EPT_ImportacionLayout (Id)
)