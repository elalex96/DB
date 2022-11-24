-- =============================================
-- Author:		DANIEL CRUZ
-- Create date: 18/12/2017
-- Description:	 Consutar los materiales de venta de un proveedor  
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarMaterialesVentaxProveedor_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, 
	@CotizacionRestringida BIT = NULL,
	@IdPeticionOferta INT = NULL,
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME = NULL 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   ---# Donde M.IdTipoProveedor=2 --> Proveedor_Procura

	--INSERT INTO #MATERIA

	IF ISNULL(@CotizacionRestringida,0) = 0
	BEGIN

	    SELECT 
			M.IdMaterial, 
			M.DescripcionCorta, 
			M.DescripcionLarga,  
			CONCAT(U.Unidad, 
			CASE WHEN U1.Unidad IS NOT NULL THEN ', '+ U1.Unidad END ,
			CASE WHEN U2.Unidad IS NOT NULL THEN ', '+ U2.Unidad END , 
			CASE WHEN U3.Unidad IS NOT NULL THEN ', '+  U3.Unidad END
			) AS UnidadesDisponibles
		FROM MM_Material AS M (NOLOCK)
			JOIN dbo.PV_MM_MaterialUnidad AS U (NOLOCK) ON U.IdUnidad = M.IdUnidad
			LEFT JOIN dbo.PV_MM_MaterialUnidad (NOLOCK) AS U1 ON U1.IdUnidad = M.IdUnidad_1
			LEFT JOIN dbo.PV_MM_MaterialUnidad (NOLOCK) AS U2 ON U2.IdUnidad = M.IdUnidad_2
			LEFT JOIN dbo.PV_MM_MaterialUnidad (NOLOCK) AS U3 ON U3.IdUnidad = M.IdUnidad_3
		WHERE M.IdProveedor = @IdProveedor 
			AND ISNULL(M.IsEliminado,0) = 0 
			AND M.Activo = 1 
			AND M.IdTipoProveedor=2;

	END
	ELSE
	BEGIN

		SELECT
			M.IdMaterial, 
			M.DescripcionCorta, 
			M.DescripcionLarga,  
			UN.Unidad AS UnidadesDisponibles
		FROM dbo.MM_PeticionOferta AS PO (NOLOCK)
			JOIN dbo.MM_SolicitudPedido AS SP  (NOLOCK)  
				ON PO.IdSolicitudPedido = SP.IdSolicitudPedido 
			JOIN dbo.MM_SolicitudPedidoDetalle AS SPD  (NOLOCK) 
				ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido 
			JOIN dbo.MM_Material AS M  (NOLOCK) 
				ON SPD.IdMaterial = M.IdMaterial 
			LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN  (NOLOCK) 
				ON SPD.IdUnidad = UN.IdUnidad
		WHERE PO.IdPeticionOferta = @IdPeticionOferta
		GROUP BY M.IdMaterial,
                 M.DescripcionCorta,
                 M.DescripcionLarga,
                 UN.Unidad;

	END
	


	


END


