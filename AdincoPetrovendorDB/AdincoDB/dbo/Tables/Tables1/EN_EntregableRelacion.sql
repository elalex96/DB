CREATE TABLE [dbo].[EN_EntregableRelacion] (
    [DocumentoEntregablePadreId] INT      NULL,
    [DocumentoEntregableHijoId]  INT      NULL,
    [CreadoEl]                   DATETIME NULL,
    [CreadoPor]                  INT      NULL,
    [ModificadoEl]               DATETIME NULL,
    [ModificadoPor]              INT      NULL,
    [Activo]                     BIT      NULL,
    FOREIGN KEY ([DocumentoEntregableHijoId]) REFERENCES [dbo].[EN_EntregableDocumento] ([DocumentoEntregableId]),
    FOREIGN KEY ([DocumentoEntregablePadreId]) REFERENCES [dbo].[EN_EntregableDocumento] ([DocumentoEntregableId])
);

