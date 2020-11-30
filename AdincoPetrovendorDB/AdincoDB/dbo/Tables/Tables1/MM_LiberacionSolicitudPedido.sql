CREATE TABLE [dbo].[MM_LiberacionSolicitudPedido] (
    [IdLiberacion]      INT IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT NULL,
    [IdUsuario]         INT NULL,
    [Estado]            INT NULL,
    CONSTRAINT [PK_MM_LiberacionSolicitudPedido] PRIMARY KEY CLUSTERED ([IdLiberacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

