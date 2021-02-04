-- =============================================
-- Author:		Daniel Cruz
-- Create date: 31-05-2018
-- Description:	/*CONSULTAR ESTATUS DE PROCESOS*/
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 03/02/2021
-- Description:	Optimización por issue 955
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidacionEliminacionProceso] 
    -- Add the parameters for the stored procedure here
    @IdProceso INT,
    @Proceso NVARCHAR(200),
	@IdProveedor INT = NULL 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	DECLARE @IDELIMINADO INT = 0

	IF @Proceso='ACEPTACION_FACTURA' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE FACTURA OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_AceptacionFactura WHERE IdAceptacionPedido = @IdProceso

		/*NO EXISTE ACEPTACION DE FACTURA OBTENER EL IDELIMINADO DE LA ULTIMA APROBACIÓN DE ACEPTACION CARTA CONTENIDO NACIONAL */
		/*PARA LLEGAR A ESTE PUNTO SE TIENE QUE HABER TENIDO UNA CARTA DE CONTENIDO NACIONAL APROBADA*/
		IF ISNULL(@IDELIMINADO,0) =0  		
			SELECT TOP 1 @IDELIMINADO= IdEliminado FROM dbo.MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdProceso ORDER BY CreadoEl DESC 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO


	END 

	IF @Proceso='ACEPTACION_CARTA_CN' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdProceso

		/*NO EXISTE ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINADO DE LA ACEPTACION PEDIDO */
		/*PARA LLEGAR A ESTE PUNTO TIENE QUE EXISTIR UNA ACEPTACIÓN DE PEDIDO*/
		IF ISNULL(@IDELIMINADO,0) =0  		
			SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdProceso 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO

	END 

	/*USO EN ORDEN DE COMPRA (PETROVENDOR) Y PEDIDO (PROCURA)*/
	IF @Proceso='PEDIDO' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_Pedido WHERE IdPedido = @IdProceso
				 
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO


	END 

	IF @Proceso='COTIZACION' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_PeticionOferta WHERE IdPeticionOferta = @IdProceso
				 
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO


	END 

	IF @Proceso='COMPROBANTE_EXTRANJERO' 
	BEGIN 
		/*VALIDAR EXISTE UN PEDIMENTO EXTRANJERO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= PC.IdEliminado 
		FROM dbo.FI_PedimentoComprobante  PC
		INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
		INNER JOIN dbo.MM_AceptacionPedido AP 
			ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
		WHERE AP.IdAceptacionPedido = @IdProceso

		/*NO EXISTE PEDIMENTO EXTRANJERO OBTENER EL IDELIMINADO DE LA ACEPTACION PEDIDO */
		/*PARA LLEGAR A ESTE PUNTO TIENE QUE EXISTIR UNA ACEPTACIÓN DE PEDIDO*/
		IF ISNULL(@IDELIMINADO,0) =0  		
			SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdProceso 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO

	END 

	IF @Proceso='ACEPTACION_PEDIDO' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdProceso 
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO

	END 

	IF @Proceso='OFERTA' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM  Ta_Operacion
		WHERE IdDocumento = @IdProceso AND IdTipoOperacion = 6 --> Operacion de cotización
		GROUP BY IdEliminado 
		
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO

	END 

	IF @Proceso='SOLICITUD_PEDIDO' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado FROM  dbo.MM_SolicitudPedido
		WHERE IdSolicitudPedido = @IdProceso  
		 
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO

	END 
	

	IF @Proceso='APROBACION' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/ 
		SELECT @IDELIMINADO= IdEliminado FROM  dbo.TA_Operacion 
		WHERE IdOperacion = @IdProceso  

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno FROM dbo.AD_RegistroEliminacion 
		WHERE IdEliminacion=@IDELIMINADO
	END 
END 
