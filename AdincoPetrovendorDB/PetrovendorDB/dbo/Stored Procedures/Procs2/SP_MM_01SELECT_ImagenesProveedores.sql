-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Materiales que se quieren agregar al pedido de manera Temp 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_01SELECT_ImagenesProveedores]
    -- Add the parameters for the stored procedure here
    
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    SET NOCOUNT ON;
	     
		SELECT IdImagen,Imagen FROM  dbo.S_ImagenPerfil

END;


