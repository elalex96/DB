CREATE TABLE [dbo].[MM_Unidad] (
    [IdUnidad]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreUnidad] NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    CONSTRAINT [PK_Unidades] PRIMARY KEY CLUSTERED ([IdUnidad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

