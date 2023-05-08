-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-17
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultarDatosCompraDirectaEmisor] --44, 5879,18346
    -- Add the parameters for the stored procedure here
   
    
    @IdProveedor INT,
    @IdRegistro INT,
    @IdFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
	/*-------------------------------------------------------------*/
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @PROVEEDORCAT NVARCHAR(MAX) = (SELECT Emisor FROM dbo.FI_Factura WHERE IdFactura = @IdFactura)

	DECLARE @EXISTEPROVEEDOR INT = (SELECT IdProveedor FROM dbo.S_Proveedor WHERE RFC = @PROVEEDORCAT)
	
		DECLARE @RazonSocialPV NVARCHAR(MAX) = '';
		DECLARE @DomicilioPV NVARCHAR(MAX) = '';
		DECLARE @CONTACTOPV NVARCHAR(MAX) = '';
		DECLARE @EMAILPV NVARCHAR(MAX) = '';
		DECLARE @TELEFONOPV NVARCHAR(MAX) = '';

	IF(@EXISTEPROVEEDOR > 0)
	BEGIN
		SET @RazonSocialPV = (SELECT ISNULL(RazonSocial, '') + ' ' + ISNULL(RegimenCapital, '') FROM dbo.S_Proveedor WHERE IdProveedor = @EXISTEPROVEEDOR)
		SET @DomicilioPV = (SELECT CASE WHEN IdDomicilio IS NOT NULL THEN CONCAT('Col.', ISNULL(Colonia, ''),' ','Calle.',Calle,' ','N°Interior.',NoExterior,' ','N°Exterior.',NoInterior,' ','CP.',CodigoPostal) ELSE ''END FROM dbo.DG_Domicilio WHERE IdProveedor = @EXISTEPROVEEDOR AND IdTipoDomicilio = 1 AND Activo = 1)
		SET @CONTACTOPV = (SELECT Nombres FROM dbo.S_Contacto_PA WHERE IdProveedor = @EXISTEPROVEEDOR AND IsPredeterminado = 1 AND IsEliminado = 0)
		SET @EMAILPV = (SELECT Email FROM dbo.S_Contacto_PA WHERE IdProveedor = @EXISTEPROVEEDOR AND IsPredeterminado = 1 AND IsEliminado = 0)
		SET @TELEFONOPV = (SELECT Telefono FROM dbo.S_Proveedor WHERE IdProveedor = @EXISTEPROVEEDOR)
	END

    SELECT @RazonSocialPV AS RazonSocial,@PROVEEDORCAT AS RFC, @DomicilioPV AS Domicilios, @CONTACTOPV AS Contacto, @EMAILPV AS Email, @TELEFONOPV AS Telefono, ImagenProveedor AS Imagen FROM dbo.S_ImagenPerfil WHERE IdProveedor = @EXISTEPROVEEDOR

END;
 
