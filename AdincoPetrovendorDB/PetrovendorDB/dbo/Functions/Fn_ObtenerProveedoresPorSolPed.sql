USE Petrovendor
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Fn_ObtenerProveedoresPorSolPed'
)
    DROP FUNCTION Fn_ObtenerProveedoresPorSolPed;
/****** Object:  UserDefinedFunction [dbo].[Fn_ObtenerProveedoresPorSolPed]    Script Date: 22/09/2022 03:41:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 22/09/2022
-- Description: Obtener proveedores concatenados de una requisición
-- =============================================

CREATE FUNCTION [dbo].[Fn_ObtenerProveedoresPorSolPed]
	( @IdSolicitudPedido INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)
		DECLARE @tablaAux TABLE
			(NombreProveedor VARCHAR(MAX))

		INSERT INTO @tablaAux
			( NombreProveedor )
		SELECT	s.RazonSocial
		FROM	dbo.MM_PeticionOferta po (NOLOCK)
		JOIN	dbo.S_Proveedor s (NOLOCK)
			ON po.IdSubcontratista = s.IdProveedor
		WHERE	po.IdSolicitudPedido = @IdSolicitudPedido		
				
		SELECT	@retorno
			= STUFF (
				  (	  SELECT	CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), NombreProveedor )
					  FROM		@tablaAux
					  GROUP BY	NombreProveedor
					  FOR XML PATH ( '' )), 1, 1, '' )

		RETURN @retorno
	END