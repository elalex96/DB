CREATE TABLE [dbo].[DR_ArchivosEnvioDropbox] (
    [IdArchivoEnvio]  INT           IDENTITY (1, 1) NOT NULL,
    [Identificador]   VARCHAR (200) NULL,
    [Mime]            VARCHAR (100) NULL,
    [Extension]       VARCHAR (10)  NULL,
    [NombreDocumento] VARCHAR (500) NULL,
    [Bucket]          VARCHAR (100) NULL,
    [Folder]          VARCHAR (MAX) NULL,
    [Size]            FLOAT (53)    NULL,
    [AprobadoEl]      DATETIME      NULL,
    [Archivo]         IMAGE         NULL,
    [IsFactura]       BIT           NULL,
    [IsSoporte]       BIT           NULL,
    [RutaDestino]     VARCHAR (MAX) NULL,
    [Cargado]         BIT           NULL,
    [CargadoEl]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdArchivoEnvio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

