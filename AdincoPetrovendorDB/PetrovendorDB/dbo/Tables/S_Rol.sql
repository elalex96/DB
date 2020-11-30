CREATE TABLE [dbo].[S_Rol] (
    [IdRol]      INT            IDENTITY (1, 1) NOT NULL,
    [Rol]        NVARCHAR (350) NULL,
    [CreadorPor] INT            NULL,
    [CreadoEl]   DATETIME       NULL,
    CONSTRAINT [PK_S_Rol] PRIMARY KEY CLUSTERED ([IdRol] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

