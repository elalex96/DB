CREATE TABLE [dbo].[EN_Area] (
    [idArea]        INT           IDENTITY (10000, 1) NOT NULL,
    [NombreArea]    VARCHAR (500) NULL,
    [idContrato]    INT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEn]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEn]  DATETIME      NULL,
    [Activo]        BIT           NULL,
    CONSTRAINT [PK_EN_Area] PRIMARY KEY CLUSTERED ([idArea] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Area_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Area_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [indiceEN_Area]
    ON [dbo].[EN_Area]([NombreArea] ASC, [idContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

go

create index IX_EN_Area					on	EN_Area(idArea)