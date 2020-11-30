CREATE TABLE [dbo].[OF_DocAdjuntosXOficio] (
    [IdDocAdjuntosXOficio] INT              IDENTITY (1, 1) NOT NULL,
    [IdDocumentoOficio]    INT              NOT NULL,
    [Bucket]               NVARCHAR (MAX)   NULL,
    [Folder]               NVARCHAR (MAX)   NULL,
    [UUIDAmazon]           UNIQUEIDENTIFIER NULL,
    [Meta]                 NVARCHAR (MAX)   NULL,
    [Comentario]           VARCHAR (1500)   NULL,
    [NomDocumento]         NVARCHAR (MAX)   NULL,
    [Eliminado]            BIT              NOT NULL,
    CONSTRAINT [PK_OF_DocAdjuntosXOficio] PRIMARY KEY CLUSTERED ([IdDocAdjuntosXOficio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

