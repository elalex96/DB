CREATE TABLE [dbo].[CO_Cromatografia] (
    [IdCromatografia] INT      NOT NULL,
    [IdContrato]      INT      NOT NULL,
    [Anio]            SMALLINT NOT NULL,
    [Mes]             TINYINT  NOT NULL,
    [CreadoEl]        DATETIME NOT NULL,
    [CreadoPor]       INT      NOT NULL,
    [ModificadoEl]    DATETIME NULL,
    [ModificadoPor]   INT      NULL,
    CONSTRAINT [PK_CO_Cromatografia] PRIMARY KEY CLUSTERED ([IdCromatografia] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Cromatografia_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_Cromatografia_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_Cromatografia]
    ON [dbo].[CO_Cromatografia]([Anio] ASC, [Mes] ASC, [IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

