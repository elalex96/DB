-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/12/2018
-- Description: Guardar factura extranjeros
-- =============================================
-- Author:		LUIS DAVID DE LA CRUZ
-- Update date: 05/08/2021
-- Description:	SE AGREGA LA COLUMNA BUCKET
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_InsFacturaExtranjero]
	-- Add the parameters for the stored procedure here
	@Folio NVARCHAR(MAX),
	@NumFactura NVARCHAR(MAX),
	@FechaFacturacion DATETIME,
	@IdMoneda INT,
	@SubTotal MONEY,
	@UnidadMedida INT,
	@Descripcion NVARCHAR(MAX),
	@IdUsuario INT,
	@IdContrato INT,
	@IdPedido NVARCHAR(50),
	@NombreDoc NVARCHAR(MAX),
	@Carpeta NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@Extension NVARCHAR(100),
	@Mime NVARCHAR(MAX),
	@IdOperadora INT,
	@IdVendor NVARCHAR(50),
	@Bucket VARCHAR(200)	= NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @IdUnidadAdinco int,
			@IdUnidadPetro int


	--DMORENO Asegurarse de obtener una unidad válida
	IF NOT EXISTS(
		select  1
		from Adinco..PV_MM_MaterialUnidad
		WHERE IdUnidad = @UnidadMedida
	)
	BEGIN		
		select @IdUnidadAdinco = IdUnidad 
		from Adinco..PV_MM_MaterialUnidad
		WHERE Unidad LIke '%NO%ESPECIFICADO%'

	END
	Else
	begin
		select @IdUnidadAdinco = IdUnidad 
		from Adinco..PV_MM_MaterialUnidad
		WHERE IdUnidad = @UnidadMedida
	End

	IF NOT EXISTS(
		select  1
		from PV_MM_MaterialUnidad
		WHERE IdUnidad = @UnidadMedida
	)
	BEGIN		
		select @IdUnidadPetro = IdUnidad 
		from PV_MM_MaterialUnidad
		WHERE Unidad LIke '%NO%ESPECIFICADO%'

	END
	Else
	Begin
		select @IdUnidadPetro = IdUnidad 
		from PV_MM_MaterialUnidad
		WHERE IdUnidad = @UnidadMedida
	End
	

    -- Insert statements for procedure here

	DECLARE @IdSubContratista INT = (SELECT TOP 1 PR.IdProveedor
										FROM Adinco.dbo.CO_SAPVendor AS V
										LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = V.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
										WHERE V.VendorIDSAP = @IdVendor)


	--INSERTADO DE PEDIMENTO COMPROBANTE EN PETROVENDOR
	DECLARE @IdPedimentoComprobantePetrovendor INT;
	INSERT INTO dbo.FI_PedimentoComprobante
	(
	    IdContrato,
	    NumeroPedimento,
	    FolioComprobante,
	    FechaPago,
	    IdSubcontratistaImportador,
	    IdSubcontratistaExportador,
	    IdMoneda,
	    CreadoPor,
	    CreadoEn,
	    IsActivo,
	    IdPedidoGeneral
	)
	VALUES
	(   @IdContrato,         -- IdContrato - int
	    @NumFactura,       -- NumeroPedimento - nvarchar(50)
	    @Folio,       -- FolioComprobante - nvarchar(50)
	    @FechaFacturacion, -- FechaPago - date
	    @IdOperadora,         -- IdSubcontratistaImportador - int
	    @IdSubContratista,         -- IdSubcontratistaExportador - int
	    @IdMoneda,
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEn - datetime
	    1,      -- IsActivo - bit
	    0         -- IdPedidoGeneral - int
	   );

	   SET @IdPedimentoComprobantePetrovendor = (@@IDENTITY);

	INSERT INTO dbo.FI_PedimentoComprobanteDetalle
	(
	    IdPedimentoComprobante,
	    IdUnidadMedida,
	    DescripcionMercancia,
	    PrecioUnitario,
	    CreadoPor,
	    CreadoEn,
	    IsActivo
	)
	VALUES
	(   @IdPedimentoComprobantePetrovendor,         -- IdPedimentoComprobante - int
	    @IdUnidadPetro,         -- IdUnidadMedida - int
	    @Descripcion,       -- DescripcionMercancia - nvarchar(max)
	    @SubTotal,      -- PrecioUnitario - money
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEn - datetime
	    1      -- IsActivo - bit
	  )

	--INSERTADO DE PEDIMENTO COMPROBANTE EN ADINCO
	DECLARE @IdPedimentoComprobanteADINCO INT;
	INSERT INTO Adinco.dbo.FI_PedimentoComprobante
	(
	    IdContrato,
	    NumeroPedimento,
	    FolioComprobante,
	    FechaPago,
	    --IdSubcontratistaImportador,
	    --IdSubcontratistaExportador,
	    IdMoneda,
	    CreadoPor,
	    CreadoEn,
	    Activo,
	    IdPedimentoComprobantePetrovendor
	)
	VALUES
	(   @IdContrato,         -- IdContrato - int
	    @NumFactura,       -- NumeroPedimento - nvarchar(50)
	    @Folio,       -- FolioComprobante - nvarchar(50)
	    @FechaFacturacion, -- FechaPago - date
	    --@IdOperadora,         -- IdSubcontratistaImportador - int
	    --@IdSubContratista,         -- IdSubcontratistaExportador - int
	    @IdMoneda,         -- IdMoneda - int
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEn - datetime
	    1,      -- Activo - bit
	    @IdPedimentoComprobantePetrovendor         -- IdPedimentoComprobantePetrovendor - int
	    );

	SET @IdPedimentoComprobanteADINCO = (@@IDENTITY);

	INSERT INTO Adinco.dbo.FI_PedimentoComprobanteDetalle
	(
	    IdPedimentoComprobante,
	    IdUnidadMedida,
	    DescripcionMercancia,
	    PrecioUnitario,
	    CreadoPor,
	    CreadoEn
	)
	VALUES
	(   @IdPedimentoComprobanteADINCO,         -- IdPedimentoComprobante - int
	    @IdUnidadAdinco,         -- IdUnidadMedida - int
	    @Descripcion,       -- DescripcionMercancia - nvarchar(max)
	    @SubTotal,      -- PrecioUnitario - money
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE() -- CreadoEn - datetime
	    );

	--GUARDADO DE LA RELACION PEDIDO-PEDIMENTO COMPROBANTE - ARCHIVO S3
	INSERT INTO dbo.MPY_FI_RelacionPedimentoComprobantePedido
	(
	    IdPedido,
	    NombreDoc,
		IdPedimentoComprobanteADINCO,
	    Carpeta,
	    Identificador,
	    Extension,
	    Mime,
	    Activo,
	    CreadoPor,
	    CreadoEl,
		IdProveedorVenta,
		Bucket
	)
	VALUES
	(   @IdPedido,        -- IdPedido - int
	    @NombreDoc,      -- NombreDoc - nvarchar(max)
		@IdPedimentoComprobanteADINCO,
	    @Carpeta,       -- Carpeta - varchar(300)
	    @Identificador,       -- Identificador - varchar(300)
	    @Extension,       -- Extension - varchar(300)
	    @Mime,      -- Mime - nvarchar(300)
	    1,     -- Activo - bit
	    @IdUsuario,        -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
		@IdVendor,
		@Bucket
	    ); 

		

	SELECT @@IDENTITY
END