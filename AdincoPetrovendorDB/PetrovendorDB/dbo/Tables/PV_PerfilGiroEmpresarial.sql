CREATE TABLE [dbo].[PV_PerfilGiroEmpresarial] (
    [Activo]                  BIT      NULL,
    [CreadoEl]                DATETIME NULL,
    [EditadoEl]               DATETIME NULL,
    [IdCreadorPor]            INT      NULL,
    [IdEditadoPor]            INT      NULL,
    [IdGiroEmpresarial]       INT      NULL,
    [IdPerfilGiroEmpresarial] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedor]             INT      NULL
);

