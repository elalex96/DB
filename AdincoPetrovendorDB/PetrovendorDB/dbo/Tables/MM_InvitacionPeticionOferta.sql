CREATE TABLE [dbo].[MM_InvitacionPeticionOferta] (
    [IdInvitacion]          INT            IDENTITY (1, 1) NOT NULL,
    [Fecha]                 DATETIME       NULL,
    [CorreoEnviado]         BIT            NULL,
    [IdSolicitudPedido]     INT            NULL,
    [IdProveedorInvitado]   INT            NULL,
    [CreadoPor]             INT            NULL,
    [IdPeticionOferta]      INT            NULL,
    [InvitacionPorMaterial] BIT            NULL,
    [CorreoInvitacion]      NVARCHAR (350) NULL,
    [CodigoActivo]          BIT            NULL,
    [Invitado]              BIT            NULL,
    [RazonNoInvitacion]     NVARCHAR (MAX) NULL,
    [InvitacionPorCorreo]   BIT            NULL,
    [CodigoActivacion]      NVARCHAR (150) NULL,
    [FechaActualizacion]    DATETIME       NULL,
    [Activo]                BIT            NULL,
    [IdProveedorInvito]     INT            NULL,
    [CotizacionRestringida] BIT            NULL,
    CONSTRAINT [PK_MM_InvitacionPeticionOferta] PRIMARY KEY CLUSTERED ([IdInvitacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

