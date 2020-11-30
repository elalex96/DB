CREATE TABLE [dbo].[AM_MenuCard] (
    [IdMenu]      INT           IDENTITY (1, 1) NOT NULL,
    [TituloEs]    VARCHAR (100) NULL,
    [SubtituloEs] VARCHAR (100) NULL,
    [TituloEn]    VARCHAR (100) NULL,
    [SubtituloEn] VARCHAR (100) NULL,
    [CardIcon]    VARCHAR (150) NULL,
    [AlertColor]  VARCHAR (100) NULL,
    [IsEnabled]   BIT           NULL,
    PRIMARY KEY CLUSTERED ([IdMenu] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

