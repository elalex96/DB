CREATE TABLE [dbo].[CO_Opciones] (
    [IdOpcion]      INT            IDENTITY (1, 1) NOT NULL,
    [Opcion]        NVARCHAR (MAX) NULL,
    [Clave]         NVARCHAR (MAX) NULL,
    [Activo]        BIT            NULL,
    [Creado]        DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [Modificado]    DATETIME       NULL,
    [CreadoPor]     INT            NULL,
    CONSTRAINT [PK_Opciones] PRIMARY KEY CLUSTERED ([IdOpcion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

