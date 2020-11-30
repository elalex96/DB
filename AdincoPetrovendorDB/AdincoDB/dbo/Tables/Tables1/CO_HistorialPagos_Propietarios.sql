CREATE TABLE [dbo].[CO_HistorialPagos_Propietarios] (
    [IdPagoPropietario] INT             IDENTITY (10000, 1) NOT NULL,
    [IdPropietario]     INT             NULL,
    [MesPago]           DATE            NULL,
    [MontoCalculado]    MONEY           NULL,
    [MontoPagado]       MONEY           NULL,
    [FechaPago]         DATETIME        NULL,
    [MetodoPago]        NVARCHAR (150)  NULL,
    [Comentarios]       NVARCHAR (1000) NULL,
    [CreadoPor]         INT             NULL,
    [CreadoEl]          DATETIME        NULL,
    [ModificadoPor]     INT             NULL,
    [ModificadoEl]      DATETIME        NULL,
    CONSTRAINT [PK_CO_HistorialPagos_Propietarios] PRIMARY KEY CLUSTERED ([IdPagoPropietario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_HistorialPagos_Propietarios_CO_PropietariosAreaContractual] FOREIGN KEY ([IdPropietario]) REFERENCES [dbo].[CO_PropietariosAreaContractual] ([IdPropietario])
);

