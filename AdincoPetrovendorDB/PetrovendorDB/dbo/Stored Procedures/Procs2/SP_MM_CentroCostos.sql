-- =============================================
-- Author:		Daniel Cruz
-- Create date: 06-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_CentroCostos]
	-- Add the parameters for the stored procedure here
	@IdProveedor int 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here Descripcion
		 
		 CREATE TABLE #CentroCosto(IdCentroCosto int,CentroCosto nvarchar(300))

		 INSERT INTO #CentroCosto(IdCentroCosto,CentroCosto) values(0, '-- Seleccione un opción ---')

		 INSERT INTO #CentroCosto
         SELECT IdCentroCosto,
                CentroCosto
		FROM CC_CentroCosto AS CC
		WHERE CC.IdProveedor = @IdProveedor
		AND CC.IsActivo=1
		 
		ORDER BY CentroCosto ASC 

		 SELECT * FROM #CentroCosto

     END;
	  
