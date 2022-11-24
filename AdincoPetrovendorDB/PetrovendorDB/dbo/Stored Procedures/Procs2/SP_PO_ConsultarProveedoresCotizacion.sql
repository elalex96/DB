-- =============================================
-- Author:		Daniel AC
-- Create date: 31-10-17
-- Description:	Consultar usuarios de proveedores que tiene una cotización 
--				relaciona ala solicitud de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_PO_ConsultarProveedoresCotizacion]  
	-- Add the parameters for the stored procedure here

@IdSolicitudPedido INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

         SET NOCOUNT ON;
       
		SELECT P.IdProveedor, p.RazonSocial +' '+ p.RegimenCapital AS Proveedor, u.IdUsuario, u.Nombre, u.Correo, po.IdPeticionOferta
		FROM S_Proveedor AS P
		INNER JOIN dbo.S_UsuarioProveedor AS up ON up.IdProveedor= p.IdProveedor
		INNER JOIN dbo.S_Usuario AS u ON u.IdUsuario= up.IdUsuario	
		INNER JOIN dbo.MM_PeticionOferta AS po ON po.IdSubcontratista= p.IdProveedor
		INNER JOIN dbo.MM_SolicitudPedido AS sp ON sp.IdSolicitudPedido = po.IdSolicitudPedido
		WHERE sp.IdSolicitudPedido = @IdSolicitudPedido AND u.Activo= 1 AND (U.IdTipoUsuario= 3 OR U.IdTipoUsuario=4) 
		GROUP BY p.IdProveedor, p.RazonSocial , p.RegimenCapital, u.IdUsuario, u.Nombre, u.Correo,po.IdPeticionOferta
		ORDER BY P.RazonSocial
					 
     END;


