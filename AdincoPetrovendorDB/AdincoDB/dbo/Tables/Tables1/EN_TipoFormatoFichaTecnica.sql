CREATE TABLE [dbo].[EN_TipoFormatoFichaTecnica] (
    [idTipoFormatoFichaTecnica]     INT           IDENTITY (10000, 1) NOT NULL,
    [NombreTipoFormatoFichaTecnica] VARCHAR (300) NULL,
    [CreadoPor]                     INT           NULL,
    [CreadoEl]                      DATETIME      NULL,
    [ModificadoPor]                 INT           NULL,
    [ModificadoEl]                  DATETIME      NULL,
    [Activo]                        BIT           NULL,
    CONSTRAINT [PK_EN_TipoFormatoFichaTecnica] PRIMARY KEY CLUSTERED ([idTipoFormatoFichaTecnica] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [CreadoPor_EN_TipoFormatoFichaTecnica] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [Modificado_EN_TipoFormatoFichaTecnica] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

