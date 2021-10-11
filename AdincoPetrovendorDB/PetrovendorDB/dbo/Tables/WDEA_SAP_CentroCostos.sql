CREATE TABLE [dbo].[WDEA_SAP_CentroCostos]
(
	Id int primary key not null identity(1,1),
	IdCentroCostosADINCO int,
	AcronimoSAP varchar(300),
	WBS_Element varchar(300),
	IdContrato int,
	IdProveedor int,
	Activo bit,
	CreadoEl datetime,
	ModificadoEl datetime,
	CreadoPor int,
	ModificadoPor int
)
