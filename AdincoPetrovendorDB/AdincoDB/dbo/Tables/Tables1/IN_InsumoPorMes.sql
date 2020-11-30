CREATE TABLE [dbo].[IN_InsumoPorMes] (
    [idInsumoMes]     INT             IDENTITY (1, 1) NOT NULL,
    [ValorCantidad]   DECIMAL (24, 8) NULL,
    [FechaCapturado]  DATE            NULL,
    [PeriodoMes]      VARCHAR (50)    NULL,
    [idControlInsumo] INT             NULL,
    [Año]             INT             NULL,
    [periodo]         DATE            NULL,
    [CreadoPor]       INT             NULL,
    [CreadoEl]        DATETIME        NULL,
    [ModificadoPor]   INT             NULL,
    [ModificadoEl]    DATETIME        NULL,
    [Activo]          BIT             NULL,
    CONSTRAINT [PK__IN_Insum__5AFC692AD4BDA12D] PRIMARY KEY CLUSTERED ([idInsumoMes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_idControlInsumoPorMes] FOREIGN KEY ([idControlInsumo]) REFERENCES [dbo].[IN_ControlInsumo] ([idControlInsumo])
);

