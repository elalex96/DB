CREATE TABLE [dbo].[CO_GEAceptadosMes_Log] (
    [IdGEAceptadoMes_Log] INT      IDENTITY (10000, 1) NOT NULL,
    [IdGEAceptadoMes]     INT      NOT NULL,
    [IdContrato]          INT      NULL,
    [GEAprobados]         MONEY    NULL,
    [Mes]                 DATE     NULL,
    [CreadoPor]           INT      NULL,
    [CreadoEl]            DATETIME NULL,
    [ModificadoPor]       INT      NULL,
    [ModificadoEl]        DATETIME NULL,
    [Activo]              BIT      NULL,
    CONSTRAINT [PK_CO_GEAceptadosMes_Log] PRIMARY KEY CLUSTERED ([IdGEAceptadoMes_Log] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_GEAceptadosMes_Log_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

