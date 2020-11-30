CREATE TABLE [dbo].[PS_Proveedor] (
    [IdPSProveedor]     INT            IDENTITY (1, 1) NOT NULL,
    [Proveedor]         INT            NULL,
    [NombreComercial]   NVARCHAR (MAX) NULL,
    [Giro]              INT            NOT NULL,
    [Tipo]              INT            NOT NULL,
    [Ofrece]            INT            NOT NULL,
    [Ramo]              INT            NOT NULL,
    [PaisOrigen]        NVARCHAR (MAX) NULL,
    [NumeroEmpleados]   INT            NULL,
    [RegionesAtendidas] NVARCHAR (MAX) NULL,
    [TelContacto]       NVARCHAR (10)  NOT NULL,
    [EmailContacto]     NVARCHAR (MAX) NOT NULL,
    [Facebook]          NVARCHAR (MAX) NULL,
    [Twitter]           NVARCHAR (MAX) NULL,
    [Skipe]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PS_Proveedor] PRIMARY KEY CLUSTERED ([IdPSProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PS_Proveedor_S_GiroProveedor] FOREIGN KEY ([Giro]) REFERENCES [dbo].[PV_GiroEmpresarial] ([IdGiroProveedor]),
    CONSTRAINT [FK_PS_Proveedor_S_Ofrece] FOREIGN KEY ([Ofrece]) REFERENCES [dbo].[S_Ofrece] ([IdOfrece]),
    CONSTRAINT [FK_PS_Proveedor_S_Proveedor] FOREIGN KEY ([Proveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_PS_Proveedor_S_Ramo] FOREIGN KEY ([Ramo]) REFERENCES [dbo].[S_Ramo] ([IdRamo]),
    CONSTRAINT [FK_PS_Proveedor_S_TipoProveedor] FOREIGN KEY ([Tipo]) REFERENCES [dbo].[S_TipoProveedor] ([IdTipoProveedor])
);

