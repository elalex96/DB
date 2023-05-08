CREATE TABLE [dbo].[AM_AprobacionesUsuario] (
    [IdContrato]          INT           NULL,
    [NumeroContrato]      VARCHAR (MAX) NULL,
    [TipoAprobacion]      VARCHAR (300) NULL,
    [IdTipoAprobacion]    INT           NULL,
    [FechaCreacion]       VARCHAR (MAX) NULL,
    [ComentarioDoc]       VARCHAR (MAX) NULL,
    [ComentarioApr]       VARCHAR (MAX) NULL,
    [Estatus]             VARCHAR (300) NULL,
    [IdStatusAprobacionM] INT           NULL,
    [IdTareaOrigen]       INT           NULL,
    [NoVersion]           INT           NULL,
    [IdPedido]            INT           NULL,
    [DisplayMember]       INT           NULL,
    [IdDocumento]         INT           NULL,
    [TipoFlujo]           INT           NULL,
    [IdOperacion]         INT           NULL,
    [UsuarioPetro]        INT           NULL
);

