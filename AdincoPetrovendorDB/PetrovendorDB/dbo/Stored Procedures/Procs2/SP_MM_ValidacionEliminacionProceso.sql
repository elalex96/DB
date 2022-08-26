USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ValidacionEliminacionProceso'
)
DROP PROCEDURE SP_MM_ValidacionEliminacionProceso;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ValidacionEliminacionProceso]    Script Date: 26/08/2022 03:13:03 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 31-05-2018
-- Description:	/*CONSULTAR ESTATUS DE PROCESOS*/
-- =============================================
-- Author:		Luis David
-- Create date: 04/11/2021
-- Description:	Reacomodo de tablas para optimización
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
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
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM dbo.MM_AceptacionFactura  (NOLOCK)
		WHERE IdAceptacionPedido = @IdProceso

		/*NO EXISTE ACEPTACION DE FACTURA OBTENER EL IDELIMINADO DE LA ULTIMA APROBACIÓN DE ACEPTACION CARTA CONTENIDO NACIONAL */
		/*PARA LLEGAR A ESTE PUNTO SE TIENE QUE HABER TENIDO UNA CARTA DE CONTENIDO NACIONAL APROBADA*/
		IF ISNULL(@IDELIMINADO,0) =0  		
			SELECT TOP 1 @IDELIMINADO= IdEliminado 
			FROM dbo.MM_AceptacionCartaPCN  (NOLOCK)
			WHERE IdAceptacionPedido = @IdProceso 
			ORDER BY CreadoEl DESC 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO


	END 

	IF @Proceso='ACEPTACION_CARTA_CN' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM dbo.MM_AceptacionCartaPCN (NOLOCK)
		WHERE IdAceptacionPedido = @IdProceso

		/*NO EXISTE ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINADO DE LA ACEPTACION PEDIDO */
		/*PARA LLEGAR A ESTE PUNTO TIENE QUE EXISTIR UNA ACEPTACIÓN DE PEDIDO*/
		IF ISNULL(@IDELIMINADO,0) =0  		
			SELECT @IDELIMINADO= IdEliminado 
			FROM dbo.MM_AceptacionPedido (NOLOCK)
			WHERE IdAceptacionPedido = @IdProceso 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO

	END 

	/*USO EN ORDEN DE COMPRA (PETROVENDOR) Y PEDIDO (PROCURA)*/
	IF @Proceso='PEDIDO' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM dbo.MM_Pedido (NOLOCK)
		WHERE IdPedido = @IdProceso
				 
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO


	END 

	IF @Proceso='COTIZACION' 
	BEGIN 
		/*VALIDAR EXISTE UNA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM dbo.MM_PeticionOferta (NOLOCK)
		WHERE IdPeticionOferta = @IdProceso
				 
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion (NOLOCK) 
		WHERE IdEliminacion=@IDELIMINADO


	END 

	IF @Proceso='COMPROBANTE_EXTRANJERO' 
	BEGIN 
		/*VALIDAR EXISTE UN PEDIMENTO EXTRANJERO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= PC.IdEliminado 
		FROM dbo.FI_PedimentoComprobante  PC  (NOLOCK)
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
		ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
		JOIN dbo.MM_AceptacionPedido AP (NOLOCK)
		ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
		WHERE AP.IdAceptacionPedido = @IdProceso

		/*NO EXISTE PEDIMENTO EXTRANJERO OBTENER EL IDELIMINADO DE LA ACEPTACION PEDIDO */
		/*PARA LLEGAR A ESTE PUNTO TIENE QUE EXISTIR UNA ACEPTACIÓN DE PEDIDO*/
		IF ISNULL(@IDELIMINADO,0) =0  		
			SELECT @IDELIMINADO= IdEliminado 
			FROM dbo.MM_AceptacionPedido  (NOLOCK)
			WHERE IdAceptacionPedido = @IdProceso 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO

	END 

	IF @Proceso='ACEPTACION_PEDIDO' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM dbo.MM_AceptacionPedido (NOLOCK)
		WHERE IdAceptacionPedido = @IdProceso 

		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion  (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO

	END 

	IF @Proceso='OFERTA' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM  Ta_Operacion  (NOLOCK)
		WHERE IdDocumento = @IdProceso 
		AND IdTipoOperacion = 6 --> Operacion de cotización
		GROUP BY IdEliminado 
		
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion  (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO

	END 

	IF @Proceso='SOLICITUD_PEDIDO' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		
		SELECT @IDELIMINADO= IdEliminado 
		FROM  dbo.MM_SolicitudPedido  (NOLOCK)
		WHERE IdSolicitudPedido = @IdProceso  
		 
		
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion  (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO

	END 
	

	IF @Proceso='APROBACION' 
	BEGIN 
		/*VALIDAR EXISTE UN ACEPTACIÓN PEDIDO OBTENER EL IDELIMINACION*/
		 
		SELECT @IDELIMINADO= IdEliminado 
		FROM  dbo.TA_Operacion  (NOLOCK)
		WHERE IdOperacion = @IdProceso  
		 
		
		SELECT IdEliminacion, ComentarioExterno, FechaRegistro, ComentarioInterno 
		FROM dbo.AD_RegistroEliminacion  (NOLOCK)
		WHERE IdEliminacion=@IDELIMINADO

	END 
	

END 