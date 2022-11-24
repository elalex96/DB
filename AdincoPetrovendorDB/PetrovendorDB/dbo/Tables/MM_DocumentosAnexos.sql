CREATE TABLE [dbo].[MM_DocumentosAnexos] (
    [IdDocumentoAnexo]        INT            IDENTITY (1, 1) NOT NULL,
    [IdPeticionOferta]        INT            NOT NULL,
    [IdPeticionOfertaDetalle] INT            NOT NULL,
    [Documento]               NVARCHAR (MAX) NOT NULL,
    [Nombre]                  VARCHAR (MAX)  NULL,
    [Carpeta]                 NVARCHAR (300) NULL,
    [Identificador]           NVARCHAR (300) NULL,
    [Extension]               NVARCHAR (300) NULL,
    [Mime]                    NVARCHAR (300) NULL,
    [AMS3]                    BIT            NULL,
    [Activo]                  BIT            NULL,
    [CreadoEl]                DATETIME       NULL,
    [EliminadoEl]             DATETIME       NULL,
    [CreadoPor]               INT            NULL,
    [ModificadoPor]           INT            NULL,
    [ModificadoEl]            DATETIME       NULL,
    [Bucket]                  VARCHAR (50)   NULL,
    CONSTRAINT [PK_MM_DocumentosAnexos] PRIMARY KEY CLUSTERED ([IdDocumentoAnexo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_DocumentosAnexos_MM_PeticionOferta] FOREIGN KEY ([IdPeticionOferta]) REFERENCES [dbo].[MM_PeticionOferta] ([IdPeticionOferta]),
    CONSTRAINT [FK_MM_DocumentosAnexos_MM_PeticionOfertaDetalle] FOREIGN KEY ([IdPeticionOfertaDetalle]) REFERENCES [dbo].[MM_PeticionOfertaDetalle] ([IdPeticionOfertaDetalle])
);

