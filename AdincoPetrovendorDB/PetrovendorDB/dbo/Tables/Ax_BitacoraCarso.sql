CREATE TABLE [dbo].[Ax_BitacoraCarso] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [ErrorMotivo]      NVARCHAR (MAX)  NULL,
    [Lugar]            NVARCHAR (MAX)  NULL,
    [Comparativa]      NVARCHAR (MAX)  NULL,
    [DataAreaId]       NVARCHAR (100)  NULL,
    [RecId]            NVARCHAR (1000) NULL,
    [Accion]           NVARCHAR (1000) NULL,
    [FechaRegistro]    DATETIME        NULL,
    [IdPedido]         INT             NULL,
    [IdOc]             NVARCHAR (MAX)  NULL,
    [ItemAceptacion]   NVARCHAR (MAX)  NULL,
    [UUID_Principal]   NVARCHAR (MAX)  NULL,
    [UUID_Complemento] NVARCHAR (MAX)  NULL,
    [IdAsientoPago]    NVARCHAR (MAX)  NULL
);

