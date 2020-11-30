CREATE TABLE [dbo].[FI_DocumentoSoporte] (
    [DocumentoSoporteId] INT              NOT NULL,
    [IdContrato]         INT              NULL,
    [Bucket]             NVARCHAR (MAX)   NULL,
    [Folder]             NVARCHAR (MAX)   NULL,
    [UUIDAmazon]         UNIQUEIDENTIFIER NULL,
    [NombreArchivo]      NVARCHAR (MAX)   NULL,
    [Meta]               NVARCHAR (MAX)   NULL,
    [CreadoPor]          INT              NULL,
    [CreadoEl]           DATETIME         NULL,
    [ModificadoPor]      INT              NULL,
    [ModificadoEl]       DATETIME         NULL,
    [Activo]             BIT              NULL,
    CONSTRAINT [PK__FI_Docum__028D40042E6574D7] PRIMARY KEY CLUSTERED ([DocumentoSoporteId] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__FI_Docume__Activ__3C630754] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

