-- =============================================
-- Author:		DANIEL CRUZ
-- Create date: 20/12/2017
-- Description:	 Consultar la unidad del material a cotizar  
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/08/2019
-- Description:	 Agregado de cotizacion restringida 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUnidadesMaterial_MV1_5] 
	-- Add the parameters for the stored procedure here

	@IdMaterialVendedor INT,
	@CotizacionRestringida BIT = NULL,
	@IdPeticionOferta INT = NULL,
   /*--------------------
    parametros contrato 
   --------------------*/
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME
   /*--------------------
   --------------------*/
	
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
		FROM dbo.MM_PeticionOferta AS PO
			LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
			LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.MM_Material AS M ON M.IdMaterial = SPD.IdMaterial
			LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = SPD.IdUnidad
		WHERE PO.IdPeticionOferta = @IdPeticionOferta
			AND SPD.IdMaterial = @IdMaterialVendedor
		GROUP BY UN.IdUnidad,
                 UN.Unidad;
	END
	ELSE
	BEGIN
	    SELECT * FROM (

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M	
		INNER JOIN dbo.PV_MM_MaterialUnidad AS U ON U.IdUnidad = M.IdUnidad		
		where M.IdMaterial=@IdMaterialVendedor 
		   
		UNION 

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M	
		INNER JOIN dbo.PV_MM_MaterialUnidad AS U ON U.IdUnidad = M.IdUnidad_1		
		where M.IdMaterial=@IdMaterialVendedor

		UNION

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M	
		INNER JOIN dbo.PV_MM_MaterialUnidad AS U ON U.IdUnidad = M.IdUnidad_2		
		where M.IdMaterial=@IdMaterialVendedor

		UNION

		SELECT U.IdUnidad, U.Unidad
		FROM MM_Material AS M	
		INNER JOIN dbo.PV_MM_MaterialUnidad AS U ON U.IdUnidad = M.IdUnidad_3	
		where M.IdMaterial=@IdMaterialVendedor

	) Unidades 
	ORDER BY Unidades.Unidad
	END
	
END


