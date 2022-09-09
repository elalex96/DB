CREATE TABLE [dbo].[CO_RegistroMarkup]
(
	[Id]			INT IDENTITY (1, 1) NOT NULL,
	[GastoId]		INT					NULL,
	[Porcentaje]	    FLOAT		NULL,	
	[MontoEquivalente]			FLOAT					NOT NULL,
	[MontoGasto]			FLOAT					NOT NULL,
	[Activo]		BIT                 NOT NULL,
	[CreadoPor]     INT                 NOT NULL,
    [CreadoEn]      DATETIME            NOT NULL,
    [ModificadoPor] INT                 NULL,
    [ModificadoEn]  DATETIME            NULL,
	[ContratoId] INT NULL, 
	[IdEstadoPemex] INT NULL,
    [MesEstadoPemex] DATE NULL,
    CONSTRAINT [PK_CO_RegistroMarkup] PRIMARY KEY CLUSTERED ([Id] ASC),
	CONSTRAINT [FK_CO_RegistroMarkup_CO_Registro] FOREIGN KEY ([GastoId]) REFERENCES [CO_Registro](IdRegistro),
	CONSTRAINT [FK_CO_RegistroMarkup_APP_Usuarios_Crear] FOREIGN KEY ([CreadoPor]) REFERENCES [AP_Usuario]([UsuarioID]),
	CONSTRAINT [FK_CO_RegistroMarkup_APP_Usuarios_Modifica] FOREIGN KEY ([ModificadoPor]) REFERENCES [AP_Usuario]([UsuarioID]),
	CONSTRAINT [FK_CO_RegistroMarkup_CO_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES CO_Contrato([IdContrato])
);