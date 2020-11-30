CREATE TABLE [dbo].[EI_Resultado] (
    [IdResultadoEG] INT        IDENTITY (1, 1) NOT NULL,
    [IdProveedor]   INT        NOT NULL,
    [Resultado]     FLOAT (53) NOT NULL,
    CONSTRAINT [PK_EI_Resultado] PRIMARY KEY CLUSTERED ([IdResultadoEG] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EI_Resultado_S_Proveedor1] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

