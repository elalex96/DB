CREATE TABLE [dbo].[MPY_DocumentosPRESES] (
    [IdDocumento]     INT            IDENTITY (1, 1) NOT NULL,
    [IdPRESES]        INT            NULL,
    [IdTipoDocumento] INT            NULL,
    [NombreDoc]       VARCHAR (100)  NULL,
    [Carpeta]         NVARCHAR (300) NULL,
    [Identificador]   NVARCHAR (300) NULL,
    [Extension]       NVARCHAR (300) NULL,
    [Mime]            NVARCHAR (300) NULL,
    [Activo]          BIT            NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [ModificadoPor]   INT            NULL,
    [ModificadoEl]    DATETIME       NULL,
    [Bucket]          VARCHAR (50)   NULL,
    CONSTRAINT [PK_MPY_DocumentosPRESES] PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

