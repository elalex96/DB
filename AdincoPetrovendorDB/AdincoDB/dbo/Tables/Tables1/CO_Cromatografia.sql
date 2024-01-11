CREATE TABLE [dbo].[CO_Cromatografia] (
    [IdCromatografia] INT      NOT NULL,
    [IdContrato]      INT      NOT NULL,
    [Anio]            SMALLINT NOT NULL,
    [Mes]             TINYINT  NOT NULL,
    [IdArchivoGas]      INT NULL,
    [IdArchivoPetroleo] INT NULL,
    [CreadoEl]        DATETIME NOT NULL,
    [CreadoPor]       INT      NOT NULL,
    [ModificadoEl]    DATETIME NULL,
    [ModificadoPor]   INT      NULL,
    CONSTRAINT [PK_CO_Cromatografia] PRIMARY KEY CLUSTERED ([IdCromatografia] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Cromatografia_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_Cromatografia_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT FK_CO_Cromatografia_CO_CromatografiaArchivo_Gas FOREIGN KEY (IdArchivoGas) REFERENCES CO_CromatografiaArchivo (Id),
    CONSTRAINT FK_CO_Cromatografia_CO_CromatografiaArchivo_Petroleo FOREIGN KEY (IdArchivoPetroleo) REFERENCES CO_CromatografiaArchivo (Id)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_Cromatografia]
    ON [dbo].[CO_Cromatografia]([Anio] ASC, [Mes] ASC, [IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

