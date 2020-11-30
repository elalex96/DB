CREATE TABLE [dbo].[OF_PermisosUsuario] (
    [IdPermisoUsuario] INT      IDENTITY (1, 1) NOT NULL,
    [IdUsuario]        INT      NOT NULL,
    [Creacion]         BIT      NOT NULL,
    [Revision]         BIT      NOT NULL,
    [Modificacion]     BIT      NOT NULL,
    [Aprobacion]       BIT      NOT NULL,
    [Firma]            BIT      NOT NULL,
    [ModificadoPor]    INT      NOT NULL,
    [ModificadoEl]     DATETIME NOT NULL,
    [IdContrato]       INT      NULL,
    CONSTRAINT [PK_OF_PermisosUsuario] PRIMARY KEY CLUSTERED ([IdPermisoUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

