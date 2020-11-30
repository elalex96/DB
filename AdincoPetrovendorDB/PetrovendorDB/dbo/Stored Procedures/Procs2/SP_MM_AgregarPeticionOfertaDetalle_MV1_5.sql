-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 19-04-17
-- Description:	SP que agrega Detalle Peticion de Oferta
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 09-07-2019
-- Description:	se agrega la validacion y los campos necesarios para la restriccion d ela cotizacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarPeticionOfertaDetalle_MV1_5]
		
		@IdPeticionOferta int,
		@IdMaterial int, 
		@ComentarioComprador nvarchar(MAX), 
        @NoMaterialesRequeridos FLOAT,
		@IdUsuario int, 
		@IdProveedor int, 
		@IdSolicitudPedidoDetalle INT,
		@IdUnidad INT,
		/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/
            

AS
BEGIN
 
	SET NOCOUNT ON;
	DECLARE @NoOFerta INT
    
	DECLARE @CotizacionRestringida BIT = (SELECT ISNULL(CotizacionRestringida,0) FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta = @IdPeticionOferta);

	 --- Agregar Petición Oferta Detalle ---
	 IF @CotizacionRestringida > 0
	 BEGIN
	     INSERT INTO MM_PeticionOfertaDetalle(IdPeticionOferta,IdSolicitudPedidoDetalle,IdMaterial,IdMaterialVendedor,ComentariosComprador,CreadoEl,CreadoPor,Activo,NoMaterialesRequeridos,IdProveedorVenta,Cotizado,IdUnidad,IdUnidadProveedor)
			VALUES(@IdPeticionOferta,@IdSolicitudPedidoDetalle,@IdMaterial,@IdMaterial,@ComentarioComprador,GETDATE(),@IdUsuario,1,@NoMaterialesRequeridos,@IdProveedor,0, @IdUnidad,@IdUnidad)
	 END
	 ELSE
	 BEGIN
	     INSERT INTO MM_PeticionOfertaDetalle(IdPeticionOferta,IdSolicitudPedidoDetalle,IdMaterial,ComentariosComprador,CreadoEl,CreadoPor,Activo,NoMaterialesRequeridos,IdProveedorVenta,Cotizado,IdUnidad)
			VALUES(@IdPeticionOferta,@IdSolicitudPedidoDetalle,@IdMaterial,@ComentarioComprador,GETDATE(),@IdUsuario,1,@NoMaterialesRequeridos,@IdProveedor,0, @IdUnidad)
	 END

	 
	 
	 
	 SELECT 'Success' AS Success

	
END
