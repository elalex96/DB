CREATE TABLE [dbo].[IN_ControlInsumo] (
    [idControlInsumo]      INT      IDENTITY (1, 1) NOT NULL,
    [idResponsableCaptura] INT      NULL,
    [idContrato]           INT      NULL,
    [CreadoPor]            INT      NULL,
    [CreadoEl]             DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [ModificadoEl]         DATETIME NULL,
    [Activo]               BIT      NULL,
    [idInsumoIndicador]    INT      NULL,
    CONSTRAINT [PK__IN_Contr__DC5072D13258EC87] PRIMARY KEY CLUSTERED ([idControlInsumo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__IN_Contro__idIns__2D942E62] FOREIGN KEY ([idInsumoIndicador]) REFERENCES [dbo].[IN_InsumoIndicador] ([idInsumoIndicador]),
    CONSTRAINT [FK_ControlInsumoContrato] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [fk_ResponsableUsuario] FOREIGN KEY ([idResponsableCaptura]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

