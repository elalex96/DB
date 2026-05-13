--**************************************************************
-- Modificado por:      <Jose Roman>								
-- Updated date: <09/01/2018>									
-- Description: <Se agrega parametros TerminosYcondicions y Verificable como parametros de contrato>			
--**************************************************************
-- Modificado por:      <Alexander Gomez>								
-- Updated date: <12-07-2019>									
-- Description: <se agrega la importacion de materiales en la cotizacion restringida>			
--**************************************************************
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarEstatusOfertaV2]
	@IdPeticionOferta INT,
	@IdUsuario INT,
	@IdOperacion INT,
	@IdEstatusEdicionCotizacion INT,
	@IdEdicionCotizacion INT,
	@IdProveedor INT,
	@TerminosCondiciones BIT,
	@Verificable BIT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN
  DECLARE @detallesCotizados INT,
			@detallesNoCotizados INT,
			@totalDetalles INT,
			@suma INT,
			@IdEstatus INT = 1,
			@Detalle NVARCHAR(MAX),
			@Cotizado_Actual BIT,
			@NOMBRE_USUARIO NVARCHAR(350)

  SET @detallesCotizados = (SELECT COUNT(IdPeticionOfertaDetalle)
							 FROM dbo.MM_PeticionOfertaDetalle 
							 WHERE IdPeticionOferta = @IdPeticionOferta AND Cotizado = 1)

  SET @detallesNoCotizados = (SELECT COUNT(IdPeticionOfertaDetalle)
							 FROM dbo.MM_PeticionOfertaDetalle 
							 WHERE IdPeticionOferta = @IdPeticionOferta AND NoCotizar = 1)

  SET @totalDetalles = (SELECT COUNT(IdPeticionOfertaDetalle)
							 FROM dbo.MM_PeticionOfertaDetalle 
							 WHERE IdPeticionOferta = @IdPeticionOferta )

	SET @suma = @detallesCotizados + @detallesNoCotizados

	IF(@suma >= @totalDetalles)
	BEGIN
		
		IF @IdEdicionCotizacion <> 0 AND @IdEstatusEdicionCotizacion = 1 
		BEGIN 
			SET @Cotizado_Actual =(SELECT Cotizado FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta= @IdPeticionOferta)

			IF @Cotizado_Actual <> 1 
			BEGIN 
				 SET @Detalle = 'Se cambio de No Cotizar a Cotizar' 
				 INSERT INTO MM_HistorialEdicionCotizacion(
				 [IdEdicionCotizacion],		     
				 [IdUsuario],
				 [IdProveedor],
				 [Fecha],
				 [Descripcion]
				 )
				 VALUES(
				 @IdEdicionCotizacion,
				 @IdUsuario,
				 @IdProveedor,
				 GETDATE(),	
				 @Detalle
				 )

			END 
		END 

		UPDATE MM_PeticionOferta 
		SET Cotizado = 1,
			NoCotizar=0,
			FechaFinalizado = GETDATE(),
			IdEstatus = 2,
			ModificadoPor = @IdUsuario,
			AceptoTerminosCondiciones = @TerminosCondiciones,
			Verificable = @Verificable
		WHERE IdPeticionOferta = @IdPeticionOferta

		IF @IdEdicionCotizacion <> 0 AND @IdEstatusEdicionCotizacion = 1 
		BEGIN 

			 UPDATE dbo.MM_EdicionCotizacion
			 SET ModificadoEl = GETDATE(),
			 ModificadoPor = @IdUsuario,
			 IdEstatus = 2 --ESTATUS APROBADO = EN EDICION FINALIZADA
			 WHERE IdEdicionCotizacion = @IdEdicionCotizacion

			 SET @NOMBRE_USUARIO = (SELECT Nombre FROM S_Usuario WHERE IdUsuario=@IdUsuario)
			 SET @DETALLE = ('Edición finalizada')

			  INSERT INTO MM_HistorialEdicionCotizacion(
				 [IdEdicionCotizacion],		     
				 [IdUsuario],
				 [IdProveedor],
				 [Fecha],
				 [EdicionCabecera],
				 [Descripcion]
				 )
				 VALUES(
				 @IdEdicionCotizacion,
				 @IdUsuario,
				 @IdProveedor,
				 GETDATE(),
				 1,
				 @DETALLE
				 )
		END 


		EXEC SP_MM_ActualizarEstatusOperacionOferta @IdOperacion, @IdEstatus OUTPUT

		DECLARE @COTIZACIONRESTRINGIDA BIT = (SELECT CotizacionRestringida FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta = @IdPeticionOferta);
        
		IF @COTIZACIONRESTRINGIDA = 1
		BEGIN
		    EXEC dbo.SP_MM_PR_ImportarMaterialesCotizados @IdPeticionOferta,@IdProveedor,@IdUsuario;
		END
		         -- int
		

		IF @IdEstatus = 2
				--- Enviar Información del Proveedor Cliente, para Notificar 
		BEGIN
			SELECT  'COTIZACION_TERMINADA' AS RESPONSE
					
		END
        ELSE
        BEGIN
			SELECT 'COTIZACION_PENDIENTE' AS RESPONSE
        end
    END
    ELSE
    BEGIN
		SELECT 'COTIZACION_INCOMPLETA' AS RESPONSE
    end

END
