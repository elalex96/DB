USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_ACEP_ConsultarUsuarioVentas'
)
    DROP PROCEDURE MM_ACEP_ConsultarUsuarioVentas;
/****** Object:  StoredProcedure [dbo].[MM_ACEP_ConsultarUsuarioVentas]    Script Date: 31/08/2023 05:40:59 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel AC
-- Create date: 01-09-2023
-- Description:	Se agrega columnas para poder enviar nombre del proveedor y clasificar correos 
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09-03-18
-- Description:	se agrega el idproveedor para que retorne la consulta
-- Create date: 30-07-18
-- Description:	se agrega que solo retorne los usuarios activos
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-09-2018>
-- Description:	<Se consulta si en el pedido se a solicitado o no la carta CN>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <07/07/2020>
-- Description:	<se quito el filtrado por contrato (los proveedores no estan ligados a un contrato)>
-- =============================================

CREATE PROCEDURE [dbo].[MM_ACEP_ConsultarUsuarioVentas]
    @IdAceptacionPedido INT,
    @IdPedido INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        U.Nombre,
        U.Correo,
        U.IdTipoUsuario,
        U.IdUsuario,
        PV.IdProveedor,
		U.IdTipoUsuario,
		ISNULL(U.Dominio,'') AS Dominio,
		PV.RazonSocial AS Proveedor,
		CASE WHEN UPPER(ISNULL(U.Dominio,'')) = 'ADINCO.MX' THEN 
			1
		ELSE 
			0
		END IsCorreoAdinco,
		RC.PedirCarta, 
		PC.RazonSocial AS Cliente
    FROM MM_AceptacionPedido AS AP (NOLOCK)
        JOIN MM_Pedido AS P (NOLOCK)
            ON AP.IdPedido = P.IdPedido  
		JOIN RelacionCartaCNPedido RC
			ON P.IdPedido = RC.IdPedido
			AND AP.IdAceptacionPedido = RC.IdAceptacionPedido
        JOIN S_Proveedor AS PV (NOLOCK)
            ON  P.IdSubcontratista = PV.IdProveedor
        JOIN S_UsuarioProveedor AS UP (NOLOCK)
            ON P.IdSubcontratista  = UP.IdProveedor
        JOIN S_Usuario AS U (NOLOCK)
            ON UP.IdUsuario = U.IdUsuario 
		JOIN S_Proveedor AS PC (NOLOCK)
            ON  P.IdProveedorCompras = PC.IdProveedor
    WHERE (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3) --> CTE USUARIO DE VENTA Y DE ADMISTRADOR
          AND U.Activo = 1
          AND AP.IdAceptacionPedido = @IdAceptacionPedido
          AND P.IdPedido = @IdPedido
	GROUP BY U.Nombre,
             U.Correo,
             U.IdTipoUsuario,
             U.IdUsuario,
             PV.IdProveedor,
			 PV.RazonSocial,
			 U.Dominio,
			 RC.PedirCarta,
			 PC.RazonSocial;
		  
END;

