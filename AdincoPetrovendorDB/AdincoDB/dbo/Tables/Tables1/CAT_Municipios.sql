CREATE TABLE [dbo].[CAT_Municipios] (
    [IdMunicipio] INT            NOT NULL,
    [IdEstado]    INT            NULL,
    [Municipio]   NVARCHAR (600) NULL,
    CONSTRAINT [PK_CAT_Municipios] PRIMARY KEY CLUSTERED ([IdMunicipio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CAT_Municipios_CAT_Estados] FOREIGN KEY ([IdEstado]) REFERENCES [dbo].[CAT_Estados] ([IdEstado])
);

