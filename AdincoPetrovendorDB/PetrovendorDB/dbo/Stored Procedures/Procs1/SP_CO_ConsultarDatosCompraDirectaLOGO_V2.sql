-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-17
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultarDatosCompraDirectaLOGO_V2]
    -- Add the parameters for the stored procedure here
   
    
    @IdProveedor INT,
    @IdRegistro INT,
    @IdFactura INT,
		/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

    DECLARE @PROVEDORACTUAL VARCHAR(MAX),
            @RFCOperador NVARCHAR(50),
            @TelefonoOperadora NVARCHAR(30);

    SELECT @PROVEDORACTUAL = CONCAT(ISNULL(RazonSocial, ''), ' ', ISNULL(RegimenCapital, '')),
           @RFCOperador = RFC,
           @TelefonoOperadora = Telefono
    FROM S_Proveedor
    WHERE IdProveedor = @IdProveedor;
	

    DECLARE @PROVEDORACTUALDOMICILIO VARCHAR(MAX)
        =   (
                SELECT CONCAT(
                                 'Col.',
                                 ISNULL(DF.Colonia, ''),
                                 ' ',
                                 'Calle.',
                                 DF.NombreViabilidad,
                                 ' ',
                                 'N°Interior.',
                                 DF.NoExterior,
                                 ' ',
                                 'N°Exterior.',
                                 DF.NoInterior,
                                 ' ',
                                 'CP.',
                                 DF.CodigoPostal
                             )
                FROM S_Proveedor AS PV
                    INNER JOIN DG_Domicilio AS DF
                        ON DF.IdProveedor = PV.IdProveedor
                WHERE PV.IdProveedor = @IdProveedor
                      AND DF.IdTipoDomicilio = 1
                      AND DF.Activo = 1
            );
	
	DECLARE @PROVEEDORCAT NVARCHAR(MAX) = (SELECT Emisor FROM dbo.FI_Factura WHERE IdFactura = @IdFactura)

	DECLARE @EXISTEPROVEEDOR INT = (SELECT IdProveedor FROM dbo.S_Proveedor WHERE RFC = @PROVEEDORCAT)
	
		DECLARE @RazonSocialPV NVARCHAR(MAX) = ''
		DECLARE @DomicilioPV NVARCHAR(MAX) = ''
		DECLARE @CONTACTOPV NVARCHAR(MAX) = ''
		DECLARE @EMAILPV NVARCHAR(MAX) = ''
		DECLARE @TELEFONOPV NVARCHAR(MAX) = ''
		DECLARE @LOGOPV NVARCHAR(MAX) = ''

	IF(@EXISTEPROVEEDOR > 0)
	BEGIN
		SET @RazonSocialPV = (SELECT ISNULL(RazonSocial, '') + ' ' + ISNULL(RegimenCapital, '') FROM dbo.S_Proveedor WHERE IdProveedor = @EXISTEPROVEEDOR)
		SET @DomicilioPV = (SELECT CASE WHEN IdDomicilio IS NOT NULL THEN CONCAT('Col.', ISNULL(Colonia, ''),' ','Calle.',NombreViabilidad,' ','N°Interior.',NoExterior,' ','N°Exterior.',NoInterior,' ','CP.',CodigoPostal) ELSE ''END FROM dbo.DG_Domicilio WHERE IdProveedor = @EXISTEPROVEEDOR AND IdTipoDomicilio = 1 AND Activo = 1)
		SET @CONTACTOPV = (SELECT Nombres FROM dbo.S_Contacto_PA WHERE IdProveedor = @EXISTEPROVEEDOR AND IsPredeterminado = 1 AND IsEliminado = 0)
		SET @EMAILPV = (SELECT Email FROM dbo.S_Contacto_PA WHERE IdProveedor = @EXISTEPROVEEDOR AND IsPredeterminado = 1 AND IsEliminado = 0)
		SET @TELEFONOPV = (SELECT Telefono FROM dbo.S_Proveedor WHERE IdProveedor = @EXISTEPROVEEDOR)
		SET @LOGOPV = (SELECT Imagen FROM dbo.S_ImagenPerfil WHERE IdProveedor = @EXISTEPROVEEDOR)
		
		SELECT ImagenProveedor FROM dbo.S_ImagenPerfil WHERE IdProveedor = @EXISTEPROVEEDOR
	END
	ELSE
	BEGIN

		SET @RazonSocialPV = ''
		SET @DomicilioPV = ''
		SET @CONTACTOPV = ''
		SET @EMAILPV = ''
		SET @TELEFONOPV = ''
		SET @LOGOPV = NULL

    SELECT ImagenProveedor FROM dbo.S_ImagenPerfil WHERE IdProveedor = @EXISTEPROVEEDOR
	END
		  
END;
 
