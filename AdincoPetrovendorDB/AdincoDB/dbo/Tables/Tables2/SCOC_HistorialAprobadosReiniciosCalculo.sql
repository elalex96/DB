CREATE TABLE [dbo].[SCOC_HistorialAprobadosReiniciosCalculo] (
    [idHistorialCalculo] INT            IDENTITY (10000, 1) NOT NULL,
    [idContrato]         INT            NULL,
    [MesReporte]         DATE           NULL,
    [Accion]             VARCHAR (100)  NULL,
    [Comentarios]        NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEn]           DATETIME       NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEn]       DATETIME       NULL,
    CONSTRAINT [PK_SCOC_HistorialAprobadosReiniciosCalculo] PRIMARY KEY CLUSTERED ([idHistorialCalculo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_HistorialAprobadoReinicio_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_HistorialAprobadoReinicio_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_HistorialAprobadoReinicio_CO_Contrato] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

