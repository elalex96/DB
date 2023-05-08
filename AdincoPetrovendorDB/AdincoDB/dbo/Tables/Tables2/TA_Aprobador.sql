CREATE TABLE [dbo].[TA_Aprobador] (
    [IdAprobador]  INT IDENTITY (1, 1) NOT NULL,
    [IdFlujoTarea] INT NULL,
    [NoSecuencia]  INT NULL,
    [IdUsuario]    INT NULL,
    CONSTRAINT [PK_TAAprobador] PRIMARY KEY CLUSTERED ([IdAprobador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TaAprobador_TaFlujoTarea] FOREIGN KEY ([IdFlujoTarea]) REFERENCES [dbo].[TA_FlujoTarea] ([IdFlujoTarea])
);

