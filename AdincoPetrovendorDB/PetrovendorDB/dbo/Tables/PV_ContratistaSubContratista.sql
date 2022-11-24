CREATE TABLE [dbo].[PV_ContratistaSubContratista] (
    [IdRelacion]       INT            IDENTITY (1, 1) NOT NULL,
    [IdContratista]    INT            NOT NULL,
    [IdSubContratista] INT            NOT NULL,
    [IsActivo]         BIT            NULL,
    [FechaRegistro]    DATETIME       NULL,
    [Correo]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PV_ContratistaSubContratista] PRIMARY KEY CLUSTERED ([IdRelacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_ContratistaSubContratista_S_Proveedor] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_PV_ContratistaSubContratista_S_Proveedor1] FOREIGN KEY ([IdSubContratista]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

