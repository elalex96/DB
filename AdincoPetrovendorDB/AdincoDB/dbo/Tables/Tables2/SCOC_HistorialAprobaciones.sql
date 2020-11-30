CREATE TABLE [dbo].[SCOC_HistorialAprobaciones] (
    [IdAprobacion] INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]   INT            NULL,
    [MesReporte]   DATE           NULL,
    [IdPermiso]    INT            NULL,
    [UsuarioID]    INT            NULL,
    [Comentarios]  VARCHAR (2000) NULL,
    [FecMovto]     DATETIME       NULL,
    [Rechazado]    BIT            NULL,
    CONSTRAINT [PK_SCOC_HistorialAprobaciones] PRIMARY KEY CLUSTERED ([IdAprobacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_HistorialAprobaciones_AP_Permiso] FOREIGN KEY ([IdPermiso]) REFERENCES [dbo].[AP_Permiso] ([IdPermiso]),
    CONSTRAINT [FK_SCOC_HistorialAprobaciones_AP_Usuario] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_HistorialAprobaciones_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

