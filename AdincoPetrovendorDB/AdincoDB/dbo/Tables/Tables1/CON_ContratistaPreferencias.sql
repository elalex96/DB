
CREATE TABLE CON_ContratistaPreferencias(
Id	int identity (1,1),
ContratistaId	int,
PreferenciaId	int,
Valor	varchar(1000)
Constraint  PK_CON_ContratistaPreferencias primary key(Id),
Constraint  FK_CON_Contratista_ContratistaPreferencias foreign key (ContratistaId) REFERENCES CO_Contratista (IdContratista),
Constraint  FK_CON_Preferencia_ContratistaPreferencias foreign key (PreferenciaId) 
REFERENCES APP_Preferencias (Id)
)