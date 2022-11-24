CREATE TABLE [dbo].[OF_DocumentoOficio] (
    [IdDocumentoOficio]  INT              IDENTITY (1, 1) NOT NULL,
    [IdTipoOficio]       INT              NOT NULL,
    [IdEntidad]          INT              NOT NULL,
    [IdInstancia]        INT              NULL,
    [IdRemitente]        INT              NULL,
    [NombreRemitente]    NVARCHAR (150)   NULL,
    [IdDestinatario]     INT              NULL,
    [NombreDestinatario] NVARCHAR (150)   NULL,
    [NumDocumento]       NVARCHAR (150)   NULL,
    [Descripcion]        NVARCHAR (1500)  NULL,
    [Activo]             BIT              NOT NULL,
    [IdEstatus]          INT              NULL,
    [Bucket]             NVARCHAR (MAX)   NULL,
    [Folder]             NVARCHAR (MAX)   NULL,
    [UUIAmazon]          UNIQUEIDENTIFIER NULL,
    [Meta]               NVARCHAR (MAX)   NULL,
    [CreadoPor]          INT              NOT NULL,
    [CreadoEl]           DATETIME         NOT NULL,
    [IdContrato]         INT              NULL,
    CONSTRAINT [PK_OF_DocumentoOficio] PRIMARY KEY CLUSTERED ([IdDocumentoOficio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

