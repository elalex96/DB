-- =============================================
-- Author:		Daniel Cruz
-- Create date: 09-03-17
-- Description:	SP consulta el detalle de una solicitud de oferta tomando como referencia un IDTarea
-- =============================================
CREATE PROCEDURE [dbo].[sp_MM_OfertaDetalle] 

@IdTarea INT

AS
BEGIN

SET NOCOUNT ON;

	   DECLARE @IdPeticionOferta int 
	   
	   SET @IdPeticionOferta = ( 
		
		SELECT PO.IdPeticionOferta FROM  MM_Oferta AS O
		INNER JOIN MM_PeticionOferta PO ON PO.IdPeticionOferta=O.IdPeticionOferta
		INNER JOIN MM_TareaOferta TAO on TAO.IdOferta=O.IdOferta
		INNER JOIN TaTarea T ON T.IdTarea = TAO.IdTarea
		WHERE T.IdTarea=@IdTarea)


		SELECT IdPeticionOfertaDetalle,NoMaterialesRequeridos,POD.IdMaterial,ComentariosComprador,DescripcionCorta,PrecioUnitario,POD.IdMoneda,Disponibilidad,Dias,ComentarioSubcontratista,Fecha 
		FROM MM_PeticionOfertaDetalle as POD
		INNER JOIN MM_Material AS MM on MM.IdMaterial = POD.IdMaterial
		WHERE IdPeticionOferta= @IdPeticionOferta

	
END

