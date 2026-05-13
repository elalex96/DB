CREATE TABLE [dbo].[EPT_ImportacionLayoutDetallePresupuestos] (
    [Id]                         INT           IDENTITY (1, 1) NOT NULL,
    [ImportacionLayoutDetalleId] INT           NOT NULL,
    [DocumentoFacturacionId]     INT           NOT NULL,
    [Presupuesto]                VARCHAR (100) NOT NULL,
    [PresupuestoId]              INT           NOT NULL,
    [Activo]                     BIT           NOT NULL,
    [CreadoEn]                   DATETIME      NOT NULL,
    [CreadoPor]                  INT           NOT NULL,
    [ModificadoEn]               DATETIME      NULL,
    [ModificadoPor]              INT           NULL,
    CONSTRAINT [PK_EPT_ImportacionLayoutDetallePresupuestos] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_CO_Presupuesto] FOREIGN KEY ([PresupuestoId]) REFERENCES [dbo].[CO_Presupuesto] ([IdPresupuesto]),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_Creador] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_EPT_ImportacionLayoutDetalle] FOREIGN KEY ([ImportacionLayoutDetalleId]) REFERENCES [dbo].[EPT_ImportacionLayoutDetalle] ([Id]),
    CONSTRAINT [FK_EPT_ImportacionLayoutDetallePresupuestos_Modificador] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

