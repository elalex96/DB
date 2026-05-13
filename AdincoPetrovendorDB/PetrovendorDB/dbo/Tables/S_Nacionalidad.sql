CREATE TABLE [dbo].[S_Nacionalidad] (
    [IdNacionalidad] INT           NOT NULL,
    [Nacionalidad]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_S_Nacionalidad] PRIMARY KEY CLUSTERED ([IdNacionalidad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

