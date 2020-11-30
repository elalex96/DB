-- =============================================
-- Author:		DANIEL AC	
-- Create date: 22/12/2017
-- Description:	Consulta unidades para alta express
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaUnidades_MV1_5] 

--@splitUnidades NVARCHAR(MAX)

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
		      
	  SELECT IdUnidad, Unidad FROM  PV_MM_MaterialUnidad WHERE IsActivo=1   ORDER BY Unidad ASC 

END
