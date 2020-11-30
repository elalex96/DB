CREATE TABLE [dbo].[Numbers] (
    [Number] BIGINT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [n]
    ON [dbo].[Numbers]([Number] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

