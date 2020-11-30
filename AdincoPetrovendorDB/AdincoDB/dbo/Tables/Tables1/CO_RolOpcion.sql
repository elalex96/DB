CREATE TABLE [dbo].[CO_RolOpcion] (
    [IdRolOpcion]   INT      IDENTITY (1, 1) NOT NULL,
    [IdRol]         INT      NULL,
    [IdOpcion]      INT      NULL,
    [Activo]        BIT      NULL,
    [Creado]        DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [Modificado]    DATETIME NULL,
    [CreadoPor]     INT      NULL,
    CONSTRAINT [PK_RolOpciones] PRIMARY KEY CLUSTERED ([IdRolOpcion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_RolOpciones_Opciones] FOREIGN KEY ([IdOpcion]) REFERENCES [dbo].[CO_Opciones] ([IdOpcion]),
    CONSTRAINT [FK_RolOpciones_Roles] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[CO_Rol] ([IdRol])
);

