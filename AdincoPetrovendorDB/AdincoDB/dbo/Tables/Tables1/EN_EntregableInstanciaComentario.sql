CREATE TABLE [dbo].[EN_EntregableInstanciaComentario] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [EntregableInstanciaId] INT            NULL,
    [Comentario]            NVARCHAR (MAX) NULL,
    [UsuarioId]             INT            NULL,
    [CreadoEl]              DATETIME       NULL,
    [Activo]                BIT            NULL,
    [ContratoId]            INT            NULL,
    CONSTRAINT [PK_EN_EntregableInstanciaComentario] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_EntregableInstanciaComentario_AP_Usuario] FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_EntregableInstanciaComentario_CO_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_EN_EntregableInstanciaComentario_EN_InstanciasEntregable] FOREIGN KEY ([EntregableInstanciaId]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable])
);

