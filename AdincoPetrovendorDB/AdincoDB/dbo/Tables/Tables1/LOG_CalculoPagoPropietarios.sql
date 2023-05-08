CREATE TABLE [dbo].[LOG_CalculoPagoPropietarios] (
    [IdCalculoPago]           INT        IDENTITY (1, 1) NOT NULL,
    [MesCalculo]              DATE       NULL,
    [CantPropietarios]        INT        NULL,
    [IngresoBruto]            FLOAT (53) NULL,
    [CuotaExploratoria]       FLOAT (53) NULL,
    [RegaliaBase]             FLOAT (53) NULL,
    [RegaliaAdicional]        FLOAT (53) NULL,
    [IngresoNeto]             FLOAT (53) NULL,
    [PorcentajeDestinadoPago] FLOAT (53) NULL,
    [MontoDestinadoPago]      FLOAT (53) NULL,
    [UsuarioID]               INT        NULL,
    [FecMovto]                DATETIME   NULL,
    CONSTRAINT [PK_LOG_CalculoPagoPropietarios] PRIMARY KEY CLUSTERED ([IdCalculoPago] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_LOG_CalculoPagoPropietarios_AP_Usuario] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

