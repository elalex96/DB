CREATE TABLE [dbo].[OT_SolicitudBitacoraTipo] (
    [Id]          INT           NOT NULL,
    [Descripcion] VARCHAR (250) NOT NULL,
    [Activo]      BIT           NOT NULL,
    [CreadoEl]    DATETIME      NOT NULL,
    CONSTRAINT [PK_OT_SolicitudBitacoraTipo] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

