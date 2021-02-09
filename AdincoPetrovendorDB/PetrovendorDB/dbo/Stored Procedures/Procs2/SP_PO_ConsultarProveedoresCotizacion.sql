-- =============================================
-- Author:		Daniel AC
-- Create date: 31-10-17
-- Description:	Consultar usuarios de proveedores que tiene una cotización 
--				relaciona ala solicitud de pedido
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 03/02/2021
-- Description:	Optimización por issue 955
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
		INNER JOIN dbo.S_UsuarioProveedor AS up (NOLOCK)
			ON p.IdProveedor = up.IdProveedor
		INNER JOIN dbo.S_Usuario AS u (NOLOCK)
			ON up.IdUsuario	= u.IdUsuario
		INNER JOIN dbo.MM_PeticionOferta AS po (NOLOCK)
			ON p.IdProveedor = po.IdSubcontratista
		INNER JOIN dbo.MM_SolicitudPedido AS sp (NOLOCK)
			ON po.IdSolicitudPedido = sp.IdSolicitudPedido
		WHERE sp.IdSolicitudPedido = @IdSolicitudPedido AND u.Activo= 1 AND (U.IdTipoUsuario= 3 OR U.IdTipoUsuario=4) 
		GROUP BY p.IdProveedor, p.RazonSocial , p.RegimenCapital, u.IdUsuario, u.Nombre, u.Correo,po.IdPeticionOferta
		ORDER BY P.RazonSocial
					 
     END;