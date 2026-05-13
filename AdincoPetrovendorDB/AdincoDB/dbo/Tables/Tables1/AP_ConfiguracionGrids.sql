CREATE TABLE [dbo].[AP_ConfiguracionGrids] (
    [IdConfiguracionGrids] INT            IDENTITY (10000, 1) NOT NULL,
    [IdUsuario]            INT            NULL,
    [IdNombreGrid]         NVARCHAR (MAX) NULL,
    [Configuracion]        NVARCHAR (MAX) NULL,
    [CreadoEn]             DATE           NULL,
    [cantidadcolumnas]     INT            NULL
);

