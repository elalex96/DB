CREATE TABLE [dbo].[IM_ArchivoTxt] (
    [IdNombreFactura] INT            IDENTITY (1, 1) NOT NULL,
    [NombreFactura]   NVARCHAR (255) NULL,
    [IdProveedor]     INT            NULL,
    [IdFactura]       INT            NULL
);

