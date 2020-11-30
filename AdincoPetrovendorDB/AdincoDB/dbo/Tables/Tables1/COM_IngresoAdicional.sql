CREATE TABLE [dbo].[COM_IngresoAdicional] (
    [IdIngresoAdicional] INT   IDENTITY (1, 1) NOT NULL,
    [IdContrato]         INT   NULL,
    [MesReporte]         DATE  NULL,
    [Ingreso]            MONEY NULL,
    [CostosPrevios]      MONEY NULL,
    [CostosElegibles]    MONEY NULL,
    [CostosRecuperables] MONEY NULL,
    CONSTRAINT [PK_COM_IngresoAdicional] PRIMARY KEY CLUSTERED ([IdIngresoAdicional] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_IngresoAdicional_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

