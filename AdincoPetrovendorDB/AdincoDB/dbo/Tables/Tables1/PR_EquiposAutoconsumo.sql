CREATE TABLE [dbo].[PR_EquiposAutoconsumo] (
    [IdContrato]           INT            NOT NULL,
    [IdEquipo]             INT            IDENTITY (1000, 1) NOT NULL,
    [Fecha]                DATETIME       NULL,
    [UTMX]                 FLOAT (53)     NULL,
    [UTMY]                 FLOAT (53)     NULL,
    [Producto]             VARCHAR (50)   NULL,
    [TipoEquipo]           VARCHAR (250)  NULL,
    [TAG]                  VARCHAR (300)  NULL,
    [FluidoDesplazado]     VARCHAR (300)  NULL,
    [ConsumoTeorico]       FLOAT (53)     NULL,
    [ConsumoReal]          FLOAT (53)     NULL,
    [ConsumoEnergetico]    FLOAT (53)     NULL,
    [DispositivoInyeccion] VARCHAR (1000) NULL,
    [Obervaciones]         VARCHAR (1000) NULL,
    CreadoPor INT,
		CreadoEl DATETIME,
		ModificadoPor INT null,
		ModificadoEl DATETIME null,
		Activo BIT,
	CONSTRAINT PR_EquiposAutoconsumoCreadoPor FOREIGN KEY (CreadoPor)
	REFERENCES AP_Usuario(UsuarioID),
	CONSTRAINT PR_EquiposAutoconsumoModificadoPor FOREIGN KEY (ModificadoPor)
	REFERENCES AP_Usuario(UsuarioID),
    CONSTRAINT [PK_PR_EquiposAutoconsumo] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [IdEquipo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_EquiposAutoconsumo_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

