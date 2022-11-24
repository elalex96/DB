CREATE TABLE [dbo].[MPY_MM_AceptacionNotaCredito] (
    [IdAceptacionNotaCredito] INT            IDENTITY (1000000, 1) NOT NULL,
    [IdFacturaNotaCredito]    INT            NULL,
    [IdAceptacionPedido]      INT            NULL,
    [TipoRelacion]            NVARCHAR (50)  NULL,
    [CFDIRelacionados]        NVARCHAR (MAX) NULL,
    [NoParcialidad]           INT            NULL,
    [CreadoEl]                DATETIME       NULL,
    [CreadoPor]               INT            NULL,
    [Activo]                  BIT            NULL,
    [IdEstatusEliminada]      INT            NULL,
    [IdEliminado]             INT            NULL,
    [IdEstatus]               INT            NOT NULL,
    [Comentario]              VARCHAR (250)  NULL,
    [IdAprobador]             INT            NULL,
    [FechaAprobacion]         DATETIME       NULL,
    [RevisionSAP]             BIT            NULL,
    [RevisionSAPPor]          INT            NULL,
    [RevisionSAPEl]           DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdAceptacionNotaCredito] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[TA_Estatus] ([IdEstatus]),
    CONSTRAINT [FK_MPY_MM_AceptacionNotaCredito_S_Usuario] FOREIGN KEY ([IdAprobador]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

