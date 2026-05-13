CREATE TABLE [dbo].[Ax_Incorrectos] (
    [IdTipoOperacion] INT            NULL,
    [IdDocumento]     INT            NULL,
    [Motivo]          NVARCHAR (MAX) NULL,
    [Enviado]         BIT            NULL,
    [FechaRegistro]   DATETIME       NULL
);

