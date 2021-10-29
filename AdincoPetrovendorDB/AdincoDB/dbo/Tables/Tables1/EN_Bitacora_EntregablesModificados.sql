CREATE TABLE [dbo].[EN_Bitacora_EntregablesModificados]
(
		Id int primary key not null identity(1,1),
		IdContrato int not null,
		IdEntregable int not null,
		IdArea int null,
		ElaboradorAnterior int,
		RevisorAnterior int,
		AprobadorAnterior int,
		Activo bit,
		ModificadoPor int not null,
		ModificadoEl datetime
)
