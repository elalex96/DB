CREATE TABLE [dbo].[TA_FlujoTareaCondicion] (
    [IdCondicion]          INT            IDENTITY (1, 1) NOT NULL,
    [NombreCondicion]      NVARCHAR (200) NULL,
    [IdTipoOperadorMat]    INT            NOT NULL,
    [IdFlujoTarea]         INT            NULL,
    [Valor]                FLOAT (53)     NULL,
    [IdConstanteCondicion] INT            NULL,
    CONSTRAINT [PK_TaCondicionFlujoTarea] PRIMARY KEY CLUSTERED ([IdCondicion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TaFlujoTareaCondicion_TaFlujoTarea1] FOREIGN KEY ([IdFlujoTarea]) REFERENCES [dbo].[TA_FlujoTarea] ([IdFlujoTarea]),
    CONSTRAINT [FK_TaFlujoTareaCondicion_TaFlujoTareaConstante] FOREIGN KEY ([IdConstanteCondicion]) REFERENCES [dbo].[TA_FlujoTareaConstante] ([IdConstante]),
    CONSTRAINT [FK_TaFlujoTareaCondicion_TaOperadorMatematico1] FOREIGN KEY ([IdTipoOperadorMat]) REFERENCES [dbo].[TA_OperadorMatematico] ([IdOperador])
);

