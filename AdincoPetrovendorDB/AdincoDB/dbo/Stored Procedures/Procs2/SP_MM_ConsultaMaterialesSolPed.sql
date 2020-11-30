-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialesSolPed]
	-- Add the parameters for the stored procedure here
	
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdMaterial,
                DescripcionCorta,
                U.NombreUnidad,
                Marca,
                Presentacion,
                (CASE Inventariable
                     WHEN 0
                     THEN 'Si'
                     ELSE 'No'
                 END) AS Inventariable
         FROM MM_Material AS M
              INNER JOIN MM_Unidad AS U ON U.IdUnidad = M.IdUnidad;
     END;
