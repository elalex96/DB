-- =============================================
-- Author:		DANIEL CRUZ
-- Create date: 20/12/2017
-- Description:	 Consultar la unidad del material a cotizar  
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/08/2019
-- Description:	 Agregado de cotizacion restringida 
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUnidadesMaterial_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdMaterialVendedor INT,
	@CotizacionRestringida BIT = NULL,
	@IdPeticionOferta INT = NULL,
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   ---# Donde M.IdTipoProveedor=2 --> Proveedor_Procura

	--INSERT INTO #MATERIA
	IF (@CotizacionRestringida = 1)
	BEGIN
	    SELECT
			UN.IdUnidad,  
			UN.Unidad
		FROM dbo.MM_PeticionOferta AS PO (NOLOCK)
			JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
				ON PO.IdSolicitudPedido= SP.IdSolicitudPedido
			JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK) 
				ON  SP.IdSolicitudPedido = SPD.IdSolicitudPedido			
			JOIN dbo.PV_MM_MaterialUnidad AS UN (NOLOCK) 
				ON SPD.IdUnidad = UN.IdUnidad 
		WHERE PO.IdPeticionOferta =@IdPeticionOferta
			AND SPD.IdMaterial = @IdMaterialVendedor
		GROUP BY UN.IdUnidad,
                 UN.Unidad;
	END
	ELSE
	BEGIN
	    SELECT * FROM (

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M (NOLOCK)	
		JOIN dbo.PV_MM_MaterialUnidad AS U (NOLOCK)	
		ON M.IdUnidad = U.IdUnidad 	
		where M.IdMaterial=@IdMaterialVendedor 
		   
		UNION 

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M (NOLOCK)	
		JOIN dbo.PV_MM_MaterialUnidad AS U (NOLOCK)	
		ON M.IdUnidad_1 = U.IdUnidad 		
		where M.IdMaterial=@IdMaterialVendedor

		UNION

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M (NOLOCK)	
		JOIN dbo.PV_MM_MaterialUnidad AS U (NOLOCK)	
		ON M.IdUnidad_2 = U.IdUnidad 		
		where M.IdMaterial=@IdMaterialVendedor

		UNION

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M (NOLOCK)	
		JOIN dbo.PV_MM_MaterialUnidad AS U (NOLOCK)	
		ON M.IdUnidad_3 = U.IdUnidad 
		where M.IdMaterial=@IdMaterialVendedor

	) Unidades 
	ORDER BY Unidades.Unidad
	END
	
END


