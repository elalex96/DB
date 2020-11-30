CREATE TABLE [dbo].[AY_Modulos] (
    [IdModulo]          INT           IDENTITY (1, 1) NOT NULL,
    [NombreModulo]      VARCHAR (50)  NULL,
    [DescripcionModulo] VARCHAR (200) NULL,
    CONSTRAINT [PK__AY_Modul__D9F1531523E708D6] PRIMARY KEY CLUSTERED ([IdModulo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

