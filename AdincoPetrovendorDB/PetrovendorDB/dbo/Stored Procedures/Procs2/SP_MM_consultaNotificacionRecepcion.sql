USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_consultaNotificacionRecepcion'
)
    DROP PROCEDURE SP_MM_consultaNotificacionRecepcion;
/****** Object:  StoredProcedure [dbo].[SP_MM_consultaNotificacionRecepcion]    Script Date: 30/08/2023 05:29:51 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 30/08/2023
-- Description:	Se consulta el usuario que registro el pedido [usuario activo]
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
			CONCAT(C.NumeroContrato ,' - ' ,AC.NombreAreaContractual) AS Contrato   
		FROM dbo.MM_Pedido AS p  (NOLOCK)
			INNER JOIN dbo.S_Proveedor AS pr (NOLOCK)
			ON pr.IdProveedor = @IdProveedor 
			INNER JOIN dbo.S_Usuario AS u   (NOLOCK)
			ON p.CreadoPor = u.IdUsuario 
			AND U.Activo = 1 --> PERSONA QUE CREA EL PEDIDO
			INNER JOIN dbo.MM_SolicitudPedido sp  (NOLOCK)
			ON p.IdSolicitudPedido = sp.IdSolicitudPedido 
			INNER JOIN dbo.S_Usuario ur  (NOLOCK)
			ON sp.IdUsuarioSolicitante  = ur.IdUsuario 
			AND UR.Activo = 1 --> PERSONA SOLICITANTE DE LA REQUISICIÓN
			LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
			ON sp.IdContrato = C.IdContrato 
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
			ON  C.IdAreaContractual = AC.IdAreaContractual 
		WHERE IdPedido =  @IdPedido 
		GROUP BY 
		pr.RazonSocial, 
			u.Nombre, 
			u.Correo, 
			pr.IdProveedor, 
			u.IdUsuario, 
			ur.Correo, 
			ur.Nombre, 
			ur.IdUsuario,
			C.NumeroContrato,
			AC.NombreAreaContractual  
END