CREATE TABLE [dbo].[EN_ResponsableGenerador] (
    [IdResponsableGenerador] INT            IDENTITY (10000, 1) NOT NULL,
    [ResponsableGenerador]   NVARCHAR (MAX) NULL,
    [CreadoPor]              INT            NULL,
    [CreadoEn]               DATETIME       NULL,
    CONSTRAINT [PK_EN_ResponsableGenerador] PRIMARY KEY CLUSTERED ([IdResponsableGenerador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IX_EN_ResponsableGenerador]
    ON [dbo].[EN_ResponsableGenerador]([IdResponsableGenerador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

