CREATE TABLE [dbo].[AX_ComparativaEmpresa] (
    [IdAxComparativaEmpresa] INT      IDENTITY (1, 1) NOT NULL,
    [IdProveedor]            INT      NULL,
    [DataAreaID]             CHAR (4) NULL,
    [IdUsuario]              INT      NULL,
    [FechaRegistro]          DATETIME NULL,
    [Activo]                 BIT      NULL,
    [IdContrato]             INT      NULL,
    [IdUsuarioAdinco]        INT      NULL,
    CONSTRAINT [PK_AX_ComparativaEmpresa] PRIMARY KEY CLUSTERED ([IdAxComparativaEmpresa] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

