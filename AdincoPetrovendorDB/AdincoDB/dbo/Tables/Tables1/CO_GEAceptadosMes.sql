CREATE TABLE [dbo].[CO_GEAceptadosMes] (
    [IdGEAceptadoMes] INT      IDENTITY (10000, 1) NOT NULL,
    [IdContrato]      INT      NULL,
    [GEAprobados]     MONEY    NULL,
    [Mes]             DATE     NULL,
    [CreadoPor]       INT      NULL,
    [CreadoEl]        DATETIME NULL,
    [ModificadoPor]   INT      NULL,
    [ModificadoEl]    DATETIME NULL,
    [Activo]          BIT      NULL,
    CONSTRAINT [PK_CO_GEAcptadosMes] PRIMARY KEY CLUSTERED ([IdGEAceptadoMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_GEAcptadosMes_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

