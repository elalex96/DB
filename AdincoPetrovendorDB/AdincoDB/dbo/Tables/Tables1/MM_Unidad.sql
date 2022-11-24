CREATE TABLE [dbo].[MM_Unidad] (
    [IdUnidad]     INT            NOT NULL,
    [NombreUnidad] NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED ([IdUnidad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

