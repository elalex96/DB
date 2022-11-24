CREATE TABLE [dbo].[PV_ImagenPredeterminada] (
    [IdImagenPredeterminada] INT             IDENTITY (1, 1) NOT NULL,
    [ImagenText]             NVARCHAR (MAX)  NULL,
    [ImagenBinary]           VARBINARY (MAX) NULL,
    [Detalle]                NVARCHAR (MAX)  NULL,
    [FechaAlta]              DATETIME        NULL,
    [Imagen]                 IMAGE           NULL,
    [ImagenThumb]            IMAGE           NULL,
    [CreadoPor]              INT             NULL,
    [EditadaPor]             INT             NULL,
    [EditadaEl]              DATETIME        NULL,
    CONSTRAINT [PK_PV_ImagenPredeterminada] PRIMARY KEY CLUSTERED ([IdImagenPredeterminada] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

