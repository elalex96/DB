CREATE TABLE [dbo].[FI_ArchivoXml] (
    [IdArchivoXml]  INT            IDENTITY (10000, 1) NOT NULL,
    [ArchivoXml]    IMAGE          NULL,
    [HashSHA256]    NVARCHAR (600) NULL,
    [IdFactura]     INT            NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    PRIMARY KEY CLUSTERED ([IdArchivoXml] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

