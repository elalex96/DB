-- =============================================
-- Author:		Reyna Olvera
-- Create date: 17/02/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraeProductos]
	-- Add the parameters for the stored procedure here
		@idAreaContractual int=0, 
		@idContrato int=0,
		@UsuarioId int =0

AS
BEGIN
	
	SET NOCOUNT ON;

	--Select C_PNB.ProductoNominacionID,nombre as nombreMostrar 
	--from [CO_ProductoNominacionBloque] C_PNB
	--JOIN  CO_ClasificacionProductoNominacion CPN on C_PNB.ProductoNominacionID=CPN.ProductoNominacionID
	--Where  idAreaContractual=10014

		Select ProductoNominacionID,nombre as nombreMostrar 
	from CO_ClasificacionProductoNominacion 
	
END
