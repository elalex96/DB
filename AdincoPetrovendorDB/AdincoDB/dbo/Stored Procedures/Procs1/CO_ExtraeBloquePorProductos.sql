-- =============================================
-- Author:		Reyna O.
-- Create date: 13/02/18
-- Description:Extrae los bloques que tienen ese producto
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraeBloquePorProductos] 
	-- Add the parameters for the stored procedure here
	--@Producto int,
	@idAreaContractual int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		--Select idProductoNominacionBloque,NombreAreaContractual as nombreMostrar
		-- from CO_ProductoNominacionBloque PB
		--Join CO_AreaContractual B on PB.idAreaContractual= B.idAreaContractual
		--where ProductoNominacionID=@Producto
		
		Select NombreAreaContractual as nombreMostrar
		From CO_AreaContractual idAreaContractual
		where idAreaContractual=@idAreaContractual

END
