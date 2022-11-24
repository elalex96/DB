CREATE TABLE [dbo].[EN_Sanciones] (
    [IdSancion]      INT            IDENTITY (10000, 1) NOT NULL,
    [IdMarcoLegal]   INT            NULL,
    [IdSancionador]  INT            NULL,
    [Articulo]       VARCHAR (6000) NULL,
    [Titulo]         VARCHAR (6000) NULL,
    [Capitulo]       VARCHAR (6000) NULL,
    [TipoInfraccion] VARCHAR (6000) NULL,
    [VSM_Minimo]     INT            NULL,
    [VSM_Maximo]     INT            NULL,
    [Activo]         BIT            NULL,
    [CreadoPor]      INT            NULL,
    [CreadoEn]       DATETIME       NULL,
    [ModificadoPor]  INT            NULL,
    [ModificadoEn]   DATETIME       NULL,
    [Sancion]        VARCHAR (8000) NULL,
    CONSTRAINT [PK_EN_Sanciones] PRIMARY KEY CLUSTERED ([IdSancion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Sanciones_EN_MarcoLegal] FOREIGN KEY ([IdMarcoLegal]) REFERENCES [dbo].[EN_MarcoLegal] ([IdMarcoLegal]),
    CONSTRAINT [FK_EN_Sanciones_EN_Sancionador] FOREIGN KEY ([IdSancionador]) REFERENCES [dbo].[EN_Sancionador] ([IdSancionador])
);

