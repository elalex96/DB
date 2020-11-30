-- =============================================
-- Author: Pedro Acuña
-- Create date: 28/08/2018
-- Description: obtener los centros de costos por solPed
-- =============================================

CREATE FUNCTION Fn_ObtenerProveedoresPorSolPed
	( @IdSolicitudPedido INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		DECLARE @tablaAux TABLE
			( IdProveedor INT ,
			  NombreProveedor NVARCHAR(MAX))

		INSERT INTO @tablaAux
			( IdProveedor )
		SELECT	IdSubcontratista
		FROM	dbo.MM_PeticionOferta 
		WHERE	IdSolicitudPedido = @IdSolicitudPedido

		--obtengo el nombre 
		UPDATE		t
		SET			t.NombreProveedor = s.RazonSocial
		FROM		@tablaAux t
		LEFT JOIN	dbo.S_Proveedor s
			ON s.IdProveedor = t.IdProveedor

		--y ahora si lo divido por comas los resultados
		SELECT	@retorno
			= STUFF (
				  (	  SELECT	CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), NombreProveedor )
					  FROM		@tablaAux
					  GROUP BY	NombreProveedor
					  FOR XML PATH ( '' )), 1, 1, '' )

		RETURN @retorno
	END