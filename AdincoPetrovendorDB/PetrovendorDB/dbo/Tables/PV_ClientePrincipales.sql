CREATE TABLE [dbo].[PV_ClientePrincipales] (
    [IdClientePrincipales] INT            IDENTITY (1, 1) NOT NULL,
    [NombreCliente]        NVARCHAR (350) NULL,
    [IdProveedor]          INT            NULL,
    [Activo]               BIT            NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [EditadoPor]           INT            NULL,
    [EditadoEl]            DATETIME       NULL,
    [RFC]                  NVARCHAR (350) NULL,
    CONSTRAINT [PK_PV_ClientePrincipales] PRIMARY KEY CLUSTERED ([IdClientePrincipales] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

