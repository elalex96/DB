CREATE TABLE [dbo].[MPY_MM_AceptacionFactura_Bitacora] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionFactura] INT            NOT NULL,
    [IdEstatus]           INT            NOT NULL,
    [CreadoPor]           INT            NULL,
    [IdEstatusXML]        INT            NULL,
    [IdEstatusPDF]        INT            NULL,
    [CreadoEl]            DATETIME       NULL,
    [IdAprobadorRechazo]  INT            NULL,
    [Comentario]          NVARCHAR (MAX) NULL,
    [IdAprobador]         INT            NULL,
    [FechaAprobacion]     DATETIME       NULL,
    CONSTRAINT [PK_MPY_MM_AceptacionFactura_Bitacora] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MPY_MM_AceptacionFactura_Bitacora_MPY_MM_AceptacionFactura] FOREIGN KEY ([IdAceptacionFactura]) REFERENCES [dbo].[MPY_MM_AceptacionFactura] ([IdAceptacionFactura]),
    CONSTRAINT [FK_MPY_MM_AceptacionFactura_BitacoraMM_AceptacionPedido] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[S_TipoValidacionDoc] ([IdTipoValidacionDoc]),
    CONSTRAINT [FK_MPY_MM_AceptacionFactura_BitacoraS_TipoValidacionDoc] FOREIGN KEY ([IdEstatusPDF]) REFERENCES [dbo].[S_TipoValidacionDoc] ([IdTipoValidacionDoc]),
    CONSTRAINT [FK_MPY_MM_AceptacionFactura_BitacoraS_TipoValidacionDoc1] FOREIGN KEY ([IdEstatusXML]) REFERENCES [dbo].[S_TipoValidacionDoc] ([IdTipoValidacionDoc]),
    CONSTRAINT [FK_MPY_MM_AceptacionFactura_BitacoraS_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

