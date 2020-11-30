CREATE TABLE [dbo].[CO_RegistroRPCMMesPresentacion] (
    [IdRespaldoRegistro] INT           IDENTITY (10000, 1) NOT NULL,
    [IdFactura]          INT           NULL,
    [IdContrato]         INT           NULL,
    [MetodoPago]         NVARCHAR (50) NULL,
    [FormaPago]          NVARCHAR (50) NULL,
    [IdPresupuesto]      INT           NULL,
    [FechaPago]          DATE          NULL,
    [MesPresentacion]    DATE          NULL,
    [IdEstado]           INT           NULL,
    [IdRegistro]         INT           NULL,
    CONSTRAINT [PK_CO_RegistroRPCMMesPresentacion] PRIMARY KEY CLUSTERED ([IdRespaldoRegistro] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

