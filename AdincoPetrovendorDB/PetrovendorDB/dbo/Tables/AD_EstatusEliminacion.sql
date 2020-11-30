CREATE TABLE [dbo].[AD_EstatusEliminacion] (
    [IdEstatusEliminado] INT            NOT NULL,
    [Nombre]             NVARCHAR (300) NULL,
    UNIQUE NONCLUSTERED ([IdEstatusEliminado] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

