-- =============================================
-- Author:		Daniel AC
-- Create date: 13/08/2018
-- Description:	Consultar si el usuario actual tiene permisos para acceder a las paginas de compras relacionado con la requisición 
-- Si es el requisitor relacionado la proceso actual tambien tiene permisos de acceso 
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 03/02/2021
-- Description:	Optimización por issue 955
-- =============================================

CREATE PROCEDURE [dbo].[SP_ValidarAccesoDetalleCompra] 
@IdUsuario INT, 
@IdProveedor INT,
@IdSolicitudPedido INT 

AS
	BEGIN
		DECLARE @EsAdministradorCompras BIT =0,
		@EsTipoAdministrador BIT = 0,
		@EsAdministrador BIT =0, 
		@EsRequisitor BIT = 0,
		@EsCompradorAsignado BIT;

		--CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
		SELECT  @EsAdministradorCompras=Activo
		FROM dbo.CC_AdministradorCompras 
		WHERE IdUsuario=@IdUsuario 
		AND Activo=1
		AND IdProveedor=@IdProveedor
		
		--CONSULTAR SI EL USUARIO ACTUAL ES USUARIO DE TIPO ADMINISTRADOR 
		SELECT @EsTipoAdministrador=CASE WHEN COUNT(1)> 0 THEN 1 ELSE 0 END
		FROM dbo.S_Usuario U 
		WHERE U.IdTipoUsuario IN (3,4,6,7,8) --> CTE DE TIPO DE USUARIO DE ADMINISTRADOR
		AND U.IdUsuario=@IdUsuario

		-- CONSULTAR SI EL USUARIO ACTUAL ES EL REQUISITOR DE LA SOLPED RELACIONADO AL PEDIDO ACTUAL 

		SELECT @EsRequisitor=CASE WHEN COUNT(1)> 0 THEN 1 ELSE 0 END 
		FROM dbo.MM_SolicitudPedido 
		WHERE IdSolicitudPedido=@IdSolicitudPedido
		AND IdUsuarioSolicitante=@IdUsuario

		--SI CUMPLE ALGUNO DE ESTOS PARAMETROS ES UN ADMINISTRADOR Y PUEDE VER TODAS LAS PETICIONES DE SOL OFERTA
		-- SI NO SOLO PODRÁ VER LAS SOL OFERTA DONDE FUE ASIGNADO
		IF ISNULL(@EsTipoAdministrador,0)=1 OR ISNULL(@EsAdministradorCompras,0) =1 OR ISNULL(@EsRequisitor,0) =1
		BEGIN
         SET @EsAdministrador =1
		END 

		SELECT  @EsCompradorAsignado=CP.Activo
		FROM dbo.MM_SolicitudPedidoComprador CP
		WHERE CP.IdAsignadoA=@IdUsuario 
		AND CP.IdSolicitudPedido=@IdSolicitudPedido
		AND ISNULL(CP.Activo,0)=1

		SELECT 
		CASE WHEN @EsCompradorAsignado= 1 THEN 
		'PERMISOS_ASIGNACION'
		ELSE 
		'SIN_PERMISOS'
		END AS EsComprador, 
		CASE WHEN @EsAdministrador = 1 THEN 
		'PERMISOS_ADMINISTRADOR'
		ELSE 
		'SIN_PERMISOS' END 
		AS EsAdministrador
			 
	END