CREATE TABLE [dbo].[AD_EstatusEliminacion] (
    [IdEstatusEliminado] INT            NOT NULL,
    [Nombre]             NVARCHAR (300) NULL,
    UNIQUE NONCLUSTERED ([IdEstatusEliminado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

