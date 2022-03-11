CREATE TABLE EN_Documentos_BitacoraReporteSASISOPA
(
	Id int primary key not null identity(1,1),
	IdUsuario int not null,
	IdContrato int not null,
	FechaInicial datetime not null,
	FechaFinal datetime not null,
	Procesado bit,
	FechaCreacion datetime,
	FechaModificacion datetime,
	ModificadoPor int null,
	Server varchar(300),
	FOREIGN KEY (IdUsuario) REFERENCES AP_Usuario(UsuarioId),
	FOREIGN KEY (IdContrato) REFERENCES CO_Contrato(IdContrato),
	FOREIGN KEY (ModificadoPor) REFERENCES AP_Usuario(UsuarioId)
)