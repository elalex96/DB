CREATE TABLE [dbo].[PV_TipoCuentaInterbancaria] (
    [IdTipoCuentaInterbancaria] INT          IDENTITY (1, 1) NOT NULL,
    [NombreCuentaInterbancaria] VARCHAR (30) NULL,
    CONSTRAINT [PK_TipoCuentaInterbancaria] PRIMARY KEY CLUSTERED ([IdTipoCuentaInterbancaria] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

