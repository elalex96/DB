CREATE TABLE [dbo].[MM_Unidad] (
    [IdUnidad]     INT            NOT NULL,
    [NombreUnidad] NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED ([IdUnidad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

