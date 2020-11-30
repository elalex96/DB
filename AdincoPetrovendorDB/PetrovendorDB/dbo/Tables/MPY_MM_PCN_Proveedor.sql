CREATE TABLE [dbo].[MPY_MM_PCN_Proveedor] (
    [IdPCNProveedor]   INT            IDENTITY (1, 1) NOT NULL,
    [RazonSocial]      NVARCHAR (MAX) NULL,
    [RFC]              NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [EditadoPor]       INT            NULL,
    [EditadoEl]        DATETIME       NULL,
    [Activo]           INT            NULL,
    [IdProveedor]      NVARCHAR (20)  NULL,
    [CorreoInvitacion] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_MPY_MM_PCN_Proveedor] PRIMARY KEY CLUSTERED ([IdPCNProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

