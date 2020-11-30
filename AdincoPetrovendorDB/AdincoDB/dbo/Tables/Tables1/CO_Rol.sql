CREATE TABLE [dbo].[CO_Rol] (
    [IdRol]         INT            IDENTITY (1, 1) NOT NULL,
    [Rol]           NVARCHAR (MAX) NULL,
    [Activo]        BIT            NULL,
    [Creado]        DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [Modificado]    DATETIME       NULL,
    [CreadoPor]     INT            NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([IdRol] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

