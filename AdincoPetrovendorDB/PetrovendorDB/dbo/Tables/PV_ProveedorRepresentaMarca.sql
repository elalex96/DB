CREATE TABLE [dbo].[PV_ProveedorRepresentaMarca] (
    [IdMarca]      INT             IDENTITY (1, 1) NOT NULL,
    [IdProveedor]  INT             NULL,
    [IdCredorPor]  INT             NULL,
    [IdEditadoPor] INT             NULL,
    [EditadoEl]    DATETIME        NULL,
    [CreadoEl]     DATETIME        NULL,
    [NombreMarca]  NVARCHAR (350)  NULL,
    [Activo]       BIT             NULL,
    [LogoMarca]    VARBINARY (MAX) NULL,
    [Correo]       NVARCHAR (50)   NULL,
    [Nombre]       NVARCHAR (100)  NULL,
    [Telefono]     NVARCHAR (10)   NULL,
    CONSTRAINT [PK_PV_ProveedorMarca] PRIMARY KEY CLUSTERED ([IdMarca] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

