CREATE TABLE [dbo].[PC_UnidadMedidaVenta] (
    [IdUnidadMedida] INT           IDENTITY (10000, 1) NOT NULL,
    [UnidadMedida]   NVARCHAR (10) NULL,
    [CreadoPor]      INT           NULL,
    [CreadoEn]       DATETIME      NULL,
    CONSTRAINT [PK_PC_UnidadMedidaVenta] PRIMARY KEY CLUSTERED ([IdUnidadMedida] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

