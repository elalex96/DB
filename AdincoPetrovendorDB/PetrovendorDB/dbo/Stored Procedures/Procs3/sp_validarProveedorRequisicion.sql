-- =============================================  
-- Author:   Daniel AC  
-- Create date: 26/10/2020  
-- Description:  Obtener el proveedor actual del proveedor 
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
	FROM dbo.MM_SolicitudPedido 
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

