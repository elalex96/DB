CREATE TABLE [dbo].[En_Clasificacion] (
    [IdClasificacion]     INT           IDENTITY (10000, 1) NOT NULL,
    [NombreClasificacion] VARCHAR (500) NULL,
    [CreadoEl]            DATE          NULL,
    [CreadoPor]           INT           NULL,
    [ModificadoEl]        DATE          NULL,
    [ModificadoPor]       INT           NULL,
    [activo]              BIT           NULL,
    [BitJOA]              BIT           NULL,
    CONSTRAINT [PK_IdClasificacion] PRIMARY KEY CLUSTERED ([IdClasificacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [CreadoEl_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [ModificadoPor_Usuario] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

