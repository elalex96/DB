CREATE TABLE WDEA_WBSLineaPresupuesto
(
	Id int primary key not null identity(1,1),
	IdWBS int,
	IdLineaPresupuesto int,
	IdContrato int,
	Activo bit,
	CreadoEl datetime,
	ModificadoEl datetime,
	CreadoPor int,
	ModificadoPor int
)
