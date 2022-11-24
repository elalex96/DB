CREATE TABLE [dbo].[MM_DocAnexosPeticionOferta] (
    [IdDocAnexoPeticionOferta] INT            IDENTITY (1, 1) NOT NULL,
    [IdPeticionOferta]         INT            NOT NULL,
    [Documento]                NVARCHAR (MAX) NOT NULL,
    [NomDocumento]             NVARCHAR (MAX) NOT NULL,
    [SubidoPor]                INT            NOT NULL,
    [SubidoEl]                 SMALLDATETIME  NOT NULL,
    [Comentario]               VARCHAR (1500) NULL,
    [Eliminado]                BIT            NOT NULL,
    [Carpeta]                  NVARCHAR (300) NULL,
    [Identificador]            NVARCHAR (300) NULL,
    [Extension]                NVARCHAR (300) NULL,
    [Mime]                     NVARCHAR (300) NULL,
    [AMS3]                     BIT            NULL,
    [EliminadoEl]              DATETIME       NULL,
    [Bucket]                   VARCHAR (200)  NULL,
    CONSTRAINT [PK_MM_DocAnexosPeticionOferta] PRIMARY KEY CLUSTERED ([IdDocAnexoPeticionOferta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_DocAnexosPeticionOferta_MM_PeticionOferta1] FOREIGN KEY ([IdPeticionOferta]) REFERENCES [dbo].[MM_PeticionOferta] ([IdPeticionOferta]),
    CONSTRAINT [FK_MM_DocAnexosPeticionOferta_S_Usuario1] FOREIGN KEY ([SubidoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

