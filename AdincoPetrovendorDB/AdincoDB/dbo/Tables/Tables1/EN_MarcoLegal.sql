CREATE TABLE [dbo].[EN_MarcoLegal] (
    [IdMarcoLegal]     INT            IDENTITY (10000, 1) NOT NULL,
    [MarcoLegal]       VARCHAR (8000) NULL,
    [IsInterno]        BIT            NULL,
    [CreadoPor]        INT            NULL,
    [ModificadoPor]    INT            NULL,
    [CreadoEn]         DATETIME       NULL,
    [ModificadoEn]     DATETIME       NULL,
    [Activo]           BIT            NULL,
    [BitJOA]           BIT            NULL,
    [MarcoLegalIngles] VARCHAR (8000) NULL,
    [Alias]            VARCHAR (1000) NULL,
    CONSTRAINT [PK_EN_MarcoLegal] PRIMARY KEY CLUSTERED ([IdMarcoLegal] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_MarcoLegal_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [fk_MarcoLegal_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE NONCLUSTERED INDEX [IX_EN_MarcoLegal]
    ON [dbo].[EN_MarcoLegal]([IdMarcoLegal] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

