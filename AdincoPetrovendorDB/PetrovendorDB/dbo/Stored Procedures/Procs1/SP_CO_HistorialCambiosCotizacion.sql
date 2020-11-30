-- =============================================
-- Author:		Daniel AC
-- Create date: 08/08/2017
-- Description:	 Comente la actualización automatica de la petición de oferta 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_HistorialCambiosCotizacion] 
	-- Add the parameters for the stored procedure here
		
	@IdPeticionOferta INT,
	@IdProveedor INT 
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	 SELECT HEC.IdHistorial,
	 CASE WHEN  M.TextoCorto IS NOT NULL
	 THEN 		
		('Modificación del material: ('+CAST(POD.IdMaterial AS NVARCHAR(MAX))+'-'+M.TextoCorto +') en:'+ HEC.Descripcion)		 
	 ELSE 
		HEC.Descripcion
	 END
	 AS Descripcion,
	 HEC.Fecha,  
	 U.Nombre
	 FROM MM_HistorialEdicionCotizacion AS HEC
	 INNER JOIN MM_EdicionCotizacion AS EC ON EC.IdEdicionCotizacion = HEC.IdEdicionCotizacion
	 INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = EC.IdPeticionOferta
	 LEFT JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta=PO.IdPeticionOferta AND POD.IdPeticionOfertaDetalle=HEC.IdPeticionOfertaDetalle
	 LEFT JOIN MM_Maestro AS M ON M.IdMaestro = POD.IdMaterial
	 INNER JOIN dbo.S_Usuario AS U ON U.IdUsuario = HEC.IdUsuario
	 WHERE PO.IdSubcontratista = @IdProveedor  AND EC.IdPeticionOferta=@IdPeticionOferta 
	 ORDER BY HEC.Fecha DESC
 
END

