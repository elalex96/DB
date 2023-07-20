USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_validarProveedorRequisicion'
)
    DROP PROCEDURE sp_validarProveedorRequisicion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:   Daniel AC  
-- Create date: 26/10/2020  
-- Description:  Obtener el proveedor actual del proveedor 
-- ============================================= 
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE procedure [dbo].[sp_validarProveedorRequisicion]	
@SolicitudPedidoId INT,
@ProveedorId INT,
@UsuarioId INT,
@ContratoId INT
AS
BEGIN
	/*SP PARA CONSULTAR PROVEEDOR Y CONTRATO DE LA REQUISICION ACTUAL*/
	DECLARE 
	@ProveedorRequi INT,
	@ContratoRequi INT
	
	SELECT 
	@ProveedorRequi=IdProveedor,
	@ContratoRequi=IdContrato
	FROM dbo.MM_SolicitudPedido (NOLOCK)
	WHERE IdSolicitudPedido = @SolicitudPedidoId

	IF ISNULL(@ProveedorRequi,0)=@ProveedorId
	BEGIN 
		SELECT 'SUCCESS',''
	END 
	ELSE 
	BEGIN 
		SELECT 'ERROR_SESION','Hemos detectado has iniciado sesión con otra empresa, actualiza la página o cierra y vuelve a iniciar sesión.'
	END 

	

	 
END    

