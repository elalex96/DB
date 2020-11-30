CREATE TABLE [dbo].[EN_TiempoEntrega] (
    [IdTiempoEntrega] INT            IDENTITY (10000, 1) NOT NULL,
    [TiempoEntrega]   NVARCHAR (MAX) NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEn]        DATETIME       NULL,
    CONSTRAINT [PK_EN_TiempoEntrega] PRIMARY KEY CLUSTERED ([IdTiempoEntrega] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

