CREATE TABLE [dbo].[SC_ServicioOT] (
    [IdServicioOT]  INT           IDENTITY (10000, 1) NOT NULL,
    [Descripcion]   VARCHAR (MAX) NULL,
    [IdUnidad]      INT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEl]  DATETIME      NULL,
    [Activo]        BIT           NULL,
    CONSTRAINT [PK_SC_SERVICIOOT] PRIMARY KEY CLUSTERED ([IdServicioOT] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SC_SERVICIOOT_CO_UNIDAD] FOREIGN KEY ([IdUnidad]) REFERENCES [dbo].[CO_Unidad] ([IdUnidad])
);

