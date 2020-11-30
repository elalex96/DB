CREATE TABLE [dbo].[S_TFACodigos] (
    [IdCodigo]      INT          IDENTITY (1, 1) NOT NULL,
    [Codigo]        NVARCHAR (6) NULL,
    [FechaCreacion] DATE         NULL,
    [UsuarioID]     INT          NOT NULL,
    CONSTRAINT [PK__S_TFACod__0FC2913848AD8FE1] PRIMARY KEY CLUSTERED ([IdCodigo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [Fk_UsuarioIDCodigo] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

