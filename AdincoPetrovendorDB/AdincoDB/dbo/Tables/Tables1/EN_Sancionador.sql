CREATE TABLE [dbo].[EN_Sancionador] (
    [IdSancionador]     INT           IDENTITY (1, 1) NOT NULL,
    [Sancionador]       VARCHAR (20)  NULL,
    [NombreSancionador] VARCHAR (500) NULL,
    [LogoSancionador]   VARCHAR (500) NULL,
    CONSTRAINT [PK_EN_Sancionador] PRIMARY KEY CLUSTERED ([IdSancionador] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

