CREATE TABLE [dbo].[AY_Modulos] (
    [IdModulo]          INT           IDENTITY (1, 1) NOT NULL,
    [NombreModulo]      VARCHAR (50)  NULL,
    [DescripcionModulo] VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([IdModulo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

