CREATE TABLE [dbo].[SCOC_ComentariosReportes] (
    [IdContrato]                   INT            NOT NULL,
    [MesReporte]                   DATE           NOT NULL,
    [ProductoNominacionID]         INT            NOT NULL,
    [ObservacionesContratista]     NVARCHAR (MAX) NULL,
    [ObservacionesComercializador] NVARCHAR (MAX) NULL,
    [CreadoPor]                    INT            NULL,
    [CreadoEn]                     DATETIME       NULL,
    [ModificadoPor]                INT            NULL,
    [ModificadoEn]                 DATETIME       NULL,
    CONSTRAINT [PK_SCOC_ComentariosReportes] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [MesReporte] ASC, [ProductoNominacionID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_ComentariosReportes_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_ComentariosReportes_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_ComentariosReportes_CO_ClasificacionProductoNominacion] FOREIGN KEY ([ProductoNominacionID]) REFERENCES [dbo].[CO_ClasificacionProductoNominacion] ([ProductoNominacionID]),
    CONSTRAINT [FK_SCOC_ComentariosReportes_CO_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

