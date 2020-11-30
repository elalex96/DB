-- =============================================
-- Author:		Manuel CD
-- Create date: 22-11-2017
-- Description:	
-- =============================================
CREATE PROCEDURE SP_EN_ActividadPetrolera 
	-- Add the parameters for the stored procedure here
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdClave,
                    Nombre
             FROM dbo.AP_Lista
             WHERE IdGrupo = 10006
		   ORDER BY IdClave ASC

         END

