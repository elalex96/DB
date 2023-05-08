CREATE TABLE [dbo].[IM_Facturas] (
    [IdNombres]   INT            IDENTITY (1, 1) NOT NULL,
    [Nombres]     NVARCHAR (MAX) NULL,
    [IdProveedor] INT            NULL,
    [IdFactura]   INT            NULL
);

