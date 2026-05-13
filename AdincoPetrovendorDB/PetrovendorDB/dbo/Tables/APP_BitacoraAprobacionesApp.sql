CREATE TABLE [dbo].[APP_BitacoraAprobacionesApp] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [IdTarea]      INT            NULL,
    [IdTipoPedido] INT            NULL,
    [IdEstatus]    INT            NULL,
    [Fecha]        DATETIME       NULL,
    [App]          NVARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

