creatE   procedure [dbo].[SP_MPY_NC_ConsultarInformacionNotaCredito]	
	@IdProveedor INT,
	@IdUsuario  INT,		    
	@IdNotaCredito INT 
AS
BEGIN

	DECLARE @IdUsuarioAdinco INT 
	DECLARE @IdContrato INT 
	 
	 SELECT @IdUsuarioAdinco =U.IdUsuarioADINCO 
	 FROM dbo.S_Usuario U 
	 LEFT JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario
	 WHERE U.IdUsuario=@IdUsuario
	 AND UP.IdProveedor=@IdProveedor
	
	SELECT F.IdContrato, @IdUsuarioAdinco, F.ComprobantePDFByte, F.ComprobanteXMLByte, NC.TipoRelacion, NC.CFDIRelacionados, F.IdFactura, F.UUID
	FROM dbo.MPY_MM_AceptacionNotaCredito NC 
	INNER JOIN dbo.FI_Factura F ON F.IdFactura=NC.IdFacturaNotaCredito
	INNER JOIN dbo.MPY_MM_AceptacionPedido AP ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
	LEFT JOIN dbo.MM_Pedido P ON P.IdPedido=AP.IdPedido
	WHERE NC.IdAceptacionNotaCredito=@IdNotaCredito
		
	 
END    


