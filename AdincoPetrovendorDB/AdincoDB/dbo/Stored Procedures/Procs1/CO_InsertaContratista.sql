-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/06/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_InsertaContratista]
    @NombreContratista nvarchar(4000),
    @Representante nvarchar(4000),
    @PuestoRepresentante nvarchar(4000),
    @RazonSocial nvarchar(4000),
    @Calle nvarchar(4000),
    @Numero nvarchar(4000),
    @Colonia nvarchar(4000),
    @Municipio nvarchar(4000),
    @Entidad nvarchar(4000),
    @CodigoPostal nvarchar(4000),
    @Pais nvarchar(4000),
    @RFC nvarchar(4000),
    @CorreoElectronico nvarchar(4000),
    @Telefono nvarchar(4000),
    @PaginaWeb nvarchar(4000),
    @DocumentoLegal nvarchar(4000),
    @idSipac nvarchar(4000),
    @idProveedor int,
    @Logo image,
    @idContrato int,
    @idUsuario int,
    @idRuta INT,
    @DefaultPage VARCHAR(100),
    @Abreviatura VARCHAR(7),
    @ContratistaFicticio BIT
AS
BEGIN
    INSERT INTO co_contratista
    (
        NombreContratista,
        Representante,
        PuestoRepresentante,
        RazonSocial,
        Calle,
        Numero,
        Colonia,
        Municipio,
        Entidad,
        CodigoPostal,
        Pais,
        RFC,
        CorreoElectronico,
        Telefono,
        PaginaWeb,
        DocumentoLegal,
        idSipac,
        idProveedor,
        Logo,
        CreadoPor,
        DefaultPage,
        IdRuta,
        Abreviatura,
        ContratistaFicticio
    )
    VALUES
    (@NombreContratista,
     @Representante,
     @PuestoRepresentante,
     @RazonSocial,
     @Calle,
     @Numero,
     @Colonia,
     @Municipio,
     @Entidad,
     @CodigoPostal,
     @Pais,
     @RFC,
     @CorreoElectronico,
     @Telefono,
     @PaginaWeb,
     @DocumentoLegal,
     @idSipac,
     @idProveedor,
     @Logo,
     @idUsuario,
     @DefaultPage,
     @IdRuta,
     @Abreviatura,
     @ContratistaFicticio
    )

END