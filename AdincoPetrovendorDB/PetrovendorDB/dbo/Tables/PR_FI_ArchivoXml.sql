CREATE TABLE [dbo].[PR_FI_ArchivoXml] (
    [IdArchivoXml]  INT            IDENTITY (10000, 1) NOT NULL,
    [ArchivoXml]    IMAGE          NULL,
    [HashSHA256]    NVARCHAR (MAX) NULL,
    [IdFactura]     INT            NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    [IdEliminacion] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdArchivoXml] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

