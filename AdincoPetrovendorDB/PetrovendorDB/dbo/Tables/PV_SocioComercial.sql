CREATE TABLE [dbo].[PV_SocioComercial] (
    [IdSocioComercial] INT            IDENTITY (1, 1) NOT NULL,
    [RFC]              NVARCHAR (300) NULL,
    [RazonSocial]      NVARCHAR (300) NULL,
    [IdCreadoPor]      INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [EditadoPor]       INT            NULL,
    [EditadoEl]        DATETIME       NULL,
    [Activo]           BIT            NULL,
    [IdProveedor]      INT            NULL,
    [Correo]           NVARCHAR (50)  NULL,
    [Nombre]           NVARCHAR (100) NULL,
    [Telefono]         NVARCHAR (10)  NULL,
    CONSTRAINT [PK_PV_SocioComercial] PRIMARY KEY CLUSTERED ([IdSocioComercial] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_SocioComercial_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_PV_SocioComercial_S_Usuario] FOREIGN KEY ([IdCreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

