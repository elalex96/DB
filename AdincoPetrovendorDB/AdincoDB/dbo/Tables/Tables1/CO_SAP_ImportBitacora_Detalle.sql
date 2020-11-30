CREATE TABLE [dbo].[CO_SAP_ImportBitacora_Detalle] (
    [Id]               INT           NOT NULL,
    [IdImportBitacora] INT           NOT NULL,
    [NombreArchivo]    VARCHAR (100) NOT NULL,
    [Error]            VARCHAR (250) NOT NULL,
    [TieneError]       BIT           NOT NULL,
    [CreadoEl]         DATETIME      NOT NULL,
    CONSTRAINT [PK_CO_SAP_ImportBitacora_Detalle] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAP_ImportBitacora_Detalle_CO_SAP_ImportBitacora] FOREIGN KEY ([IdImportBitacora]) REFERENCES [dbo].[CO_SAP_ImportBitacora] ([Id])
);

