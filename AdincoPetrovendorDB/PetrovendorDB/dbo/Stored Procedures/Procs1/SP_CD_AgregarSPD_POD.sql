-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 19-04-17
-- Description:	SP que agrega Detalle Peticion de Oferta
-- =============================================
CREATE PROCEDURE [dbo].[SP_CD_AgregarSPD_POD]
    @IdSolicitudPedido INT,
    @IdPeticionOferta INT,
    @IdProveedorCompraDirecta INT,
    @IdProveedor INT,
    @IdMaterial INT,
    @Cantidad FLOAT,
    @ComentarioComprador NVARCHAR(MAX),
    @CreadoPor INT,
    @IdUnidad INT,
    @IdDomicilioEntrega INT,
    @IdCentroCosto INT,
    @MaterialConcepto NVARCHAR(MAX),
    @Cotizar BIT,
    @NoCotizar BIT,
    @ComentariosSubContratista NVARCHAR(MAX),
    @Disponibilidad FLOAT,
    @FechaVigencia DATETIME,
    @PrecioUnitario DECIMAL,
    @SubTotal DECIMAL,
    @NoMaterialesRequeridos INT,   
	@IdSubFamilia INT,
	@IdMonedaFactura INT
	
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @IdSolicitudPedidoDetalle INT;
	DECLARE @IdMaterialVendedor INT;

    --- Agregar Petición Oferta ---
    INSERT INTO [dbo].[MM_SolicitudPedidoDetalle]
    ([IdSolicitudPedido],
    [IdMaterial],
    [Fecha],
    [Cantidad],
    [observaciones],
    [CreadoPor],
    [IdUnidad],
    [IdCentroCosto],
    [IdDomicilioEntrega])
    VALUES
    (@IdSolicitudPedido,
	 @IdMaterial, 
	 GETDATE(), 
	 @Cantidad, 
	 @ComentarioComprador, 
	 @CreadoPor, 
	 @IdUnidad,
     @IdCentroCosto, 
	 @IdDomicilioEntrega);


    SET @IdSolicitudPedidoDetalle =(SELECT @@Identity);


   INSERT INTO dbo.MM_Material
   (
       IdProveedor,
       IdSubFamilia,
       IdUnidad,
       DescripcionCorta,
       DescripcionLarga,
       FechaAlta,
       Activo,
       IsEliminado,
       CreadoPor,      
       IdMaestro,
       NoSecuencia
   )
   VALUES
   (   @IdProveedorCompraDirecta,         -- IdProveedor - int
       @IdSubFamilia,         -- IdSubFamilia - int
       @IdUnidad,         -- IdUnidad - int      
       @MaterialConcepto,  -- DescripcionCorta - nvarchar(max) 
	   @ComentariosSubContratista,       
       GETDATE(), -- FechaAlta - datetime       
       0,      -- Activo - bit
       0,      -- IsEliminado - bit
       0,         -- CreadoPor - int      
       @IdMaterial,         -- IdMaestro - int
       0          -- NoSecuencia - int
     )


	 SET @IdMaterialVendedor =  (SELECT @@Identity);

	   
		INSERT INTO dbo.MM_MaterialesVentaProveedor
		(
		IdProveedor,
		IdMaterial,		
		CreadoEn,
		IsActivo,
		IsEliminado
		)
		VALUES
		(
		@IdProveedorCompraDirecta,
		@IdMaterialVendedor,		
		GETDATE(),
		0,
		0
		)

    INSERT INTO MM_PeticionOfertaDetalle
    (
        IdPeticionOferta,
        IdSolicitudPedidoDetalle,
        IdMaterial,
        ComentariosComprador,
        CreadoEl,
        CreadoPor,
        Activo,
        NoMaterialesRequeridos,
        IdProveedorVenta,
        Cotizado,
		NoCotizar,
		PrecioUnitario,
		SubTotal,
		IdMoneda,
	    Disponibilidad,
        ComentarioSubcontratista,
        IdEstatus,
		ModificadoPor,
	    ModificadoEl,
		FechaVigencia,
		IdMaterialVendedor
    )
    VALUES
    (@IdPeticionOferta, @IdSolicitudPedidoDetalle, @IdMaterial, @ComentarioComprador, GETDATE(), @CreadoPor, 1,
     @NoMaterialesRequeridos, @IdProveedorCompraDirecta, @Cotizar,@NoCotizar, @PrecioUnitario, @SubTotal,@IdMonedaFactura, @Disponibilidad, @ComentariosSubContratista,2, @CreadoPor, GETDATE(),@FechaVigencia, @IdMaterialVendedor);

	 
    SELECT 'Success' AS Success


END
