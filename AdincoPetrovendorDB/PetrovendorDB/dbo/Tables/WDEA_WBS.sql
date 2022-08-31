CREATE TABLE WDEA_WBS
(
	Id int primary key not null identity(1,1),
	WBS varchar(300),
	CreadoEl datetime,
	ModificadoEl datetime,
	CreadoPor int,
	ModificadoPor int,
	IdContrato int,
	Activo bit
)
