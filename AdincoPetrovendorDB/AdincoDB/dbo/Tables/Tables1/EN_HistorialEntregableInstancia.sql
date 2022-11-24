CREATE TABLE [dbo].[EN_HistorialEntregableInstancia] (
    [IdHistorialEntregableIns] INT            IDENTITY (10000, 1) NOT NULL,
    [idInstanciaEntregable]    INT            NULL,
    [UsuarioElabora]           INT            NULL,
    [UsuarioRevisa]            INT            NULL,
    [UsuarioAprueba]           INT            NULL,
    [idTransicion]             INT            NULL,
    [FechaHistorial]           DATE           NULL,
    [Comentario]               NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdHistorialEntregableIns] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([idInstanciaEntregable]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable]),
    FOREIGN KEY ([idTransicion]) REFERENCES [dbo].[EN_TransicionEstatus] ([IdTransicion])
);

