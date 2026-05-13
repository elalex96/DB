CREATE TABLE [dbo].[PV_Gasto] (
    [idGasto]        INT            IDENTITY (1, 1) NOT NULL,
    [IdBeneficiario] INT            NULL,
    [Concepto]       VARCHAR (MAX)  NOT NULL,
    [NumeroFactura]  NVARCHAR (MAX) NULL,
    [Monto]          FLOAT (53)     NOT NULL,
    [idMoneda]       INT            NOT NULL,
    [IdUnidad]       INT            NOT NULL,
    [IdMetodoPago]   INT            NULL,
    [PagadoPor]      NVARCHAR (MAX) NULL,
    [Cuenta]         NVARCHAR (MAX) NULL,
    [Comentario]     NVARCHAR (MAX) NULL,
    [FechaRegistro]  DATETIME       NOT NULL,
    [Comision]       MONEY          NULL,
    [IVA]            MONEY          NULL,
    [IdUsuario]      INT            NOT NULL,
    CONSTRAINT [PK_Gasto] PRIMARY KEY CLUSTERED ([idGasto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_Gasto_PV_TipoMoneda] FOREIGN KEY ([idMoneda]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda]),
    CONSTRAINT [FK_PV_Gasto_PV_Unidad] FOREIGN KEY ([IdUnidad]) REFERENCES [dbo].[PV_Unidad] ([idUnidad])
);

