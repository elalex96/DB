-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar detalle de la cotización del lado de procura
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Agregue left join para obtener el registro de Edición de cotización
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarEdicionCotizacionMaterialHistorial]  
	-- Add the parameters for the stored procedure here

@IdProveedorActual INT,
@IdEdicionCotizacion INT,
@IdPeticionOfertaDetalle INT,
@PrecioUnitario FLOAT,
@Disponibilidad INT, 
@IdMoneda INT,
@ComentarioSubcontratista nvarchar(max),
@IdUsuario INT,
@IdMaterialVendedor INT,
@IdPeticionOferta INT,
@FechaVigencia DATETIME,
@NoCotizar BIT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
         SET NOCOUNT ON;

		 DECLARE
			@PrecioUnitario_Actual float,
			@Disponibilidad_Actual int, 
			@IdMoneda_Actual int,
			@MONEDA_ACTUAL NVARCHAR(300),
			@MONEDA NVARCHAR(300),
			@ComentarioSubcontratista_Actual nvarchar(max),
			----------------------
			@IdMaterialVendedor_Actual int,
			@FechaVigencia_Actual datetime,
			@NoCotizar_Actual BIT,
			@Detalle NVARCHAR(MAX) = ''

			IF ISNULL(@NoCotizar, 0) = 0 
			BEGIN 

			SET @PrecioUnitario_Actual = (SELECT PrecioUnitario FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			SET @Disponibilidad_Actual = (SELECT Disponibilidad FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			SET @IdMoneda_Actual = (SELECT IdMoneda FROM dbo.MM_PeticionOfertaDetalle 
									WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			SET @ComentarioSubcontratista_Actual = (SELECT ComentarioSubcontratista FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			SET @FechaVigencia_Actual = (SELECT FechaVigencia FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			SET @NoCotizar_Actual = (SELECT NoCotizar FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			


			IF ISNULL(@PrecioUnitario_Actual,0) <> @PrecioUnitario
			BEGIN 
				SET @Detalle = (@Detalle + ' *Cambio precio unitario de: '+ CAST(ISNULL(@PrecioUnitario_Actual,0) AS NVARCHAR(MAX)) +' a: '+ CAST(ISNULL(@PrecioUnitario,0) AS NVARCHAR(MAX))+' ')
				---SELECT @Detalle,@PrecioUnitario,@PrecioUnitario_Actual
			END 

			IF ISNULL(@Disponibilidad_Actual,0) <> @Disponibilidad
			BEGIN 
				SET @Detalle = (@Detalle + ' *Cambio cantidad de: '+ CAST(ISNULL(@Disponibilidad_Actual,0) AS NVARCHAR(MAX)) +' a: '+ CAST(ISNULL(@Disponibilidad,0) AS NVARCHAR(MAX))+' ')
				---SELECT @Detalle,@Disponibilidad_Actual,@Disponibilidad
			END 

			IF ISNULL(@IdMoneda_Actual,0) <> @IdMoneda
			BEGIN 
				SET @MONEDA_ACTUAL = (SELECT TipoMonedaCorto
									  FROM  dbo.PV_TipoMoneda
									  WHERE IdMoneda= @IdMoneda_Actual)
				SET @MONEDA = (SELECT TipoMonedaCorto
									  FROM  dbo.PV_TipoMoneda
									  WHERE IdMoneda= @IdMoneda)

				SET @Detalle = (@Detalle + ' *Cambio moneda de: '+ ISNULL(@MONEDA_ACTUAL,'') +' a: '+ ISNULL(@MONEDA,'')+' ')
				--SELECT @Detalle,@MONEDA_ACTUAL,@MONEDA
			END 

			 
			IF ISNULL(@ComentarioSubcontratista_Actual,'') <> @ComentarioSubcontratista
			BEGIN 
				SET @Detalle = (@Detalle + ' *Cambio comentario de: '+ ISNULL(@ComentarioSubcontratista_Actual,'')  +' a: '+ ISNULL(@ComentarioSubcontratista,'')+' ')
				--SELECT @Detalle,@ComentarioSubcontratista_Actual,@ComentarioSubcontratista
			END 

			IF ISNULL(@NoCotizar_Actual,0) <> @NoCotizar 
			BEGIN 
				SET @Detalle = (@Detalle + ' *Se cambio de no cotizar a  cotizar servicio/material ')				
			END 

			IF @FechaVigencia_Actual <> @FechaVigencia 
			BEGIN 
				SET @Detalle = (@Detalle + ' *Cambio fecha vigencia cotización de: '+ CAST(ISNULL(@FechaVigencia_Actual,'') AS NVARCHAR(MAX))  +' a: '+ CAST(ISNULL(@FechaVigencia,'') AS NVARCHAR(MAX))+' ')
				--SELECT @Detalle,@FechaVigencia_Actual,@FechaVigencia
			END 

          declare  @Subtotal float = @PrecioUnitario * @Disponibilidad

          UPDATE [dbo].[MM_PeticionOfertaDetalle]
			SET [PrecioUnitario]= CAST(@PrecioUnitario AS NUMERIC(18,2)),
				[ComentarioSubcontratista] = @ComentarioSubcontratista,
				[ModificadoPor] = @IdUsuario,
				[ModificadoEl]  = GETDATE(),
				[IdMoneda] = @IdMoneda,
				[Disponibilidad]= @Disponibilidad,
				[Cotizado] = 1 ,
				[SubTotal] = @Subtotal,
                [FechaVigencia] = @FechaVigencia,
				[ModificadoProveedorPor] =   @IdProveedorActual,
				[IdMaterialVendedor] = @IdMaterialVendedor,
				[NoCotizar] = @noCotizar			
			WHERE [IdPeticionOfertaDetalle]=@IdPeticionOfertaDetalle

		  INSERT INTO MM_HistorialEdicionCotizacion(
			 [IdEdicionCotizacion],		     
			 [IdUsuario],
		     [IdProveedor],
			 [Fecha],
		     [IdPeticionOfertaDetalle],
			 [Descripcion]
			 )
			 VALUES(
			 @IdEdicionCotizacion,
			 @IdUsuario,
			 @IdProveedorActual,
			 GETDATE(),	
			 @IdPeticionOfertaDetalle,		 
			 @Detalle
			 )

			 SELECT 'SUCCESS',@IdEdicionCotizacion, @Detalle

			END 
			ELSE
			BEGIN 
				
		   SET @NoCotizar_Actual = (SELECT NoCotizar FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			

			IF @NoCotizar_Actual <> @NoCotizar
			BEGIN 
				 SET @PrecioUnitario_Actual = (SELECT PrecioUnitario FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
				SET @Disponibilidad_Actual = (SELECT Disponibilidad FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
				SET @IdMoneda_Actual = (SELECT IdMoneda FROM dbo.MM_PeticionOfertaDetalle 
										WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
				SET @ComentarioSubcontratista_Actual = (SELECT ComentarioSubcontratista FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
				SET @FechaVigencia_Actual = (SELECT FechaVigencia FROM dbo.MM_PeticionOfertaDetalle WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle)
			
			IF @NoCotizar_Actual <> @NoCotizar 
			BEGIN 
				SET @Detalle = @Detalle + ' *Se cambio de cotizar a no cotizar servicio/material '
			END 

			 
			SET @Detalle = @Detalle + ' *Cambio precio unitario de: '+ CAST(ISNULL(@PrecioUnitario_Actual,0) AS NVARCHAR(MAX)) +' '
			SET @Detalle = @Detalle + ' *Cambio cantidad de: '+ CAST(ISNULL(@Disponibilidad_Actual,0) AS NVARCHAR(MAX)) +' '
			
			
			SET @MONEDA_ACTUAL = (SELECT TipoMonedaCorto
									  FROM  dbo.PV_TipoMoneda
									  WHERE IdMoneda= @IdMoneda_Actual)
				

			SET @Detalle = @Detalle + ' *Cambio moneda de: '+ ISNULL(@MONEDA_ACTUAL,'') +' '
			
			SET @Detalle = @Detalle + ' *Cambio comentario de: '+ ISNULL(@ComentarioSubcontratista_Actual,'')  +' '
			SET @Detalle = @Detalle + ' *Cambio fecha vigencia cotización '+ CAST(ISNULL(@FechaVigencia_Actual,'') AS NVARCHAR(MAX))  +' '
			
			END 
			   

				UPDATE [dbo].[MM_PeticionOfertaDetalle]
			    SET [NoCotizar] = @noCotizar,
				[PrecioUnitario]= NULL,
				[ComentarioSubcontratista] = NULL,
				[ModificadoPor] = @IdUsuario,
				[ModificadoEl]  = GETDATE(),
				[IdMoneda] = NULL,
				[Disponibilidad]= NULL,
				[Cotizado] = 0,
				[SubTotal] = NULL,
                [FechaVigencia] = NULL,
				[ModificadoProveedorPor] =   @IdProveedorActual,
				[IdMaterialVendedor] = NULL
			    WHERE [IdPeticionOfertaDetalle]=@IdPeticionOfertaDetalle

				 
				IF @NoCotizar_Actual <> @NoCotizar
				BEGIN 
					 INSERT INTO MM_HistorialEdicionCotizacion(
					 [IdEdicionCotizacion],		     
					 [IdUsuario],
					 [IdProveedor],
					 [Fecha],
					 [IdPeticionOfertaDetalle],
					 [Descripcion]
					 )
					 VALUES(
					 @IdEdicionCotizacion,
					 @IdUsuario,
					 @IdProveedorActual,
					 GETDATE(),	
					 @IdPeticionOfertaDetalle,		 
					 @Detalle
					 )
				 END 
				 SELECT 'SUCCESS',@IdEdicionCotizacion
			END 
			
			 
     END;


