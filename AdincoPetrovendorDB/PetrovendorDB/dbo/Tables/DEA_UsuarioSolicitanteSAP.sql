CREATE TABLE [dbo].[DEA_UsuarioSolicitanteSAP] (
    [IdUsuarioSolicitanteSAP] INT            IDENTITY (10000, 1) NOT NULL,
    [IdUsuario]               INT            NULL,
    [DescripcionSAP]          NVARCHAR (MAX) NULL,
    [CreadoEn]                DATETIME       NULL,
    [CreadoPor]               INT            NULL,
    [IdContratista]           INT            NULL,
    [IsEliminado]             BIT            NULL,
    [ModificadoEn]            DATETIME       NULL,
    [ModificadoPor]           INT            NULL,
    CONSTRAINT [PK_DEA_UsuarioSolicitanteSAP] PRIMARY KEY CLUSTERED ([IdUsuarioSolicitanteSAP] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DEA_UsuarioSolicitanteSAP_S_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

