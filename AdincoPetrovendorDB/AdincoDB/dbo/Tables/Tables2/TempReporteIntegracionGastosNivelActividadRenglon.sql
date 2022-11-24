CREATE TABLE [dbo].[TempReporteIntegracionGastosNivelActividadRenglon] (
    [IdReporteGastosNivelActividadRenglon] INT            IDENTITY (10000, 1) NOT NULL,
    [Servicio]                             INT            NULL,
    [Actividad]                            INT            NULL,
    [DisplayServicio]                      NVARCHAR (50)  NULL,
    [DisplayActividad]                     NVARCHAR (50)  NULL,
    [Programa]                             MONEY          NULL,
    [GastoHastaMesAnterior]                MONEY          NULL,
    [Presupuesto]                          MONEY          NULL,
    [Gastos]                               MONEY          NULL,
    [Acumulado]                            MONEY          NULL,
    [Saldo]                                MONEY          NULL,
    [Fecha]                                DATE           NULL,
    [NoServicio]                           INT            NULL,
    [DesServicio]                          NVARCHAR (MAX) NULL,
    [Orden]                                INT            NULL,
    [IdRubro]                              INT            NULL,
    [Rubro]                                VARCHAR (300)  NULL,
    CONSTRAINT [PK_TempReporteIntegracionGastosNivelActividadRenglon] PRIMARY KEY CLUSTERED ([IdReporteGastosNivelActividadRenglon] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

