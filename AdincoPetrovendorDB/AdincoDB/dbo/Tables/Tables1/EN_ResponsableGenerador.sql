CREATE TABLE [dbo].[EN_ResponsableGenerador] (
    [IdResponsableGenerador] INT            IDENTITY (10000, 1) NOT NULL,
    [ResponsableGenerador]   NVARCHAR (MAX) NULL,
    [CreadoPor]              INT            NULL,
    [CreadoEn]               DATETIME       NULL,
    CONSTRAINT [PK_EN_ResponsableGenerador] PRIMARY KEY CLUSTERED ([IdResponsableGenerador] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

