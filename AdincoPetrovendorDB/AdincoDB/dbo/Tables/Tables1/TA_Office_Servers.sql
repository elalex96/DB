  CREATE TABLE TA_Office_Servers(
		Id	int IDENTITY(1,1),
		Descripcion	varchar(300),
		Client_Id	varchar(300),
		Client_Secret varchar(300),
		Tenant	varchar(300),
		OfficeUser varchar(300),
		Server	varchar(300),
		LoginUri	varchar(300),
		TokenUri	varchar(300),
		IdContratista	int
		CONSTRAINT PK_Office_Servers PRIMARY KEY (Id)
		CONSTRAINT FK_TA_Office_Servers_CO_Contratista FOREIGN KEY(IdContratista) REFERENCES CO_Contratista (IdContratista)
		);