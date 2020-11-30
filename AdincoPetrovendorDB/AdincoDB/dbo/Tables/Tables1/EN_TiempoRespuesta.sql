CREATE TABLE [dbo].[EN_TiempoRespuesta] (
    [IdTiempoRespuesta] INT            IDENTITY (10000, 1) NOT NULL,
    [TiempoRespuesta]   VARCHAR (6000) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEn]          DATETIME       NULL,
    CONSTRAINT [PK_EN_TiempoRespuesta] PRIMARY KEY CLUSTERED ([IdTiempoRespuesta] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

