-- =============================================
-- Author:		Pedro Acuña
-- Modified date: 09/03/2018
-- Description:	se agrega el retorno del proveedor y del usuario
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_consultaNotificacionRecepcion]
	@IdPedido INT,
	@IdProveedor int
	 
AS
BEGIN
	   SELECT 
			pr.RazonSocial, 
			u.Nombre, 
			u.Correo, 
			pr.IdProveedor, 
			u.IdUsuario, 
			ur.Correo, 
			ur.Nombre, 
			ur.IdUsuario,
			(C.NumeroContrato + ' - ' + AC.NombreAreaContractual) AS Contrato   
		FROM dbo.MM_Pedido AS p
			INNER JOIN dbo.S_Proveedor AS pr ON pr.IdProveedor = @IdProveedor
			INNER JOIN dbo.S_Usuario AS u ON u.IdUsuario = p.CreadoPor
			INNER JOIN dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = p.IdSolicitudPedido
			INNER JOIN dbo.S_Usuario ur ON ur.IdUsuario = sp.IdUsuarioSolicitante
			LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = sp.IdContrato
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		WHERE IdPedido = @IdPedido
END