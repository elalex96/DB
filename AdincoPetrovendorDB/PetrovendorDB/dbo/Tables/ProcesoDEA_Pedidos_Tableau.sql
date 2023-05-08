CREATE TABLE [dbo].[ProcesoDEA_Pedidos_Tableau] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT            NULL,
    [CentroCosto]       NVARCHAR (100) NULL,
    [Requisitor]        NVARCHAR (100) NULL,
    [FechaRegistro]     DATETIME       NULL,
    [FechaAccion]       DATETIME       NULL,
    [Usuario]           NVARCHAR (100) NULL,
    [Accion]            NVARCHAR (100) NULL,
    [Estatus]           NVARCHAR (100) NULL,
    [Tiempo]            DECIMAL (5, 2) NULL
);

