CREATE TABLE [dbo].[S_Ofrece] (
    [IdOfrece] INT            NOT NULL,
    [Ofrece]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_S_Ofrece] PRIMARY KEY CLUSTERED ([IdOfrece] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

