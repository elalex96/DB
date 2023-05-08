-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-09-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_ENI_ConsultaDestinoFolder
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT IdDestinoFolder, 
                Nombre, 
                Descripcion
         FROM dbo.ENI_DestinoFolder
		 WHERE Activo = 1
     END;
