CREATE TABLE [dbo].[CO_TipoCambioDiario] (
    [IdTipoCambio] INT             IDENTITY (1, 1) NOT NULL,
    [IdMoneda]     INT             NOT NULL,
    [Fecha]        DATE            NOT NULL,
    [TipoCambio]   DECIMAL (12, 5) NULL,
    [IdUsuario]    INT             NULL,
    [Activo]       BIT             NULL,
    [CreadoPor]    INT             NULL,
    CONSTRAINT [PK_TIPOSCAMBIODIARIO] PRIMARY KEY CLUSTERED ([IdTipoCambio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [idx_MonedaFecha]
    ON [dbo].[CO_TipoCambioDiario]([IdMoneda] ASC, [Fecha] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

