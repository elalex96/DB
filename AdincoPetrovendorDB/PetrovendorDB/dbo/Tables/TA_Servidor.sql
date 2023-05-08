CREATE TABLE [dbo].[TA_Servidor] (
    [IdServidor] INT           IDENTITY (1, 1) NOT NULL,
    [Servidor]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_TA_Servidor] PRIMARY KEY CLUSTERED ([IdServidor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

