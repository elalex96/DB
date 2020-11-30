CREATE TABLE [dbo].[DG_Grafica] (
    [Id_Grafica]     INT            IDENTITY (1, 1) NOT NULL,
    [id_TipoGrafica] INT            NULL,
    [Titulo]         NVARCHAR (200) NULL,
    [Subtitulo]      NVARCHAR (200) NULL,
    [Titulo_yAxis]   NVARCHAR (200) NULL,
    [Titulo_xAxis]   NVARCHAR (200) NULL,
    [Descripcion]    NVARCHAR (250) NULL,
    [ViewDistance]   INT            NULL,
    [Depth]          INT            NULL,
    [Title]          NVARCHAR (200) NULL,
    [Subtitle]       NVARCHAR (200) NULL,
    [Title_yAxis]    NVARCHAR (200) NULL,
    [Title_xAxis]    NVARCHAR (200) NULL,
    [Periodo]        BIT            NULL
);

