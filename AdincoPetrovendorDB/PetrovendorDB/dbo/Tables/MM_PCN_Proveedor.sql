CREATE TABLE [dbo].[MM_PCN_Proveedor] (
    [IdPCNProveedor]   INT            IDENTITY (1, 1) NOT NULL,
    [RazonSocial]      NVARCHAR (MAX) NULL,
    [RFC]              NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [EditadoPor]       INT            NULL,
    [EditadoEl]        DATETIME       NULL,
    [Activo]           INT            NULL,
    [IdProveedor]      INT            NULL,
    [CorreoInvitacion] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_MM_PCN_Proveedor] PRIMARY KEY CLUSTERED ([IdPCNProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

