
CREATE TABLE CON_ContratistaPreferencias(
Id	int identity (1,1),
ContratistaId	int,
PreferenciaId	int,
Valor	varchar(5000),
[CreadoPor]     INT           NULL,
[CreadoEl]      DATETIME      NULL,
[ModificadoPor] INT           NULL,
[ModificadoEl]  DATETIME      NULL,
Constraint  PK_CON_ContratistaPreferencias primary key(Id),
Constraint  FK_CON_Contratista_ContratistaPreferencias foreign key (ContratistaId) REFERENCES CO_Contratista (IdContratista),
Constraint  FK_CON_Preferencia_ContratistaPreferencias foreign key (PreferenciaId) REFERENCES APP_Preferencias (Id), 
CONSTRAINT [FK_CON_ContratistaPreferencias_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
CONSTRAINT [FK_CON_ContratistaPreferencias_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]) 
)