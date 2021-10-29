CREATE TABLE [dbo].[Carso_Comparativa_Destinatarios]
(
	id int primary key not null identity(1,1),
	Idusuario int,
	Activo bit,
	CreadoEl datetime,
	ModificadoEl datetime,
	CreadoPor int,
	ModificadoPor int
)
