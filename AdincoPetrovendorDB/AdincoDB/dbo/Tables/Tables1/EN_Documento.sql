CREATE TABLE [dbo].[EN_Documento] (
    [IdDocumento]          INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]           INT            NULL,
    [FechaDocumento]       DATE           NULL,
    [NoReferencia]         NVARCHAR (100) NULL,
    [NombreDocumento]      NVARCHAR (MAX) NULL,
    [ClvTipo]              INT            NULL,
    [NombreArchivo]        NVARCHAR (MAX) NULL,
    [Extension]            NVARCHAR (MAX) NULL,
    [Archivo]              IMAGE          NULL,
    [IdEntregable]         INT            NULL,
    [IdActividadPetrolera] INT            NULL,
    [IsActivo]             INT            NULL,
    [IsEliminado]          BIT            NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [ModificadoPor]        INT            NULL,
    [ModificadoEl]         DATETIME       NULL,
    CONSTRAINT [PK_Documentos] PRIMARY KEY CLUSTERED ([IdDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

