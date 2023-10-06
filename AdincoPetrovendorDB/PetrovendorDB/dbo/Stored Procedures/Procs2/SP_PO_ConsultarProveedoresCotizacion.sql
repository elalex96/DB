USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PO_ConsultarProveedoresCotizacion'
)
    DROP PROCEDURE SP_PO_ConsultarProveedoresCotizacion;

/****** Object:  StoredProcedure [dbo].[SP_PO_ConsultarProveedoresCotizacion]    Script Date: 20/09/2023 01:36:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 20-09-2023
-- Description:	Consultar usuarios de proveedores que tiene una cotización 
--				relaciona ala solicitud de pedido, validar si los usuarios son dominio Adinco
-- =============================================
CREATE PROCEDURE [dbo].[SP_PO_ConsultarProveedoresCotizacion]  
	-- Add the parameters for the stored procedure here
@IdSolicitudPedido INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

         SET NOCOUNT ON;
       
		SELECT P.IdProveedor, 
		CONCAT(ISNULL(p.RazonSocial,''), ' ', ISNULL(p.RegimenCapital,'')) AS Proveedor, 
		U.IdUsuario, 
		U.Nombre, 
		U.Correo, 
		PO.IdPeticionOferta,
		CASE WHEN UPPER(U.Dominio) = UPPER('adinco.mx') THEN 1 ELSE 0 END IsCorreoAdinco
		FROM S_Proveedor AS P (NOLOCK)
		JOIN dbo.S_UsuarioProveedor AS UP (NOLOCK)
		ON P.IdProveedor = UP.IdProveedor
		JOIN dbo.S_Usuario AS U (NOLOCK)
		ON UP.IdUsuario = U.IdUsuario
		JOIN dbo.MM_PeticionOferta AS PO (NOLOCK)
		ON P.IdProveedor = PO.IdSubcontratista
		JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
		ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE SP.IdSolicitudPedido = @IdSolicitudPedido 
		AND U.Activo= 1 --> CTE USUARIO ACTIVO
		AND (U.IdTipoUsuario= 3 OR U.IdTipoUsuario=4)  --> CTES USARIO DE VENTAS O ADMIN DE PETROVENDOR
		GROUP BY P.IdProveedor, 
		P.RazonSocial ,
		P.RegimenCapital,
		U.IdUsuario, 
		U.Nombre,
		U.Correo,
		PO.IdPeticionOferta,
		U.Dominio
		ORDER BY P.RazonSocial
					 
     END;
