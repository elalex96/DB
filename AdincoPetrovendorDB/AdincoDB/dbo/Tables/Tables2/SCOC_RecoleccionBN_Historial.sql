CREATE TABLE [dbo].[SCOC_RecoleccionBN_Historial] (
    [IdContrato]        INT            NOT NULL,
    [MesReporte]        DATE           NOT NULL,
    [Observaciones]     VARCHAR (2000) NULL,
    [TotalBN]           FLOAT (53)     NULL,
    [FechaElaboracion]  DATE           NULL,
    [FechaEntrega]      DATE           NULL,
    [Firma_GCHC]        VARCHAR (3000) NULL,
    [Firma_Conformidad] VARCHAR (3000) NULL,
    [CreadoPor]         INT            NULL,
    [CreadoEn]          DATETIME       NULL,
    [ModificadoPor]     INT            NULL,
    [ModificadoEn]      DATETIME       NULL,
    CONSTRAINT [PK_SCOC_RecoleccionBN_Historial] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [MesReporte] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_RecoleccionBN_Historial_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_RecoleccionBN_Historial_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_RecoleccionBN_Historial_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

