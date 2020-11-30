-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-08-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_ENI_ClasificacionDocumento
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT Clasificacion, 
                Descripcion
         FROM ENI_ClasificacionDocumento;
     END;
