CREATE TABLE [dbo].[EN_InstanciasProcesosFecha] (
    [IdInstanciasProcesos] INT            IDENTITY (10000, 1) NOT NULL,
    [IdProceso]            INT            NULL,
    [Descripcion]          NVARCHAR (MAX) NULL,
    [Fecha]                DATE           NULL,
    [FechaInicial]         BIT            NULL,
    [idContrato]           INT            NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [ModificadoPor]        INT            NULL,
    [ModificadoEl]         DATETIME       NULL,
    [Activo]               BIT            NULL,
    [FechaInicioProceso]   DATE           NULL,
    [FechaFinProceso]      DATE           NULL,
    [NoRecalculo]          BIT            NULL,
    CONSTRAINT [PK_InstanciasProcesos] PRIMARY KEY CLUSTERED ([IdInstanciasProcesos] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ContratoInstanciasProcesosFechas] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_InstanciasProcesos_Procesos] FOREIGN KEY ([IdProceso]) REFERENCES [dbo].[EN_Procesos] ([IdProceso]),
    CONSTRAINT [FK_InstanciasProcesos_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_InstanciasProcesos_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE NONCLUSTERED INDEX [IX_EN_InstanciasProcesosFecha]
    ON [dbo].[EN_InstanciasProcesosFecha]([IdInstanciasProcesos] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

