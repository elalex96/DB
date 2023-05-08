CREATE TABLE [dbo].[WS_URLsMetodos] (
    [IdUrlsMetodos] INT             IDENTITY (1, 1) NOT NULL,
    [Descripcion]   NVARCHAR (1500) NULL,
    [URL]           NVARCHAR (1500) NULL,
    [Activo]        BIT             NOT NULL
);

