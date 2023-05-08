CREATE TABLE [dbo].[PV_Recurrencia] (
    [idRecurrecia] INT          IDENTITY (1, 1) NOT NULL,
    [Recurrencia]  VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_PV_Recurrencia] PRIMARY KEY CLUSTERED ([idRecurrecia] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

