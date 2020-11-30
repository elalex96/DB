CREATE TABLE [dbo].[MM_FlujoEstatico] (
    [IdFlujoEstatico] INT            NOT NULL,
    [IdFlujo]         INT            NOT NULL,
    [Detalle]         NVARCHAR (200) NULL,
    [CreadoEl]        DATETIME       NULL,
    [IdCreadoPor]     INT            NULL,
    [EditadoEl]       INT            NULL,
    [IdEditadoPor]    INT            NULL,
    UNIQUE NONCLUSTERED ([IdFlujoEstatico] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

