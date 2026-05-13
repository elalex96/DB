-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
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
		('Modificación del material: ('+CAST(POD.IdMaterial AS NVARCHAR(MAX))+'-'+ISNULL(M.TextoCorto,'') +') en:'+ ISNULL(HEC.Descripcion,''))		 
	 ELSE 
		HEC.Descripcion
	 END
	 AS Descripcion,
	 HEC.Fecha,  
	 U.Nombre
	 FROM MM_HistorialEdicionCotizacion AS HEC  (NOLOCK)
	 JOIN MM_EdicionCotizacion AS EC  (NOLOCK)
		ON HEC.IdEdicionCotizacion =EC.IdEdicionCotizacion 
	 JOIN dbo.MM_PeticionOferta AS PO  (NOLOCK)
		ON EC.IdPeticionOferta = PO.IdPeticionOferta  
		 AND EC.IdPeticionOferta=@IdPeticionOferta 
	 JOIN dbo.S_Usuario AS U  (NOLOCK)
		ON HEC.IdUsuario = U.IdUsuario 
	 LEFT JOIN MM_PeticionOfertaDetalle AS POD  (NOLOCK)
		ON PO.IdPeticionOferta  = POD.IdPeticionOferta
		AND HEC.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	 LEFT JOIN MM_Maestro AS M  (NOLOCK)
		ON POD.IdMaterial	 = M.IdMaestro 
	 WHERE PO.IdSubcontratista = @IdProveedor  
	 ORDER BY HEC.Fecha DESC
 
END

