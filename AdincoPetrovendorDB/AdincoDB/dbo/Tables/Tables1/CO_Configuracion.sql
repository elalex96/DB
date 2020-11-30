CREATE TABLE [dbo].[CO_Configuracion] (
    [IdConfiguracion] INT      IDENTITY (1, 1) NOT NULL,
    [IdContrato]      INT      NULL,
    [IdRol]           INT      NULL,
    [IdUsuario]       INT      NULL,
    [Activo]          INT      NULL,
    [Creado]          DATETIME NULL,
    [ModificadoPor]   INT      NULL,
    [Modificado]      DATETIME NULL,
    [CreadoPor]       INT      NULL,
    CONSTRAINT [PK_ContratistaContratoRolUsuario] PRIMARY KEY CLUSTERED ([IdConfiguracion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

