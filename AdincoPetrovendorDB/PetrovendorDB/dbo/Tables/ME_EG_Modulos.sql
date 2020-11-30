CREATE TABLE [dbo].[ME_EG_Modulos] (
    [IdModulo]    INT           IDENTITY (1, 1) NOT NULL,
    [Modulo]      VARCHAR (200) NOT NULL,
    [IdModuloUrl] INT           NULL,
    CONSTRAINT [PK_ME_EG_Modulos] PRIMARY KEY CLUSTERED ([IdModulo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_EG_Modulos_Modulo1] FOREIGN KEY ([IdModuloUrl]) REFERENCES [dbo].[Modulo] ([IdModulo])
);

