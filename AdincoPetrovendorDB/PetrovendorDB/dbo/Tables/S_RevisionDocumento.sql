CREATE TABLE [dbo].[S_RevisionDocumento] (
    [idRevision]         INT            IDENTITY (1, 1) NOT NULL,
    [idDocumento]        INT            NOT NULL,
    [idUsuarioAprovador] INT            NOT NULL,
    [AutorizadoEl]       SMALLDATETIME  NOT NULL,
    [Comentario]         NVARCHAR (MAX) NULL,
    [EstatusAnterior]    INT            NULL,
    [DocumentoAnterior]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_S_RevisionDocumento] PRIMARY KEY CLUSTERED ([idRevision] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_RevisionDocumento_S_Documento] FOREIGN KEY ([idDocumento]) REFERENCES [dbo].[S_Documento] ([IdDocumento]),
    CONSTRAINT [FK_S_RevisionDocumento_S_TipoValidacionDoc] FOREIGN KEY ([EstatusAnterior]) REFERENCES [dbo].[S_TipoValidacionDoc] ([IdTipoValidacionDoc]),
    CONSTRAINT [FK_S_RevisionDocumento_S_Usuario] FOREIGN KEY ([idUsuarioAprovador]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

