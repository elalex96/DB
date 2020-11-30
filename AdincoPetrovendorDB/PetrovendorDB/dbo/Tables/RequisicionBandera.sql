CREATE TABLE [dbo].[RequisicionBandera] (
    [IdSolicitudPedido] INT            NULL,
    [IdUsuario]         INT            NULL,
    [EnviarCorreo]      BIT            NULL,
    [FechaRegistro]     DATETIME       NULL,
    [Identificador]     NVARCHAR (MAX) NULL
);

