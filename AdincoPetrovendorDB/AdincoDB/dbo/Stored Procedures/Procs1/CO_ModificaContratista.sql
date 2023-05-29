-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/06/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_ModificaContratista]
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
    @idContratista int,
    @idContrato int,
    @idUsuario int,
    @idRuta INT,
    @DefaultPage VARCHAR(100),
    @Abreviatura VARCHAR(7),
    @ContratistaFicticio BIT
AS
BEGIN

    Update co_contratista
    Set NombreContratista = @NombreContratista,
        Representante = @Representante,
        PuestoRepresentante = @PuestoRepresentante,
        RazonSocial = @RazonSocial,
        Calle = @Calle,
        Numero = @Numero,
        Colonia = @Colonia,
        Municipio = @Municipio,
        Entidad = @Entidad,
        CodigoPostal = @CodigoPostal,
        Pais = @Pais,
        RFC = @RFC,
        CorreoElectronico = @CorreoElectronico,
        Telefono = @Telefono,
        PaginaWeb = @PaginaWeb,
        DocumentoLegal = @DocumentoLegal,
        IDSIPAC = @idSipac,
        idProveedor = @idProveedor,
        Logo = @Logo,
        DefaultPage = @DefaultPage,
        IdRuta = @idRuta,
        Abreviatura = @Abreviatura,
        ContratistaFicticio = @ContratistaFicticio
    Where idcontratista = @idContratista

END