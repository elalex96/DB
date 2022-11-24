CREATE TABLE [dbo].[CAT_Estados] (
    [IdEstado] INT            NOT NULL,
    [IdPais]   INT            NULL,
    [Estado]   NVARCHAR (600) NULL,
    CONSTRAINT [PK_CAT_Estados] PRIMARY KEY CLUSTERED ([IdEstado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CAT_Estados_CAT_Paises] FOREIGN KEY ([IdPais]) REFERENCES [dbo].[CAT_Paises] ([IdPais])
);

