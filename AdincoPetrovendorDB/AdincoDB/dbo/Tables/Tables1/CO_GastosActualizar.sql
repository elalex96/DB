CREATE TABLE [dbo].[CO_GastosActualizar] (
    [Id]                 INT           NOT NULL,
    [UUIDImport]         VARCHAR (100) NOT NULL,
    [RFCEmisor]          VARCHAR (18)  NOT NULL,
    [UUID]               VARCHAR (100) NOT NULL,
    [CuentaContable]     VARCHAR (20)  NOT NULL,
    [Poliza]             VARCHAR (20)  NOT NULL,
    [GastoAdmon]         BIT           NOT NULL,
    [Procesado]          BIT           NOT NULL,
    [Error]              BIT           NULL,
    [ErrorDesc]          VARCHAR (150) NULL,
    [CreadoEl]           DATETIME      NOT NULL,
    [CreadoPor]          INT           NOT NULL,
    [IdLineaPresupuesto] INT           NULL,
    CONSTRAINT [PK_CO_GastosActualizar_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

