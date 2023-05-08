CREATE TABLE [dbo].[PV_DocumentoCuentaBancaria] (
    [IdDocCuentaBancaria]   INT            IDENTITY (1, 1) NOT NULL,
    [Documento]             NVARCHAR (MAX) NULL,
    [EstatusAprobacion]     INT            NULL,
    [IsActivo]              BIT            NULL,
    [FechaRegistro]         DATETIME       NULL,
    [IdCuentaBancaria]      INT            NULL,
    [ComentarioCancelacion] NVARCHAR (MAX) NULL,
    [IdSubContratista]      INT            NULL,
    [IdTipoOperacion]       INT            NULL,
    [IdTipoDocumento]       INT            NULL,
    [EnviadoPor]            INT            NULL,
    [FileNameDoc]           VARCHAR (100)  NULL,
    CONSTRAINT [PK_PV_DocumentoCuentaBancaria] PRIMARY KEY CLUSTERED ([IdDocCuentaBancaria] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_DocumentoCuentaBancaria_PV_EstatusAprobacionCtaBancaria] FOREIGN KEY ([EstatusAprobacion]) REFERENCES [dbo].[PV_EstatusAprobacionCtaBancaria] ([IdEstatusCuentaBancaria]),
    CONSTRAINT [FK_PV_DocumentoCuentaBancaria_S_Proveedor] FOREIGN KEY ([EnviadoPor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_PV_DocumentoCuentaBancaria_S_TipoDocumento] FOREIGN KEY ([IdTipoDocumento]) REFERENCES [dbo].[S_TipoDocumento] ([IdTipoDocumento]),
    CONSTRAINT [FK_PV_DocumentoCuentaBancaria_TA_TipoOperacion] FOREIGN KEY ([IdTipoOperacion]) REFERENCES [dbo].[TA_TipoOperacion] ([IdTipoOperacion])
);

