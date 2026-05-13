CREATE TABLE [dbo].[TA_OperadorMatematico] (
    [IdOperador]    INT            IDENTITY (1, 1) NOT NULL,
    [SignoOperador] NVARCHAR (100) NULL,
    CONSTRAINT [PK_TA_OperadorMatematico] PRIMARY KEY CLUSTERED ([IdOperador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

