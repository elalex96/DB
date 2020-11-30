-- =============================================
-- Author:		DANIEL AC	
-- Create date: 27/03/2018
-- Description:	Consulta unidades 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaUnidades_PedimentoComprobante] 

	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME
  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		      
	  SELECT IdUnidad, Unidad,IsActivo FROM  Adinco.dbo.PV_MM_MaterialUnidad WHERE IsActivo=1   ORDER BY Unidad ASC 


END

