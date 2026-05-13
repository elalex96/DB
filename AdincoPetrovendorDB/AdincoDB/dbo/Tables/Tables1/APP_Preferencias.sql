CREATE TABLE APP_Preferencias(
Id	int identity (1,1),
Nombre	varchar(1000),
EsDeContratista	bit,
Descripcion	varchar(1000),
RequiereValor	bit,
[CreadoPor]     INT           NULL,
[CreadoEl]      DATETIME      NULL,
[ModificadoPor] INT           NULL,
[ModificadoEl]  DATETIME      NULL,
Constraint  PK_APP_Preferencias primary key(Id),
CONSTRAINT [FK_APP_Preferencias_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
CONSTRAINT [FK_APP_Preferencias_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
)