CREATE TABLE [dbo].[BI_Aprobaciones] (
    [IdAprobacion]   INT           IDENTITY (1, 1) NOT NULL,
    [IdPedidoUnico]  INT           NULL,
    [IdRequicion]    INT           NULL,
    [Aprobador1]     DATETIME      NULL,
    [Aprobador2]     DATETIME      NULL,
    [Aprobador3]     DATETIME      NULL,
    [Aprobador4]     DATETIME      NULL,
    [Aprobador5]     DATETIME      NULL,
    [Aprobador6]     DATETIME      NULL,
    [TipoAprobacion] VARCHAR (200) NULL,
    CONSTRAINT [PK_BI_Aprobaciones] PRIMARY KEY CLUSTERED ([IdAprobacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

