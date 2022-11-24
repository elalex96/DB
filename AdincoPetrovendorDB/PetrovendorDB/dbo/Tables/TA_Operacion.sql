CREATE TABLE [dbo].[TA_Operacion] (
    [IdOperacion]        INT            IDENTITY (1, 1) NOT NULL,
    [IdDocumento]        INT            NULL,
    [IdTipoOperacion]    INT            NULL,
    [IdFlujoTarea]       INT            NULL,
    [IdEstatusOperacion] INT            NULL,
    [IdEstadoFlujo]      INT            NULL,
    [IdProveedor]        INT            NULL,
    [IdAsignador]        INT            NULL,
    [FechaRegistro]      DATETIME       NULL,
    [Descripcion]        NVARCHAR (MAX) NULL,
    [FechaModificacion]  DATETIME       NULL,
    [IdPrioridad]        INT            NULL,
    [IdVigencia]         INT            NULL,
    [FechaFinalizacion]  DATETIME       NULL,
    [HoraFinalizacion]   TIME (7)       NULL,
    [NoVersion]          INT            CONSTRAINT [DF_TA_Operacion_NoVersion] DEFAULT ((1)) NULL,
    [IdFirma]            NVARCHAR (35)  NULL,
    [MostrarOperacion]   BIT            NULL,
    [IdEstatusEliminado] INT            NULL,
    [IdEliminado]        INT            NULL,
    [IsMercadeo]         BIT            NULL,
    CONSTRAINT [PK_TA_Operacion] PRIMARY KEY CLUSTERED ([IdOperacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_Operacion_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_TA_Operacion_TA_FlujoTarea] FOREIGN KEY ([IdFlujoTarea]) REFERENCES [dbo].[TA_FlujoTarea] ([IdFlujoTarea]),
    CONSTRAINT [FK_TA_Operacion_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion]),
    CONSTRAINT [FK_TA_Operacion_TA_TipoOperacion] FOREIGN KEY ([IdTipoOperacion]) REFERENCES [dbo].[TA_TipoOperacion] ([IdTipoOperacion])
);


GO
CREATE NONCLUSTERED INDEX [<TA_OperacionIdEstatusOp, sysname,>]
    ON [dbo].[TA_Operacion]([IdEstatusOperacion] ASC)
    INCLUDE([IdDocumento]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdTipoOperacion]
    ON [dbo].[TA_Operacion]([IdTipoOperacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxOperacion_IdTipoOperacion]
    ON [dbo].[TA_Operacion]([IdTipoOperacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxOperacion_IdDocumento]
    ON [dbo].[TA_Operacion]([IdDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [dbo].[TA_Operacion]([IdTipoOperacion] ASC, [IdEstatusOperacion] ASC)
    INCLUDE([IdDocumento], [NoVersion]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

