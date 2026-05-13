CREATE TABLE [dbo].[CO_ActividadCIEP] (
    [IdActividad]        INT           IDENTITY (1, 1) NOT NULL,
    [ID_CATACTIV]        NVARCHAR (50) NULL,
    [NombreActividad]    NVARCHAR (50) NULL,
    [IdProveedor]        INT           NULL,
    [IdUsuarioCreadoPor] INT           NULL,
    [Creado]             DATETIME      NULL,
    [IdUsuarioModPor]    INT           NULL,
    [Modificado]         DATETIME      NULL,
    [CreadoPor]          INT           NULL,
    CONSTRAINT [PK_Actividades] PRIMARY KEY CLUSTERED ([IdActividad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

