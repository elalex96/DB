-- =============================================
-- Author:		DANIEL AC
-- Create date: 15/11/2017
-- Description:CALCULO PCN para materiales o servicios 
-- SP de referencia --> SP_PCN_ActualizarCalculoCN
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_ActualizarCalculoCN_Bienes_Servicios]

@IdValoresEnPesosPedidoDetalle INT,
@IdAceptacionPedidoDetalle INT,
@IdAceptacionPedido INT,
@VNMO_SueldoNacional float,
@VMO_Sueldo float,
@CreadoPor INT,
@IdProveedor INT,

@ValorFactura float,
@IdCriterio INT, 
@IdTipoMaterial INT, 
@IdTipoNacionalidad INT, 
@IdCatalogoHidrocarburos INT, 
@FraccionArrancelaria NVARCHAR(MAX),
@IdClasificacionCN INT 
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @PCNMjxVMj float
	DECLARE @VNMOi float
	DECLARE @VMOi float
	DECLARE @VMjxVMOi float
	DECLARE @VMj float
	DECLARE @PCN_MaterialFinal DECIMAL(18,4)
	DECLARE @PCN_PedidoDetalleAll INT
	DECLARE @PCN_PedidoDetalleAdd INT


	IF @IdCatalogoHidrocarburos = 0  
		SET @IdCatalogoHidrocarburos = NULL
	
	/*1. VALIDAR TIPO DE MATERIAL ES UN BIEN O UN SERVICIO*/

	
	IF @IdTipoMaterial = 1 /*ES UN MATERIAL*/
	BEGIN 

		/*2. ES UN MATERIAL NACIONAL O EXTRANJERO*/		
		IF @IdTipoNacionalidad = 1 /*ES NACIONAL */
			BEGIN 
			/*3. CRITERIO DEL BIEN */
		    IF @IdCriterio = 1  OR  @IdCriterio = 2 OR  @IdCriterio = 3
				BEGIN
				 /*PCN = 1 POR DEFAULT ES 1 */
				  
				  IF @IdCriterio <> 2 /*CRITERIO 1 Y 2 NO LLEVAN FRACCION ARRANCELARIA*/
					 SET @FraccionArrancelaria= NULL

					
					UPDATE MM_PCN_ValoresPesos
					SET IdTipoMaterialServicio=@IdTipoMaterial,
					IdCatalogoHidrocarburos=@IdCatalogoHidrocarburos,
					IdTipoNacionalidad=@IdTipoNacionalidad,			
					IdTipoCriterio=@IdCriterio,
					FraccionArancelaria= @FraccionArrancelaria,
					ValorFactura=@ValorFactura,
					VNMO_SueldoNacional = @VNMO_SueldoNacional,
					VMO_Sueldo= @VMO_Sueldo,					
					IdClasificacionCN=NULL,
					EditadoEl=GETDATE(),
					EditadoPor=@CreadoPor,
					EditadorProveedorPor =@IdProveedor
					WHERE IdValoresEnPesosPedidoDetalle	= @IdValoresEnPesosPedidoDetalle

					/*NO SE CALCULA PCN POR DEFAULT ES 1*/
					SET @PCN_MaterialFinal= 1

					--#Actualizar Contenido Nacional General del Servicio Final

					UPDATE MM_AceptacionPedidoDetalle
					SET [PCN] = @PCN_MaterialFinal,
					PCN_Agregado=1,
					EditadoEl=GETDATE(),
					EditadoPor=@CreadoPor
					WHERE IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle	

					--#Actualizar Estatus de AddPCN en 

					SET @PCN_PedidoDetalleAll = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
												 FROM MM_AceptacionPedidoDetalle APD
												 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
												 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)

					SET @PCN_PedidoDetalleAdd = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
												 FROM MM_AceptacionPedidoDetalle APD
												 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
												 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND APD.PCN_Agregado=1)
			
					/*VALIDA SI TODOS LAS ACEPTACIONES DE PEDIDO DETALLE TIENE UN VALOR DE CONTENIDO NACIONAL ACTUALIZA EL ESTATUS
					GENERAL DE TODA LA ACEPTACIÓN DE PEDIDO Y QUIERE DECIR QUE YA SE CALCULARON TODOS LOS CONTENIDOS NACIONAL DE LOS
					MATERIALES SERVICIOS DE ESA ACEPTACIÓN DE PEDIDO
					*/
					IF @PCN_PedidoDetalleAll = @PCN_PedidoDetalleAdd
					BEGIN
						UPDATE MM_AceptacionPedido
						SET PCN_Agregado=1,
						Modificado=GETDATE(),
						ModificadoPor=@CreadoPor
						WHERE IdAceptacionPedido= @IdAceptacionPedido	
					END 
			
				  SELECT 'SUCCESS' AS RESULTADO_PROCESO_ACTUAL,
				  'CALCULO CRITERIO '+ CAST(ISNULL(@IdCriterio,-1) AS NVARCHAR(200)) AS DETALLE,
				  @PCN_PedidoDetalleAll AS TOTAL_DE_APD,
				  @PCN_PedidoDetalleAdd AS TOTAL_APD_CON_PCN


				END 
			ELSE IF  @IdCriterio = 4  				
				BEGIN		
						
					/*PCN = AL CALCULO DEACUERDO A LA FORMULA DE CNBi*/

					/*ACTUALIZAR DATOS DE CABECERA*/

					UPDATE MM_PCN_ValoresPesos
					SET IdTipoMaterialServicio=@IdTipoMaterial,
					IdCatalogoHidrocarburos=@IdCatalogoHidrocarburos,
					IdTipoNacionalidad=@IdTipoNacionalidad,			
					IdTipoCriterio=@IdCriterio,
					FraccionArancelaria= NULL,
					ValorFactura=@ValorFactura,
					VNMO_SueldoNacional = @VNMO_SueldoNacional,
					VMO_Sueldo= @VMO_Sueldo,					
					IdClasificacionCN=NULL,
					EditadoEl=GETDATE(),
					EditadoPor=@CreadoPor,
					EditadorProveedorPor =@IdProveedor
					WHERE IdValoresEnPesosPedidoDetalle	= @IdValoresEnPesosPedidoDetalle

					/*CALCULAR Proporción de contenido nacional del bien i (PCNBi)
					FORMULA BIEN 

								Sum^m 𝑗=1 𝑃𝐶𝑁𝑀𝑗 × 𝑉𝑀𝑗 + 𝑉𝑁𝑀𝑂𝑖
						𝑃𝐶𝑁𝐵𝑖 = ----------------------------------
								Sum^m 𝑗=1  𝑉𝑀𝑗 + 𝑉𝑀𝑂𝑖

						 Donde:
							PCNMj: Proporción de contenido nacional del material o servicio “j” utilizado en la producción del bien final, lo
							proporciona el proveedor de cada material o servicio utilizado en la producción del bien final;
							VMj: Valor factura en pesos del material o servicio “j” utilizado en la producción del bien final;
							VNMOi: Valor en pesos mexicanos de los sueldos u honorarios más prestaciones pagados a los trabajadores
							nacionales empleados por el proveedor del bien final en la producción del mismo;
							VMOi: Valor en pesos mexicanos de los sueldos u honorarios más prestaciones pagados a los trabajadores
							empleados por el proveedor del bien final en la producción del mismo;
							m: Número de materiales o servicio utilizados por el productor.
			
					*/

					/*CALCULAR 𝑃𝐶𝑁𝑀𝑗 × 𝑉𝑀𝑗*/
  
			

					SET @PCNMjxVMj =(SELECT SUM(ISNULL(MU.PCNM_Utilizado,0) * ISNULL(MU.VM_ValorFactura,0)) AS PCNMixVMi
								FROM MM_PCN_MaterialesUtilizados MU				
								WHERE MU.IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle 
								AND ISNULL(MU.IsEliminado,0) = 0)

					/*CALCULAR 𝑉𝑀𝑗*/

					SET @VMj =(SELECT SUM(MU.VM_ValorFactura) AS VMi
								FROM MM_PCN_MaterialesUtilizados MU				
								WHERE MU.IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle 
								AND ISNULL(MU.IsEliminado,0) = 0)



					SET @VNMOi = (SELECT ISNULL(VNMO_SueldoNacional,0) FROM MM_PCN_ValoresPesos WHERE IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle)
					SET @VMOi = (SELECT ISNULL(VMO_Sueldo,0) FROM MM_PCN_ValoresPesos WHERE IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle)

					/*CALCULAR  𝑉𝑀𝑗 + 𝑉𝑀𝑂𝑖*/
					SET @VMjxVMOi = (ISNULL(@VMj,0)+ISNULL(@VMOi,0))


					/*CALCULAR PCNBi DEL MATERIAL ACTUAL CON FORMULA DEL BIEN*/

					/*SI EL VALOR DEL DIVIDENDO ES 0 EL PCN ES 0 */
					
					IF(@VMjxVMOi<>0)
						SET @PCN_MaterialFinal = (((ISNULL(@PCNMjxVMj,0))+ISNULL(@VNMOi,0))/ISNULL(@VMjxVMOi,0))
					ELSE 
						SET @PCN_MaterialFinal = 0

					

					--#Actualizar Contenido Nacional General del Servicio Final

					UPDATE MM_AceptacionPedidoDetalle
					SET [PCN] = @PCN_MaterialFinal,
					PCN_Agregado=1,
					EditadoEl=GETDATE(),
					EditadoPor=@CreadoPor
					WHERE IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle	

					--#Actualizar Estatus de AddPCN en 

					SET @PCN_PedidoDetalleAll = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
												 FROM MM_AceptacionPedidoDetalle APD
												 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
												 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)

					SET @PCN_PedidoDetalleAdd = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
												 FROM MM_AceptacionPedidoDetalle APD
												 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
												 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND APD.PCN_Agregado=1)
			
					/*VALIDA SI TODOS LAS ACEPTACIONES DE PEDIDO DETALLE TIENE UN VALOR DE CONTENIDO NACIONAL ACTUALIZA EL ESTATUS
					GENERAL DE TODA LA ACEPTACIÓN DE PEDIDO Y QUIERE DECIR QUE YA SE CALCULARON TODOS LOS CONTENIDOS NACIONAL DE LOS
					MATERIALES SERVICIOS DE ESA ACEPTACIÓN DE PEDIDO
					*/
					IF @PCN_PedidoDetalleAll = @PCN_PedidoDetalleAdd
					BEGIN
						UPDATE MM_AceptacionPedido
						SET PCN_Agregado=1,
						Modificado=GETDATE(),
						ModificadoPor=@CreadoPor
						WHERE IdAceptacionPedido= @IdAceptacionPedido	
					END 
			
				  SELECT 'SUCCESS' AS RESULTADO_PROCESO_ACTUAL,
				  'CALCULO CRITERIO 4 "NINGUNO" DE MATERIAL' AS DETALLE,
				  @PCN_PedidoDetalleAll AS TOTAL_DE_APD,
				  @PCN_PedidoDetalleAdd AS TOTAL_APD_CON_PCN
				
				 
					 
				END 
			ELSE 
				BEGIN		
				
						
					SELECT 'ERROR','NO SE SELECCIONO NINGUN CRITERIO DEL BIEN'
				END 
				 
		END 
		ELSE IF @IdTipoNacionalidad = 2 /*ES EXTRANJERO*/			
			BEGIN
					UPDATE MM_PCN_ValoresPesos
					SET IdTipoMaterialServicio=@IdTipoMaterial,
					IdCatalogoHidrocarburos=@IdCatalogoHidrocarburos,
					IdTipoNacionalidad=@IdTipoNacionalidad,			
					IdTipoCriterio=NULL,
					FraccionArancelaria= NULL,
					ValorFactura=@ValorFactura,
					VNMO_SueldoNacional = @VNMO_SueldoNacional,
					VMO_Sueldo= @VMO_Sueldo,					
					IdClasificacionCN=NULL,
					EditadoEl=GETDATE(),
					EditadoPor=@CreadoPor,
					EditadorProveedorPor =@IdProveedor
					WHERE IdValoresEnPesosPedidoDetalle	= @IdValoresEnPesosPedidoDetalle

					/*NO SE CALCULA PCN POR DEFAULT ES 0*/
					SET @PCN_MaterialFinal= 0

					--#Actualizar Contenido Nacional General del Servicio Final

					UPDATE MM_AceptacionPedidoDetalle
					SET [PCN] = @PCN_MaterialFinal,
					PCN_Agregado=1,
					EditadoEl=GETDATE(),
					EditadoPor=@CreadoPor
					WHERE IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle	

					--#Actualizar Estatus de AddPCN en 

					SET @PCN_PedidoDetalleAll = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
												 FROM MM_AceptacionPedidoDetalle APD
												 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
												 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)

					SET @PCN_PedidoDetalleAdd = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
												 FROM MM_AceptacionPedidoDetalle APD
												 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
												 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND APD.PCN_Agregado=1)
			
					/*VALIDA SI TODOS LAS ACEPTACIONES DE PEDIDO DETALLE TIENE UN VALOR DE CONTENIDO NACIONAL ACTUALIZA EL ESTATUS
					GENERAL DE TODA LA ACEPTACIÓN DE PEDIDO Y QUIERE DECIR QUE YA SE CALCULARON TODOS LOS CONTENIDOS NACIONAL DE LOS
					MATERIALES SERVICIOS DE ESA ACEPTACIÓN DE PEDIDO
					*/
					IF @PCN_PedidoDetalleAll = @PCN_PedidoDetalleAdd
					BEGIN
						UPDATE MM_AceptacionPedido
						SET PCN_Agregado=1,
						Modificado=GETDATE(),
						ModificadoPor=@CreadoPor
						WHERE IdAceptacionPedido= @IdAceptacionPedido	
					END 
			
				  SELECT 'SUCCESS' AS RESULTADO_PROCESO_ACTUAL,
				  'CALCULO EXTRANJERO ' AS DETALLE,
				  @PCN_PedidoDetalleAll AS TOTAL_DE_APD,
				  @PCN_PedidoDetalleAdd AS TOTAL_APD_CON_PCN

			END 


	END 
	ELSE IF @IdTipoMaterial =2 /*ES UN SERVICIO*/
	BEGIN 
		/*PCN = AL CALCULO DEACUERDO A LA FORMULA DE PCNSi*/

			/*ACTUALIZAR DATOS DE CABECERA*/

			UPDATE MM_PCN_ValoresPesos
			SET IdTipoMaterialServicio=@IdTipoMaterial,
			IdCatalogoHidrocarburos=@IdCatalogoHidrocarburos,
			IdTipoNacionalidad=NULL,			
			IdTipoCriterio=NULL,
			FraccionArancelaria= NULL,
			ValorFactura=@ValorFactura,
			VNMO_SueldoNacional = @VNMO_SueldoNacional,
			VMO_Sueldo= @VMO_Sueldo,					
			IdClasificacionCN=NULL,
			EditadoEl=GETDATE(),
			EditadoPor=@CreadoPor,
			EditadorProveedorPor =@IdProveedor
			WHERE IdValoresEnPesosPedidoDetalle	= @IdValoresEnPesosPedidoDetalle

			/*CALCULAR Proporción de contenido nacional del servicio i (PCNSi)
			FORMULA SERVICIOS

						Sum^m 𝑗=1 𝑃𝐶𝑁𝑀𝑆𝑗 × 𝑉𝑀𝑆𝑗 + 𝑉𝑁𝑀𝑂𝑖
				𝑃𝐶𝑁𝑆𝑖 = ----------------------------------
						Sum^m 𝑗=1   𝑉𝑀𝑆𝑗+𝑉𝑀𝑂𝑖

				PCNMSj: Proporción de contenido nacional del material o servicio “j” utilizado para brindar el servicio “i”;
				VMSj: Valor factura en pesos del material o servicio “j” utilizado para brindar el servicio;
				VNMOi: Valor en pesos de los sueldos u honorarios más prestaciones pagados a los trabajadores nacionales
				empleados por el proveedor para brindar el servicio;
				VMOi: Valor en pesos de los sueldos u honorarios más prestaciones pagados a los trabajadores empleados por el
				proveedor para brindar el servicio;
				m: Número de materiales o servicio utilizados por el productor
			
			*/

			DECLARE @PCNMSjxVMSj DECIMAL(18,2)			
			DECLARE @VMSjxVMOi DECIMAL(18,2)
			DECLARE @VMSj DECIMAL(18,2)
			
			/*CALCULAR 𝑃𝐶𝑁𝑀𝑆𝑗×𝑉𝑀𝑆𝑗*/
  
			

			SET @PCNMSjxVMSj =(SELECT SUM(ISNULL(MU.PCNM_Utilizado,0) * ISNULL(MU.VM_ValorFactura,0)) AS PCNMixVMi
						FROM MM_PCN_MaterialesUtilizados MU				
						WHERE MU.IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle 
						AND ISNULL(MU.IsEliminado,0) = 0)

			/*CALCULAR 𝑉𝑀𝑆𝑗*/

			SET @VMSj =(SELECT SUM(MU.VM_ValorFactura) AS VMi
						FROM MM_PCN_MaterialesUtilizados MU				
						WHERE MU.IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle 
						AND ISNULL(MU.IsEliminado,0) = 0)



			SET @VNMOi = (SELECT ISNULL(VNMO_SueldoNacional,0) FROM MM_PCN_ValoresPesos WHERE IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle)
			SET @VMOi = (SELECT ISNULL(VMO_Sueldo,0) FROM MM_PCN_ValoresPesos WHERE IdValoresEnPesosPedidoDetalle = @IdValoresEnPesosPedidoDetalle)

			/*CALCULAR 𝑉𝑀𝑆𝑗+𝑉𝑀𝑂𝑖*/
			SET @VMSjxVMOi = (ISNULL(@VMSj,0)+ISNULL(@VMOi,0))


			/*CALCULAR PCNSi DEL SERCIVICIO ACTUAL CON FORMULA SERVICIOS*/
			IF @VMSjxVMOi <> 0 
				SET @PCN_MaterialFinal= (((ISNULL(@PCNMSjxVMSj,0))+ISNULL(@VNMOi,0))/ISNULL(@VMSjxVMOi,0))
			ELSE 
				SET @PCN_MaterialFinal=0
			---SELECT @PCN_MaterialFinal

			--#Actualizar Contenido Nacional General del Servicio Final

			UPDATE MM_AceptacionPedidoDetalle
			SET [PCN] = @PCN_MaterialFinal,
			PCN_Agregado=1,
			EditadoEl=GETDATE(),
			EditadoPor=@CreadoPor
			WHERE IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle	

			--#Actualizar Estatus de AddPCN en 

			SET @PCN_PedidoDetalleAll = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
										 FROM MM_AceptacionPedidoDetalle APD
										 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
										 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido)

			SET @PCN_PedidoDetalleAdd = (SELECT COUNT(APD.IdAceptacionPedidoDetalle) 
										 FROM MM_AceptacionPedidoDetalle APD
										 INNER JOIN MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
										 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND APD.PCN_Agregado=1)
			
			/*VALIDA SI TODOS LAS ACEPTACIONES DE PEDIDO DETALLE TIENE UN VALOR DE CONTENIDO NACIONAL ACTUALIZA EL ESTATUS
			GENERAL DE TODA LA ACEPTACIÓN DE PEDIDO Y QUIERE DECIR QUE YA SE CALCULARON TODOS LOS CONTENIDOS NACIONAL DE LOS
			MATERIALES SERVICIOS DE ESA ACEPTACIÓN DE PEDIDO
			*/
			IF @PCN_PedidoDetalleAll = @PCN_PedidoDetalleAdd
			BEGIN
				UPDATE MM_AceptacionPedido
				SET PCN_Agregado=1,
				Modificado=GETDATE(),
				ModificadoPor=@CreadoPor
				WHERE IdAceptacionPedido= @IdAceptacionPedido	
			END 
			
		  SELECT 'SUCCESS' AS RESULTADO_PROCESO_ACTUAL,
		  'CALCULO PCNSi DE SERVICIO' AS DETALLE,
		  @PCN_PedidoDetalleAll AS TOTAL_DE_APD,
		  @PCN_PedidoDetalleAdd AS TOTAL_APD_CON_PCN

	END 



	 
END
