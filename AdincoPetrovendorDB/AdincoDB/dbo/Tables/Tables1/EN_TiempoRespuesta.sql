CREATE TABLE [dbo].[EN_TiempoRespuesta] (
    [IdTiempoRespuesta] INT            IDENTITY (10000, 1) NOT NULL,
    [TiempoRespuesta]   VARCHAR (6000) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEn]          DATETIME       NULL,
    CONSTRAINT [PK_EN_TiempoRespuesta] PRIMARY KEY CLUSTERED ([IdTiempoRespuesta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

