CREATE TABLE [dbo].[AA_ReportesCargados] (
    [IdReporteCargado] INT            IDENTITY (10000, 1) NOT NULL,
    [IdTipoReporte]    INT            NULL,
    [NombreArchivo]    NVARCHAR (MAX) NULL,
    [FechaReporte]     DATE           NULL,
    [ReporteArchivo]   IMAGE          NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEn]         DATETIME       NULL,
    [IdContrato]       INT            NULL,
    CONSTRAINT [PK_AA_ReportesCargados] PRIMARY KEY CLUSTERED ([IdReporteCargado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AA_ReportesCargados_AA_TipoReporte] FOREIGN KEY ([IdTipoReporte]) REFERENCES [dbo].[AA_TipoReporte] ([IdTipoReporte]),
    CONSTRAINT [FK_AA_ReportesCargados_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AA_ReportesCargados_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

