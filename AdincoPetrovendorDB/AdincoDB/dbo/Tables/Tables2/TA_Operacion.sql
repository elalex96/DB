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
    CONSTRAINT [PK_TA_Operacion] PRIMARY KEY CLUSTERED ([IdOperacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TA_Operacion_TA_FlujoTarea] FOREIGN KEY ([IdFlujoTarea]) REFERENCES [dbo].[TA_FlujoTarea] ([IdFlujoTarea]),
    CONSTRAINT [FK_TA_Operacion_TA_Operacion] FOREIGN KEY ([IdOperacion]) REFERENCES [dbo].[TA_Operacion] ([IdOperacion])
);

