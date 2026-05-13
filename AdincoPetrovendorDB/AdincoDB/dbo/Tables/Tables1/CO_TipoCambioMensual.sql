CREATE TABLE [dbo].[CO_TipoCambioMensual] (
    [IdTipoCambioMensual] INT             IDENTITY (1, 1) NOT NULL,
    [IdMoneda]            INT             NOT NULL,
    [Anio]                INT             NOT NULL,
    [IdMes]               INT             NOT NULL,
    [TipoCambio]          DECIMAL (12, 4) NULL,
    [IdUsuario]           INT             NULL,
    [FecMovto]            INT             NULL,
    [Activo]              BIT             NULL,
    [CreadoPor]           INT             NULL,
    [ObtenidoSDK]         BIT             NULL,
    [TipoCambioBanxico]   DECIMAL (12, 4) NULL
);
GO
CREATE INDEX IX_CO_TipoCambioMensual_Moneda_Anio_Mes
    ON dbo.CO_TipoCambioMensual (IdMoneda, Anio, IdMes)
    INCLUDE (TipoCambio);

