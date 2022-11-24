CREATE TABLE [dbo].[S_TipoValidacionDoc] (
    [IdTipoValidacionDoc] INT            IDENTITY (1, 1) NOT NULL,
    [TipoValidacion]      NVARCHAR (50)  NULL,
    [TipoValidacionEn]    NVARCHAR (100) NULL,
    CONSTRAINT [PK_S_TipoValidacion] PRIMARY KEY CLUSTERED ([IdTipoValidacionDoc] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

