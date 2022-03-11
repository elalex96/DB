CREATE TABLE [dbo].[EN_DocumentosSASISOPA_Relacion]
(
	Id int primary key not null identity(1,1),
	IdBitacoraReporte int not null,
	IdDocumento int not null,
	NombreDocumento varchar(1000) null,
	FOREIGN KEY (IdBitacoraReporte) REFERENCES EN_Documentos_BitacoraReporteSASISOPA(Id),
	FOREIGN KEY (IdDocumento) REFERENCES AWS_Documentos(AWSDocumentoId)
)
