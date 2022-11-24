CREATE TABLE [dbo].[EN_CF_SolicitUDescargaCarpetas] (
    [IdSolicitud]    INT             IDENTITY (1, 1) NOT NULL,
    [SolicitadoPor]  INT             NULL,
    [SolicitadoEl]   DATETIME        NULL,
    [ContratoId]     INT             NULL,
    [RutaDescargada] NVARCHAR (MAX)  NULL,
    [Procesado]      INT             NULL,
    [UltimaDescarga] DATETIME        NULL,
    [Bucket]         NVARCHAR (1000) NULL,
    [Folder]         NVARCHAR (1000) NULL,
    [UUIDAmazon]     NVARCHAR (1000) NULL,
    [NombreArchivo]  NVARCHAR (1000) NULL,
    [Size]           FLOAT (53)      NULL,
    [Meta]           NVARCHAR (1000) NULL,
    [FechaProcesado] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdSolicitud] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

