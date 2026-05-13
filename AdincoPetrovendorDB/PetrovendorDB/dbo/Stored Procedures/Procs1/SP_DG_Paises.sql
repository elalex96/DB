-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22/01/2018
-- Description:	Consultar paises 
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_Paises] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT, 
@IdContrato INT, 
@FechaRegistro DATETIME

AS
   BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
          
		  
		SELECT [id], [pais] FROM [PV_PaisRepublica] ORDER BY [pais] 

		     
 END; 
