CREATE TABLE [dbo].[S_TipoRegimen] (
    [IdTipoRegimen] INT           IDENTITY (1, 1) NOT NULL,
    [TipoRegimen]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_S_TipoRegimen] PRIMARY KEY CLUSTERED ([IdTipoRegimen] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

