CREATE TABLE [dbo].[ENT_BitacoraArchivos]
(
	Id Int primary key not null identity (1,1),
	ModuloId int,
	Fecha datetime,
	Ruta varchar(300),
	Archivo varchar(500),
	AWSArchivoId int,
	AWSIdentificador varchar(max) NOT NULL,	
	UsuarioId int,
	IdContrato int,
	Accion varchar(300),
	FOREIGN KEY (UsuarioId) REFERENCES AP_Usuario(UsuarioId),
	FOREIGN KEY (IdContrato) REFERENCES CO_Contrato(IdContrato)
)
