CREATE TABLE [dbo].[RE_Documentos] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [Identificador]   UNIQUEIDENTIFIER NOT NULL,
    [Icon]            NVARCHAR (MAX)   NULL,
    [Nombre]          NVARCHAR (MAX)   NULL,
    [Extension]       NVARCHAR (MAX)   NULL,
    [Mime]            NVARCHAR (MAX)   NULL,
    [FechaCreacion]   DATETIME         NOT NULL,
    [SizeMB]          DECIMAL (18, 2)  NOT NULL,
    [EsVersion]       BIT              NOT NULL,
    [CreadoPor]       INT              NOT NULL,
    [TipoDocumentoId] INT              NOT NULL,
    [RequerimientoId] INT              NOT NULL,
    [Version]         INT              NULL,
    CONSTRAINT [PK_RE_Documentos] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

