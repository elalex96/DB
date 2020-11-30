-- =============================================
-- Author:		Alexander
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_ContarOfertas]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	COUNT(CASE O.IdEstatus WHEN 2 THEN 1 ELSE NULL END) AS OfertasAprobados,
	COUNT(CASE O.IdEstatus WHEN 1 THEN 1 ELSE NULL END) AS OfertasPendientes,
	COUNT(CASE O.IdEstatus WHEN 3 THEN 1 ELSE NULL END) AS OfertasRechazadas
	FROM MM_Oferta AS O
	WHERE  
	O.IdSubcontratista = @IdProveedor

END

