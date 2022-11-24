CREATE TABLE [dbo].[Control] (
    [IdControl]     INT          IDENTITY (1, 1) NOT NULL,
    [NombreControl] VARCHAR (50) NULL,
    [IdModulo]      INT          NULL,
    CONSTRAINT [PK_Control] PRIMARY KEY CLUSTERED ([IdControl] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Control_Modulo] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[Modulo] ([IdModulo])
);

