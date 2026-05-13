-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-17
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultarDatosCompraDirecta_V2] --44, 5879,18346
    -- Add the parameters for the stored procedure here
   
    
    @IdProveedor INT,
    @IdRegistro INT,
    @IdFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT=NULL,
    @IdUsuario     INT=NULL,
    @FechaRegistro DATETIME=NULL
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
                                 DF.Calle,
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
	END

    SELECT

        --Operadora 
        @PROVEDORACTUAL AS NombreOperador,
        @PROVEDORACTUALDOMICILIO AS DireccionFisicaOperador,
        @RFCOperador AS RFCOperador,
        U.Nombre AS ContactoOperadora,
        U.Correo AS ContactoOperadoraCorreo,
        @TelefonoOperadora AS TelefonoOperadora,
        PG.IdPedido AS OrdenCompra,
        CONVERT(NVARCHAR(MAX),O.FechaRegistro,103) + CONVERT(NVARCHAR(MAX),O.FechaRegistro,108) AS FechaRegistro,
        contrato.NumeroContrato,
        areaContractual.NombreAreaContractual AS CampoBloque,
        U.Nombre AS Solicitante,
        centroCostoOp.CentroCosto AS CentroCostoOperadora,

        --Datos del Proveedor
        ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
        F.Emisor AS RFCProveedor,
        (CASE
             WHEN DG.IdDomicilio IS NOT NULL THEN
                 CONCAT(
                           'Col.',
                           ISNULL(DG.Colonia, ''),
                           ' ',
                           'Calle.',
                           DG.Calle,
                           ' ',
                           'N°Interior.',
                           DG.NoExterior,
                           ' ',
                           'N°Exterior.',
                           DG.NoInterior,
                           ' ',
                           'CP.',
                           DG.CodigoPostal
                       )
             ELSE
                 ''
         END
        ) AS DomicilioProveedor,
		@CONTACTOPV AS ContactoProveedor,
		@EMAILPV AS EmailProveedor,
		@TELEFONOPV as TelefonoProveedor,
		@LOGOPV AS LogoProveedor,
        --Especificaciones de la compra
        '' AS TipoCompra,
        TM.TipoMonedaCorto,
        @TelefonoOperadora AS CompraTelefono,
        U.Correo AS CompraMail,

        --Materiales y Elaboro
        F.SubTotal,
        '' AS CantidadConLetra,
        C.IdRegistro,
        F.MontoConIva,
        0 AS IVA,
        F.Descuento,
        PR.Nombre,
        U.Nombre AS Asignador,
        F.CondicionesDePago,
        U.Nombre AS Elaboro,
		CONVERT(NVARCHAR(MAX),F.CreadoEn,103) +' '+ CONVERT(NVARCHAR(MAX),F.CreadoEn,108) AS ElaboroFecha,
        --F.CreadoEn AS ElaboroFecha,
        c.Comentarios AS ComentariosComprador,
		o.IdFirma
    FROM dbo.FI_Factura F
        INNER JOIN dbo.CO_Registro C
            ON C.IdFactura = F.IdFactura
        INNER JOIN dbo.S_Proveedor PV
            ON PV.RFC = F.Emisor
        INNER JOIN dbo.TA_Operacion O
            ON O.IdDocumento = F.IdFactura
        INNER JOIN dbo.TA_Estatus E
            ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN dbo.PV_TipoMoneda TM
            ON TM.IdMoneda = F.IdMoneda
        INNER JOIN dbo.TA_Prioridad PR
            ON PR.IdPrioridad = O.IdPrioridad
        LEFT JOIN dbo.S_Usuario U
            ON U.IdUsuario = O.IdAsignador
        LEFT JOIN dbo.MM_Pedidos PG
            ON PG.IdIdentificador = O.IdDocumento
               AND PG.IdTipoPedido = 1
               AND O.IdProveedor = PG.IdProveedorCliente
        LEFT JOIN CO_LineaPresupuestoMes lineaPresupuesto
            ON lineaPresupuesto.IdInstalacion = C.IdInstalacion
        LEFT JOIN Adinco.dbo.CO_Area area
            ON area.IdArea = lineaPresupuesto.IdArea
        LEFT JOIN Adinco.dbo.CO_Contrato contrato
            ON contrato.IdContrato = area.IdContrato
        LEFT JOIN Adinco.dbo.CO_AreaContractual areaContractual
            ON areaContractual.IdAreaContractual = contrato.IdAreaContractual
        LEFT JOIN dbo.CC_CentroCosto centroCostoOp
            ON centroCostoOp.IdCentroCosto = C.CentroCostos
        LEFT JOIN dbo.DG_Domicilio AS DG
            ON DG.IdProveedor = PV.IdProveedor
               AND DG.IdTipoDomicilio = 1
               AND DG.Activo = 1
    WHERE F.IdFactura = @IdFactura
          AND C.IdRegistro = @IdRegistro
          AND O.IdTipoOperacion = 14;

		  
END;
 
