CREATE TABLE [dbo].[S_RegistroProveedorOperador] (
    [IdRegistroProveedorOperador] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedorRegistrado]       INT      NULL,
    [IdProveedorCreador]          INT      NULL,
    [IdCreadoPor]                 INT      NULL,
    [CreadoEl]                    DATETIME NULL,
    [IdEditadoPor]                INT      NULL,
    [EditadoEl]                   DATETIME NULL,
    [Activo]                      BIT      NULL
);

