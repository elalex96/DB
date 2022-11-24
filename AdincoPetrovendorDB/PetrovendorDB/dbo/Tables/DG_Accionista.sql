CREATE TABLE [dbo].[DG_Accionista] (
    [IdAccionista]            INT            IDENTITY (1, 1) NOT NULL,
    [APaterno]                NVARCHAR (50)  NOT NULL,
    [AMaterno]                NVARCHAR (50)  NULL,
    [Nombre]                  NVARCHAR (50)  NULL,
    [PorcentajePart]          FLOAT (53)     NULL,
    [DescripcionObjetoSocial] NVARCHAR (150) NULL,
    [FechaRPC]                DATE           NULL,
    [DatosInscripcionRPC]     NVARCHAR (MAX) NULL,
    [IdProveedor]             INT            NULL,
    [IsEliminado]             BIT            NULL,
    [IsActivo]                BIT            NULL,
    [CreadoPor]               INT            NULL,
    [CreadoEn]                DATETIME       NULL,
    [ModificadoPor]           INT            NULL,
    [ModificadoEn]            DATETIME       NULL,
    [RFC]                     NVARCHAR (100) NULL,
    [CIF]                     NVARCHAR (100) NULL,
    CONSTRAINT [PK_DG_Accionista] PRIMARY KEY CLUSTERED ([IdAccionista] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DG_Accionista_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_DG_Accionista_S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario]),
    CONSTRAINT [FK_DG_Accionista_S_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

