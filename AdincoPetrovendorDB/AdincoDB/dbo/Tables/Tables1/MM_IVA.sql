CREATE TABLE [dbo].[MM_IVA] (
    [id_]               INT        IDENTITY (1, 1) NOT NULL,
    [year_]             FLOAT (53) NULL,
    [valor_iva]         FLOAT (53) NULL,
    [fecha_inicio]      DATE       NULL,
    [fecha_terminacion] DATE       NULL,
    [CreadoPor]         INT        NULL
);

