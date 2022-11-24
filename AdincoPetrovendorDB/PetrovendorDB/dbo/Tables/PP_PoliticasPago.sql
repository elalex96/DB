CREATE TABLE [dbo].[PP_PoliticasPago] (
    [IdPolicitaPago]   INT            IDENTITY (1, 1) NOT NULL,
    [PoliticaPago]     NVARCHAR (MAX) NOT NULL,
    [FechaRegistro]    SMALLDATETIME  NOT NULL,
    [IdUsuarioCreador] INT            NOT NULL,
    [IdProveedor]      INT            NOT NULL,
    CONSTRAINT [PK_PP_PoliticasPago] PRIMARY KEY CLUSTERED ([IdPolicitaPago] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PP_PoliticasPago_S_Proveedor1] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_PP_PoliticasPago_S_Usuario1] FOREIGN KEY ([IdUsuarioCreador]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

