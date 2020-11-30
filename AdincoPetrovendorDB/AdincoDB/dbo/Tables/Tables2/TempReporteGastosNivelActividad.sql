CREATE TABLE [dbo].[TempReporteGastosNivelActividad] (
    [IdReporteGastosNivelActividad] INT           IDENTITY (10000, 1) NOT NULL,
    [Servicio]                      INT           NULL,
    [Actividad]                     INT           NULL,
    [DisplayServicio]               NVARCHAR (50) NULL,
    [DisplayActividad]              NVARCHAR (50) NULL,
    [Programa]                      MONEY         NULL,
    [GastoHastaMesAnterior]         MONEY         NULL,
    [Presupuesto]                   MONEY         NULL,
    [Gastos]                        MONEY         NULL,
    [Acumulado]                     MONEY         NULL,
    [Saldo]                         MONEY         NULL,
    [Fecha]                         DATE          NULL,
    [Orden]                         INT           NULL,
    CONSTRAINT [PK_TempReporteGastosNivelActividad] PRIMARY KEY CLUSTERED ([IdReporteGastosNivelActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

