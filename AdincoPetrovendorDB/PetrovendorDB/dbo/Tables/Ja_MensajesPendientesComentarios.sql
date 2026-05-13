CREATE TABLE [dbo].[Ja_MensajesPendientesComentarios] (
    [IdMensaje]          INT      IDENTITY (1, 1) NOT NULL,
    [IdPrimario]         INT      NULL,
    [IdProveedor]        INT      NULL,
    [TipoMensaje]        INT      NULL,
    [Enviado]            BIT      NULL,
    [FechaEnviado]       DATETIME NULL,
    [Visto]              BIT      NULL,
    [IdOferta]           INT      NULL,
    [IdSolPed]           INT      NULL,
    [IdProveedorCreador] INT      NULL,
    [FechaCreado]        DATETIME NULL,
    [IdContratoCreador]  INT      NULL,
    CONSTRAINT [PK__Ja_Mensa__E4D2A47F4FA4512E] PRIMARY KEY CLUSTERED ([IdMensaje] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

