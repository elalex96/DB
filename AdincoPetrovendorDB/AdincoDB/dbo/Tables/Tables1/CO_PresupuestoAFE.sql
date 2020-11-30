CREATE TABLE [dbo].[CO_PresupuestoAFE] (
    [IdPresupuestoAFE] INT           NOT NULL,
    [IdContratista]    INT           NOT NULL,
    [Descripcion]      VARCHAR (200) NOT NULL,
    [IdEstatus]        TINYINT       NOT NULL,
    [CreadoEl]         DATETIME      NOT NULL,
    [CreadoPor]        INT           NOT NULL,
    [AprobadoPor]      INT           NULL,
    [AprobadoEl]       DATETIME      NULL,
    CONSTRAINT [PK_CO_PresupuestoAFE] PRIMARY KEY CLUSTERED ([IdPresupuestoAFE] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PresupuestoAFE_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

