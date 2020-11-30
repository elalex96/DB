CREATE TABLE [dbo].[SCOC_RecoleccionBN] (
    [IdContrato]              INT            NOT NULL,
    [FechaIniVig]             DATE           NOT NULL,
    [FechaFinVig]             DATE           NULL,
    [RecibidoEn]              VARCHAR (1000) NULL,
    [NombreServicio]          VARCHAR (500)  NULL,
    [Transporte]              VARCHAR (500)  NULL,
    [Costo]                   FLOAT (53)     NULL,
    [PorcentajeServicioAdmon] FLOAT (53)     NULL,
    [TituloGCHC]              VARCHAR (500)  NULL,
    [CreadoPor]               INT            NULL,
    [CreadoEn]                DATETIME       NULL,
    [ModificadoPor]           INT            NULL,
    [ModificadoEn]            DATETIME       NULL,
    CONSTRAINT [PK_SCOC_RecoleccionBN] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [FechaIniVig] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_RecoleccionBN_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_RecoleccionBN_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_RecoleccionBN_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

